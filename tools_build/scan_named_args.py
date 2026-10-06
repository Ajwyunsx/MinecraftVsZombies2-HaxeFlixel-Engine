#!/usr/bin/env python3
"""扫描 C# 命名实参（`name: value`）调用点在 Haxe 移植端是否被错位落槽。

背景（工作包 E）：C# 的命名实参在移植时被改写成位置实参，若槽位没对齐，
就会「编译通过但行为错误」。典型形态：
    C#:   new BlueprintChooseItem(id, innate: true)
    Haxe: new BlueprintChooseItem(id, true, false)      // true 落到了 isCommandBlock
    C#:   boss.PlaySound(soundID, volume: 0.5f)
    Haxe: boss.PlaySound(soundID, 0.5)                  // 0.5 落到了 pitch

算法：
  1. 解析 Assets/Scripts/**/*.cs：方法/构造声明（形参名、类型、默认值、是否扩展方法 this 首参）
     以及**全部**调用点（不只命名实参的，用于配对）。
  2. 解析 HaxePort/source/**/*.hx：function/构造声明与调用点。
  3. 对每个 Haxe 调用点，找同名 C# 调用点配对：
       候选 = 同一逻辑文件（C# 文件名去 `_XXX` 后缀后 == Haxe 文件名）里的同名调用
              ∪ 全部带命名实参的同名 C# 调用点
     用「配对质量」（非字面量匹配数、冲突数）选最佳，只有最佳配对才产出结论。
  4. 规则：
       MISPLACED  : 两侧「实际提供的实参值序列」完全一致，但绑定的形参槽位不同 —— 错位。
       VALUE-CONF : 同一形参两侧取值不同（至少一侧为字面量）—— 语义可能被改。
  5. 附加扫描（无需配对）：Haxe 侧 `new X(...)` 之类签名确定的调用点，字面量实参与声明形参类型冲突。

用法： python HaxePort/tools_build/scan_named_args.py [--json out.json]
环境变量 HX_ROOT 可覆盖 Haxe 源码根目录（用于对照旧版本自检）。
"""
import hashlib
import json
import os
import re
from collections import defaultdict

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
CS_ROOT = os.path.join(ROOT, "Assets", "Scripts")
HX_ROOT = os.environ.get("HX_ROOT") or os.path.join(ROOT, "HaxePort", "source")

KEYWORDS = {
    "if", "while", "for", "foreach", "switch", "catch", "using", "lock", "return",
    "new", "fixed", "else", "do", "get", "set", "nameof", "typeof", "sizeof",
    "default", "throw", "await", "yield", "checked", "unchecked", "where", "when",
    "stackalloc", "is", "as", "in", "out", "ref", "case", "this", "base", "delegate",
    "function", "var", "trace", "cast", "untyped", "macro", "super",
}

MODIFIERS = ("public|private|protected|internal|static|virtual|override|abstract|sealed|"
             "async|partial|readonly|extern|unsafe|new|const|inline|dynamic|final")


# --------------------------------------------------------------------------
# 词法辅助
# --------------------------------------------------------------------------

def strip_noncode(src, haxe=False):
    """把注释替换成空白、把字符串字面量压缩成无歧义的短记号。

    字符串内容需要参与比较（否则 `"a"` 与 `"b"` 都会变成空串而互相误配），
    但记号里不能出现逗号/括号等分隔符，故把内容映射成 `[A-Za-z0-9_]` 并做长度截断。
    """
    out = []
    i, n = 0, len(src)
    while i < n:
        c = src[i]
        if c == "/" and i + 1 < n and src[i + 1] == "/":
            while i < n and src[i] != "\n":
                out.append(" ")
                i += 1
        elif c == "/" and i + 1 < n and src[i + 1] == "*":
            out.append("  ")
            i += 2
            while i < n and not (src[i] == "*" and i + 1 < n and src[i + 1] == "/"):
                out.append("\n" if src[i] == "\n" else " ")
                i += 1
            if i < n:
                out.append("  ")
                i += 2
        elif c == '"':
            i += 1
            buf = []
            while i < n:
                if src[i] == "\\" and i + 1 < n:
                    buf.append(src[i + 1])
                    i += 2
                    continue
                if src[i] == '"':
                    i += 1
                    break
                buf.append(src[i])
                i += 1
            content = "".join(buf)
            safe = re.sub(r"[^A-Za-z0-9_]", "_", content)
            if len(safe) > 48:
                safe = safe[:40] + "_" + hashlib.md5(content.encode("utf-8")).hexdigest()[:6]
            out.append('"' + safe + '"')
        elif c == "'" and not haxe:
            i += 1
            while i < n:
                if src[i] == "\\" and i + 1 < n:
                    i += 2
                    continue
                if src[i] == "'":
                    i += 1
                    break
                i += 1
            out.append('"C"')
        else:
            out.append(c)
            i += 1
    return "".join(out)


