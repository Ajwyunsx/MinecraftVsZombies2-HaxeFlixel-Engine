# 工作包：实体行为注册 / 音轨注册 排查笔记

> 每推进一处就更新本文件，避免超时丢进度。
> 隔离验证工程：`HaxePort/tools_build/verify_registry/`（复制自 verify_startup 的 Project.xml，
> `bash setup.sh` 建 assets 目录联接，`bash run.sh [秒]` 跑 + 打印 boot-trace 末尾）。

## 0. 环境

- 工作目录：仓库根。源码 `HaxePort/source/`（2478 模块）。
- 参照实现：`Assets/Scripts/**`（C# 原逻辑）。

## 1. 问题①：`[WARN] Cannot find entity behaviour with ID mvz2:*`

### 1.1 症状
启动与 meta 加载阶段成百上千条 `Cannot find entity behaviour with ID mvz2:<name>`，
出现位置：`pvzengine/entities/EntityDefinition.hx` 的 `CacheContents()`
（对应 `Assets/Scripts/Engine/Level/Entities/EntityDefinition.cs:57`）。

### 1.2 根因链（已用源码逐一确认）

1. `mvz2/LandingSceneController.hx:31~32` 用 `Assembly.GetAssembly(VanillaMod)` /
   `GetAssembly(LogicMain)` 造两个"程序集"占位，交给 `ModLoader.Load(mod, assemblies)`。
   C# 对应 `Assets/Scripts/Loader/LandingSceneController.cs:29`：
   `Assembly.GetAssembly(typeof(VanillaMod))` = **MVZ2.Vanilla** 程序集（`Assets/Scripts/Vanilla/**`），
   `typeof(LogicMain).Assembly` = **MVZ2.Logic** 程序集（`Assets/Scripts/Logic/**`）。
2. `mvz2/modding/ModLoader.hx:135~142` 的 `AssemblyGetTypes()` 用
   `Reflect.field(assembly, "GetTypes")` 动态取方法；
   `source/system/reflection/Assembly.hx` **只有 name / GetAssembly / GetExecutingAssembly**，
   没有 `GetTypes` → `Reflect.field` 返回 null → **恒返回 `[]`**。
3. 于是 `ModLoader.LoadAssemblies`（`ModLoader.hx:166~198`）里：
   - `PropertyMapper.InitPropertyMaps(nsp, types)` 遍历空数组 → 从不注册任何 `PropertyMeta`；
   - 带 `@:autoXxxDefinition(...)` 元数据的 Definition 类**一个都不会被实例化并 `mod.AddDefinition`**；
   - `@:modGlobalCallbacks` 的全局回调类也不会被 `ApplyGlobalCallbacks`。
4. `Mod.PostReloadMods`（`mvz2logic/modding/Mod.hx`）对每个 definition 调 `CacheContents`；
   `EntityDefinition.CacheContents`（`pvzengine/entities/EntityDefinition.hx:75`）里
   `content.GetEntityBehaviourDefinition(behaviourID)` 查不到 → 打印告警。

**结论：不是 ID 常量/命名空间不一致，而是"注册表根本没被填充"**——
Haxe 侧把 C# 的运行期反射（`Assembly.GetTypes` + 特性）换成了编译期元数据
（`@:autoXxxDefinition` / `@:modGlobalCallbacks` / `@:propertyRegistryRegion`），
但没有任何地方把这些编译期元数据在运行期暴露出来，`Assembly` shim 也就答不出 `GetTypes`。

`Global.BuiltinNamespace` 的兜底常量 `mvz2`（`mvz2logic/Global.hx`）与此无关：
告警里的 `mvz2:` 前缀是对的（`NamespaceID.ToString()` 正常）。

### 1.3 元数据清单（编译期统计，供宏使用）

> **注（2026-10-05 17:5x）**：下表是早期（16:2x 前）的统计。`PopCaptain` 补标注后
> `@:autoEntityBehaviourDefinition` 的出现次数已从 368 增至 **371**（含注释中的举例文本），
> 注册表里实际的 `entity_behaviour` 定义数为 **370**。其余各项未变。

| 元数据 | 出现次数 | 来源目录 |
|---|---|---|
| `@:autoEntityBehaviourDefinition` | 368 | mvz2/gamecontent |
| `@:autoBuffDefinition` | 195 | mvz2/gamecontent |
| `@:autoStageDefinition` | 44 | mvz2/gamecontent |
| `@:autoIZombieLayoutDefinition` | 35 | mvz2/gamecontent |
| `@:randomChinaEventDefinition` | 29 | mvz2/gamecontent |
| `@:autoArtifactDefinition` | 27 | mvz2/gamecontent |
| `@:autoOptionWidgetDefinition` | 26 | mvz2/gamecontent |
| `@:autoCommandDefinition` | 20 | mvz2/gamecontent |
| `@:autoHeldItemBehaviourDefinition` | 19 | mvz2/gamecontent |
| `@:autoShellDefinition` | 15 | mvz2/gamecontent |
| `@:autoPlacementDefinition` | 14 | mvz2/gamecontent |
| `@:autoHeldItemDefinition` | 13 | mvz2/gamecontent |
| `@:autoAreaDefinition` | 9 | mvz2/gamecontent |
| `@:autoNoteDefinition` | 8 | mvz2/gamecontent |
| `@:autoSeedOptionDefinition` | 7 | mvz2/gamecontent |
| `@:autoGridDefinition` | 7 | mvz2/gamecontent |
| `@:autoArmorBehaviourDefinition` | 5 | mvz2/gamecontent |
| `@:autoRechargeDefinition` | 4 | mvz2/gamecontent |
| `@:autoMapElementBehaviourDefinition` | 3 | mvz2/gamecontent |
| `@:autoSpawnDefinition` | 2 | mvz2/gamecontent |
| `@:autoBuffDefinition` | 3 | mvz2logic/contents |
| `@:modGlobalCallbacks` | 17 + 2 | mvz2/gamecontent/globalcallbacks, mvz2logic/contents/globalcallbacks |

