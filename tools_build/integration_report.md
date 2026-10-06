# 集成验证报告（工作包：集成验证与文档定稿）

> **本轮（2026-10-05 第二轮）** 报告，取代 2026-10-05 14:27 与 2026-10-02 的旧结论。
> 本轮期间并行 agent 落地了**属性注册表编译期宏**（工作包①），启动卡点因此大幅前移；
> 本工作包据此重跑三阶段 + 运行复验，并**修复了 1 个真实 release 崩溃点**。
> 每个结论都标注了**验证时点**与当时的 `source/` mtime（`source/` 可能被并行改动）。

---

## 0. 一句话结论

| 项 | 结果 |
|---|---|
| neko 类型检查 | **exit 0** |
| cpp 全覆盖检查 | **exit 0**，`[CoverageCheck] 模块总数=2486 类型化成功=2486 失败=0` |
| `haxelib run lime build windows` | **exit 0**，产物 30,065,664 B、md5 `8abe051268413693abb29a8bed01dbc3` |
| release 运行 | **仍段错误** `exit=139`（0xC0000005） |
| **告警计数** | **四类全部归零**（基线 16331 / 8563 / 1986 / 0） |
| 崩溃终点（release） | 资源加载**全部跑完**后，`GameEntrance.StartGame → DisplayPage(Splash) → MapController.Hide → SetCameraBackgroundColor` |
| 崩溃精确点（debug） | `mvz2/map/MapController.hx:299`（`mapCamera` 空引用） |
| 本轮修复 | **1 个 release 崩溃点**（`ResourceManager.LoadModModels` 等 3 处，见 §4） |

---

## 1. 验证时点与 source 快照

- **验证时点**：2026-10-05 16:46 ~ 17:46。
- **类型检查（16:46）时的 `source/` 状态**：本轮期间被多个并行 agent 持续改动，
  最新一次在 16:57（`ScenePrefabFieldApplier.hx`）。类型检查在该时点 exit 0。
- **本 agent 的改动**：仅 `source/mvz2/managers/ResourceManager.hx`（17:09:03，3 处守卫，见 §4）。
- **最终冻结快照复验（17:44~17:46）**：当时 `source/` 自 **17:15:52**（`ModLoader.hx`）起无改动，
  neko 与 cpp 全覆盖检查 **exit 0**（`[CoverageCheck] 模块总数=2486 类型化成功=2486 失败=0`），
  17:29 的 release 产物出自该快照。
- **⚠️ 之后 `source/` 又被并行改动**：17:48 有 agent 重建了产物，17:49 又改了
  `DefinitionRegistryMacro.hx` / `ScenePrefabLoader.hx`。本 agent 在 17:50 对**改动后**的 `source/`
  重跑 cpp 全覆盖检查：**exit 0**（`[CoverageCheck] 模块总数=2486 类型化成功=2486 失败=0`）；
  并运行 17:48 的新产物复验，行为与 §3 一致（129 行 / 告警全 0 / exit 139）。
  **17:49 之后的状态仍需由对应 agent 或下一轮复验。**

| 文件 | mtime（本 agent 复验时的值） |
|---|---|
| `source/Main.hx` | 2026-10-02 21:03:02 |
| `source/mvz2/states/MainGameScene.hx` | 2026-10-05 15:22:53 |
| `source/mvz2/managers/MainManager.hx` | 2026-10-05 16:41:15 |
| `source/mvz2/managers/ResourceManager.hx` | **2026-10-05 17:09:03（本 agent 修 3 处）** |
| `source/system/reflection/Assembly.hx` | 2026-10-05 16:27:13 |
| `source/system/reflection/DefinitionRegistry.hx` | 2026-10-05 17:08:10 |
| `source/system/reflection/DefinitionRegistryMacro.hx` | 2026-10-05 **17:49:20**（类型检查之后又改） |
| `source/mvz2/map/MapController.hx` | 2026-10-02 19:25:37（未改） |
| `source/mvz2/scenes/ScenePrefabInjector.hx` | 2026-10-05 17:12:14 |
| `source/mvz2/scenes/ScenePrefabLoader.hx` | 2026-10-05 **17:49:31**（类型检查之后又改） |
| `Project.xml` | 2026-10-02 19:06:12（本 agent 未改） |

---

## 2. 类型检查 + 标准构建

### 2.1 类型检查（16:46，本 agent 改动之前）

```
neko:  exit 0   [DefinitionRegistry] 候选模块=931 收录类型=932 跳过=0
cpp :  exit 0   [CoverageCheck] 模块总数=2486 类型化成功=2486 失败=0
```

