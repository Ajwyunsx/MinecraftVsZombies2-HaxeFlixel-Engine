"""生成"cpp 目标可编译/可启动"的临时覆盖层（工作包 ⑥ 启动链路接线新增）。

背景
----
类型检查命令用的是 `-neko` 目标，而实际发布目标是 hxcpp。`Null<Bool>`/`Null<Float>` 这类写法在
neko 上合法、在 cpp 上直接报错，所以"类型检查 0 错误"并不能保证 `lime build windows` 通过。

本脚本把上面这些"cpp 目标特有问题"的修补集中生成到 `verify_build` 使用的覆盖层目录里
（Haxe 的 -cp 里后出现的路径优先，所以覆盖层必须排在 source 之后）。
覆盖层只用于验证构建，**不修改仓库里的原文件**；正式修法应由对应工作包完成（见报告）。

变更记录
--------
工作包 C（hxcpp 启动期静态初始化崩溃）已在 source/ 里落地正式修法：
  * `mvz2logic/Global.hx` 增加启动期回退值 `BOOT_BUILTIN_NAMESPACE`，`BuiltinNamespace` 在
    `Game == null` 时回退到该常量；
  * 25 个文件里 118 个"静态初始化期读取运行期单例"的静态字段改为惰性 getter
    （见 tools_build/pkgc_lazy_statics.py）。
因此覆盖层里与之相关的三项补丁（`LAZY_FIELDS` / `LITERAL_NSP` / `HotKeys`）已删除，
覆盖层现在只保留**尚未由对应工作包修复**的 cpp 类型错误补丁。
每次运行都会先清空输出目录，避免上一轮写入的文件残留下来遮蔽 source/。

用法
----
    python tools_build/make_cpp_overlay.py [--out <目录>]

默认输出到 %TEMP%/mvz2_cppfix，与 tools_build/verify_build/Project.xml 中的路径一致。

剩余待其它工作包修复的条目
--------------------------
  * mvz2/io/XMLHelper.hx              —— GetAttributeBool 声明为 Bool 却返回 null（cpp 报错）
  * mvz2/debugs/DebugManager.hx       —— `Std.parseFloat(x) != null`（cpp 上 Float 不可空）
  * mvz2/level/LevelBlueprintChooseController.hx —— BlueprintChooseItem 构造实参错位
"""
import argparse
import os
import shutil
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(HERE)                      # HaxePort/
SOURCE = os.path.join(ROOT, "source")
NL = "\n"


def read(rel):
    with open(os.path.join(SOURCE, rel.replace("/", os.sep)), encoding="utf-8") as f:
        return f.read()


def write(out, rel, content):
    dst = os.path.join(out, rel.replace("/", os.sep))
    os.makedirs(os.path.dirname(dst), exist_ok=True)
    with open(dst, "w", encoding="utf-8", newline=NL) as f:
        f.write(content)
    print("  overlay:", rel)


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--out", default=os.path.join(os.environ.get("TEMP", "."), "mvz2_cppfix"))
    args = ap.parse_args()
    out = args.out
    if os.path.isdir(out):
        shutil.rmtree(out)
    print("输出到", out)

    # cpp 特有类型错误
    rel = "mvz2/io/XMLHelper.hx"
    s = read(rel)
    s = s.replace("public static function GetAttributeBool(node:XmlNode, name:String):Bool {",
                  "public static function GetAttributeBool(node:XmlNode, name:String):Null<Bool> {", 1)
    write(out, rel, s)

    rel = "mvz2/debugs/DebugManager.hx"
    s = read(rel)
    old = "\t\t\t\t\treturn Std.parseFloat(paramText) != null;"
    if old in s:
        s = s.replace(old, "\t\t\t\t\t// PORT-NOTE: [cpp 覆盖层] cpp 上 Std.parseFloat 返回 Float，不能与 null 比较。\n\t\t\t\t\treturn !Math.isNaN(Std.parseFloat(paramText));", 1)
        write(out, rel, s)

    rel = "mvz2/level/LevelBlueprintChooseController.hx"
    s = read(rel)
    old = "CreateChosenBlueprint(seedPackIndex, new BlueprintChooseItem(seedID, null, commandBlock));"
    if old in s:
        s = s.replace(old, "\t\t// PORT-NOTE: [cpp 覆盖层] C# 用命名实参 isCommandBlock:，移植时错位成了 null。\n\t\tCreateChosenBlueprint(seedPackIndex, new BlueprintChooseItem(seedID, commandBlock, false));", 1)
        write(out, rel, s)

    print("完成。")
    return 0


if __name__ == "__main__":
    sys.exit(main())