（`pvzengine/` 下命中的 3 个文件是注释/字符串，不是真实标注。）

### 1.4 修法（已实现）

**新增 3 个文件（都不对应 C# 源文件，是移植层的「程序集反射」替代实现）：**

| 文件 | 作用 |
|---|---|
| `HaxePort/source/system/reflection/DefinitionRegistryMacro.hx` | 编译期宏：扫描 `source/` 下全部 `.hx`，读真实元数据（`@:auto*Definition` / `@:modGlobalCallbacks` / `@:propertyRegistryRegion` / 字段级 `@:propertyRegistry` 等），生成运行期数据 |
| `HaxePort/source/system/reflection/DefinitionRegistry.hx` | 运行期注册表：`@:build` 注入数据，提供 `getClasses()` / `getClassesOfAssembly(name)` / `getRecordOfClass(cls)` |
| （改写）`HaxePort/source/system/reflection/Assembly.hx` | `GetTypes` / `IsAbstract` / `HasCustomAttribute` / `GetCustomAttributes` / `InvokeConstructor` 改为从注册表作答 |

**关键设计点：**

1. **权威来源是类型化后的元数据**，不是源文本：宏先用「剥掉注释的源码文本」筛出候选模块
   （929 个），再 `Context.getModule` 载入并逐个 `ClassType` 读真实元数据。
   源文本只用来做候选筛选与「简单类名 → 全路径」索引。
2. **元数据参数在类自己的作用域里求值**：先 `Context.typeExpr`（同文件常量可解析），
   失败再按「限定类.静态字段」取该静态字段的编译期字符串字面量
   （`VanillaEntityBehaviourNames.armorEntity` 这类跨文件引用）。工程内参数只有这两种形态。
3. **DCE**：宏为每个类发出**直接的类引用**（`macro $p{parts}`），因此这些类不会被 DCE 删掉。
   此前它们正是因为「没人引用」而被整批优化掉（实测 `export/windows/obj/src` 下
   `mvz2/gamecontent/entities/` 只有 `AIEntityBehaviour.cpp`，`ArmorEntityBehaviour` 根本不存在）。
4. **Haxe 的元数据名带冒号前缀**：`@:foo` 在 `ClassType.meta` 里存成 `:foo`（实测），
   宏里统一去掉前缀后比较。这是第一版扫描「候选 929 个、收录 0 个」的原因。
5. **程序集归属按包前缀判定**（对应 asmdef）：
   `mvz2logic.*`→MVZ2.Logic；`mvz2.gamecontent.*`/`mvz2.vanilla.*`→MVZ2.Vanilla；
   `mvz2.view.*`→MVZ2.View；`pvzengine.base*`→PVZEngine.Base；其它 `pvzengine.*`→PVZEngine.Level。
   与三个 `GetAssembly(typeof(X))` 调用点（VanillaMod / LogicMain / LevelEngine）一致。
6. **`IsAbstract`**：Haxe 无抽象类，工程按 PORTING.md 用类声明上方的 `// abstract` 注释标记（共 81 处），
   宏据此判定（`VanillaGlobalCallbacks`、`BlueprintHeldItemBehaviour` 等基类必须被跳过）。
7. **单函数体过大**：930 条记录塞进一个函数会让 neko 运行期报
   `Stack check failed for function scope`（实测），改为按 100 条一块切成 `__classes_N` 再 concat。

**验证：** 见 §4。

## 2. 问题②：`AudioMixer.SetFloat：Mixer「MusicVolume」没有暴露参数…`

### 2.1 症状（Oct 2 的 boot-trace，`tools_build/verify_startup/export/windows/bin/boot-trace.log`）
```
[step] [log] 音频清单已加载：audio_manifest.json（clips=526，mixer=Main）
[step] [log] 音频模板「mainTrackSource」指定的 mixer 总线「MainTrack」不存在（audio_manifest.json）。
[step] [log] 音频模板「subTrackSource」指定的 mixer 总线「SubTrack」不存在（audio_manifest.json）。
[step] [log] AudioMixer.SetFloat：Mixer「Main」没有暴露参数「MainWeight」，已按同名总线处理…
[step] [log] AudioMixer.SetFloat：Mixer「Main」没有暴露参数「SubWeight」，已按同名总线处理…
…（后面还有 MusicVolume / SoundVolume 两条）
```

### 2.2 实测结论：当前源码里这类告警已经是 0 条（问题②已由音频工作包修掉）

本工作包先跑了当前源码的 release 构建 + 运行（`tools_build/verify_registry/`，2026-10-05 14:30）：
```
=== MVZ2.exe 已退出，exit code=139（运行 45s）===
[step] [log] 音频清单已加载：audio_manifest.json（clips=526，mixer=Main）
（boot-trace 里 grep "AudioMixer|音频模板" 命中 0 条）
```
即 `MainTrack/SubTrack/MainWeight/SubWeight/MusicVolume/SoundVolume` 六条告警**全部消失**。
`new AudioMixer("MusicMixer")` 那类名字不匹配的告警在源码里也已不存在（全仓 `grep MusicMixer` 无命中）。

**根因（Oct 2 版本）与修法（已被音频工作包落地）**：
`unity/AudioMixer.hx` 的 `main` 是「首次访问即缓存」（`_main = new AudioMixer("Main")` → 构造函数里
`getGraph` 在 `graphs` 为空时新建一张**空图**并写进 `graphs`）。若 `AudioMixer.main` 在
`AudioManifest.ensureLoaded()`（即 `defineGraph`）之前被访问过，`_main.graph` 就永久指向空图，
之后 `defineGraph` 只是把 `graphs["Main"]` 覆盖成新图，`_main.graph` 不会更新。
`MainGameScene.hx:258/272` 现在改用 `AudioManifest.mainMixer`（先 `ensureLoaded()` 再取 `AudioMixer.main`），
顺序问题因此消失。**本工作包无需再改音频代码。**

