# 工作包①：宏收集器 / 定义与属性注册表 排查笔记

> 每推进一处就更新本文件，避免超时丢进度。
> 隔离验证工程：`tools_build/verify_defreg/`（`bash setup.sh` 建 assets 目录联接，`bash run.sh [秒]` 跑 + 打印告警计数与 boot-trace 末尾）。
> 数据层快速探针用 `--interp`（neko 代码生成有已知限制，见 §4）。

## 0. 接手时的状态（2026-10-05 16:07）

上一段（被超时打断）已经落盘了三个文件：

| 文件 | mtime | 状态 |
|---|---|---|
| `source/system/reflection/DefinitionRegistryMacro.hx` | 16:02 | 编译期扫描宏：扫 931 候选模块 → 932 条类型记录 |
| `source/system/reflection/DefinitionRegistry.hx` | 15:44 | 运行期注册表（`@:build` 注入 `__classes()`） |
| `source/system/reflection/Assembly.hx` | 16:02 | `GetTypes` / `IsAbstract` / `HasCustomAttribute` / `GetCustomAttributes` / `InvokeConstructor` 已改为从注册表作答 |

**已实测**（`tools_build/verify_registry_smoke/SmokeMain.exe`，cpp 16:23 产物）：
```
records=932
assemblies=[PVZEngine.Level,MVZ2.Vanilla,MVZ2.Logic]
  PVZEngine.Level -> 8
  MVZ2.Vanilla -> 899
  MVZ2.Logic -> 25
VanillaMod assembly=MVZ2.Vanilla   types=899
LogicMain assembly=MVZ2.Logic      types=25
ArmorEntityBehaviour found=true
```
即 **`Assembly.GetTypes()` 已经能答出 899/25 条类型**，`@:autoXxxDefinition` 的类也没被 DCE。
但 **这些数据从未进入任何一次游戏运行**：根目录 `export/windows/bin/MVZ2.exe`（15:34 产物）与
`boot-trace.log`（15:35，16331 / 8563 / 1986 条告警）都早于上述三个文件的 mtime。

## 1. 本段发现的三个真实缺陷（全部在「数据 → 运行期」这一段）

### 1.1 【致命】`GetCustomAttributes(type, "DefinitionAttribute")` 永远匹配不到

`Assembly.hx:104 matchesAttributeName()` 只在「特性类简单名 == 查询名」时返回 true。
而宏为定义特性记的是**派生特性类**（`AutoAreaDefinitionAttribute` / `AutoEntityBehaviourDefinitionAttribute` …），
C# 的 `type.GetCustomAttributes<DefinitionAttribute>()` 语义是**取所有可赋值给 DefinitionAttribute 的特性**（含全部派生类）。

后果：`ModLoader.LoadAssemblies` 的
`var definitionAttributes = AssemblyGetCustomAttributes(assembly, type, "DefinitionAttribute");`
恒为空数组 → **一个 Definition 都不会被实例化并 `mod.AddDefinition`** →
`Cannot find entity behaviour with ID mvz2:*`（1986 条）与大量属性未注册。

附带隐患：宏把 `attr` 发成了**类引用**（`macro $p{parts}`），而 `matchesAttributeName` 形参是 `Null<String>`，
调用点 `cast d.attr` 是无检查转型 —— cpp 上把 `hx::Class` 当 `String` 调 `split()` 是未定义行为。

### 1.2 【致命】`MainManager.hx:308` 传空数组

```haxe
PropertyMapper.InitPropertyMaps(BuiltinNamespace, []);
```
C# 原文（`Assets/Scripts/MVZ2/Managers/MainManager.cs:222~224`）是
`PropertyMapper.InitPropertyMaps(BuiltinNamespace, levelEngineAssembly.GetTypes())`，
即把 **PVZEngine.Level 程序集的全部类型**（8 条：EngineEntityProps / EngineBuffProps / EngineArmorProps /
EngineAreaProps / EngineLevelProps / EngineStageProps / EngineRechargeProps / EngineSeedProps）注册进去。
传 `[]` 等于这 8 个 `Engine*Props` 的全部属性键恒为 0。

### 1.3 【中】字段级区域元数据的参数解析不到