def match_paren(src, open_idx):
    depth, i, n = 0, open_idx, len(src)
    while i < n:
        c = src[i]
        if c in "([{":
            depth += 1
        elif c in ")]}":
            depth -= 1
            if depth == 0:
                return i
        i += 1
    return -1


def split_top(text, sep=","):
    parts, depth, cur = [], 0, []
    for ch in text:
        if ch in "([{":
            depth += 1
            cur.append(ch)
        elif ch in ")]}":
            depth -= 1
            cur.append(ch)
        elif ch == sep and depth == 0:
            parts.append("".join(cur))
            cur = []
        else:
            cur.append(ch)
    parts.append("".join(cur))
    return parts


def norm(expr):
    e = re.sub(r"\s+", "", expr.strip())
    e = re.sub(r"^(this|base)\.", "", e)
    e = re.sub(r"!(?=[,)\]}]|$)", "", e)      # C# null-forgiving 后缀
    m = re.match(r"^(-?)(\d+(?:\.\d+)?)[fFdDmM]?$", e)
    if m:                                   # 0.5f == 0.5 == 0.50，1.0 == 1
        sign, num = m.group(1), m.group(2)
        if "." in num:
            num = num.rstrip("0").rstrip(".")
        return sign + (num or "0")
    return e


def is_literal(e):
    return bool(re.match(r'^(true|false|null|-?\d+(\.\d+)?[fFdDmM]?|".*")$', e.strip()))


def literal_kind(e):
    e = e.strip()
    if re.match(r"^(true|false)$", e):
        return "bool"
    if e == "null":
        return "null"
    if re.match(r'^".*"$', e):
        return "string"
    if re.match(r"^-?\d+(\.\d+)?$", e):
        return "number"
    return None


def receiver_of(src, pos):
    """取调用点前面的接收者（`a.b.Foo(` -> `a.b`）。"""
    before = src[max(0, pos - 60): pos]
    r = re.search(r"([A-Za-z_][\w\.\[\]()]*)\.$", before)
    return re.sub(r"\s+", "", r.group(1)) if r else None


def file_stem(path):
    return os.path.splitext(os.path.basename(path))[0]


# --------------------------------------------------------------------------
# C# 解析
# --------------------------------------------------------------------------

DECL_RE = re.compile(
    r"^(?P<indent>[ \t]*)"
    r"(?:(?:%s)[ \t]+)*"
    r"(?P<ret>[A-Za-z_][\w\.<>\[\],\?]*[ \t]+)?"
    r"(?P<name>[A-Za-z_]\w*)[ \t]*(?P<gen><[^<>]*>)?[ \t]*\(" % MODIFIERS,
    re.M,
)


def cs_param(p):
    p = p.strip()
    if not p:
        return None
    is_ext = bool(re.match(r"^this[ \t]+", p))
    p = re.sub(r"^(params|this|ref|out|in|scoped|readonly)[ \t]+", "", p)
    default = None
    if "=" in p:
        p, default = p.split("=", 1)
        default = default.strip()
    m = re.match(r"^(?P<type>.+?)[ \t]+(?P<name>[A-Za-z_]\w*)$", p.strip())
    if not m:
        return None
    return (m.group("name"), m.group("type").strip(), default, is_ext)