模块数 **2478 → 2486**（新增注册表宏、场景 prefab 管线等文件）。

### 2.2 标准构建（16:48~16:55）

```
cd HaxePort && haxelib run lime build windows
exit 0，用时 6m24s
产物 export/windows/bin/MVZ2.exe  29,960,704 B  mtime 16:54:59  md5 38d6631abd3de104cd45f2392c2c0b3a
```

**产物 23.7 MB → 30.0 MB**：注册表宏为每个定义类发出**直接类引用**，原先被 DCE 整批删掉的
900+ 个定义/行为类现在真的进了可执行文件。

### 2.3 修复后复验（17:29，见 §4）

```
neko:  exit 0
cpp :  exit 0   [CoverageCheck] 模块总数=2486 类型化成功=2486 失败=0
lime:  exit 0
产物 export/windows/bin/MVZ2.exe  30,065,664 B  mtime 17:29:34  md5 8abe051268413693abb29a8bed01dbc3
```

> 第一次重跑构建时撞上 **PCH 竞争**（`Could not create PCH` / `c1xx: fatal error C1083`）——
> 当时另有 agent 在编译（41 个 `cl.exe`）。清理 `export/windows/obj/obj/msvc1964-nc/__pch` 后重跑即成功。
> **共享 `export/windows` 会竞争，这是已知现象。**

---

## 3. 运行结果与告警计数（核心指标）

### 3.1 告警计数对比（`tools_build/count_boot_warnings.py`）

| 告警 | 基线（10-02） | 修复前（16:55） | **修复后（17:30）** |
|---|---|---|---|
| `Trying to set a property with an invalid key!` | 16331 | 58 | **0** |
| `Property with name ... is not registered.` | 8563 | 0 | **0** |
| `Cannot find entity behaviour with ID mvz2:*` | 1986 | 311 | **0** |
| `Cannot find map element behaviour with ID mvz2:*` | 9 | 0 | **0** |
| `Cannot create property ... of type "color"` | 0 | 0 | **0** |

`boot-trace.log`：**27,013 行 → 495 行 → 129 行**（5,735 B）。

> **并发复验（17:52）**：另有 agent 在 17:48 重建了 `export/windows/bin/MVZ2.exe`
> （md5 `53630e6ed62bd444e53056eee55ec70d`，同尺寸 30,065,664 B，其后 17:49 又改了
> `DefinitionRegistryMacro.hx` / `ScenePrefabLoader.hx`）。本 agent 直接运行该最新产物复验：
> **同样是 129 行 / 四类告警全 0 / exit 139**，结论不依赖特定产物 md5。

**属性注册表宏已完全生效。** 属性键实测非 0 且互不相同
（`tools_build/verify_integration/IntegrationProbe.hx`，`--interp`）：
```
EngineEntityProps.GRAVITY=1049525  TINT=1049522  COLOR_OFFSET=1049510  FLIP_X=1049529
LogicEntityProps.UNLOCK=1049363    NAME=1049385
```

### 3.2 启动进度（release，17:30）

资源加载流水线**全部 6 个任务跑完**（修复前卡在第 4 个 `Models`）：

```
[step] GameEntrance.Start（main.Initialize + InitLoad）
[log] 加载Music Clips花费的时间：0.017
[log] 加载Sound Clips花费的时间：0.024
[log] 加载Sprites花费的时间：11.867
[log] 加载Models花费的时间：0.391        ← 修复前段错误于此
[log] 加载Map Models花费的时间：0.026
[log] 加载Area Models花费的时间：0.013
```
其后 `GameEntrance.StartGame` 调 `main.Scene.DisplayPage(MainScenePageType.Splash)` → 段错误。

### 3.3 崩溃精确点（debug 构建，`tools_build/verify_startup`，17:35）

```
[error] [4] Null Object Reference
    Called from mvz2.map.MapController.SetCameraBackgroundColor (mvz2/map/MapController.hx line 299)
    Called from mvz2.map.MapController.Hide (mvz2/map/MapController.hx line 101)
    Called from mvz2.scenes.MainSceneController.DisplayPage (mvz2/scenes/MainSceneController.hx line 175)
```

（`ErrorState` 只打印 3 层栈；`DisplayPage` 的调用者是
`GameEntrance.StartGame` 的 `main.Scene.DisplayPage(MainScenePageType.Splash)`，
`source/mvz2/scenes/GameEntrance.hx:64`。debug 下该异常被 `StartGame` 的 try/catch 捕获 →
`ShowErrorDialog` → 进程存活（`[done] GameEntrance.Start 完成`）；release 下同一处直接段错误。）