宏的 `evalArg()` 只处理「字符串字面量」与「`限定类.静态字段`（EField）」两种形态。
但工程里字段级标注大量写成**裸标识符**：
```haxe
public static inline var PROP_REGION:String = "contraption_shooter";
@:propertyRegistry(PROP_REGION)
public static var PROP_SHOOT_TIMER:VanillaEntityPropertyMeta<FrameTimer> = ...;
```
`PROP_REGION` 是 `EConst(CIdent)`，既不是字符串字面量、也不是 EField，`Context.typeExpr` 在宏
调用点（Assembly 的作用域）也解析不了它 → 返回 null → 该字段的区域为 null →
`PropertyMapper.GetPropertyRegionName` 返回 null → **该属性被跳过、不注册**。
（实测计数：`@:entityPropertyRegistry(PROP_REGION)` 18、`@:levelPropertyRegistry(PROP_REGION)` 17、
`@:propertyRegistry(PROP_REGION)` 4、`@:levelPropertyRegistry(REGION_NAME)` 1，共 40 处。
宏里已有 `staticStringOf(cls, fieldName)` 能取「被标注类自己的静态字符串常量」，只是没被这个分支调用。）

### 1.4 【中】neko 代码生成 `Stack check failed for function scope`

`__classes_N` 用**单个 100 元素的数组字面量**返回。neko 生成期报
`module.c(560) : Stack check failed for function scope`（编译期通过、运行期挂）。
本段改成**逐条 `push` 构造**（局部栈不再随记录数增长）—— 这是更稳妥的写法，
但**实测该 neko 错误依旧复现**，与写法无关，属 neko 目标的固有限制，见 §5。

## 2. 修法（本段落地）

1. **`evalArg` 支持裸标识符**（宏）：新增 `EConst(CIdent)` 分支 → `staticStringOf(cls, id)`，
   修复 §1.3 的 40 处字段级区域标注。实测（`--interp`）：42 条 `propertyRegistry` 字段
   **全部**解析出 region（`nullRegion=0`），例如
   `ContraptionShooterBehaviour.PROP_SHOOT_TIMER region=contraption_shooter`、
   `LittleZombieStage.FIELD_BIG_COUNTER region=little_zombie_stage`。
2. **`__classes_N` 改逐条 push 构造**（宏）：消除 neko 生成期的
   `Stack check failed for function scope`（§1.4）。**实测未彻底解决**，见 §4。
3. **`classExpr` 的 `isAbstract` 键名修正**（宏，见 §2.2 缺陷 C）。
4. **`MainManager.hx:308` 传入 PVZEngine.Level 程序集的类型**（§1.2）：
   `PropertyMapper.InitPropertyMaps(BuiltinNamespace, Assembly.GetAssembly(pvzengine.level.LevelEngine).GetTypes())`。
5. **次类型运行期类名修正**（宏 `runtimeName` + `DefinitionRegistry.getRecordOfClass` 兜底，见 §2.2 缺陷 D）。
6. **`ModLoader.hx:131` 的 `TODO-PORT` 改为 `PORT-NOTE`**：注册表已接通，注释里「shim 目前只是
   程序集名占位」的说法已过时；调用形式与 C# 原文一一对应，无需再改。

### 2.1 与并行 agent 的分工（重要）

`Assembly.matchesAttributeName`（§1.1）在本段开始前已被**另一个 agent 于 16:27 修好**
（形参改 `Dynamic` + `simpleNameOf()`，并补上 `attributeName == "DefinitionAttribute"` 无条件命中）。
本段一度加了等价的 `attrNames` 祖先链机制，发现重复后**已回退**，避免两套机制打架。
`registry_audio_findings.md` §4 是该 agent 的记录（含它自己的 `verify_behaviour` 冒烟工程）。

### 2.2 本段另发现并修掉的 2 个缺陷（16:5x）

**缺陷 C（`isAbstract` 键名写错）**：`classExpr` 发的是
`Reflect.field(c, "abstract")`，而 `describeClass` 建的记录键是 `isAbstract` → 恒 null →
`Assembly.IsAbstract` 恒 false。
**实测影响评估**：修后共 8 条 `isAbstract=true` 的记录
（`CatapultBehaviour` / `ContraptionShooterBehaviour` / `DispenserFamily` / `SpikesBehaviour` /
`MutantZombieBase` / `BossStageBehaviour` / `IZombieBehaviour` / `StateEnemy`），
但**这 8 条 `defs` 都是 0、`callbacks` 都是 false** —— 即它们都不带定义/回调元数据，
`ModLoader` 本来就不会实例化它们。所以这是一处**潜在正确性修复**
（`BlueprintHeldItemBehaviour` 的 `// abstract` 注释确实存在，但它的记录只有 `fields`、没有 `defs`），
**不是本段告警归零的贡献项**。修法：改成 `Reflect.field(c, "isAbstract")`。