def parse_cs_file(path):
    with open(path, encoding="utf-8-sig", errors="replace") as fh:
        src = strip_noncode(fh.read())
    cls = None
    for m in re.finditer(r"\b(?:class|struct|record|interface)\s+([A-Za-z_]\w*)", src):
        cls = m.group(1)
        break

    decls = []
    for m in DECL_RE.finditer(src):
        name = m.group("name")
        if name in KEYWORDS:
            continue
        open_idx = m.end() - 1
        close_idx = match_paren(src, open_idx)
        if close_idx < 0:
            continue
        rest = re.sub(r"^\s*where[^{;=>]*", "", src[close_idx + 1: close_idx + 600])
        head = rest.lstrip()
        if head[:1] not in ("{", ";") and not head.startswith("=>"):
            continue
        if not (cls is not None and name == cls) and not m.group("ret"):
            continue
        plist, ok = [], True
        for item in split_top(src[open_idx + 1: close_idx]):
            if not item.strip():
                continue
            cp = cs_param(item)
            if cp is None:
                ok = False
                break
            plist.append(cp)
        if not ok or not plist:
            continue
        decls.append({
            "class": cls, "name": name, "params": plist,
            "file": os.path.relpath(path, ROOT).replace("\\", "/"),
            "line": src[: m.start()].count("\n") + 1,
        })

    calls = []
    for m in re.finditer(r"[A-Za-z_]\w*[ \t]*(?:<[^<>]*>)?[ \t]*\(", src):
        open_idx = m.end() - 1
        close_idx = match_paren(src, open_idx)
        if close_idx < 0:
            continue
        callee = re.match(r"([A-Za-z_]\w*)", m.group(0)).group(1)
        if callee in KEYWORDS:
            continue
        before = src[max(0, m.start() - 40): m.start()]
        if re.search(r"\b(?:class|struct|interface|record|enum)\s+$", before):
            continue
        args = split_top(src[open_idx + 1: close_idx])
        named = []
        for idx, a in enumerate(args):
            am = re.match(r"^[ \t]*([a-z_]\w*)[ \t]*:[^:=](.*)$", a, re.S)
            if am:
                named.append((idx, am.group(1), am.group(2)))
        calls.append({
            "callee": callee,
            "receiver": receiver_of(src, m.start()),
            "file": os.path.relpath(path, ROOT).replace("\\", "/"),
            "stem": file_stem(path),
            "line": src[: m.start()].count("\n") + 1,
            "args": [re.sub(r"\s+", " ", a).strip() for a in args],
            "named": named,
            "class": cls,
        })
    return decls, calls


# --------------------------------------------------------------------------
# Haxe 解析
# --------------------------------------------------------------------------

HX_FUNC_RE = re.compile(r"\bfunction[ \t]+([A-Za-z_]\w*)[ \t]*(?:<[^<>]*>)?[ \t]*\(", re.M)
HX_CALL_RE = re.compile(r"[A-Za-z_]\w*[ \t]*(?:<[^<>]*>)?[ \t]*\(")


def hx_param_list(text):
    plist = []
    for item in split_top(text):
        item = item.strip()
        if not item:
            continue
        item = re.sub(r"^[@?]", "", item)
        default = None
        if "=" in item:
            item, default = item.split("=", 1)
            default = default.strip()
        pm = re.match(r"^(?P<name>[A-Za-z_]\w*)[ \t]*:[ \t]*(?P<type>.+)$", item.strip())
        if not pm:
            return None
        plist.append((pm.group("name"), pm.group("type").strip(), default))
    return plist


def parse_hx_file(path):
    with open(path, encoding="utf-8-sig", errors="replace") as fh:
        src = strip_noncode(fh.read(), haxe=True)
    decls = []
    for m in HX_FUNC_RE.finditer(src):
        open_idx = m.end() - 1
        close_idx = match_paren(src, open_idx)
        if close_idx < 0:
            continue
        plist = hx_param_list(src[open_idx + 1: close_idx])
        if plist is None:
            continue
        decls.append({"name": m.group(1), "params": plist,
                      "file": os.path.relpath(path, ROOT).replace("\\", "/")})
    calls = []
    for m in HX_CALL_RE.finditer(src):
        callee = re.match(r"([A-Za-z_]\w*)", m.group(0)).group(1)
        if callee in KEYWORDS:
            continue
        before = src[max(0, m.start() - 30): m.start()]
        if re.search(r"\bfunction[ \t]+$", before):
            continue
        open_idx = m.end() - 1
        close_idx = match_paren(src, open_idx)
        if close_idx < 0:
            continue
        args = [re.sub(r"\s+", " ", a).strip() for a in split_top(src[open_idx + 1: close_idx])]
        if len(args) == 1 and args[0] == "":
            args = []
        calls.append({
            "callee": callee,
            "receiver": receiver_of(src, m.start()),
            "is_new": bool(re.search(r"\bnew[ \t]+$", before)),
            "file": os.path.relpath(path, ROOT).replace("\\", "/"),
            "stem": file_stem(path),
            "line": src[: m.start()].count("\n") + 1,
            "args": args,
        })
    return decls, calls


