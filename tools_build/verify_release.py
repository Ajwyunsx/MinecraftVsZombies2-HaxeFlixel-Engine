"""标准构建 / 启动的端到端复验（工作包 F 新增）。

把工作包 F 的四项验证固化成一条命令，保证结论可复现：

  1. neko 目标类型检查（PORTING.md 的基线命令）
  2. cpp  目标类型检查（coverage 版：-neko 检查不到 `Null<Bool>`/`Null<Float>` 这类错误）
  3. `haxelib run lime build windows`（标准 Project.xml，不带任何覆盖层）
  4. 运行产物 MVZ2.exe，读进程工作目录下的 boot-trace.log

用法（在 HaxePort/ 下执行）
--------------------------
    python tools_build/verify_release.py                 # 全跑
    python tools_build/verify_release.py --skip-build    # 只跑类型检查 + 运行已有产物
    python tools_build/verify_release.py --only-build    # 只跑标准构建

每次运行的日志落在 %TEMP%/mvz2_verify_<时间戳>/ 下，stdout 只打印摘要。
"""

import argparse
import os
import shutil
import subprocess
import sys
import time

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(HERE)                      # HaxePort/
BIN = os.path.join(ROOT, "export", "windows", "bin")
EXE = os.path.join(BIN, "MVZ2.exe")
TRACE = os.path.join(BIN, "boot-trace.log")

LIB_ARGS = [
    "-lib", "flixel", "-lib", "flixel-addons", "-lib", "flixel-ui",
    "-lib", "lime", "-lib", "openfl",
    "-lib", "hscript", "-lib", "hxjsonast", "-lib", "json2object",
]

# PORT-NOTE: `include('tools', …)` 必须用第 4 个参数把 classpath 限制成工程自己的 source/。
# 否则 -lib hxcpp 把 hxcpp 包的 tools/ 也带进 classpath，其中的 tools/build/Build.hx、
# tools/hxcpp/BuildTool.hx 没有 package 声明（按路径写的老式模块），include 会报
# "Invalid commandline class : tools.build.Build should be Build" 而中断检查。
NEKO_CHECK = (
    ["haxe", "-cp", "source"] + LIB_ARGS +
    ["-main", "Main", "-neko", os.path.join(os.environ.get("TEMP", "."), "mvz2_check.n"), "--no-output",
     "-D", "lime_use_old_deltatime",
     "--macro", "flixel.system.macros.FlxDefines.run()",
     "--macro", "include('mvz2',true)", "--macro", "include('pvzengine',true)",
     "--macro", "include('mvz2logic',true)", "--macro", "include('unity',true)",
     "--macro", "include('system',true)", "--macro", "include('tools',true,null,['source'])"]
)

CPP_CHECK = (
    ["haxe", "-cp", "source", "-cp", "verify"] + LIB_ARGS + ["-lib", "hxcpp"] +
    ["-main", "Main", "-cpp", os.path.join(os.environ.get("TEMP", "."), "mvz2_cppcheck"), "--no-output",
     "-D", "lime_use_old_deltatime",
     "--macro", "flixel.system.macros.FlxDefines.run()",
     "--macro", "coverage.CoverageCheck.run()"]
)


def run(name, cmd, logdir, cwd=None, timeout=None, env=None):
    log = os.path.join(logdir, name + ".log")
    t0 = time.time()
    with open(log, "w", encoding="utf-8", errors="replace") as f:
        p = subprocess.run(cmd, cwd=cwd or ROOT, stdout=f, stderr=subprocess.STDOUT,
                           timeout=timeout, env=env)
    dt = time.time() - t0
    text = open(log, encoding="utf-8", errors="replace").read()
    print("[%s] exit=%d  用时=%.1fs  log=%s" % (name, p.returncode, dt, log))
    return p.returncode, text


def tail(text, n=25):
    lines = [l for l in text.splitlines() if l.strip()]
    return "\n".join(lines[-n:])


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--skip-typecheck", action="store_true")
    ap.add_argument("--skip-build", action="store_true")
    ap.add_argument("--only-build", action="store_true")
    ap.add_argument("--run-timeout", type=int, default=90)
    ap.add_argument("--cwd", default=BIN)
    args = ap.parse_args()

    logdir = os.path.join(os.environ.get("TEMP", "."), "mvz2_verify_" + time.strftime("%Y%m%d-%H%M%S"))
    os.makedirs(logdir, exist_ok=True)
    print("日志目录:", logdir)
    ok = True

    if not args.skip_typecheck and not args.only_build:
        rc, out = run("typecheck-neko", NEKO_CHECK, logdir)
        ok &= rc == 0
        rc, out = run("typecheck-cpp", CPP_CHECK, logdir)
        ok &= rc == 0

    if not args.skip_build:
        rc, out = run("lime-build-windows", ["haxelib", "run", "lime", "build", "windows"], logdir)
        ok &= rc == 0
        if rc != 0:
            print(tail(out, 40))

    if not args.only_build:
        if not os.path.exists(EXE):
            print("[run] 找不到产物:", EXE)
            return 1
        st = os.stat(EXE)
        print("[artifact] %s  size=%d bytes  mtime=%s" %
              (EXE, st.st_size, time.strftime("%Y-%m-%d %H:%M:%S", time.localtime(st.st_mtime))))
        if os.path.exists(TRACE):
            os.remove(TRACE)
        t0 = time.time()
        try:
            p = subprocess.run([EXE], cwd=args.cwd, timeout=args.run_timeout,
                               stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
            rc = p.returncode
        except subprocess.TimeoutExpired:
            rc = "timeout(进程仍在运行)"
        print("[run] exit=%s  存活=%.1fs" % (rc, time.time() - t0))
        path = os.path.join(args.cwd, "boot-trace.log")
        if os.path.exists(path):
            text = open(path, encoding="utf-8", errors="replace").read()
            shutil.copyfile(path, os.path.join(logdir, "boot-trace.log"))
            print("[boot-trace] 最后 15 行:\n" + tail(text, 15))
        else:
            print("[boot-trace] 未生成:", path)
            ok = False

    return 0 if ok else 1


if __name__ == "__main__":
    sys.exit(main())