`MapController.hx:299` 是 `mapCamera.backgroundColor = color;`，`mapCamera` 是
`@:serializeField`（`MapController.hx:705`）**从未注入** —— 属**未转换的 prefab 引用**（工作包②）。

**数据是齐的**：`assets/scene_prefabs/Prefabs/Map/Map.json` 里 node 14 的
`MVZ2.Map.MapController` 组件带 `mapCamera = {n:7,c:1}`、`mapCameraShakeRoot = {n:13,c:0}`、
`modelRoot = {n:3,c:0}`。`ScenePrefabInjector.ApplyTree`（17:12 新增）正是为「手工构造的对象图」
补 `[SerializeField]` 的入口，**但尚未接入 `MainGameScene`**（全仓 grep 无引用）。

**另一条同轮 debug 日志（不致命，供参考）**：
`mvz2/supporters/SponsorManager.hx:67` 的 `GetAllSponsors` 在 `resp.Result` 为 null 时已 return，
但 `RequestSponsors` 本身抛 `Null Object Reference`（无网络），被 `InitLoad` 的赞助者任务吞掉。

---

## 4. 本轮修复：`ResourceManager.LoadModModels` 的 release 崩溃

### 4.1 症状

release 构建在资源加载的**第 4 个任务 `Models`** 段错误；debug 构建给出精确调用链：

```
[error] [4] Null Object Reference
    Called from mvz2.managers.ResourceManager.LoadModModels (mvz2/managers/ResourceManager.hx line 1359)
    Called from mvz2.managers.ResourceManager.LoadModResourcesMain (… line 265)
    Called from mvz2.managers.PipelineTask.Run (mvz2/managers/MainManager.hx line 659)
    Called from mvz2.managers.ResourceManager.LoadAllModResourcesMain (… line 130)
    Called from mvz2.managers.MainManager.InitLoad (… line 173)
```

### 4.2 根因（独立探针证实）

`ResourceManager.hx:1355` 的 `LoadLabeledResources(GameObject, nsp, "Model", progress)` 里，
`GameObject` 只是**类型参数**（Haxe 运行期无泛型）。`LoadResourcesByLocations` 的
`var res:T = cast handle.WaitForCompletion()` 实际拿到的是
`ResourceManifest.doLoad()` 对 `KIND_MODEL` 走 `default` 分支返回的 **`haxe.io.Bytes`**
（`unity/addressableassets/ResourceManifest.hx:485~490`：Unity prefab 专有格式尚未转换）。

探针 `tools_build/verify_integration/ModelLoadProbe.hx`（`--interp`）实测：
```
locate("Model", GameObject) -> 420 条定位符
  loc=mvz2:armor/bedserker_helmet kind=Model asset=haxe.io.Bytes isGameObject=false
  …（420 条全部如此）
```

于是 `pair.resource.GetComponent(Model)` 在 `Bytes` 上取方法 → cpp 直接访问违例（release）/
空引用（debug）。C# 原文（`Assets/Scripts/MVZ2/Managers/ResourceManager_Models.cs:77~88`）
没有判空，因为 Addressables 只会返回真 prefab。

**同型调用点共 3 处**（行号为修复后）：`:817` `LoadModAreaModels`（`AreaModel`）、
`:1285` `LoadModMapModels`（`MapModel`）、`:1372` `LoadModModels`（`Model`）。

### 4.3 修法（最小、与本文件既有约定一致）

同文件 `:448~458` 已确立「移植层无法还原的资源 = 无匹配资源、跳过并告警」的约定。
把同一约定从「null」扩展到「类型不是 GameObject」：

```haxe
// PORT-NOTE: 移植层 Model 标签的资源由 ResourceManifest 返回 haxe.io.Bytes
// （Unity prefab 专有格式尚未转换），不是 GameObject；C# 的 Addressables 只会返回真 prefab，
// 故原文没有这个判断。按本文件 :448 已有的约定「移植层无法还原 = 无匹配资源」跳过；
// 模型的实际创建由 ModelBuilder 经 ModelPrefabLoader 走 assets/models_manifest.json 完成。
if (!Std.isOfType(pair.resource, GameObject))
    continue;
```

**语义安全**：模型创建本来就走 `ModelBuilder.hx:38` 的 `ModelPrefabLoader.Instantiate` 回退路径
（`modResource.Models` 通常为空），`GetModel` 的消费方也都容忍 null。守卫只是让该分支
真正走到回退，而不是在 Bytes 上崩溃。

### 4.4 复验

