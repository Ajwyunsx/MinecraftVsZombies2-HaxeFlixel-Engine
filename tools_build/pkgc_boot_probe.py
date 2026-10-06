"""工作包 C 临时验证脚本：给指定构建目录的 __boot__.cpp 插桩，重链后运行，报出崩溃序号。

与 cpp_boot_check.py 的区别：本脚本接受任意构建目录（-d），不改动 tools_build/verify_build，
便于在 HaxePort/export/windows 这类"真实 source（不带覆盖层）"的构建上复现/验证静态初始化崩溃。

用法（在 HaxePort/ 下）：
    python tools_build/pkgc_boot_probe.py -d export/windows              # 插桩 + 重链 + 运行 + 报崩溃点
    python tools_build/pkgc_boot_probe.py -d export/windows --restore    # 撤销插桩 + 重链，恢复干净产物

注意 __boot__.cpp 是生成产物，下次 lime build 会重新生成（覆盖插桩）。
"""
import argparse
import os
import re
import shutil
import subprocess
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(HERE)
PROGRESS = os.path.join(os.environ.get("TEMP", "."), "mvz2_boot_progress.txt")
NL = "\n"

MARKER_FN = NL.join([
    "static void __BOOT_MARK(int i) {",
    "    static FILE* f = NULL;",
    '    if (!f) { f = fopen("%s", "w"); if (!f) return; }' % PROGRESS.replace("\\", "/"),
    '    fprintf(f, "%d ", i);',
    "    fflush(f);",
    "}",
    "",
])


def instrument(boot_cpp):
    s = open(boot_cpp, encoding="utf-8", errors="ignore").read()
    if "__BOOT_MARK" in s:
        print("already instrumented")
        return
    s = s.replace("void __files__boot();", MARKER_FN + "void __files__boot();", 1)
    start = s.index("void __boot_all()")
    head, tail = s[:start], s[start:]
    counter = [0]

    def repl(m):
        counter[0] += 1
        return "__BOOT_MARK(%d);%s%s" % (counter[0], NL, m.group(0))

    tail, n = re.subn(r"^::[A-Za-z0-9_:]+::__boot\(\);$", repl, tail, flags=re.M)
    open(boot_cpp, "w", encoding="utf-8", newline=NL).write(head + tail)
    print("instrumented %d __boot() calls" % n)


def boot_order(boot_cpp):
    s = open(boot_cpp, encoding="utf-8", errors="ignore").read()
    start = s.index("void __boot_all()")
    return re.findall(r"^::([A-Za-z0-9_:]+)::__boot\(\);$", s[start:], flags=re.M)


def restore(build):
    """撤销插桩（__boot__.cpp 是生成产物，下次 lime build 也会重新生成）。"""
    boot_cpp = os.path.join(build, "obj", "src", "__boot__.cpp")
    s = open(boot_cpp, encoding="utf-8", errors="ignore").read()
    if "__BOOT_MARK" not in s:
        print("未插桩，无需还原")
        return
    s = re.sub(r"__BOOT_MARK\(\d+\);\n", "", s)
    s = re.sub(r"\nstatic void __BOOT_MARK\(int i\) \{.*?\n\}\n", "", s, flags=re.S)
    open(boot_cpp, "w", encoding="utf-8", newline=NL).write(s)
    print("已还原", boot_cpp)


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("-d", "--dir", required=True, help="构建目录，例如 export/windows")
    ap.add_argument("--timeout", type=int, default=90)
    ap.add_argument("--skip-hxcpp", action="store_true")
    ap.add_argument("--restore", action="store_true")
    args = ap.parse_args()

    build = os.path.join(ROOT, args.dir.replace("/", os.sep))
    obj = os.path.join(build, "obj")
    boot_cpp = os.path.join(obj, "src", "__boot__.cpp")

    if args.restore:
        restore(build)
        p = subprocess.run(["haxelib", "run", "hxcpp", "Build.xml"], cwd=obj,
                           shell=(os.name == "nt"))
        if p.returncode != 0:
            print("hxcpp build failed")
            return 1
        shutil.copyfile(os.path.join(obj, "ApplicationMain.exe"),
                        os.path.join(build, "bin", "MVZ2.exe"))
        print("已重链并更新 bin/MVZ2.exe")
        return 0

    instrument(boot_cpp)

    if not args.skip_hxcpp:
        p = subprocess.run(["haxelib", "run", "hxcpp", "Build.xml"], cwd=obj,
                           shell=(os.name == "nt"))
        if p.returncode != 0:
            print("hxcpp build failed")
            return 1

    src_exe = os.path.join(obj, "ApplicationMain.exe")
    dst_exe = os.path.join(build, "bin", "MVZ2.exe")
    shutil.copyfile(src_exe, dst_exe)

    if os.path.exists(PROGRESS):
        os.remove(PROGRESS)
    print(">> run", dst_exe)
    try:
        p = subprocess.run([dst_exe], cwd=os.path.dirname(dst_exe), timeout=args.timeout,
                           stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
        print("exit code:", p.returncode)
    except subprocess.TimeoutExpired:
        print("运行未退出（超时）→ 没有在启动期崩溃")

    if not os.path.exists(PROGRESS):
        print("没有产生进度标记 → 崩溃发生在 main() 之前、__boot_all() 之外的环节")
        return 2
    idx = int(open(PROGRESS).read().split()[-1])
    order = boot_order(boot_cpp)
    cls = order[idx - 1] if idx - 1 < len(order) else "?"
    print("最后完成的静态初始化序号: %d / %d" % (idx, len(order)))
    print("崩溃点（第 %d 个 __boot()）: %s" % (idx, cls))
    return 0


if __name__ == "__main__":
    sys.exit(main())