### 2.3 独立复现（neko）
`AudioMixer.defineGraph` 本身是对的：单独喂 `audio_manifest.json` 的 mixers[0]，
得到 `groups=[Sound,SubTrack,Music,Master,Fade,MainTrack]`、`exposed=5` 条，`getGraph("Main")` 同一实例。

## 3. 待办
- [x] 跑当前源码的 release 构建 + 运行，拿新的 boot-trace（2026-10-05）。
- [x] 实现 1.4 的宏 + Assembly shim（由宏 agent 落地，见 §4）。
- [x] 修 2.2（无需改动：已由音频工作包修掉，实测 0 告警）。

---

## 4. 行为注册链路：宏 agent 的产出 + 本工作包补的两个缺陷（2026-10-05 16:2x）

### 4.1 现状（宏 agent 已落地的文件）

| 文件 | mtime | 作用 |
|---|---|---|
| `source/system/reflection/DefinitionRegistryMacro.hx` | 16:02 | 编译期扫描 `source/`，收集 `@:auto*Definition` / `@:modGlobalCallbacks` / `@:propertyRegistryRegion` / 字段级 `@:propertyRegistry`，按 100 条一块注入 `DefinitionRegistry.__classes_N()` |
| `source/system/reflection/DefinitionRegistry.hx` | 15:44 | 运行期注册表（`@:build` 注入数据），`getClasses` / `getClassesOfAssembly` / `getRecordOfClass` |
| `source/system/reflection/Assembly.hx` | 16:02（本包 16:2x 再改） | 「程序集视图」：`GetTypes` / `IsAbstract` / `HasCustomAttribute` / `GetCustomAttributes` / `InvokeConstructor` |

**注册表数据本身是对的**（用 `--interp` 直读 `DefinitionRegistry.getClasses()` 实测）：

```
records=932  totalDefs=849  callbacks=18  regions=43  propertyFields=42
byType=stage=44, spawn=2, shell=15, seed_option=7, recharge=4, placement=14, option_widget=26,
       note=8, mvz2:random_china_event=29, map_element_behaviour=3, i_zombie_layout=35,
       held_item_behaviour=19, held_item=13, grid=7, entity_behaviour=368, command=20,
       buff=195, artifact=27, armor_behaviour=5, area=8
```

`attr` 字段的运行期形态是**类引用**（`Std.isOfType(d.attr, Class) == true`，
`Type.getClassName(d.attr) == "pvzengine.definitions.AutoEntityBehaviourDefinitionAttribute"`），
不是字符串 —— 这一点是 §4.2 缺陷的根源。

### 4.2 缺陷 A（阻断级）：`Assembly.matchesAttributeName` 把类引用当字符串

`Assembly.hx` 旧签名是 `matchesAttributeName(attrPath:Null<String>, ...)`，
调用点写作 `matchesAttributeName(cast d.attr, ...)` —— `d.attr` 是 `Class<Dynamic>`，
`cast` 成 `String` 后**在任何真实目标上都会抛**：

```
Unexpected value VPrototype(Class<pvzengine.definitions.AutoEntityBehaviourDefinitionAttribute>), expected string
  Called from system/reflection/Assembly.hx:108   (simpleNameOf 内的 .split("."))
  Called from system/reflection/Assembly.hx:81    (GetCustomAttributes)
```

即 `Assembly.GetCustomAttributes(type, "DefinitionAttribute")` **恒抛异常**。
`ModLoader.LoadAssemblies`（`ModLoader.hx:184`）正好用这个方法枚举定义特性，
于是**一个定义都不会 `mod.AddDefinition`** → 所有 behaviour 缺失 →
`Cannot find entity behaviour with ID mvz2:*`。

**修法**（`source/system/reflection/Assembly.hx`）：

1. `matchesAttributeName` 形参改为 `attr:Dynamic`，新增 `simpleNameOf(attr)` 同时接受
   **类引用**（宏发出的形态，用 `Type.getClassName` 取简单名）与**字符串路径**（旧形态）。
2. 补上 C# 的**基类匹配**语义：`GetCustomAttributes<DefinitionAttribute>()` 传的是基类，
   `AttributeUsage(Inherited = false)` 不影响「基类是否命中派生特性」，因此
   `attributeName == "DefinitionAttribute"` 时无条件命中（注册表 `defs` 里每条本就是
   一个 `DefinitionAttribute` 派生实例）。

### 4.3 缺陷 B（曾存在，**已由宏 agent 于 17:08 修复**）：`IsAbstract` 恒为 false

> 本小节记录的是 **16:2x 时点**的状态；17:08 宏 agent 更新注册表后此缺陷已消失，
> 见本小节末段。保留原文是为了让「当时的判断」可追溯。

`DefinitionRegistry` 的 `isAbstract` 字段当时恒为 `false`（实测 932 条记录里 0 条为 true），
`Assembly.IsAbstract` 因此恒返回 false。宏里 `isAbstract()` 的判定是读 `ClassType.meta` 的
`abstract` / `:abstract`，再退回读源码里类声明上方的 `// abstract` 注释。

**但 `// abstract` 在工程里是「类声明上方的注释行」，不是 `@:abstract` 元数据**
（`grep -rn '^// abstract' source/` 共 81 处，如 `BossBehaviour.hx:6`），
所以第二条路径也没生效。宏里那段读文件的代码没有命中，原因未进一步定位
（可能是 `Context.getClassPath()` 与 `cls.module` 的相对路径拼接在 lime 构建下不成立）。

**影响评估（已用 C# 源码量化）**：`Assets/Scripts` 里带 `[AutoXxxDefinition]` /
`[RandomChinaEventDefinition]` / `[ModGlobalCallbacks]` 的类共 **868 个，其中 abstract 的 0 个**。
即**没有任何被注册的定义类/回调类是抽象类**，`IsAbstract` 恒 false 在当前工程里不会造成
「实例化抽象类」的错误。唯一被 `// abstract` 标记的 `DefinitionAttribute.hx`（抽象特性基类）
不带定义元数据，不进注册表。

