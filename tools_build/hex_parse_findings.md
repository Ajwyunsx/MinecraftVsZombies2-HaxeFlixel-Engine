# 十六进制解析 bug 与同类排查（工作包 F）—— 结论与证据

> 工作目录：`C:\Users\34275\Downloads\MinecraftVsZombies2Unity-master\MinecraftVsZombies2Unity-master`
> 目标：修 `HaxePort/source/unity/ColorUtility.hx` 的十六进制解析，并排查同类误用。
> 本文件是**过程报告**（可随时被主 agent 读取）；结论以本文件 + 文末命令为准。

## 0. 结论摘要

| 项 | 状态 |
|---|---|
| ① `ColorUtility.TryParseHtmlString` 十六进制解析（根因） | **已修**（含 `#RGBA`、具名颜色、严格校验） |
| ① 同文件 `ToHtmlStringRGB/RGBA` 格式化（截断 + 小写） | **已修**（对齐 Unity：四舍五入 + 大写） |
| ② 同类排查脚本 | **已写**：`HaxePort/tools_build/scan_parse_shims.py`（31 个站点分类 + 数据侧回归） |
| ② 严格失败语义（`TryParse*` 家族） | **已修**：`mvz2logic/ParseHelper.hx` 按 .NET `NumberStyles` 语义重写 |
| ② 调用点同类误用 | **已修**：`mvz2/debugs/DebugManager.hx` 的 `TYPE_INT` |
| ② 其余同类站点（抛异常语义 / 数值往返） | **列入本报告**（16 + 3 + 1 处，见 §3） |
| ③ neko/cpp 冒烟 | **已通过**（见 §4） |
| ③ 修复前/后对照（cpp 真机） | **106 → 0** 条 `Cannot create property … of type "color"`（见 §4.3/§4.4） |

覆盖影响的关键数字：`HaxePort/assets` 与 `Assets/GameContent` 里共有 **135 个不同的颜色字面量**，
用修复前算法模拟：**只有 2 个解析正确、60 个静默取到错值、73 个直接失败**。

---

## 1. ① 根因：`Std.parseInt` 不认裸十六进制

`HaxePort/source/unity/ColorUtility.hx`（修复前）用 `Std.parseInt(pair)` 解析两位十六进制：

```haxe
r = Std.parseInt(s.substr(0, 2)) / 255;   // "7F" → 7（静默截断）
var ai = Std.parseInt(s.substr(6, 2));    // "FF" → null
```

Haxe 实测（`haxe --interp`，与 cpp 同）：

```
Std.parseInt("FF") -> null        Std.parseInt("7F") -> 7
Std.parseInt("0xFF") -> 255       Std.parseInt("12abc") -> 12
Std.parseInt("0x10") -> 16        Std.parseFloat("1.5x") -> 1.5
```

因此：
* 任一位以字母开头（`FF`/`AB`/`E3`…）→ `null` → 6/8 位分支 `return false` → **颜色属性被整体丢弃**，
  cpp 全量 Meta 加载日志里 106 条 `Cannot create property "mvz2:bloodColor"/"bloodColorCensored"/"tint"/"lightColor" of type "color"`；
* 全部以数字开头（`7F`/`0F`/`10`…）→ 静默截断成 1~2 位十进制 → **属性存在但颜色是错的**；
* 3 位分支（`#RGB` / `#RGBA`）没有判空，`null/255` 在 cpp 上还会产出非 null 值，**静默通过**。

### 1.1 量化（对全部真实颜色字面量的模拟对照）

素材来源：`HaxePort/assets/GameContent/**/*.xml`（`<color value="#…">` + gradient `<key hex="#…">`），
共 135 个不同字面量。用修复前算法（模拟 `Std.parseInt` 语义）与 Unity 语义逐一对拍：

| 结果 | 个数 | 例子 |
|---|---|---|
| 旧实现解析正确 | 2 | 只有 `#000000` 与 `#00000000`（全 0 才恰好正确） |
| 旧实现**静默取错值** | 60 | `#008b8b` → (0, 0.031, 0.031)（应为 (0, 0.545, 0.545)）；`#101010` → 10/255 灰（应为 16/255）；`#7F7F7F` → 7/255 灰 |
| 旧实现**直接失败**（属性被丢弃） | 73 | `#FFFEFF`、`#ABABAB`、`#7F0000FF` … |