# --------------------------------------------------------------------------
# 配对与比较
# --------------------------------------------------------------------------

def offset_for(call, decl):
    """接收者是否占用了声明的第一个形参（C#/Haxe 扩展方法、`using` 静态调用）。"""
    recv = call.get("receiver")
    if not recv:
        return 0
    last = recv.split(".")[-1]
    if last[:1].isupper():                  # 形如 LogicEntityExt.Foo(...) 的静态调用
        return 0
    if call["callee"] == decl["name"] and decl["name"] == decl.get("class"):
        return 0
    # 参数个数差最多 1 时才认为是省略了接收者
    if len(decl["params"]) - len(call["args"]) in (1, 2):
        return 1
    return 0


FUNC_NAMES = set()


def evident_kind(arg):
    """从实参写法上能确定的种类，用于模拟 Haxe 的「跳过可选参数」行为。"""
    a = arg.strip()
    if a == "null":
        return "null"
    if a in ("true", "false"):
        return "bool"
    if re.match(r'^".*"$', a):
        return "string"
    if re.match(r"^-?\d+(\.\d+)?$", a):
        return "number"
    if re.match(r"^function\s*\(", a) or ("->" in a and "(" in a):
        return "function"
    if re.match(r"^[A-Za-z_]\w*$", a) and a in FUNC_NAMES:
        return "function"          # 裸标识符且确实是某个方法（方法引用）
    return None


def param_kind(ptype):
    t = ptype.strip()
    if t in ("Int", "Float", "Number"):
        return "number"
    if t == "Bool":
        return "bool"
    if t == "String":
        return "string"
    if "->" in t:
        return "function"
    return None


def kinds_compatible(a, b):
    if a is None or b is None or a == "null" or b == "null":
        return True
    return a == b


def side_map(params, args, named, off, allow_skip=False):
    """把一侧的实参绑定到形参名。

    allow_skip=True 时模拟 Haxe 的规则：实参类型与「带默认值的形参」明显不符时，
    编译器会跳过该形参继续往后匹配（形如 `f(a, b, fn)` 绑定到 `(x, y, z=0, ?w)`）。
    """
    named_idx = {n[0] for n in named}
    positional = [a for i, a in enumerate(args) if i not in named_idx]
    prov = []
    j = off
    for v in positional:
        if allow_skip:
            while (j < len(params) and params[j][2] is not None
                   and not kinds_compatible(evident_kind(v), param_kind(params[j][1]))):
                j += 1
        if j < len(params):
            prov.append((params[j][0], v))
            j += 1
    for _idx, pname, val in named:
        if any(p[0] == pname for p in params):
            prov.append((pname, val))
    order = {p[0]: k for k, p in enumerate(params)}
    prov.sort(key=lambda kv: order.get(kv[0], 1 << 30))
    resolved = dict(prov)
    for p in params:
        if p[0] not in resolved and p[2] is not None:
            resolved[p[0]] = p[2]
    return resolved, prov


def compare(cs_decl, cs_call, hx_decl, hx_call):
    """尝试 (C# 偏移, Haxe 偏移) 的几种组合，取配对质量最高的那一种。

    偏移表示「接收者占用了声明的第 0 个形参」——`using` 静态调用（Haxe）与
    扩展方法（C#）写作 `recv.Foo(a, b)` 时为 1，写成 `Ext.Foo(recv, a, b)` 时为 0。
    没有类型信息时用参数个数差只能猜，这里直接两种都试，取匹配最好的。
    """
    cs_base = offset_for(cs_call, cs_decl)
    hx_base = offset_for(hx_call, hx_decl)
    # 只有写成了 `recv.Foo(...)`（有接收者）才可能存在「接收者占用首参」的偏移，
    # 否则偏移 1 只是把两侧一起平移、反而会掩盖错位。
    cs_offsets = dict.fromkeys([cs_base] + ([1 - cs_base] if cs_call.get("receiver") else []))
    hx_offsets = dict.fromkeys([hx_base] + ([1 - hx_base] if hx_call.get("receiver") else []))
    best = None
    for cs_off in cs_offsets:
        for hx_off in hx_offsets:
            cand = compare_aligned(cs_decl, cs_call, hx_decl, hx_call, cs_off, hx_off)
            if os.environ.get("SCAN_DEBUG_ALIGN"):
                print("      ALIGN cs=%d hx=%d -> %s fs=%d"
                      % (cs_off, hx_off, cand[1], len(cand[0])))
            # 质量相同时优先默认偏移
            if best is None or cand[1] > best[1]:
                best = cand
    return best


