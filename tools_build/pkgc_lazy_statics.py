"""工作包 C：把启动期读取运行期单例的静态字段改为惰性 getter（临时/一次性转换脚本）。

背景
----
C# 的 `static readonly` 字段是"首次使用时初始化"，而 hxcpp 会在 main() 之前跑完 __boot_all() 里的
全部静态初始化。于是 `public static var componentID = new NamespaceID(Global.BuiltinNamespace, "x")`
在 hxcpp 上会在启动阶段读到 Global.Game（null）而段错误。

本脚本把下面这些文件里的静态字段改写为惰性 getter（缓存到 private 静态字段，等价于 C# 的
readonly static 只求值一次）：

    mvz2/level/components/{Advice,Area,Artifact,HeldItem,Light,Logic,Money,Music,Sound,Talk,UI}Component.hx
    mvz2/metas/ModelArmorConfigMeta.hx
    mvz2/options/HotKeys.hx
    mvz2logic/armors/LogicArmorSlots.hx
    mvz2logic/audios/{LogicMusicID,LogicSoundID}.hx
    mvz2logic/blueprints/{LogicBlueprintErrors,LogicBlueprintStyles}.hx
    mvz2logic/contents/buffs/FrameworksBuffID.hx
    mvz2logic/helditems/LogicHeldTypes.hx
    mvz2logic/level/LogicAreaTags.hx
    mvz2logic/options/{LogicOptionItemID,LogicOptionWidgetID}.hx
    mvz2logic/stats/LogicStats.hx
    mvz2logic/unlocks/LogicUnlockGroupID.hx

用法（在 HaxePort/ 下，可重复执行，已转换过会跳过）：
    python tools_build/pkgc_lazy_statics.py [--check]
"""
import argparse
import os
import re
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(HERE)
SOURCE = os.path.join(ROOT, "source")
NL = "\n"

FILES = [
    "mvz2/level/components/AdviceComponent.hx",
    "mvz2/level/components/AreaComponent.hx",
    "mvz2/level/components/ArtifactComponent.hx",
    "mvz2/level/components/HeldItemComponent.hx",
    "mvz2/level/components/LightComponent.hx",
    "mvz2/level/components/LogicComponent.hx",
    "mvz2/level/components/MoneyComponent.hx",
    "mvz2/level/components/MusicComponent.hx",
    "mvz2/level/components/SoundComponent.hx",
    "mvz2/level/components/TalkComponent.hx",
    "mvz2/level/components/UIComponent.hx",
    "mvz2/metas/ModelArmorConfigMeta.hx",
    "mvz2/options/HotKeys.hx",
    "mvz2logic/armors/LogicArmorSlots.hx",
    "mvz2logic/audios/LogicMusicID.hx",
    "mvz2logic/audios/LogicSoundID.hx",
    "mvz2logic/blueprints/LogicBlueprintErrors.hx",
    "mvz2logic/blueprints/LogicBlueprintStyles.hx",
    "mvz2logic/contents/buffs/FrameworksBuffID.hx",
    "mvz2logic/helditems/LogicHeldTypes.hx",
    "mvz2logic/level/LogicAreaTags.hx",
    "mvz2logic/options/LogicOptionItemID.hx",
    "mvz2logic/options/LogicOptionWidgetID.hx",
    "mvz2logic/stats/LogicStats.hx",
    "mvz2logic/unlocks/LogicUnlockGroupID.hx",
]

NOTE = "// PORT-NOTE: C# 的 static readonly 字段是首次使用时才初始化；hxcpp 会在 main() 之前执行全部静态初始化\n" \
       "// （__boot_all()），那时 Global.Game / MainManager.Instance 仍为 null，直接求值会段错误。\n" \
       "// 此处改为惰性 getter（结果缓存一次，等价于 C# 的 readonly static），还原 C# 语义。"

FIELD_RE = re.compile(r"^([ \t]*)public static var ([A-Za-z_]\w*):NamespaceID = (.+);$")


def convert(text):
    lines = text.split("\n")
    out = []
    changed = []
    noted = False
    i = 0
    while i < len(lines):
        line = lines[i]
        m = FIELD_RE.match(line)
        if m:
            indent, name, expr = m.group(1), m.group(2), m.group(3)
            back = "_" + name[0].lower() + name[1:]
            if not noted:
                out.append(indent + NOTE.split("\n")[0])
                out.append(indent + NOTE.split("\n")[1])
                out.append(indent + NOTE.split("\n")[2])
                noted = True
            out.append("%spublic static var %s(get, never):NamespaceID;" % (indent, name))
            out.append("%sprivate static var %s:NamespaceID;" % (indent, back))
            out.append("%sstatic function get_%s():NamespaceID" % (indent, name))
            out.append("%s{" % indent)
            out.append("%s\tif (%s == null) %s = %s;" % (indent, back, back, expr))
            out.append("%s\treturn %s;" % (indent, back))
            out.append("%s}" % indent)
            changed.append(name)
            i += 1
            continue
        # HotKeys.blueprintList：多行数组字面量，元素本身是上面已转换的惰性 getter。
        m2 = re.match(r"^([ \t]*)private static var blueprintList:Array<NamespaceID> = \[$", line)
        if m2:
            indent = m2.group(1)
            body = []
            j = i + 1
            while j < len(lines) and lines[j].strip() != "];":
                body.append(lines[j])
                j += 1
            out.append("%s// PORT-NOTE: 同上的启动期求值问题：数组元素是惰性的，数组本身也必须惰性。" % indent)
            out.append("%sprivate static var blueprintList(get, never):Array<NamespaceID>;" % indent)
            out.append("%sprivate static var _blueprintList:Array<NamespaceID>;" % indent)
            out.append("%sstatic function get_blueprintList():Array<NamespaceID>" % indent)
            out.append("%s{" % indent)
            out.append("%s\tif (_blueprintList == null)" % indent)
            out.append("%s\t\t_blueprintList = [" % indent)
            for b in body:
                out.append(b)
            out.append("%s\t\t];" % indent)
            out.append("%s\treturn _blueprintList;" % indent)
            out.append("%s}" % indent)
            changed.append("blueprintList")
            i = j + 1
            continue
        out.append(line)
        i += 1
    return "\n".join(out), changed


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--check", action="store_true", help="只报告，不写文件")
    args = ap.parse_args()
    total = 0
    for rel in FILES:
        path = os.path.join(SOURCE, rel.replace("/", os.sep))
        with open(path, encoding="utf-8") as f:
            text = f.read()
        if "get, never):NamespaceID;" in text:
            print("  [跳过] 已转换:", rel)
            continue
        new, changed = convert(text)
        if not changed:
            print("  [跳过] 没有匹配字段:", rel)
            continue
        total += len(changed)
        print("  %-58s %2d 个字段" % (rel, len(changed)))
        if not args.check:
            with open(path, "w", encoding="utf-8", newline=NL) as f:
                f.write(new)
    print("合计转换 %d 个静态字段" % total)
    return 0


if __name__ == "__main__":
    sys.exit(main())