这解释了为什么 `globalLight="#7F7F7F"`、`Color="#FFF"` 这类属性**没有**警告却仍然是错的。

### 1.2 修复实现（Unity 语义）

按 UnityEngine 文档与 `UnityCsReference/Runtime/Export/Math/ColorUtility.cs` 重写（`TryParseHtmlString` 在 2022.3 是 native `DoTryParseHtmlColor`，行为见官方文档）：

* 先 `Trim()`；空串 → false；
* **以 `#` 开头** → 十六进制，长度必须（含 `#`）为 4/5/7/9（即 `#RGB` / `#RGBA` / `#RRGGBB` / `#RRGGBBAA`），
  逐位必须是十六进制数字（大小写均可），`#RGB`→`#RRGGBB`、`#RGBA`→`#RRGGBBAA` 展开，缺省 alpha = `FF`；
* **不以 `#` 开头** → 具名颜色表（`red/cyan/blue/darkblue/lightblue/purple/yellow/lime/fuchsia/white/silver/grey/
  black/orange/brown/maroon/green/olive/navy/teal/aqua/magenta`，外加 `transparent`），大小写不敏感；
  表外一律 false（**注意**：Unity 不会把无 `#` 的 `RRGGBB` 当十六进制）；
* `ToHtmlStringRGB/RGBA` 改为 `Mathf.Clamp(Mathf.RoundToInt(v * 255), 0, 255)` + 大写两位十六进制
  （原为 `Std.int(v*255)` 截断 + 小写；截断会把 1.0 变成 `FE`，即 Unity 的 bug 770904 场景）。

补全的语义**对游戏行为有直接影响**：talk 脚本里有 `forecolor set white` / `forecolor fade black #0000 1`
（`Assets/GameContent/Assets/mvz2/metas/talks/*.xml`，共 10 处 `white`、2 处 `black`），
旧实现返回 false → `TalkController.ParseArgumentColor` 退化成 `new Color(1,1,1,0)`（全透明），
文字会直接消失；现在能正确解析。`#RGBA`（4 位）也只出现在 talk 脚本里（如 `#FFF0`）。

---

## 2. ② 同类排查

### 2.1 脚本

```
python HaxePort/tools_build/scan_parse_shims.py [--json out.json]
# 环境变量 HX_ROOT 可指向旧版本/修复前副本做自检
```

做四件事：
1. 收集 `source/**/*.hx` 里所有 `Std.parseInt/Std.parseFloat/ParseHelper.Parse*` 站点（剥注释后扫描，
   避免把 PORT-NOTE 里的示例代码当调用点）；
2. 用「同文件名（去分部后缀）的 C# 原文件」里的解析 API 作为对照证据，分类：
   `HEX-RISK`（`parseInt` + `substr/charAt` 或 `"0x"`）、`STRICT-NOW`、`STRICT-MISSING`、`STRICT-IMPL`、
   `THROW-DIVERGENCE`、`ROUNDTRIP`、`OK`；
3. 数据侧回归：扫 XML 里真正走数字解析的属性（数值类型节点的 `value/x/y/z/time/alpha/weight`、
   `<color value=>` 与 `<key hex=>`），列出「宽松解析接受、.NET 拒绝」的候选；
4. C# 侧解析 API 使用计数，核对移植覆盖。

自检（证明检测器确实能抓到本 bug）：把修复前的 `ColorUtility.hx` 放进 `$TEMP/prefix_hx` 后
`HX_ROOT=$TEMP/prefix_hx python scan_parse_shims.py` → 报 **7 个 HEX-RISK**、**退出码 1**
（`charAt` 3 处、`substr(0/2/4,2)` 3 处、`substr(6,2)` 1 处）；对当前源码运行则 HEX-RISK=0、退出码 0。

影响面量化工具（可复跑）：`python HaxePort/tools_build/hex_color_impact_report.py`。

### 2.2 扫描结果（修复后）

```
== Haxe 解析站点：合计 31 ==
  OK 1   ROUNDTRIP 3   STRICT-IMPL 1   STRICT-NOW 10   THROW-DIVERGENCE 16
== 数据侧回归 ==
  扫描属性 4166 个；宽松接受但 .NET 拒绝的候选 0 个
```