def compare_aligned(cs_decl, cs_call, hx_decl, hx_call, cs_off, hx_off):
    cp, hp = cs_decl["params"], hx_decl["params"]
    cm, cprov = side_map(cp, cs_call["args"], cs_call["named"], cs_off)
    hm, hprov = side_map(hp, hx_call["args"], [], hx_off, allow_skip=True)

    cnames = [k for k, _ in cprov]
    hnames = [k for k, _ in hprov]
    cvals = [norm(v) for _, v in cprov]
    hvals = [norm(v) for _, v in hprov]
    shared = [n for n in cnames if n in hnames]
    matches = [n for n in shared if norm(cm[n]) == norm(hm[n])]
    meaningful = [n for n in matches if not (is_literal(cm[n]) and is_literal(hm[n]))]
    cidx = {p[0]: k for k, p in enumerate(cp)}
    hidx = {p[0]: k for k, p in enumerate(hp)}

    findings = []
    base = {
        "callee": cs_call["callee"],
        "cs": "%s:%d" % (cs_call["file"], cs_call["line"]),
        "cs_decl": "%s:%d" % (cs_decl["file"], cs_decl["line"]),
        "hx": "%s:%d" % (hx_call["file"], hx_call["line"]),
        "cs_args": cs_call["args"],
        "hx_args": hx_call["args"],
        "cs_params": [p[0] for p in cp],
        "hx_params": [p[0] for p in hp],
    }

    # 规则 A（最强）：两侧「实际提供的实参值」在前缀上逐个相同，但落在不同的形参槽位。
    # 允许一侧多提供若干尾部实参（例如 Haxe 把带默认值的形参也显式写出来）。
    nmin = min(len(cvals), len(hvals))
    if nmin >= 1 and cvals[:nmin] == hvals[:nmin]:
        for k in range(nmin):
            cn, hn = cnames[k], hnames[k]
            if cn == hn:
                continue
            i, j = cidx.get(cn), hidx.get(hn)
            if i is None or j is None or i == j:
                continue                    # 仅参数改名，槽位没变，不算错位
            f = dict(base)
            slot_type = hp[j][1] if j < len(hp) else "?"
            # Haxe 允许「跳过带默认值、且实参类型对不上的可选形参」，
            # 因此当目标槽是标量类型而实参不是字面量时，可能是被跳过的参数而非真的错位。
            rule = "MISPLACED"
            if slot_type.strip() in ("Int", "Float", "Bool", "String") and not is_literal(hvals[k]):
                rule = "SKIP-OR-MISPLACED"
            f.update({
                "rule": rule,
                "cs_param": cn,
                "cs_param_index": i,
                "hx_param": hn,
                "hx_param_index": j,
                "value": cvals[k],
                "hx_slot_type": slot_type,
                "cs_slot_type": cp[i][1] if i < len(cp) else "?",
            })
            findings.append(f)

    # 规则 B：同一形参槽位两侧取值不同（至少一侧是字面量，避免变量改名噪声）
    quality = (len(meaningful), -0, len(matches))
    if not findings:
        for p in cp:
            n = p[0]
            if n not in cm or n not in hm:
                continue
            cv, hv = norm(cm[n]), norm(hm[n])
            if cv == hv:
                continue
            if not (is_literal(cv) or is_literal(hv)):
                continue
            c_only = n in cnames and n not in hnames
            h_only = n in hnames and n not in cnames
            f = dict(base)
            f.update({
                "rule": "VALUE-CONF",
                "cs_param": n,
                "hx_param": n,
                "param_type": p[1],
                "cs_value": cm[n],
                "hx_value": hm[n],
                "cs_provided": n in cnames,
                "hx_provided": n in hnames,
                "detail": ("仅 C# 提供" if c_only else "仅 Haxe 提供" if h_only else "取值不同"),
            })
            findings.append(f)
    quality = (len(meaningful), -len(findings) if findings else 0, len(matches))
    if not meaningful:
        return [], (0, 0, 0)
    return findings, quality


