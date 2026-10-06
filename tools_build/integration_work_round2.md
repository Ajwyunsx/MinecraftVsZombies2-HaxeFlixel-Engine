# 集成验证 —— 本轮（2026-10-05 第二轮）工作记录

> 分段落盘，避免超时丢进度。最终结论写入 `integration_report.md`。

## 0. 开工状态（16:07）

上一轮 `integration_report.md`（14:27）的结论已过期：本轮期间并行 agent 落地了
**属性注册表编译期宏**（`source/system/reflection/DefinitionRegistryMacro.hx` 等），
且一直在改 `source/`（最新改动 16:57 `ScenePrefabFieldApplier.hx`）。

本工作包流程：① 等其它 agent 段落 → ② 三阶段复验 → ③ 运行抓 boot-trace → ④ 告警计数对比
→ ⑤ 卡点精确定位 → ⑥ 落盘报告 + 更新 PORTING.md。

## 1. 新增工具

`tools_build/count_boot_warnings.py`：boot-trace 告警计数（工作包④要求）。
基线 16331 / 8563 / 1986 / 0，支持多日志对比与 `--json`。

## 2. 三阶段复验（16:46~16:55，source 快照见报告 §1）

| 阶段 | 结果 |
|---|---|
| neko 类型检查 | exit 0（`[DefinitionRegistry] 候选模块=931 收录类型=932`） |
| cpp 全覆盖检查 | exit 0，`[CoverageCheck] 模块总数=2486 类型化成功=2486 失败=0` |
| `lime build windows` | exit 0（6m24s），产物 29,960,704 B，md5 `38d6631abd3de104cd45f2392c2c0b3a` |

**注意**：构建期间（16:52/16:54/16:57）另有 agent 改了 3 个文件，产物与最终 `source/` 不完全对应。
但类型检查在 16:46 已过，且后续改动由各自 agent 负责复验。

## 3. 运行结果（16:55，release）

- exit **139**（0xC0000005），存活约 14 s。
- `boot-trace.log` **495 行 / 31,095 B**（上一轮 27,013 行 / 1.77 MB）。

### 3.1 告警计数对比（`count_boot_warnings.py`）

| 告警 | 基线 | 本轮 | 变化 |
|---|---|---|---|
| `Trying to set a property with an invalid key!` | 16331 | 58 | -16273 |
| `Property with name ... is not registered.` | 8563 | 0 | -8563 |
| `Cannot find entity behaviour with ID mvz2:*` | 1986 | 311 | -1675 |
| `Cannot find map element behaviour with ID mvz2:*` | 9 | 0 | -9 |
| `Cannot create property ... of type "color"` | 0 | 0 | 持平 |

**属性注册表宏已生效**：前两项基本归零；属性键实测非 0 且互不相同
（`EngineEntityProps.GRAVITY=1049525`、`TINT=1049522`、`LogicEntityProps.UNLOCK=1049363`）。

剩余 311 条里 310 条是 `mvz2:entity_physics`、1 条 `mvz2:pop_captain`。

## 4. 卡点精确定位（debug 构建，`verify_startup`，17:0x）

`haxelib run lime build windows -debug`（隔离工程，无覆盖层）→ `bash run.sh 60`：

```
[error] [4] Null Object Reference
    Called from mvz2.managers.ResourceManager.LoadModModels (mvz2/managers/ResourceManager.hx line 1359)
    Called from mvz2.managers.ResourceManager.LoadModResourcesMain (mvz2/managers/ResourceManager.hx line 265)
    Called from mvz2.managers.PipelineTask.Run (mvz2/managers/MainManager.hx line 659)
    Called from mvz2.managers.ResourceManager.LoadModResourcesMain (mvz2/managers/ResourceManager.hx line 299)
    Called from mvz2.managers.ResourceManager.LoadAllModResourcesMain (mvz2/managers/ResourceManager.hx line 130)
    Called from mvz2.managers.MainManager.InitLoad (mvz2/managers/MainManager.hx line 173)
```

**精确卡点：`source/mvz2/managers/ResourceManager.hx:1359`**
```haxe
var model = pair.resource.GetComponent(Model);   // ← pair.resource 是 haxe.io.Bytes，不是 GameObject
```

### 4.1 根因（已用独立探针证实）

`ResourceManager.hx:1355` 的 `LoadLabeledResources(GameObject, nsp, "Model", progress)`：
`GameObject` 只是**类型参数**（Haxe 运行期无泛型），`LoadResourcesByLocations` 里
`var res:T = cast handle.WaitForCompletion()` 实际拿到的是
`ResourceManifest.doLoad()` 对 `KIND_MODEL` 走 `default` 分支返回的 **`haxe.io.Bytes`**
（`unity/addressableassets/ResourceManifest.hx:485~490`：Unity prefab 专有格式尚未转换）。

探针 `tools_build/verify_integration/ModelLoadProbe.hx`（`--interp`）实测：
```
locate("Model", GameObject) -> 420 条定位符
  loc=mvz2:armor/bedserker_helmet kind=Model asset=haxe.io.Bytes isGameObject=false
  …（420 条全部如此）
```