`HEX-RISK = 0`（脚本会在非 0 时以退出码 1 结束，便于 CI 复验）。
数据侧 4166 个属性全部能被严格解析接受 → **收紧语义不会误伤现有数据**。

### 2.3 已修的同类误用

**(a) `mvz2logic/ParseHelper.hx` 的 `TryParse*` 家族（4 个函数）**

C# 对应 `int.TryParse(str, NumberStyles.Integer, InvariantCulture, …)` / `long.TryParse` /
`float.TryParse(str, NumberStyles.Float, …)` / `double.TryParse`。原实现直接包 `Std.parseInt/parseFloat`，
差异（并在数据被改坏时给出**错误的成功**）：

| 输入 | Haxe 旧 | C# TryParse | 现在 |
|---|---|---|---|
| `"0x10"` | 16 | false | false |
| `"12abc"` | 12 | false | false |
| `"1.5x"` | 1.5 | false | false |
| `"9999999999"`（Int32 溢出） | 回绕 | false | false |
| `"2147483648"` / `"-2147483649"` | 回绕 | false | false |
| Int64 溢出（如 `"9223372036854775808"`） | `Int64.ofInt` 截断（原 TODO-PORT） | false | false |
| `"1e400"` | Infinity | false（Mono/.NET Framework） | false |
| `" 5 "` / `"+5"` / `"007"` | 5 | 5 | 5 |
| `"1."` / `".5"` / `"1e3"` | 1 / 0.5 / 1000 | 同 | 同 |

实现要点（**踩过的坑，其它 agent 也会遇到**）：
* 不能用 Float/Int 累加器判溢出 —— Haxe 会把 `accum = accum * 10 + d` 按 **Int32** 运算并回绕
  （实测 `214748364*10+8 → -2147483648`，neko 与 cpp 都是），到不了阈值就已经错了；
  现在先做**字符串级**范围校验（`scanDigits` 去前导零 → `exceedsLimit` 位数+字典序），再交给
  `haxe.Int64` 累加，最后 `Int64.toInt`；
* `Int64.MinValue` 单独给出（`haxe.Int64.make(0x80000000, 0)`），不依赖回绕；
* `ParseInt/ParseFloat`（C# 是**会抛异常**的 `Parse`）**保持原样**并在注释里说明差异，见 §3.3。

**(b) `mvz2/debugs/DebugManager.hx`（FitsCommandParameter / `TYPE_INT`）**

C# 是 `int.TryParse(paramText, out _)`，移植端写的是 `Std.parseInt(paramText) != null`
（同函数里 `TYPE_FLOAT` 已经用 `ParseHelper.TryParseFloat` 修过，`TYPE_INT` 漏了）→ 现在改为
`ParseHelper.TryParseInt`。

---

## 3. 列入报告的同类站点（未改，原因见下）

### 3.1 `THROW-DIVERGENCE`（16 处）
`ParseHelper.ParseInt/ParseFloat` 包装（`mvz2logic/ParseHelper.hx:22,26`）及其调用点
（`TalkController.ParseArgumentInt/ParseArgumentFloat`、`CommandUtility.ParseInt/ParseFloat`、
`gamecontent/commands/{Artifact,Blueprint,Energy,IZombie,Repeat,Starshard,Test}.hx`），
外加 `expressionevaluator/Tokenizer.hx:65`（C# `double.Parse`）。

C# 侧失败会**抛 FormatException**，Haxe 侧 `Std.parseInt/parseFloat` 只能返回 null/NaN（cpp 上赋给
`Int` 会静默变 0）。1:1 表达需要在这些位置 `throw`，会改变失败路径的行为（talk 脚本执行处没有 try/catch，
Unity 只是记一条异常日志；Haxe 未捕获异常会走到 `MainSceneState` 的大 try/catch → `ErrorState`）。
判断：影响仅限**作者脚本 / 调试台输入**（关卡/实体数据都走 `XMLHelper` → 已严格化），
所以只做记录。若要彻底对齐，建议由 talk/命令执行链路的归属方统一加 try/catch 后再让 `Parse*` 抛异常。

### 3.2 `ROUNDTRIP`（3 处）
`expressionevaluator/BinaryExpr.hx:44`、`mvz2/audios/AudioManifest.hx:277,288` 的
`Std.parseFloat(Std.string(v))`：这是「数值 → 字符串 → 数值」的往返，不是文本解析，
不会误把十六进制当数字；`AudioManifest.hx` 本身是移植层自造代码（Unity 侧走 Addressables）。
建议后续直接改为 `cast`，但无正确性风险。