def plausibility(d, call):
    """一个 C# 声明对某个调用点的「可信度」，用于排序与复核（越左越高）。"""
    named = {n for _, n, _ in call["named"]}
    pnames = {p[0] for p in d["params"]}
    recv = call.get("receiver")
    recv_last = recv.split(".")[-1] if recv else None
    instance_call = bool(recv) and not recv_last[:1].isupper()
    cls = d["class"] or ""
    class_from_receiver = 0
    if instance_call and recv_last:
        up = recv_last[0].upper() + recv_last[1:]
        if cls == up or cls.endswith(up):
            class_from_receiver = 1
    diff = len(d["params"]) - len(call["args"])
    return (class_from_receiver,
            1 if (instance_call and d["params"] and d["params"][0][3]) else 0,
            -abs(diff),
            1 if d["class"] == call["class"] else 0,
            len(pnames & named))


def resolve_cs_decl_candidates(decl_index, call, limit=8):
    """按可信度排序的 (plaus, decl)；第一个是主选，其余用于「换一种签名能否更好解释」的复核。"""
    named = {n for _, n, _ in call["named"]}
    scored = []
    for d in decl_index.get(call["callee"], []):
        if not named <= {p[0] for p in d["params"]}:
            continue
        scored.append((plausibility(d, call), d))
    scored.sort(key=lambda t: t[0], reverse=True)
    return scored[:limit]


def resolve_cs_decl(decl_index, call):
    cands = resolve_cs_decl_candidates(decl_index, call)
    return cands[0][1] if cands else None


def hx_decl_candidates(hx_ctors, hx_decls, callee, cs_decl):
    """优先取形参个数与 C# 声明一致（或差 1，扩展方法省略接收者）的同名声明。"""
    cands = list(hx_ctors.get(callee) or [])
    if not cands:
        cands = list(hx_decls.get(callee) or [])
    if not cands:
        return []
    n = len(cs_decl["params"])
    cs_names = {p[0] for p in cs_decl["params"]}
    def rank(d):
        m = len(d["params"])
        return (1 if n - m in (0, 1) else 0,
                len({p[0] for p in d["params"]} & cs_names))
    top = max(rank(d) for d in cands)
    return [d for d in cands if rank(d) == top]


# --------------------------------------------------------------------------
# 无配对的字面量检查（签名确定的构造调用）
# --------------------------------------------------------------------------

HX_VALUE_TYPES = {"Bool", "Int", "Float", "String"}


def hx_literal_check(hx_ctors, hx_calls):
    out = []
    for callee, calls in hx_calls.items():
        decls = hx_ctors.get(callee)
        if not decls:
            continue
        for hc in calls:
            if not hc["is_new"]:
                continue
            for hd in decls:
                hp = hd["params"]
                if len(hp) != len(hc["args"]):
                    continue
                for i, a in enumerate(hc["args"]):
                    kind = literal_kind(a)
                    ptype = hp[i][1].strip()
                    if kind is None:
                        continue
                    # 泛型形参（T/U/K/V 等）没有可用类型信息，跳过
                    if re.match(r"^[A-Z]$", ptype) or ptype.startswith("Null<"):
                        continue
                    rule = None
                    if kind == "null" and ptype in HX_VALUE_TYPES:
                        rule = "HX-NULL"
                    elif kind == "bool" and ptype not in ("Bool", "Dynamic", "Any"):
                        rule = "HX-BOOL"
                    elif kind == "number" and ptype not in ("Int", "Float", "Number", "Dynamic", "Any"):
                        rule = "HX-NUM"
                    if rule:
                        out.append({
                            "rule": rule, "callee": callee,
                            "param": "%s : %s" % (hp[i][0], ptype),
                            "hx": "%s:%d" % (hc["file"], hc["line"]),
                            "hx_args": hc["args"], "hx_decl": hd["file"],
                        })
                        break
                else:
                    continue
                break
    seen, uniq = set(), []
    for f in out:
        k = (f["rule"], f["callee"], f["hx"])
        if k in seen:
            continue
        seen.add(k)
        uniq.append(f)
    return uniq


# --------------------------------------------------------------------------