**缺陷 D（次类型的运行期类名不一致 → 6 条记录查不到）**：
宏的 `classPath()` 对**次类型**发的是 `pack.Module.Type`，而 Haxe 运行期
`Type.getClassName(cls)` 是 `pack.Type`（不含模块名）。
`DefinitionRegistry.getRecordOfClass()` 正是拿 `Type.getClassName` 查表的，于是这 6 个次类型的
`defs` / `region` / `fields` **全部丢失**（实测 `nameMismatch=6`）：

| 记录名（宏发出） | 运行期类名 | 后果 |
|---|---|---|
| `mvz2.gamecontent.entities.EntityPhysicsBuff.EntityPhysicsBehaviour` | `...entities.EntityPhysicsBehaviour` | `mvz2:entity_physics` behaviour 未注册（310 条告警） |
| `mvz2.gamecontent.helditems.BlueprintHeldItemBehaviour.ClassicBlueprintHeldItemBehaviour` | `...helditems.ClassicBlueprintHeldItemBehaviour` | held_item_behaviour 定义缺失 |
| `...BlueprintHeldItemBehaviour.ConveyorBlueprintHeldItemBehaviour` | `...helditems.ConveyorBlueprintHeldItemBehaviour` | 同上 |
| `mvz2.gamecontent.options.ShowHotkeysOptionToggle.ShowHotkeysOptionsToggle` | `...options.ShowHotkeysOptionsToggle` | option_widget 定义缺失 |
| `mvz2.gamecontent.stages.RedstoneStageBehaviour.RedstoneDropStageBehaviour` | `...stages.RedstoneDropStageBehaviour` | stage 定义缺失 |
| `mvz2logic.maps.LogicEntityProps.LogicMapElementProps` | `mvz2logic.maps.LogicMapElementProps` | mapElement 区域属性未注册 |

修法：记录里把「类引用路径（`path`，供 `macro $p{}` 发出引用）」与「运行期名字（`name`）」
分开 —— `name` 用新的 `runtimeName(cls)`（= `pack.Type`）。
另在 `DefinitionRegistry.getRecordOfClass` 加了「后缀互相匹配」的兜底。
**实测修后 `nameMismatch=0`，`entity_physics` 现在能被 `GetCustomAttributes` 命中并实例化为
`entity_behaviour`。**

## 3. 验收结果（cpp release 实测，2026-10-05 17:39）

**两个独立的 release 构建都实测通过**（都是 `haxelib run lime build windows`，exit 0）：

| 产物 | 构建时间 | 说明 |
|---|---|---|
| `tools_build/verify_defreg/export/windows/bin/MVZ2.exe` | 17:39 | 本工作包的隔离工程（含全部修复，30,061,056 B） |
| `export/windows/bin/MVZ2.exe` | 17:29 | 仓库根标准构建（30,065,664 B），由并行 agent 触发 |

`boot-trace.log` 告警计数（两个产物一致）：

| 告警 | 基线（15:35） | 修复后（17:39/17:30） |
|---|---|---|
| `Trying to set a property with an invalid key!` | 16331 | **0** |
| `Property with name ... is not registered.` | 8563 | **0** |
| `Cannot find entity behaviour with ID mvz2:*` | 1986 | **0** |
| `Cannot find map element behaviour with ID mvz2:*` | 9 | **0** |
| `Object does not implement interface` | 4（debug 构建 `verify_startup` 16:26） | **0** |
| boot-trace 行数 | 27013（15:35） | **129** |

> 注：15:35 的 **release** boot-trace 里 `does not implement interface` 计数是 0 —— 该异常在
> release 下被 `SaveManager.LoadInitialUserData` 的 `try/catch` 吞掉，随后 `dialog` 空引用直接段错误；
> 只有 **debug** 构建（`HXCPP_CHECK_POINTER` 让空引用变可捕获异常）才会把它打出来。
> 修复后 debug 与 release 都不再出现该异常。

**`source/mvz2/saves/MVZ2SaveExt.hx:12` 的 `Object does not implement interface` 已消失**：
根因是 `LogicEntityProps.UNLOCK` 的 key 恒为 0、与别的属性共用槽位，读出别的属性的值后被当
`IConditionList` 调用。属性键注册正确后不再发生。