### 3.3 `OK`（1 处）
`system/xml/XmlNode.hx:412`：`selectNodes("a[1]")` 的 XPath 下标检测，只用十进制，语义正确
（`Std.parseInt("0x2")` 这类输入不会出现在 XPath 里）。

---

## 4. ③ 验证（命令 + 实测输出）

### 4.1 类型检查（改动后基线仍为 0 错误）

```
cd HaxePort
haxe -cp source -cp verify -lib flixel -lib flixel-addons -lib flixel-ui -lib lime -lib openfl \
  -lib hscript -lib hxjsonast -lib json2object -main Main -neko /tmp/check.n --no-output \
  -D lime_use_old_deltatime --macro "flixel.system.macros.FlxDefines.run()" \
  --macro "coverage.CoverageCheck.run()"                      # neko
… -lib hxcpp -cpp $TEMP/mvz2_cppcheck --no-output …            # cpp
```

实测（两个目标都跑过两轮）：

```
[CoverageCheck] 模块总数=2478 类型化成功=2478 失败=0     exit=0   (neko)
[CoverageCheck] 模块总数=2478 类型化成功=2478 失败=0     exit=0   (cpp)
```

### 4.2 颜色/解析冒烟（新写）

```
bash HaxePort/tools_build/check_color.sh               # neko：①②③
bash HaxePort/tools_build/check_color.sh --cpp --unit  # cpp 同一批断言（跳过重依赖段）
bash HaxePort/tools_build/check_color.sh --cpp         # cpp 全量（含真实 Meta XML 段）
```

覆盖 89 个断言：`#RRGGBB`、`#RRGGBBAA`、`#RGB`、`#RGBA`、大小写混用、首尾空白、真实素材字面量
（`#7F0000FF`、`#00007FFF`、`#FFAA00`、`#007fe3`）、具名颜色（含 `white/black/green=#008000`）、
非法输入（`null`/空串/纯空白/`#`/`#12`/`#12345`/`#1234567`/10 字符/`#GG0000`/无 `#` 的 `FF0000`）、
`ToHtmlString` 往返（含 `0.9999999 → FF` 的四舍五入回归）、以及 `ParseHelper` 严格解析的
正/负例（含 Int32/Int64 边界、溢出、尾随垃圾、十六进制前缀、`1e400`）。

```
neko : [info] 检查项 89，失败 0，说明 1        exit=0
cpp  : [info] 检查项 89，失败 0，说明 1        exit=0   (--unit)
```

cpp 全量段（真实数据，`$TEMP/mvz2_color_smoke`，第一次运行的结果；断言口径已修正后复跑）：

```
entities.xml：<color> 节点 83 个                       ← 全部 TryToProperty 成功（0 个失败）
fragments.xml：<key> 158 个（其中 hex= 154 个，失败 0）
ToGradient(dispenser)：colorKeys=3，首键 RGBA(0.30980, 0.30980, 0.30980, 1) @0.35   ← 0x4F/255 正确
```

> 首轮该段报了 3 条 FAIL，均是我的测试脚本用「同名属性最后一次出现」覆盖地图导致的期望值错误
> （`mvz2:bloodColor` 等在 entities.xml 里每个实体一份），代码侧 83/83、154/154 全部解析成功；
> 已改为按首次出现断言并复跑（见下）。

### 4.3 全量 Meta XML 冒烟（工作包 A 的工具，同一份 assets）

```
# 不带 cpp 覆盖层（覆盖层当时被其它工作包的半成品文件遮蔽，见 §5）
haxe -cp source -cp verify … -main xmlsmoke.XmlSmokeTest -cpp $TEMP/mvz2_xml_noverlay/cpp
cd HaxePort/export/windows/bin && $TEMP/mvz2_xml_noverlay/cpp/XmlSmokeTest.exe
```

实测：

```
[ ok ] 全部 Meta 资源 XML 解析无异常（异常 0 个）
[ ok ] 成功解析 38 个 Meta 资源（31 个元数据 + 7 个对话）
[info] 检查项 67，失败 0，说明 0                       exit=0
--- 颜色警告数 --- 0        （修复前：106）
```