于是 `pair.resource.GetComponent(Model)` 在 `Bytes` 上取方法 → cpp 直接访问违例（release）
/ 空引用（debug）。**同一 bug 还有两处同型调用点**：
- `:815` `LoadModAreaModels`：`pair.resource.GetComponent(AreaModel)`（标签 `AreaModel`）
- `:1279` `LoadModMapModels`：`pair.resource.GetComponent(MapModel)`（标签 `MapModel`）

C# 原文（`Assets/Scripts/MVZ2/Managers/ResourceManager_Models.cs:77~88`）没有判空，
因为 Addressables 只会返回真的 prefab GameObject。

### 4.2 修法（最小、与本文件既有约定一致）

同文件 `:448~458` 已经确立了「移植层无法还原的资源 = 无匹配资源、跳过并告警」的约定
（用于 null 的情形）。把同一约定扩展到「类型不是 GameObject」的情形即可，
语义与 C# 等价（C# 该分支永不触发）：

```haxe
// PORT-NOTE: 移植层 Model/AreaModel/MapModel 标签的资源由 ResourceManifest 返回
// haxe.io.Bytes（Unity prefab 专有格式尚未转换），不是 GameObject；C# 的
// Addressables 只会返回真 prefab，故原文无此判断。按本文件 :448 的既有约定
// 「无法还原 = 无匹配资源」跳过（ModelBuilder 已有 ModelPrefabLoader 回退路径）。
if (!Std.isOfType(pair.resource, GameObject))
    continue;
```

## 5. 修复已应用（17:0x）

对三处同型调用点都加了守卫（`source/mvz2/managers/ResourceManager.hx`）：

| 行（修复后） | 函数 | 标签 |
|---|---|---|
| `:817` | `LoadModAreaModels` | `AreaModel` |
| `:1285` | `LoadModMapModels` | `MapModel` |
| `:1372` | `LoadModModels` | `Model` |

```haxe
if (!Std.isOfType(pair.resource, GameObject))
    continue;
```

neko 与 cpp 类型检查均 **exit 0**（cpp `[CoverageCheck] 模块总数=2486 类型化成功=2486 失败=0`；
`[DefinitionRegistry] 候选模块=932 收录类型=933`）。正在重跑 release 构建 + 运行复验。

## 6. 修复复验（17:29 release 产物，md5 `8abe051268413693abb29a8bed01dbc3`，30,065,664 B）

**告警全部归零**（`count_boot_warnings.py`）：

| 告警 | 基线 | 修复前 | 修复后 |
|---|---|---|---|
| `Trying to set a property with an invalid key!` | 16331 | 58 | **0** |
| `Property with name ... is not registered.` | 8563 | 0 | **0** |
| `Cannot find entity behaviour with ID mvz2:*` | 1986 | 311 | **0** |
| `Cannot find map element behaviour with ID mvz2:*` | 9 | 0 | **0** |
| `Cannot create property ... of type "color"` | 0 | 0 | **0** |

`boot-trace.log` 从 495 行降到 **129 行**（5,735 B）。资源加载流水线**全部 6 个任务跑完**：

```
[log] 加载Music Clips花费的时间：0.017
[log] 加载Sound Clips花费的时间：0.024
[log] 加载Sprites花费的时间：11.867
[log] 加载Models花费的时间：0.391      ← 修复前卡在这里
[log] 加载Map Models花费的时间：0.026
[log] 加载Area Models花费的时间：0.013
```

**注意**：`Cannot find entity behaviour with ID mvz2:entity_physics`（310 条）的消失**不是**修复
`LoadModModels` 带来的（那条崩溃发生在资源加载阶段，在这些告警打印之后）。真正原因是**宏的次类型命名缺陷**
（`classPath()` 发 `pack.Module.Type`、运行期 `Type.getClassName` 是 `pack.Type`，6 个次类型记录查不到），
由宏 agent 在 17:08 修好（`registry_macro_findings.md`「缺陷 D」）。探针
`verify_integration/EntityPhysicsProbe.hx` 复核：`definitionType=entity_behaviour`、
`查 entity_behaviour -> EntityPhysicsBehaviour`。`mvz2:pop_captain` 则由另一个 agent 在 16:52 补了
`@:autoEntityBehaviourDefinition(VanillaEnemyNames.popCaptain)`。

**仍段错误**（exit 139），但卡点已推进到资源加载**之后**：`MapController.hx:299`
（`mapCamera` 未注入，属工作包②的 prefab 注入，见报告 §5.1）。

## 7. 待办
- [x] 应用 §4.2 的三处守卫。
- [x] neko + cpp 类型检查复验 exit 0。
- [x] release 构建 + 运行复验：告警全 0、流水线跑完。
- [x] 定位新卡点：`MapController.hx:299`（工作包②）。
- [x] 写 `integration_report.md` 定稿。
- [x] 更新 `PORTING.md` 构建与验证。