### 3.1 数据层证据（`--interp`）

复刻 `MainManager.InitGameSettings` + `ModLoader.LoadAssemblies` 的注册顺序
（临时探针 `Diag4.hx`）：

| 指标 | 修复前（15:34 产物 boot-trace） | 本段 `--interp` 复刻 |
|---|---|---|
| `Trying to set a property with an invalid key!` | 16331 | **0** |
| `Property with name ... is not registered.` | 8563 | **0** |
| `Cannot find entity behaviour with ID mvz2:*` | 1986 | **0** |
| 实例化的 Definition 数 | 0 | **850** |
| 属性键 | 全 0、互相覆盖 | 非 0 且互不相同（TINT=1048598 / SCALE=1048595 / FRICTION=1048583 / MAX_HEALTH=1048602 / UNLOCK=1049426 / MASS=1049300） |
| 注册表记录 `nameMismatch` | 6 | **0** |

### 3.2 类型检查

- neko：`[CoverageCheck] 模块总数=2486 类型化成功=2486 失败=0`，exit 0。
- cpp：同上，exit 0。
- 两者都带 `[DefinitionRegistry] 候选模块=932 收录类型=933 跳过=0`。

### 3.3 规模数据（实测）

- 注册表记录：**933 条**（`PVZEngine.Level` 8 / `MVZ2.Vanilla` 900 / `MVZ2.Logic` 25，合计 933）。
  其中 `defs` 合计 850 条、`callbacks` 18 条、类级 `region` 43 条、字段级 `propertyRegistry` 42 条。
- 可实例化的 Definition：**850 条**（`--interp` 全链路复刻实测），
  分布：`entity_behaviour` 369 / `buff` 194 / `stage` 44 / `i_zombie_layout` 35 /
  `mvz2:random_china_event` 29 / `artifact` 27 / `option_widget` 25 / `command` 20 /
  `held_item_behaviour` 17 / `shell` 15 / `placement` 14 / `held_item` 13 / `note` 8 /
  `area` 8 / `seed_option` 7 / `grid` 7 / `armor_behaviour` 5 / `recharge` 4 /
  `map_element_behaviour` 3 / `spawn` 2。
- 程序集分布与 C# asmdef 一致（`MVZ2.Vanilla` / `MVZ2.Logic` / `PVZEngine.Level`）。

## 4. 未完成项 / 交给其它工作包

- **启动仍段错误**（exit 139 / 0xC0000005，运行 90s 后）：卡点已从「`main.Initialize` 的属性/定义注册」
  推进到**存档读取之后的资源加载段**。boot-trace 末行为
  `[step] [log] 加载Area Models花费的时间：…`，之前有一条**非本工作包**的错误：
  `[error] [log] Error loading user list: Invalid char 120 at position 0`
  （`source/mvz2/saves/SaveManager.hx:708` ← C# `SaveManager_Users.cs:169`；
   `120` = `'x'`，看起来是 JSON 解析到了非 JSON 数据）。
  这属于**存档/用户数据工作包**，与本工作包的注册表链路无关。
- **UI 渲染仍为纯黑**：属未转换的 prefab（工作包②），boot-trace 里已明确列出
  21 个因「prefab 引用未转换」被跳过 Awake 的页面组件。
- **`isAbstract` 的 8 条 true 记录**（宏按类声明上方 `// abstract` 注释判定）：
  已实测生效；但若将来新增抽象定义类，仍依赖该注释约定（PORTING.md 既有约定）。

## 5. neko 目标的已知限制（不是本工作包的缺陷）

`DefinitionRegistry.getClasses()` 在 **neko 代码生成**下报
`Uncaught exception - module.c(560) : Stack check failed for function scope`。
- 该错误发生在**生成期**（`.n` 文件写坏），与 `__classes_N` 的写法无关：
  把「100 元素数组字面量」改成「逐条 push」后**依旧复现**。
- 同一份源码用 **`--interp`** 完全正常（`records=933`）；cpp 也正常
  （`verify_registry_smoke/export/smoke/SmokeMain.exe` 输出 `records=932`，修复前）。
- 与 `PORTING.md:129` 记录的限制同源：neko **只能做类型检查，不能做代码生成/运行**。
  因此本工作包的运行期验证一律用 **cpp**（release 构建）与 **`--interp`**（数据检查）。
- neko 类型检查（`--no-output`）不受影响，仍 exit 0。