def main():
    decl_index = defaultdict(list)
    cs_calls = []
    for dirpath, _dn, filenames in os.walk(CS_ROOT):
        for fn in filenames:
            if not fn.endswith(".cs"):
                continue
            decls, calls = parse_cs_file(os.path.join(dirpath, fn))
            for d in decls:
                decl_index[d["name"]].append(d)
            cs_calls.extend(calls)

    hx_decls, hx_ctors, hx_calls = defaultdict(list), defaultdict(list), defaultdict(list)
    for dirpath, _dn, filenames in os.walk(HX_ROOT):
        for fn in filenames:
            if not fn.endswith(".hx"):
                continue
            path = os.path.join(dirpath, fn)
            decls, calls = parse_hx_file(path)
            for d in decls:
                hx_decls[d["name"]].append(d)
                if d["name"] == "new":
                    hx_ctors[file_stem(path)].append(d)
            for c in calls:
                hx_calls[c["callee"]].append(c)

    FUNC_NAMES.update(hx_decls.keys())
    FUNC_NAMES.update(hx_ctors.keys())

    # C# 调用索引：按 (stem, callee) 和 (callee, 有命名实参)
    # 分部类文件名（Seija_States.cs / LevelController_Transitions.cs）同时登记到去后缀的主名，
    # 以便和合并后的 Haxe 文件（Seija.hx / LevelController.hx）对上。
    cs_by_stem_callee = defaultdict(list)
    cs_named = defaultdict(list)
    for c in cs_calls:
        cs_by_stem_callee[(c["stem"], c["callee"])].append(c)
        head = c["stem"].split("_")[0]
        if head != c["stem"]:
            cs_by_stem_callee[(head, c["callee"])].append(c)
        c["_decls"] = resolve_cs_decl_candidates(decl_index, c)
        c["_decl"] = c["_decls"][0][1] if c["_decls"] else None
        c["_plaus"] = c["_decls"][0][0] if c["_decls"] else None
        if c["named"]:
            cs_named[c["callee"]].append(c)

    hx_decl_cache = {}

    def decls_for(callee, cs_decl):
        key = (callee, tuple(p[0] for p in cs_decl["params"]))
        if key not in hx_decl_cache:
            hx_decl_cache[key] = hx_decl_candidates(hx_ctors, hx_decls, callee, cs_decl)
        return hx_decl_cache[key]

    def related(hc, csc):
        """Haxe 调用点与 C# 调用点是否属于同一逻辑文件（含分部类）。"""
        a, b = hc["stem"], csc["stem"]
        return a == b or a == b.split("_")[0] or b == a.split("_")[0]

    debug_callee = os.environ.get("SCAN_DEBUG")

    # 第一轮：只在「C# 命名实参调用点」周围找 Haxe 对应点（快，且这是本工作包的靶心）。
    best_by_hx = {}
    review = []                     # 全部 117 个 C# 命名实参调用点的对照记录
    for csc in cs_calls:
        if not csc["named"]:
            continue
        if csc.get("_decl") is None:
            # 解析不出声明（重载/泛型签名太重名）的调用点也列出来，供人工核对
            review.append({
                "cs": "%s:%d" % (csc["file"], csc["line"]),
                "callee": csc["callee"],
                "cs_args": csc["args"],
                "confidence": "NO-DECL",
            })
            continue
        cs_decl = csc["_decl"]
        top = None                  # 该 C# 调用点最匹配的 Haxe 调用点
        debug = (debug_callee == csc["callee"])
        if debug:
            print("DBG csc %s:%d decl=%s:%d params=%s alts=%s"
                  % (csc["file"], csc["line"], cs_decl["file"], cs_decl["line"],
                     [p[0] for p in cs_decl["params"]],
                     [(a["file"].split("/")[-1] + ":" + str(a["line"]), len(a["params"])) for _p, a in csc.get("_decls", [])]))
        for hc in hx_calls.get(csc["callee"], []):
            if not related(hc, csc):
                continue
            best = None
            for hd in decls_for(csc["callee"], cs_decl):
                fs, quality = compare(cs_decl, csc, hd, hc)
                if debug:
                    print("   DBG hc %s:%d args=%s hd=%s params=%s -> %s"
                          % (hc["file"], hc["line"], hc["args"], hd["file"],
                             [p[0] for p in hd["params"]], quality))
                if quality[0] <= 0:
                    continue
                if best is None or quality > best[0]:
                    best = (quality, fs, hd)
            # 主选签名下出现了结论时，换用「同等可信」的其它候选 C# 签名复核一次：
            # 若另一种签名能更干净地解释同一个 Haxe 调用点，则说明主选签名只是错配。
            if best is not None and best[1]:
                for plaus, alt in csc.get("_decls", [])[1:]:
                    if plaus < csc["_plaus"]:
                        continue
                    for hd in decls_for(csc["callee"], alt):
                        fs, quality = compare(alt, csc, hd, hc)
                        if debug:
                            print("   DBG alt %s:%d hd=%s -> %s fs=%d"
                                  % (alt["file"], alt["line"], hd["file"], quality, len(fs)))
                        if quality[0] > 0 and quality > best[0]:
                            best = (quality, fs, hd)
            if best is None:
                continue
            if top is None or best[0] > top[0]:
                top = (best[0], best[1], best[2], hc)
            key = (hc["file"], hc["line"], tuple(hc["args"]))
            if key not in best_by_hx or best[0] > best_by_hx[key][0]:
                best_by_hx[key] = (best[0], best[1], csc, hc)
        review.append({
            "cs": "%s:%d" % (csc["file"], csc["line"]),
            "callee": csc["callee"],
            "cs_args": csc["args"],
            "cs_params": [p[0] for p in cs_decl["params"]],
            "cs_decl": "%s:%d" % (cs_decl["file"], cs_decl["line"]),
            "hx": ("%s:%d" % (top[3]["file"], top[3]["line"])) if top else None,
            "hx_args": top[3]["args"] if top else None,
            "hx_params": [p[0] for p in top[2]["params"]] if top else None,
            "confidence": ("MATCH" if top and not top[1] else "REVIEW") if top else "NO-HX-SITE",
        })

    # 第二轮：若同一逻辑文件里存在另一个「零冲突」的 C# 调用点能更好解释该 Haxe 调用点，
    # 说明第一轮只是错配（例如同一方法在同文件有多处调用），丢弃该结论。
    findings = []
    for key, (quality, fs, csc, hc) in best_by_hx.items():
        if not fs:
            continue
        stems = {hc["stem"], hc["stem"].split("_")[0]}
        rivals = []
        for st in stems:
            rivals.extend(cs_by_stem_callee.get((st, csc["callee"]), []))
        suppressed = False
        for r in rivals:
            if r is csc or r.get("_decl") is None:
                continue
            for hd in decls_for(csc["callee"], r["_decl"]):
                _rfs, rq = compare(r["_decl"], r, hd, hc)
                if rq[0] > 0 and rq > quality:
                    suppressed = True
                    break
            if suppressed:
                break
        if not suppressed:
            findings.extend(fs)
    seen, uniq = set(), []
    for f in findings:
        k = (f["rule"], f["callee"], f["cs"], f["hx"], tuple(f["hx_args"]))
        if k in seen:
            continue
        seen.add(k)
        uniq.append(f)
    uniq.sort(key=lambda f: (f["rule"], f["callee"], f["hx"]))

    lits = hx_literal_check(hx_ctors, hx_calls)

    print("C# 调用点总数: %d（其中带命名实参 %d）"
          % (len(cs_calls), sum(1 for c in cs_calls if c["named"])))
    print("== 配对可疑点: %d ==" % len(uniq))
    for f in uniq:
        print(json.dumps(f, ensure_ascii=False))
    print("== 构造调用字面量落槽可疑点: %d ==" % len(lits))
    for f in lits:
        print(json.dumps(f, ensure_ascii=False))
    print("== 命名实参调用点对照: 共 %d，其中 REVIEW=%d NO-HX-SITE=%d =="
          % (len(review),
             sum(1 for r in review if r["confidence"] == "REVIEW"),
             sum(1 for r in review if r["confidence"] == "NO-HX-SITE")))
    for r in review:
        if r["confidence"] != "MATCH":
            print(json.dumps(r, ensure_ascii=False))
    out = os.environ.get("SCAN_OUT")
    if out:
        with open(out, "w", encoding="utf-8") as fh:
            json.dump({"paired": uniq, "literal": lits, "review": review},
                      fh, ensure_ascii=False, indent=1)
        print("saved -> %s" % out)


if __name__ == "__main__":
    main()