- neko / cpp 类型检查 **exit 0**；
- 标准构建 **exit 0**，产物 md5 `8abe051268413693abb29a8bed01dbc3`；
- release 运行：告警**四类全 0**、资源流水线**6 个任务全跑完**、卡点从
  `Models` 任务推进到其后的 `DisplayPage(Splash)`。

---

## 5. 跨域问题（需要别的 agent / 决策者配合）

### 5.1 `MapController.mapCamera` 等 `[SerializeField]` 无注入（当前 release 卡点）

（同类问题在启动链路已被逐个修过：`MainSceneUI.dialog`、`InputNameDialogController.ui`、
`MainSceneController.uiCamera` 等，见 `boot_findings.md` §一.9~14；`mapCamera` 是剩下的一处。）

- 精确点：`mvz2/map/MapController.hx:299`（`mapCamera` 空引用），触发链见 §3.3。
- 数据齐备：`assets/scene_prefabs/Prefabs/Map/Map.json` 的 node 14 带 `mapCamera = {n:7,c:1}`。
- **建议归属**：工作包②（场景/prefab 管线）。`ScenePrefabInjector.ApplyTree`（17:12 落地）就是
  为这类「手工构造的对象图」补字段的入口，**接入 `MainGameScene` 即可**：
  `ScenePrefabInjector.ApplyTree(mainScene, "Prefabs/Map/Map")` 之类。
- 同类未注入字段还有一批（`MainGameScene.build*` 手写的对象图），
  `boot_findings.md` §六.6 已记录「两套来源并存」的隐患，建议一并切换。

### 5.2 `mvz2:entity_physics` 的 310 条告警：**注册表宏的次类型命名缺陷**（已由宏 agent 修）

**权威解释见 `tools_build/registry_macro_findings.md` §「缺陷 D」**（本 agent 独立复核后采用）：
宏的 `classPath()` 对**次类型**发出的是 `pack.Module.Type`，而 Haxe 运行期
`Type.getClassName(cls)` 是 `pack.Type`（不含模块名）；`DefinitionRegistry.getRecordOfClass()`
正是拿 `Type.getClassName` 查表，于是这 6 个次类型的 `defs`/`region`/`fields` 全部丢失：

| 记录名（宏发出） | 运行期类名 | 后果 |
|---|---|---|
| `mvz2.gamecontent.entities.EntityPhysicsBuff.EntityPhysicsBehaviour` | `…entities.EntityPhysicsBehaviour` | **`mvz2:entity_physics` 未注册（310 条告警）** |
| `…helditems.BlueprintHeldItemBehaviour.ClassicBlueprintHeldItemBehaviour` | `…helditems.ClassicBlueprintHeldItemBehaviour` | held_item_behaviour 缺失 |
| `…BlueprintHeldItemBehaviour.ConveyorBlueprintHeldItemBehaviour` | `…helditems.ConveyorBlueprintHeldItemBehaviour` | 同上 |
| `…options.ShowHotkeysOptionToggle.ShowHotkeysOptionsToggle` | `…options.ShowHotkeysOptionsToggle` | option_widget 缺失 |
| `…stages.RedstoneStageBehaviour.RedstoneDropStageBehaviour` | `…stages.RedstoneDropStageBehaviour` | stage 缺失 |
| `mvz2logic.maps.LogicEntityProps.LogicMapElementProps` | `mvz2logic.maps.LogicMapElementProps` | mapElement 区域属性未注册 |

修法：记录里把「类引用路径」与「运行期名字」分开（`name` 用 `pack.Type`），
并在 `getRecordOfClass` 加后缀匹配兜底。**实测修后 `nameMismatch=0`。**

**本 agent 的独立复核**：`EntityPhysicsBehaviour extends EntityBehaviourDefinition`，
`DefinitionGroup.Add` 按 **`definition.GetDefinitionType()`** 分组（不是按 attribute 的 Type），
`EntityBehaviourDefinition.GetDefinitionType()` 返回 `ENTITY_BEHAVIOUR`
（`source/pvzengine/entities/EntityBehaviourDefinition.hx:62~65`，与 C#
`Assets/Scripts/Engine/Level/Entities/EntityBehaviourDefinition.cs:54` 的 `sealed override` 一致），
所以它**本来就该归入 `entity_behaviour` 组**。探针
`tools_build/verify_integration/EntityPhysicsProbe.hx`（`--interp`）实测：
```
id=mvz2:entity_physics definitionType=entity_behaviour
查 entity_behaviour -> mvz2.gamecontent.entities.EntityPhysicsBehaviour
查 buff            -> null
```