**结论**：缺陷 B 属**语义正确性隐患**（将来新增抽象定义类会被错误实例化），
不在本包修复范围。

**❗ 2026-10-05 17:08 更新（宏 agent 已修）**：`DefinitionRegistry.hx` / `DefinitionRegistryMacro.hx`
被更新后，`isAbstract=true` 的记录从 **0 条变成 8 条**，`Assembly.IsAbstract` 已能正确作答。
本包复核确认（`--interp` 直读注册表）：
```
isAbstract count=8
```
即 §4.3 的缺陷 B **已由宏 agent 修复**，本包不再列为遗留项。
（`isAbstract` 修好也消除了「抽象基类被错误实例化」的隐患；
实测 `DefinitionRegistryMacro` 仍把 `d.attr` 以**类引用**形态发出，
与本包 §4.2 的 `simpleNameOf` 兼容。）

### 4.4 验证（修复缺陷 A 之后）

自检程序 `HaxePort/tools_build/verify_behaviour/BehaviourMain.hx`（复刻 `LoadAssemblies` 的调用形式）：

```
haxe -cp source -cp tools_build/verify_behaviour -lib flixel -lib flixel-addons -lib flixel-ui \
  -lib lime -lib openfl -lib hscript -lib hxjsonast -lib json2object \
  -main BehaviourMain --interp -D lime_use_old_deltatime \
  --macro "flixel.system.macros.FlxDefines.run()"
```

修复前后对比（同一条命令；「修复后」是 16:2x 时点，注册表随后被宏 agent 更新，最新数字见 §7）：

| 指标 | 修复前 | 修复后（16:2x） | 最新（17:5x） |
|---|---|---|---|
| `Assembly.GetCustomAttributes(type,"DefinitionAttribute")` | **抛异常**（`expected string`） | 正常返回 | 正常返回 |
| 有 DefinitionAttribute 的类型数 | — | 845 | 850 |
| 实例化成功的定义数 | **0** | **845** | **850** |
| 其中 `EntityBehaviourDefinition` | 0 | 368 | **370** |
| 单个 behaviour 探针 | — | `fadeout_by_timeout → FadeoutByTimeoutBehaviour` | probe lookup **5/5** |

### 4.5 与宏 agent 的接口约定（写入交接）
- **`Assembly` 的运行期契约（ModLoader 通过 `Reflect.field` 动态调用）**：
  `GetTypes():Array<Class<Dynamic>>`、`IsAbstract(type):Bool`、
  `HasCustomAttribute(type, attributeName:String):Bool`、
  `GetCustomAttributes(type, attributeName:String):Array<Dynamic>`（元素须有可读的 `Name` / `Type` 字段）、
  `InvokeConstructor(type, args:Array<Dynamic>):Dynamic`。