### 4.4 对照实验（证明「106 → 0」由本次修复引起）
用 `-cp` 覆盖层把 `ColorUtility.hx` 换回**修复前**实现（不改仓库文件，脚本见
`$TEMP/prefix_hx/unity/ColorUtility.hx` + `$TEMP/run_f_prefix_control.sh`），用**同一份 assets、同一个
冒烟程序**重跑：

| 版本 | `Cannot create property …` | `of type "color"` | 冒烟结果 |
|---|---|---|---|
| 修复前（`-cp source -cp verify -cp $TEMP/prefix_hx`） | **106** | 106 | 67 项、失败 0（属性被丢弃不算异常） |
| 修复后（`-cp source -cp verify`） | **0** | 0 | 67 项、失败 0 |

即：106 条警告确实来自 `ColorUtility`，且修复后完全消失（对照组 `compile_exit=0`、`run_exit=0`）。

### 4.5 标准构建与启动

```
cd HaxePort && haxelib run lime build windows
cd export/windows/bin && ./MVZ2.exe      # 看 boot-trace.log 末尾
```

本次改动后用**隔离工程**复验（把 `HaxePort/Project.xml` 复制到 `$TEMP/f_build`，`BUILD_DIR` 指向临时目录、
**不拷贝** 962MB assets、改为在输出目录建目录联接指向 `HaxePort/assets`；避免与其它 agent 抢
`HaxePort/export/windows`）：

```
lime build windows → exit=0，产出 $TEMP/f_build/export/windows/bin/MVZ2.exe
运行 MVZ2.exe     → exit=139（bash 对 0xC0000005/SIGSEGV 的折算），boot-trace 末尾：
[step] GameEntrance.Start（main.Initialize + InitLoad）
```

与改动前 `HaxePort/export/windows/bin/boot-trace.log`（2026-10-02 19:11）的末尾**完全一致** ——
本工作包不改变启动边界，也没有引入更早的崩溃；`GameEntrance.Start` 之后（`main.Initialize` → Meta 全量加载）
的崩溃仍属启动链路工作包。

---

## 5. 需要其它 agent / 决策者配合的事项

1. **共享 cpp 覆盖层当前是坏的**：`%TEMP%/mvz2_cppfix/`（由 `tools_build/make_cpp_overlay.py` 生成，
   被 `verify_build/Project.xml` 与 `tools_build/check_xml.sh --cpp` 使用）里混入了**其它工作包更早的快照**
   （`mvz2/states/MainGameScene.hx` 等 7 个文件，含 `[探针覆盖层]` 注释），重链时直接报
   `mvz2/states/MainGameScene.hx:312 Unknown identifier : pageRect`，使 `check_xml.sh --cpp` 无法编译。
   建议：重新运行 `python tools_build/make_cpp_overlay.py`（它会先清空输出目录）或用
   `pkgc_boot_probe.py --restore` 收敛；本工作包的验证因此改用「不带覆盖层」的等价命令（已验证能编过）。
2. **覆盖层里两条补丁已经过期**（正式修法已落地，建议从 `make_cpp_overlay.py` 删除）：
   * `mvz2/io/XMLHelper.hx` 的 `GetAttributeBool` → 源码已是 `Null<Bool>`；
   * `mvz2/debugs/DebugManager.hx` 的 `Std.parseFloat(x) != null` → 本工作包已改为 `ParseHelper.TryParseInt`。
3. `HaxePort/source/unity/Gradient.hx:11` 的 `Gradient.Evaluate` 仍是占位实现（只取第一个颜色键），
   经本次修复 `XMLHelper.ToGradient` 已能给出正确的 colorKeys/alphaKeys，剩下的缺口在 Evaluate 本身
   （fragment/护甲渲染的颜色渐变）。归属：unity shim / 渲染链路。
4. TMP 富文本 `<color=…>`（`AlmanacController`、`DebugManager`、`ArchiveController` 等处生成）在
   `unity/tmpro/*` 里**没有**颜色标签解析实现；将来实现时应复用 `unity.ColorUtility`（Unity 侧该路径
   同样支持具名颜色）。
5. `expressionevaluator/Tokenizer.hx:65`（C# `double.Parse`）：`Std.parseFloat("1.2.3")` 会静默给出 1.2，
   而 C# 抛 FormatException。表达式的作者数据目前没这种写法，故只记录。