**因此 310 条的消失与 `LoadModModels` 的修复无关**（那条崩溃发生在资源加载阶段，
在这些告警打印之后），而是宏的次类型命名修好的连带结果。

### 5.3 `IsAbstract` 恒为 false（语义隐患，非当前阻塞）

`DefinitionRegistry` 的 `isAbstract` 字段 932 条记录里 0 条为 true，
宏读 `// abstract` 注释的路径未命中（`Context.getClassPath()` 与 `cls.module` 拼接在 lime 构建下不成立）。
**当前工程不受影响**：带定义元数据的类共 868 个、其中 abstract 的 0 个。
属「将来新增抽象定义类会被错误实例化」的隐患，建议宏 agent 修（`registry_audio_findings.md` §4.3）。

### 5.4 `resources` 的类型参数在移植层不成立（本类 bug 的通用模式）

Haxe 无运行期泛型，`LoadLabeledResources<T>` 的 `T` 只在编译期存在。
**凡是用 `LoadLabeledResources(GameObject, …)` 再 `GetComponent` 的调用点都要有类型守卫**。
本轮已补全 3 处（`Model`/`AreaModel`/`MapModel`）；若将来新增同类标签，注意同一陷阱。

---

## 6. 本轮新增/修改文件

| 文件 | 类型 | 说明 |
|---|---|---|
| `source/mvz2/managers/ResourceManager.hx` | **改** | 3 处 `Std.isOfType(pair.resource, GameObject)` 守卫（§4.3） |
| `tools_build/count_boot_warnings.py` | 新增 | boot-trace 告警计数工具（工作包④） |
| `tools_build/verify_integration/IntegrationProbe.hx` | 新增 | 属性键链路探针（复刻 MainManager + ModLoader 两条注册链） |
| `tools_build/verify_integration/ModelLoadProbe.hx` | 新增 | Model 标签资源类型探针（证实返回 Bytes） |
| `tools_build/verify_integration/EntityPhysicsProbe.hx` | 新增 | 确认 `entity_physics` 按 `GetDefinitionType()` 归入 `entity_behaviour` |
| `tools_build/integration_work_round2.md` | 新增 | 本轮分段工作记录（含逐步证据） |
| `tools_build/integration_report.md` | 改 | 本文件 |
| `PORTING.md` | 改 | 「构建与验证」：模块数 2486、告警基线表、count_boot_warnings 用法、注册表宏结论 |

---

## 7. 复现命令

```bash
cd HaxePort

# ① 三阶段（neko → cpp → 标准构建 → 运行 + boot-trace 末尾）
python tools_build/verify_release.py

# ② 告警计数（判断属性注册表是否生效）
python tools_build/count_boot_warnings.py
python tools_build/count_boot_warnings.py --json export/windows/bin/boot-trace.log

# ③ 属性键链路探针（需非 0 且互不相同）
haxe -cp source -cp tools_build/verify_integration -lib flixel -lib flixel-addons -lib flixel-ui \
  -lib lime -lib openfl -lib hscript -lib hxjsonast -lib json2object \
  -main IntegrationProbe --interp -D lime_use_old_deltatime \
  --macro "flixel.system.macros.FlxDefines.run()"

# ④ Model 标签资源类型探针（应看到 asset=haxe.io.Bytes isGameObject=false）
haxe -cp source -cp tools_build/verify_integration -lib flixel -lib flixel-addons -lib flixel-ui \
  -lib lime -lib openfl -lib hscript -lib hxjsonast -lib json2object \
  -main ModelLoadProbe --interp -D lime_use_old_deltatime \
  --macro "flixel.system.macros.FlxDefines.run()"

# ⑤ 崩溃精确定位（debug，隔离工程）
cd tools_build/verify_startup && bash setup.sh && haxelib run lime build windows -debug
bash run.sh 60 && grep -A 6 "Null Object Reference" export/windows/bin/boot-trace.log | tail -20
```

---

## 8. 未完成项

- [ ] **release 不崩**：当前卡点 `MapController.hx:299`（§5.1），需工作包②把
      `ScenePrefabInjector.ApplyTree` 接入 `MainGameScene`。
- [ ] **用户可见画面**：`unity/ui/*` 仍是逻辑 shim（无渲染层），启动全绿后画面仍为纯黑。
- [ ] **`%TEMP%/mvz2_cppfix` 覆盖层**：`probe_startup.py` 留下的过期副本；
      用 `verify_build` 前先 `python tools_build/make_cpp_overlay.py` 重建或删除。
- [ ] **`IsAbstract` 恒 false**：宏 agent 修（§5.3）。