- **注册表记录的字段契约**：`cls`(类引用) / `name`(全路径) / `assembly`(C# 程序集名) /
  `isAbstract`(Bool) / `defs:[{name, attr, meta, type}]` / `callbacks`(Bool) / `region` /
  `fields:[{name, type, region}]`。
  **`attr` 必须是类引用（`Class<Dynamic>`），不是字符串路径**；本包已让 `Assembly` 两种都接受，
  但宏保持「类引用」形态（这也是它解决 DCE 的手段）。
- **程序集归属映射**（`Assembly.assemblyNameOfPath` 与 `DefinitionRegistryMacro.assemblyOf` 必须一致）：
  `mvz2logic.*`→MVZ2.Logic；`mvz2.gamecontent.*`/`mvz2.vanilla.*`→MVZ2.Vanilla；
  `mvz2.view.*`→MVZ2.View；`pvzengine.base*`→PVZEngine.Base；其它 `pvzengine.*`→PVZEngine.Level；
  其它→MVZ2。三个 `GetAssembly(typeof(X))` 调用点是 `VanillaMod` / `LogicMain` / `LevelEngine`。
- **`isAbstract`（原缺陷 B）已由宏 agent 于 17:08 修复**（实测 `isAbstract=true` 从 0 条 → 8 条，见 §4.3 末段）。
- **`attr` 契约**：宏发出的是**类引用**（`Class<Dynamic>`）；本包已让 `Assembly` 同时兼容
  「类引用」与「字符串路径」两种形态，宏无需改。



---

## 5. 端到端实测：修复前后的告警计数对比（2026-10-05 16:47 构建）

**命令**（隔离工程 `tools_build/verify_registry/`，无覆盖层，编译的就是 `source/`）：

```
cd HaxePort/tools_build/verify_registry
bash setup.sh                       # assets 目录联接（已存在则跳过）
haxelib run lime build windows      # exit 0，产物 30,008,832 B @ 16:47
bash run.sh 60                      # 运行 60s + 打印 boot-trace 末尾
```

`boot-trace.log`：**527,687 B / 8,176 行**（修复前 1,769,618 B / 27,013 行 —— 日志缩小 70%，
因为数万条告警消失）。

| 告警 | 修复前（14:31 基线） | 修复后（16:47） | 变化 |
|---|---|---|---|
| `Cannot find entity behaviour with ID mvz2:*` | **1986** | **311** | **-84.3%** |
| ├ 唯一 ID 数 | 数百个 | **2 个**（`entity_physics` / `pop_captain`，见 §5.2） | |
| `Trying to set a property with an invalid key!` | 16331 | **4942** | **-69.7%** |
| `Property with name ... is not registered.` | 8563 | **2797** | **-67.3%** |
| `Cannot find map element behaviour with ID mvz2:*` | 9 | **0** | **归零** |
| `AudioMixer.SetFloat` / 音频模板 / `MusicMixer` | 0 | **0** | 0（本工作包②） |
| `Duplicate property meta` | 0 | 1 | +1（见 §5.3，注册表真的开始工作了） |

**另外**：修复前 boot-trace 末行是「无法读取用户0的MODmvz2的存档…创建一个新存档」后立即段错误
（exit 139）；修复后启动**继续推进**到资源加载阶段：

```
[step] [log] 加载Music Clips花费的时间：0.0139999999999993
[step] [log] 加载Sound Clips花费的时间：0.024
[step] [log] 加载Sprites花费的时间：8.841
```

（仍然 exit 139，但卡点已从「存档降级路径」推进到「精灵加载之后的某个点」，
说明行为注册这条链路不再是阻断点。）

### 5.1 为什么没有归零（残余 4942 / 2797）—— **已由宏 agent 17:08 的更新归零**

`PropertyDictionary` 的无效键告警在 16:47 那轮仍有 4942 / 2797 条，说明**属性键注册仍有缺口**，
但已从「全 0」变成「大部分有值、少数缺失」——`-69.7%` 的下降正是 `PropertyMapper`
终于开始工作的直接证据（修复前 `PropertyMapper.InitTypePropertyMaps` 根本没被调用过）。

**❗ 2026-10-05 17:08 更新**：宏 agent 更新 `DefinitionRegistryMacro.hx` / `DefinitionRegistry.hx` 后，
这两类告警在 17:36 构建里**全部归零**（见 §7），**本包未改 `PropertyMapper` / `PropertyDictionary`**。
归因：宏 agent 把 `d.attr` 改为在**类自己的作用域**求值 + 修好 `isAbstract`，
使 `PropertyMapper` 的区域/定义特性解析完整起来。

下面 3 条是 16:47 时点的**候选原因**，保留备查（当时未验证，**现已不再表现为告警**）：

1. `PropertyMapper.foreachField` 用 `Type.getClassFields(type)`，只返回**类自身**的字段。
   C# 的 `type.GetFields(BindingFlags...)` 默认含继承链上的字段。
   若某些 `PropertyMeta` 静态字段声明在基类（如 `*Props` 基类）而子类才被注册，就会漏注册。
   文件:行 = `HaxePort/source/pvzengine/PropertyMapper.hx:214`（`foreachField`）。
2. `PropertyMapper` 的字段级区域查询依赖注册表记录的 `fields`（当前只有 42 条），
   而工程里 `@:entityPropertyRegistry` 19 + `@:levelPropertyRegistry` 20 + `@:propertyRegistry` 8 = 47 处。
   差的 5 处与 42 条的差异值得宏 agent 复核（`DefinitionRegistryMacro.describeClass` 只扫 `cls.statics`）。
3. `InitPropertyMaps` 只对 `AssemblyGetTypes` 返回的类型调用；该列表只含「带定义/回调/属性元数据的类」。
   C# 同样只传 `assembly.GetTypes()`（全量），**这一点移植层与 C# 不等价**：
   C# 传的是程序集里**所有**类型，移植层传的是**带元数据的子集**。
   没有区域元数据的 `PropertyMeta` 字段在 C# 里本来也会被跳过（`regionName == null` → return），
   所以理论上等价；但若有「只有字段级 `@:propertyRegistry` 而没有类级元数据」的类，
   宏会把它收进注册表（`fields.length > 0` 即收录），这点是等价的。
   **建议宏 agent 用 `PropertyMapper` 的告警里打印的具体属性名反查**（当前告警没带类型名）。
   **注**：17:08 的宏更新后告警已归零，本条仅为当时（16:47）的推测记录，**无需再处理**。

### 5.2 残余 2 个 behaviour ID

```
Cannot find entity behaviour with ID mvz2:entity_physics   (311 条里绝大多数)
Cannot find entity behaviour with ID mvz2:pop_captain
```

- `mvz2:pop_captain`：**真缺陷，本包已修**（见 §5.3）。
- `mvz2:entity_physics`：**本包先前误判为「C# 原版同样缺失」，特此更正 —— 该判断是错的。**
  `EntityPhysicsBehaviour` 虽然标的是 `[AutoBuffDefinition(VanillaEntityBehaviourNames.entityPhysics)]`
  （`Assets/Scripts/Vanilla/GameContent/Entities/EntityPhysicsBuff.cs:11`），
  但它 `extends EntityBehaviourDefinition`，而 `EntityBehaviourDefinition.GetDefinitionType()` 是
  **`sealed override => EngineDefinitionTypes.ENTITY_BEHAVIOUR`**
  （`Assets/Scripts/Engine/Level/Entities/EntityBehaviourDefinition.cs:54`），
  `DefinitionGroup.Add` 按 `GetDefinitionType()` 分桶（`Assets/Scripts/Engine/Base/Definitions/DefintionGroup.cs:19`），
  所以 **C# 里它落在 entity_behaviour 桶、`mvz2:entity_physics` 查得到**。
  移植层同样是 `class EntityPhysicsBehaviour extends EntityBehaviourDefinition`
  （`source/mvz2/gamecontent/entities/EntityPhysicsBuff.hx`），
  `GetDefinitionType()` 同样返回 `entity_behaviour`，因此**语义本就等价**。

  **结论**：`entity_physics` 在 16:47 构建里报警是**当时的属性/定义注册还不完整导致的连带现象**
  （该轮 `PropertyMapper` 尚未修好）；到 17:36（含宏 agent 17:08 的注册表更新）已**不再出现**，
  本包用 `BehaviourMain.hx` 直查 `mvz2:entity_physics` 也返回 `EntityPhysicsBehaviour`。
  本包未对该文件做任何修改 —— 它的标注与 C# 逐字一致，**不需要改**。

  **教训（供后续 agent）**：判断「是不是移植缺陷」时，**不能只看特性标注**，
  必须跟到 `GetDefinitionType()` / 分桶逻辑。`AutoXxxDefinition` 标注的 type 只是
  `DefinitionAttribute.Type`（C# 里 `ModLoader` 根本没用它分桶，只用 `attribute.Name` 取名字）。

### 5.3 本工作包修掉的第 3 个缺陷：`PopCaptain` 的 partial 合并丢标注

C# 是 `public partial class PopCaptain`，`[AutoEntityBehaviourDefinition(VanillaEnemyNames.popCaptain)]`
标在 `Assets/Scripts/Vanilla/GameContent/Enemies/Chapter5/PopCaptain.cs:16` 上
（另一半 `PopCaptain_States.cs` 没有标注）。移植层按 PORTING.md 把两个 partial 合并成
`source/mvz2/gamecontent/enemies/PopCaptain.hx` 时**漏掉了这个标注**，
于是 `mvz2:pop_captain` 这个 behaviour 从未注册
（`Assets/GameContent/Assets/mvz2/metas/entities.xml` 里被实体引用）。

**修法**：在 `PopCaptain.hx` 的类声明上方补
`@:autoEntityBehaviourDefinition(VanillaEnemyNames.popCaptain)`（`VanillaEnemyNames` 同包，无需 import）。

**同类风险扫描**（本包已做，结论：**标注种类只此 1 处缺失**）：

1. **特性种类**比对（`AutoBuffDefinition` ↔ `autoBuffDefinition` 归一化后比较）：
   `Assets/Scripts/**` 的 847 个带标注类 vs `source/**` 的对应类 ——
   **「种类不一致」0 处**，「C# 有、Haxe 完全没标注」1 处（`PopCaptain`，已修）。
2. **解析出的 ID 值**比对：脚本只做**文本**比对时会有 193 条假阳性，
   根源是 C# 的嵌套静态类 `VanillaBuffNames.Enemy.beingRiden` 在 Haxe 里按工程既有约定
   压平成 `VanillaBuffNames.Enemy_beingRiden`（`source/mvz2logic/contents/buffs/FrameworksBuffNames.hx:3~8`
   有 PORT-NOTE 说明）。**已实测两者的常量值相同**
   （`being_riden` / `riding_passenger` / `damage_color` 等，用 `--interp` 直读
   `DefinitionRegistry.getClasses()[].defs[].name` 验证）。
3. `DefinitionRegistryMacro.evalArg` 对「限定类.静态字段」的解析是**先 `Context.typeExpr`**，
   所以嵌套类压平**不影响**解析结果 —— 这是设计上就避免了这个坑。

**结论**：标注层面只丢了 `PopCaptain` 一处，已修；其余 ID 都能正确解析。

---

## 6. 问题②（音频 mixer）：实测已归零，本包另补 1 处漏接

### 6.1 告警本身：当前源码实测 0 条

`tools_build/verify_registry/export/windows/bin/boot-trace.log`（2026-10-05 16:47 构建、16:5x 运行）：

```
$ grep -c "AudioMixer\|音频模板\|MusicMixer" boot-trace.log
0
```

`Awake MusicManager` / `Awake SoundManager` 两条里程碑都在 trace 里（第 19/20 行），
说明 `MusicManager.Awake`（唯一调用 `mixer.SetFloat("MusicVolume"/"MainWeight"/"SubWeight")` 的地方）
**确实执行过且没有产生任何 mixer 告警**。全仓 `grep "MusicMixer"` 也是 0 命中。

修法（已由音频工作包落地，本包复核确认）：

- `mvz2/states/MainGameScene.hx:272` `music.mixer = AudioManifest.mainMixer;`
- `mvz2/states/MainGameScene.hx:286` `sound.mixer = AudioManifest.mainMixer;`
- `AudioManifest.get_mainMixer()` 先 `ensureLoaded()`（即 `AudioMixer.defineGraph("Main", …)`）
  再取 `AudioMixer.main`，避开了「先构造出空图并永久缓存」的时序陷阱。
- `AudioManifest` 从 `assets/audio_manifest.json` 读到的真实 mixer 名就是 `Main`
  （`mixers[0].name == "Main"`，`exposedParameters` = FadeVolume/MainWeight/MusicVolume/SoundVolume/SubWeight，
  与 `unity/AudioMixer.hx` 文件头注释里的总线树一致）。

### 6.2 本包补的漏接：`SoundManager.Awake` 没有应用音频模板

`AudioManifest.applyTemplate` 的文档（`AudioManifest.hx:223~226`）写明对应 **4 个**模板
（`soundTemplate` / `loopSoundTemplate` / `mainTrackSource` / `subTrackSource`），
但修复前只有 `MusicManager.Awake`（`MusicManager.hx:156~157`）调了 `mainTrackSource` / `subTrackSource`；
`SoundManager.Awake` **一个都没调**（`grep applyTemplate` 全仓只有 2 处）。

后果（不是告警，是静默失效）：`MainGameScene` 手工 new 出来的
`soundTemplate.audioSource` / `loopSoundTemplate.audioSource` 没有
`outputAudioMixerGroup`（清单里是 `mixerGroup: "Sound"`），
按 `unity/AudioSource.hx:385~386` 的语义就是「不过 Sound 总线」→
**设置里的音效音量滑条对音效不生效**（音乐轨因为 MusicManager 调过模板，是生效的）。

**修法**（`source/mvz2/audios/SoundManager.hx` 的 `Awake`）：按 `MusicManager.Awake` 的同样写法补
`AudioManifest.applyTemplate(soundTemplate.AudioSource, "soundTemplate")` 与
`AudioManifest.applyTemplate(loopSoundTemplate.AudioSource, "loopSoundTemplate")`，
并加 `mixer == null` 兜底（同 `MusicManager`，避免 `SetGlobalVolume` 空引用）。
prefab→场景转换落地后这些值与清单相同，重复设置无副作用。

### 6.3 剩余风险（不在本包范围）

`MainGameScene` 手工构造对象图这件事本身与工作包②的 `ScenePrefabInjector` 职责重叠
（见 `boot_findings.md` §六.6）。本包补的 `applyTemplate` 是「清单兜底」，
场景 prefab 正式接入后应由 prefab 的序列化值提供，届时这两处调用可删。

---

## 7. 最终实测（2026-10-05 17:36 构建，含本包 3 处修复 + 宏 agent 17:08 的注册表更新）

**构建**（隔离工程，编译的就是 `source/`）：

```
cd HaxePort/tools_build/verify_registry && haxelib run lime build windows
# exit 0，产物 export/windows/bin/MVZ2.exe 30,061,056 B @ 17:36
```

**运行**：`bash run.sh 90`（`boot-trace.log` 5,833 B / 129 行；17:41 复跑 75s 同样 0 告警）。

| 告警 | 14:31 基线（修复前） | 16:47（本包修缺陷 A + PopCaptain） | **17:36（最终）** |
|---|---|---|---|
| `Cannot find entity behaviour with ID mvz2:*` | 1986 | 311 | **0** |
| `Trying to set a property with an invalid key!` | 16331 | 4942 | **0** |
| `Property with name ... is not registered.` | 8563 | 2797 | **0** |
| `Cannot find map element behaviour with ID mvz2:*` | 9 | 0 | **0** |
| `AudioMixer` / 音频模板 / `MusicMixer` | 0 | 0 | **0** |
| `Duplicate property meta` | 0 | 1 | **0** |

`boot-trace.log` 从 **1,769,618 B / 27,013 行** 降到 **5,833 B / 129 行**（-99.7%）。

### 7.1 计数归零的三段归因（诚实拆分）

1. **本包缺陷 A 修复（16:2x）**：`Assembly.GetCustomAttributes(type, "DefinitionAttribute")`
   从「恒抛异常」变成正常返回 → 定义注册从 **0 条**变成 **845 条**（其中 368 behaviour）。
   这是「1986 → 311」的**直接原因**，用 `tools_build/verify_behaviour/BehaviourMain.hx`
   在 `--interp` 下可独立复现（不需要完整构建）。
2. **本包 `PopCaptain` 修复（16:52）**：注册的 behaviour 368 → 369，消掉 `mvz2:pop_captain`。
   （后续宏 agent 的更新使总数进一步到 370，见 §7 的表格。）
3. **宏 agent 17:08 的注册表更新**：`DefinitionRegistry.hx` / `DefinitionRegistryMacro.hx`
   在 17:08 被更新（`isAbstract` 从 0 条变为 **8 条** —— 说明 `// abstract` 的解析路径被修好了；
   `d.attr` 也改为在**类自己的作用域**求值）。这次更新使 `PropertyDictionary` 的无效键告警
   **4942 → 0**（本包未改 `PropertyMapper` / `PropertyDictionary`）。
   **归属：宏 agent**；本包只负责证明它生效并记录。

`entity_physics` 在计数归零后不再出现——它**不是移植缺陷**（该文件标注与 C# 逐字一致，
`GetDefinitionType()` 同样是 `entity_behaviour`，见 §5.2），
16:47 那轮的告警是当时属性/定义注册尚不完整造成的连带现象。

### 7.2 运行进度（release）

修复前停在「存档降级 → 段错误」；修复后启动**推进过资源加载**，末尾里程碑：

```
[step] [log] SpriteManifestLoader: 已载入 709 个精灵、222 个精灵图集、988 张贴图；其中 931 条的贴图路径取自 resource_manifest.json。
[step] [log] 加载Music Clips花费的时间：0.011
[step] [log] 加载Sound Clips花费的时间：0.014
[step] [log] 加载Sprites花费的时间：8.162
[step] [log] 加载Models花费的时间：0.336
[step] [log] 加载Map Models花费的时间：0.004
[step] [log] 加载Area Models花费的时间：0.002
```

仍以 exit 139 结束（段错误），但**卡点已不再是行为/属性注册链路**。
另有 1 条新的错误行需别的 agent 关注：

```
[error] [log] Error loading user list: Invalid char 120 at position 0
```

`Invalid char 120 at position 0`（`'x'`）来自 JSON 解析——存档目录里的某个文件不是合法 JSON
（很可能是别的 agent 跑验证时留下的残留文件，或 `userList.json` 本身格式问题）。
它不阻断启动（随后走了「创建新存档」），但会掩盖真实的存档路径问题。

### 7.3 复现命令汇总

```bash
# ① 独立验证「定义注册链路」（不需要完整构建，~60s）
cd HaxePort
haxe -cp source -cp tools_build/verify_behaviour -lib flixel -lib flixel-addons -lib flixel-ui \
  -lib lime -lib openfl -lib hscript -lib hxjsonast -lib json2object \
  -main BehaviourMain --interp -D lime_use_old_deltatime \
  --macro "flixel.system.macros.FlxDefines.run()"
# 期望（2026-10-05 17:5x 实测）：实例化成功=850 其中behaviour=370 callbacks=18，probe lookup 5/5
# 注：这些数字会随宏 agent 继续更新注册表而变化；判据是「probe lookup 5/5」且无异常。

# ② 端到端（隔离工程，~16min 构建）
cd tools_build/verify_registry && bash setup.sh && haxelib run lime build windows && bash run.sh 90
# 期望：boot-trace 里 4 类告警计数全为 0

# ③ 类型检查（两目标都必须 exit 0）
haxe -cp source -cp verify -lib flixel -lib flixel-addons -lib flixel-ui -lib lime -lib openfl \
  -lib hscript -lib hxjsonast -lib json2object -main Main -neko /tmp/check.n --no-output \
  -D lime_use_old_deltatime --macro "flixel.system.macros.FlxDefines.run()" \
  --macro "coverage.CoverageCheck.run()"
haxe -cp source -cp verify -lib flixel -lib flixel-addons -lib flixel-ui -lib lime -lib openfl \
  -lib hxcpp -lib hscript -lib hxjsonast -lib json2object -main Main \
  -cpp "$TEMP/mvz2_cppcheck" --no-output -D lime_use_old_deltatime \
  --macro "flixel.system.macros.FlxDefines.run()" --macro "coverage.CoverageCheck.run()"
# 期望两者都是 [CoverageCheck] 模块总数=2486 类型化成功=2486 失败=0 且 exit 0
```

---

## 8. 交接清单（本工作包）

### 8.1 修改/新增文件

| 文件 | 类型 | 说明 |
|---|---|---|
| `source/system/reflection/Assembly.hx` | **改** | `matchesAttributeName` 形参 `Null<String>` → `Dynamic`；新增 `simpleNameOf`（同时接受**类引用**与字符串路径）；补 C# 的基类匹配语义（`attributeName == "DefinitionAttribute"` 无条件命中）。**缺陷 A 的修复点** |
| `source/mvz2/gamecontent/enemies/PopCaptain.hx` | **改** | 补 `@:autoEntityBehaviourDefinition(VanillaEnemyNames.popCaptain)`（partial 合并时漏掉的标注） |
| `source/mvz2/audios/SoundManager.hx` | **改** | `Awake` 补 `mixer` 兜底 + `AudioManifest.applyTemplate(soundTemplate/loopSoundTemplate)`，与 `MusicManager.Awake` 对齐 |
| `tools_build/verify_behaviour/BehaviourMain.hx` | **新增** | 复刻 `ModLoader.LoadAssemblies` + 按 ID 查询 behaviour 的自检程序（`--interp` 约 35s，不需要完整构建） |
| `tools_build/verify_registry_smoke/export/` | 已删 | 本包为快速 cpp 编译产生的临时产物（540MB），已清理；`SmokeMain.hx` 保留 |

**未改**：`hmm.json`、`Project.xml`、`source/Main.hx`、`source/mvz2/states/**`、
`source/system/reflection/{DefinitionRegistry,DefinitionRegistryMacro}.hx`（宏 agent 的文件）、
`source/pvzengine/PropertyMapper.hx`。

### 8.2 修掉的问题数

| 分类 | 数量 | 明细 |
|---|---|---|
| **定义/行为注册链路** | 2 | 缺陷 A（`GetCustomAttributes` 恒抛异常 → 0 定义注册）、`PopCaptain` 漏标注 |
| **音频 mixer** | 1 | `SoundManager` 未应用音频模板（音效不走 Sound 总线，音量滑条静默失效） |
| **合计** | **3** | 另有 1 条本包**误判并已更正**的记录（`entity_physics`，见 §5.2） |

### 8.3 需要别的 agent / 决策者配合

1. **宏 agent（进行中，已部分完成）**：
   - 17:08 的注册表更新使 4 类告警全部归零，本包已复核。若继续改动注册表，
     请保持 §4.5 的字段契约（尤其 `d.attr` 是**类引用**）。
   - 本包未改 `DefinitionRegistry*.hx`，避免冲突。
2. **`Invalid char 120 at position 0`（新出现的错误行）**：
   `source/mvz2/saves/SaveManager.hx:708` 的 `LoadUserList` 报的 JSON 解析失败
   （`'x'` 在 position 0），对应 C# `Assets/Scripts/MVZ2/Saves/SaveManager_Users.cs:169`。
   存档目录 `%APPDATA%/MVZ2/mvz2-haxe/` 当前为空，**怀疑是别的 agent 跑验证时留下的残留
   文件或路径解析差异**，需存档/prefab 工作包复核。它不阻断启动（走了「创建新存档」）。
3. **release 段错误仍未解**（exit 139）：卡点已从「存档降级路径」推进到
   「资源加载（Sprites/Models/Map Models/Area Models）之后」，**不再是本工作包的链路**。
4. **`MainGameScene` 手工对象图 vs 工作包②的 `ScenePrefabInjector`**（见 §6.3）：
   本包补的 `applyTemplate` 是清单兜底，场景 prefab 正式接入后应删除这两处调用。

### 8.4 遗留 / 未完成

- `tools_build/verify_registry_smoke/` 只有 `SmokeMain.hx`，没有 `Project.xml`，
  不能直接用 `lime build`；本包是用 `haxe ... -main SmokeMain --interp` 跑的。
  若后续要复用它，建议参照 `verify_registry/` 补一个 `Project.xml`。
- `BehaviourMain.hx` 里的数字（850 / 370）会随宏 agent 继续更新而变化，
  判据请用「probe lookup 5/5 + 无异常」，而不是固定数字。

---

## 9. 最终验收（标准构建产物，2026-10-05 18:06）

**命令**：

```bash
cd HaxePort && haxelib run lime build windows     # exit 0，产物 30,150,144 B @ 18:06
cd export/windows/bin && ./MVZ2.exe               # 运行 70s
```

**结果**（`export/windows/bin/boot-trace.log`，129 行 / 5,737 B）：

```
Cannot find entity behaviour          0
Cannot find map element behaviour     0
invalid key                           0
is not registered                     0
AudioMixer                            0
音频模板                              0
MusicMixer                            0
Duplicate property                    0
```

对照**修复前基线**（同一路径，14:31 的旧产物）：`1986 / 9 / 16331 / 8563 / 0 / 0 / 0 / 0`，
`boot-trace.log` 1,769,618 B / 27,013 行。

| | 修复前 | 最终 |
|---|---|---|
| boot-trace 行数 | 27,013 | **129**（-99.5%） |
| 四类告警合计 | 26,889 | **0** |
| release exit code | 139 | 139（卡点已推进过资源加载，见 §7.2） |

**类型检查**（本包最终快照，2026-10-05 17:5x）：

```
neko: exit=0  [CoverageCheck] 模块总数=2486 类型化成功=2486 失败=0
cpp : exit=0  [CoverageCheck] 模块总数=2486 类型化成功=2486 失败=0
```