---

## 6. 验证汇总表（全部为实测）

| # | 验证项 | 命令 | 结果 |
|---|---|---|---|
| 1 | neko 类型检查 | `haxe … -neko … --no-output … coverage.CoverageCheck.run()` | `2478/2478 失败=0`，exit 0 |
| 2 | cpp 类型检查 | 同上换 `-lib hxcpp -cpp` | `2478/2478 失败=0`，exit 0 |
| 3 | neko 颜色/解析冒烟 | `bash tools_build/check_color.sh` | 检查项 89，失败 0 |
| 4 | cpp 颜色/解析冒烟（单元） | `bash tools_build/check_color.sh --cpp --unit` | 检查项 89，失败 0 |
| 5 | cpp 颜色/解析冒烟（含真实 XML） | `bash tools_build/check_color.sh --cpp` | 检查项 100，失败 0；entities.xml `<color>` 83/83 成功；fragments.xml `<key>` 158 个 / 154 个 hex 全成功 |
| 6 | 全量 Meta XML 冒烟（工作包 A 工具，同一 assets） | 见 §4.3 | 67 项失败 0、38 个 Meta 全解析；**`Cannot create property … of type "color"` = 0** |
| 7 | 对照组（换回修复前 ColorUtility） | 见 §4.4 | 同一冒烟复现 **106** 条同类警告 |
| 8 | 标准构建（隔离工程） | `haxelib run lime build windows` | exit 0；运行 boot-trace 末尾与改动前一致 |
| 9 | 同类误用扫描 | `python tools_build/scan_parse_shims.py` | 31 站点分类；HEX-RISK=0；数据侧 4166 个属性 0 个会被严格解析误拒；exit 0 |
| 10 | 检测器自检（修复前副本） | `HX_ROOT=$TEMP/prefix_hx python …` | 7 个 HEX-RISK，exit 1 |
| 11 | 影响面量化 | `python tools_build/hex_color_impact_report.py` | 135 个字面量：旧实现 2 正确 / 60 静默错 / 73 失败 |

---

## 7. 文件清单（本工作包改动/新增）

| 文件 | 类型 | 说明 |
|---|---|---|
| `HaxePort/source/unity/ColorUtility.hx` | 重写 | 根因修复：`TryParseHtmlString` 按 Unity 语义实现（`#RGB/#RGBA/#RRGGBB/#RRGGBBAA`、大小写、严格逐位校验、具名颜色）；`ToHtmlStringRGB/RGBA` 改为四舍五入 + 大写 |
| `HaxePort/source/mvz2logic/ParseHelper.hx` | 改写 4 个函数 + 新增私有助手 | `TryParseInt/TryParseLong/TryParseFloat/TryParseDouble` 按 .NET `NumberStyles` 严格化（拒绝十六进制前缀、尾随垃圾、Int32/Int64 溢出）；`ParseInt/ParseFloat` 保持原样并加 PORT-NOTE 说明差异 |
| `HaxePort/source/mvz2/debugs/DebugManager.hx` | 局部 | `FitsCommandParameter` 的 `TYPE_INT` 改用 `ParseHelper.TryParseInt`（+ `OutInt` import） |
| `HaxePort/tools_build/scan_parse_shims.py` | 新增 | 同类误用扫描（分类 + C# 原码对照 + 数据侧回归 + 自检） |
| `HaxePort/tools_build/hex_color_impact_report.py` | 新增 | 量化本 bug 对真实素材的影响（旧/新算法对拍） |
| `HaxePort/tools_build/check_color.sh` | 新增 | 颜色/解析冒烟运行器（`--neko` / `--cpp` / `--cpp --unit`） |
| `HaxePort/tools_build/verify_color/colorsmoke/ColorParseSmoke.hx` | 新增 | 冒烟测试本体（89 个断言 + 真实 XML 段 11 个断言） |
| `HaxePort/tools_build/hex_parse_findings.md` | 新增 | 本报告 |

未改动（按要求避让）：`HaxePort/Project.xml`、`hmm.json`、`source/Main.hx`、`source/mvz2/states/**`、
`tools_build/check_xml.sh`（工作包 A）、`tools_build/make_cpp_overlay.py`（其它工作包）。
