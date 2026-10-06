"""cpp 目标启动自检工具（工作包 ⑥ 启动链路接线新增）。

用途
----
hxcpp 会在进程启动时执行"全部静态初始化"（生成的 export/windows/obj/src/__boot__.cpp 里的
__boot_all()），任何在静态初始化里访问运行期单例（Global.Game / MainManager.Instance）的代码
都会在 main() 之前直接段错误（lime 的 Windows 程序是 GUI 子系统，stdout/stderr 全部丢弃，
所以看不到任何输出）。

本脚本给 __boot_all() 的每个 __boot() 调用前面插入一个序号写盘标记，重新做一次 hxcpp 原生构建
并运行程序；崩溃时最后一个写下的序号就是"出事的那个静态初始化"。

用法（在 HaxePort/ 下执行）
--------------------------
    python tools_build/cpp_boot_check.py            # 先用 lime 编译，再插桩、原生构建、运行并报错点
    python tools_build/cpp_boot_check.py --no-lime  # 跳过 lime 编译（只重做插桩 + 原生构建）

注意：lime 编译会重新生成 __boot__.cpp（覆盖插桩），所以每轮都要重新插桩。
"""
import argparse
import os
import re
import shutil
import subprocess
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
VERIFY = os.path.join(HERE, "verify_build")
OBJ = os.path.join(VERIFY, "export", "windows", "obj")
BOOT_CPP = os.path.join(OBJ, "src", "__boot__.cpp")
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


def run(cmd, cwd):
    print(">>", " ".join(cmd))
    p = subprocess.run(cmd, cwd=cwd, shell=(os.name == "nt"))
    return p.returncode


def instrument():
    s = open(BOOT_CPP, encoding="utf-8", errors="ignore").read()
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
    open(BOOT_CPP, "w", encoding="utf-8", newline=NL).write(head + tail)
    print("instrumented %d __boot() calls" % n)


def boot_order():
    s = open(BOOT_CPP, encoding="utf-8", errors="ignore").read()
    start = s.index("void __boot_all()")
    return re.findall(r"^::([A-Za-z0-9_:]+)::__boot\(\);$", s[start:], flags=re.M)


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--no-lime", action="store_true")
    ap.add_argument("--timeout", type=int, default=90)
    ap.add_argument("--cwd", default=None, help="运行 exe 时的工作目录（默认 verify 的 bin）")
    args = ap.parse_args()

    if not args.no_lime:
        if run(["haxelib", "run", "lime", "build", "windows"], VERIFY) != 0:
            print("lime build failed")
            return 1
    instrument()
    if run(["haxelib", "run", "hxcpp", "Build.xml"], OBJ) != 0:
        print("hxcpp build failed")
        return 1
    bin_exe = os.path.join(VERIFY, "export", "windows", "bin", "MVZ2.exe")
    shutil.copyfile(os.path.join(OBJ, "ApplicationMain.exe"), bin_exe)

    if os.path.exists(PROGRESS):
        os.remove(PROGRESS)
    cwd = args.cwd or os.path.dirname(bin_exe)
    print(">> run", bin_exe, "(cwd=%s)" % cwd)
    p = subprocess.run([bin_exe], cwd=cwd, timeout=args.timeout,
                       stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    print("exit code:", p.returncode)

    if not os.path.exists(PROGRESS):
        print("没有产生进度标记 → 崩溃发生在 main() 之前、__boot_all() 之外的环节")
        return 2
    idx = int(open(PROGRESS).read().split()[-1])
    order = boot_order()
    cls = order[idx - 1] if idx - 1 < len(order) else "?"
    print("最后完成的静态初始化序号: %d" % idx)
    print("崩溃点（第 %d 个 __boot()）: %s" % (idx, cls))
    return 0


if __name__ == "__main__":
    sys.exit(main())
