# 启动链路排查进度（工作包：启动链路续推）

> 每推进 1~2 处就更新本文件，避免上下文/超时丢进度。
> 隔离验证工程：`HaxePort/tools_build/verify_startup/`（= HaxePort/Project.xml 的副本，只把
> source/icon 改成相对路径、去掉 943MB 的 `<assets>`，不含任何 cpp 覆盖层）。
> `bash setup.sh` 建 `export/windows/bin/assets` 目录联接；`bash run.sh [秒数]` 跑 + 打印 boot-trace 末尾。

---

## 0. 交接点（2026-10-05 本轮开工时的实际状态）

上一轮（2026-10-02 21:xx）写下的 §六 之后，**`MainGameScene.hx` 在 21:54 又改过一次**（改用
`AudioManifest.mainMixer`），但那次改动**没有跑过构建**：`source/mvz2/states/MainGameScene.hx:257/271`
引用了 `AudioManifest`，文件顶部却没有 `import mvz2.audios.AudioManifest;`。

**所以本轮开工时仓库处于「构建红」状态**（`verify_startup` + `haxelib run lime build windows` 都报
`Type not found : AudioManifest`）。先修掉这一处（见 §一.0），基线才回到可验证。

---

## 一、已修复

### 本轮（2026-10-05）

| # | 文件:行 | 症状 | 修法 |
|---|---|---|---|
| 0 | `HaxePort/source/mvz2/states/MainGameScene.hx:21` | 构建直接失败：`MainGameScene.hx:257/271 characters 18-31 : Type not found : AudioManifest`。上一轮 21:54 的改动用了 `AudioManifest.mainMixer` 但漏了 import，此后没跑过构建 | 补 `import mvz2.audios.AudioManifest;` |

### 上一轮（2026-10-02，保留备查）

| # | 文件:行 | 症状（C# 原语义） | 修法 |
|---|---|---|---|
| 1 | `MainGameScene.hx:397` | `MainManager.scene` 全仓无赋值 → `PerformanceManager.hx:61` 空引用 | 在 `buildMainScene()` 末尾补 `mainManager.scene = sceneController;`。**本轮已复核存在**，且对照 `Assets/Prefabs/MainGame.prefab` 的 `MainScene` 对象（fileID 851195532773048538）上的 `MainSceneController`（fileID 127843766599020872）逐字验证一致 |
| 2 | `MainGameScene.hx:246~283` | `SoundManager.mixer/soundSourceRoot/...` 5 个 prefab 引用未注入 → `SoundManager.SetGlobalVolume` 空引用 | 按 `MainManager.prefab` 重建 |
| 2b | 同上 | `music.mixer = new AudioMixer("MusicMixer")` 与 prefab 不符 | 改为 `AudioManifest.mainMixer`（本轮已复核） |
| 3 | `MainGameScene.hx:376~384` | `FPSDisplayer.rectTransform`/`fpsText` 未注入 → 每秒 `SetFPS` 空引用 | 新建 RectTransform + 子对象 Text 的 TextMeshProUGUI |
| 4 | `MainSceneState.hx:42~46,89~106` | `ShowErrorDialog` 会把异常吞掉 | `startAll()` 后把 `StartupError.all` 全量落盘 |
| 5 | `BootTrace.hx:43~52` | `finish()` 会 `close()` 句柄，之后的错误写不进去 | `finish()` 只 flush 不 close |
| 6 | `MainGameScene.hx:131~165` | 组件 Update/协程抛异常会冒到 FlxGame | 逐组件 try/catch 隔离 |
| 7 | `Main.hx:31~53` | 无法区分"进程活着"与"FlxState.update 真被调用" | stage 上挂 ENTER_FRAME 心跳 |
| 8 | `MainSceneState.hx:60~84` | `MainSceneState.update` 自身无 try/catch | 包 try/catch 并落盘 |
| 9 | `MainGameScene.hx:349~356`（新增 `buildDialog()`，`:519~560`） | `MainSceneUI.dialog` 未注入 → `MainSceneUI.hx:32` 空引用（本轮实测的**第一个真实崩点**，见 §三.1） | 按 `Assets/Prefabs/UI/Dialogs/CustomDialog.prefab` 重建对象图并注入。层级/引用逐条对照 prefab：`Root`=dialogTransform、`Title`/`Desc` 的 TextMeshProUGUI、`Buttons` 上的 `ElementListUI`（`_listRoot`/`_template`）、`ButtonRow` 上的 `ElementList`+`ButtonRow`、`TextButton` 上的 `TextButton`+`Text`+`Button`。**三个对话框共用一个 `Dialogs` 父节点**（与 MainGame.prefab 一致：该节点下挂 3 个实例） |
| 10 | `source/unity/Transform.hx:57~66` | **shim 缺陷（跨域，见 §六.5）**：Unity 的 `Transform.transform` 返回自身，但 shim 的 `Component.transform` 是普通字段，`Transform` 构造时从不自赋值 → 任何 `someTransform.transform` 都是 null。实测崩点 `ElementListUI.hx:18` 的 `_template.transform.parent`（修掉 9 之后立刻暴露） | 在 `Transform.new()` 里 `this.transform = this;` |
| 11 | `source/unity/UnityObject.hx:37~53`（重写，新增 `:56~200` 的深拷贝辅助） | **shim 缺陷（跨域，见 §六.2）**：`Instantiate` 只 `new GameObject + AddComponent(Type.getClass(original))`，克隆体上所有 `@:serializeField` 都是 null。实测崩点 `CustomDialog.SetDialog → ElementListUI.updateList → CreateItem → rect.GetComponent(ButtonRow)` 返回 null → `CustomDialog.hx:42` 空引用 | 重写为 Unity 语义的**整棵子树深拷贝**：复制节点（name/active/layer/tag + Transform/RectTransform 布局）、每个节点的全部组件（同类型同顺序）、以及可序列化值类别的字段（Bool/Int/Float/String/Array/UnityObject），并把指向子树内部的引用重映射到克隆体。**这一处同时解掉 §六.2 里 SoundManager / TalkManager / 各种列表模板的隐患** |
| 12 | `MainGameScene.hx:416~417`（新增 `buildInputNameDialog()` / `buildDeleteUserDialog()`，`:593~700`） | `InputNameDialogController.ui` / `DeleteUserDialogController.ui` 未注入 → `InputNameDialogController.hx:15 ui.ResetPosition()` 空引用（存档损坏分支必经） | 按 `Assets/Prefabs/UI/Dialogs/InputNameDialog.prefab` / `DeleteUserDialog.prefab` 重建对象图并注入 |
| 13 | `MainGameScene.hx:332~341` | `MainSceneUI.blackscreenImage` 未注入 → `MainSceneUI.hx:85` 的 `blackscreenImage.color = value` 空引用（`SetScreenCoverColor` / `FadeScreenCoverColor` 触发，见章节切换、IZombie 开始） | prefab 里 ScreenCover 节点（4077540474257370161）上 Image 与 ColorFader 是**两个组件**，同一节点上各挂一个 |
| 14 | `MainGameScene.hx:354~367` | `MainSceneController.uiCamera` 未注入 → `MainSceneController.hx:317` 的 `uiCamera.ScreenToWorldPoint(...)` 空引用；`CameraLimiter._camera` 同样是 prefab 引用 | 按 `Assets/Prefabs/Camera.prefab` 建一个 Camera 实例；`uiCamera` 与 `uiCameraLimiter._camera` 指向**同一个**实例（对照 MainGame.prefab 的 `1519143245969430927` / `4198902581164152378` 与 Camera.prefab 的 `_camera: 8695281478793315978`，三者同源） |

---

## 二、prefab 序列化引用核对结论（本轮复核）

`Assets/Prefabs/Init/MainManager.prefab` 里 MainManager 组件的 24 个对象引用 =
`coroutine/resource/model/sound/music/level/lang/save/mod/cursor/shake/file/fontManager/options/resolution/sceneLoadingManager/almanacManager/storeManager/inputManager/sponsorManager/graphicsManager/debugManager/performanceManager/talkManager`
（+ `builtinNamespace="mvz2"`、`fastMode=1`）。

**结论：24/24 已全部注入**（23 个在 `MainGameScene.buildManagers()`，`scene` 在 `buildMainScene()`）。
本轮再次逐条比对 `MainManager.cs` 的 `[SerializeField]` 字段列表与 `buildManagers()` 的赋值行，无遗漏。

`MainSceneController` 侧本轮新增核对（`MainGame.prefab` fileID 127843766599020872）：

```
uiCamera: 1519143245969430927   uiCameraLimiter: 4198902581164152378   ui: 4113767335989909255
splash/titlescreen/mainmenu/note/map/portal/chapterTransition/almanac/store/archive/addons/
musicRoom/arcade/keybinding/credits/achievementHint/popup/fpsDisplayer/debugConsole/
inputNameDialog/deleteUserDialog
```

`MainGameScene.buildMainScene()` 里 22/23 已注入；**唯一缺 `uiCamera`**（见 §五.2）。

顺带核对 `MainSceneUI` 组件（fileID 4113767335989909255）的 5 个引用：

```
tooltip: 3769618580586818851   dialog: 6257896535643423245   blackscreenImage: 3413564443117529296
screenCoverFader: 3657868704250761626   debugConsoleIcon: 7502026848991266976
```

`buildMainScene()` 只注入了 `screenCoverFader`/`debugConsoleIcon`/`tooltip`，**`dialog` 与 `blackscreenImage`
未注入**——`dialog` 就是本轮实际崩点（见 §三.1）。

---

## 三、实测结果

### 3.1 本轮实际崩点：`MainSceneUI.dialog` 未注入

debug 构建（`verify_startup`，2026-10-05 14:17 产物）实测 boot-trace 末尾：

```
[step] [log] 无法读取用户0的MODmvz2的存档或任何备份，创建一个新存档。
[step] [log] 存档加载失败：Object does not implement interface
[error] MainSceneState.create 抛出：Null Object Reference
[error] 启动失败详情：
Null Object Reference

Called from mvz2.ui.scene.MainSceneUI.ShowDialogTask (mvz2/ui/scene/MainSceneUI.hx line 32)
Called from mvz2.ui.scene.MainSceneUI.ShowDialog (mvz2/ui/scene/MainSceneUI.hx line 27)
Called from mvz2.scenes.MainSceneController.ShowDialog (mvz2/scenes/MainSceneController.hx line 67)
Called from mvz2.scenes.MainSceneController.ShowDialogMessage (mvz2/scenes/MainSceneController.hx line 73)
Called from mvz2.scenes.MainSceneController.ShowDialogMessageAsync (mvz2/scenes/MainSceneController.hx line 81)
Called from mvz2.scenes.GameEntrance.CheckSaveDataStatus (mvz2/scenes/GameEntrance.hx line 126)
Called from mvz2.scenes.GameEntrance.Start (mvz2/scenes/GameEntrance.hx line 30)
Called from mvz2.states.MainGameScene.startAll (mvz2/states/MainGameScene.hx line 130)
```

`MainSceneUI.hx:32` 是 `dialog.gameObject.SetActive(true);`，`dialog` 是 `@:serializeField` 字段，
移植层从未赋值 → 空引用。**这是 §一.0 修掉构建后、启动链路走到的第一个真实崩点。**

同时可见启动链路的**真实进度**已经比交接描述更远：`GameEntrance.Start` 已经不再提前 return
（上一轮 §六.3 的 `Task.completedTask()` bug 已修），现在真的执行到了
`CheckSaveDataStatus()`（`GameEntrance.hx:30`）。

### 3.2 release 构建实测（2026-10-05 15:12，修完 §一.9~14 之后）

`verify_startup` release 产物（`haxelib run lime build windows`，23,757,312 B，15:08）：

```
=== MVZ2.exe 已退出，exit code=139 ===
… boot-trace 末行：
[step] [log] Cannot find entity behaviour with ID mvz2:fadeout_by_timeout
[step] [log] 无法读取用户0的MODmvz2的存档或任何备份，创建一个新存档。
```

**关键：release 的卡点位置与 debug 的第 5 轮完全一致**（都停在 `CreateNewUser → SetCurrentUserIndex →
LoadUserData → EvaluateUnlockedEntities → MVZ2SaveExt.hx:12`）。
debug 下这条是"可捕获的接口分派失败"（被 `LoadInitialUserData` 的 catch 吞掉 → 状态变
`AllCorrupted` → 走建新存档分支），release 下同一非法接口指针直接访问违例。

**结论：启动链路本身已经打通到"用户存档初始化"这一步，剩下的唯一 release 崩溃点就是 §四 的属性注册缺失。**
**结论：启动链路本身已经打通到"用户存档初始化"这一步，剩下的唯一 release 崩溃点就是 §四 的属性注册缺失。**

### 3.3 本轮推进轨迹（每修一处就重跑 debug 构建）

| 轮次 | boot-trace 里的崩溃点 | 根因 | 修法 |
|---|---|---|---|
| 1 | `MainSceneUI.ShowDialogTask (MainSceneUI.hx:32)` `dialog.gameObject.SetActive` | `MainSceneUI.dialog` 从未注入 | 新增 `MainGameScene.buildDialog()`（§一.9） |
| 2 | `ElementListUI.updateList (ElementListUI.hx:18)` `_template.transform.parent` | **shim 缺陷**：`unity.Transform` 的 `transform` 字段从不自赋值 | `Transform.new()` 里 `this.transform = this`（§一.10） |
| 3 | `CustomDialog.SetDialog (CustomDialog.hx:42)` `rect.GetComponent(ButtonRow)` 返回 null | **shim 缺陷**：`UnityObject.Instantiate` 不拷贝模板组件/字段 | 重写 `Instantiate` 为整棵子树深拷贝（§一.11） |
| 4 | `InputNameDialogController.Show (InputNameDialogController.hx:15)` `ui.ResetPosition()` | `InputNameDialogController.ui` / `DeleteUserDialogController.ui` 未注入 | 新增 `buildInputNameDialog()` / `buildDeleteUserDialog()`（§一.12） |
| 5 | `MVZ2SaveExt.IsNullOrMeetsConditions (MVZ2SaveExt.hx:12)` `Object does not implement interface` | **§四 的跨域根因**（属性键全 0），非本包可修 | — |

**第 5 轮的调用链（本轮最终实测）**：

```
[step] [log] 无法读取用户0的MODmvz2的存档或任何备份，创建一个新存档。
[step] [log] 存档加载失败：Object does not implement interface      ← 第 1 次，被 LoadInitialUserData 的 catch 吞掉
[step] [log] 无法读取用户0的MODmvz2的存档或任何备份，创建一个新存档。   ← CreateNewUser → SetCurrentUserIndex
[error] MainSceneState.create 抛出：Object does not implement interface
Called from mvz2.saves.MVZ2SaveExt.IsNullOrMeetsConditions (mvz2/saves/MVZ2SaveExt.hx line 12)
Called from mvz2.saves.SaveManager.EvaluateUnlockedEntities (mvz2/saves/SaveManager.hx line 558)
Called from mvz2.saves.SaveManager.EvaluateUnlocks (mvz2/saves/SaveManager.hx line 518)
Called from mvz2.saves.SaveManager.LoadUserData (mvz2/saves/SaveManager.hx line 174)
Called from mvz2.saves.SaveManager.SetCurrentUserIndex (mvz2/saves/SaveManager.hx line 600)
Called from mvz2.scenes.GameEntrance.CheckSaveDataStatus (mvz2/scenes/GameEntrance.hx line 130)
Called from mvz2.scenes.GameEntrance.Start (mvz2/scenes/GameEntrance.hx line 30)
Called from mvz2.states.MainGameScene.startAll (mvz2/states/MainGameScene.hx line 142)
```

**这说明启动链路本身已经全通了**：`GameEntrance.Start` 依次跑完
`main.Initialize()`（全部管理器 + MOD 资源）→ `CheckSaveDataStatus()`（存档损坏 → 弹对话框 →
`CreateNewUser` → `SetCurrentUserIndex`）。剩下的**唯一**障碍就是 §四 的属性注册缺失——
它让 `EvaluateUnlockedEntities` 读出的 `unlock` 属性拿到别的属性的值（一个非 `IConditionList`
的对象），在 `MVZ2SaveExt.hx:12` 被当接口调用。

**`release` 构建的 exit 139 也是这一处**（debug 下是"可捕获的接口分派失败"，release 下没有空指针
检查 → 同一非法指针直接访问违例）。**本工作包能修的部分到此为止。**


见 §五.1 —— 根因是属性键全 0 导致的 `Object does not implement interface`，
debug 下被 `SaveManager.LoadInitialUserData` 的 catch 吞掉（`存档加载失败：...`），release 下直接段错误。

---

## 四、根因诊断（本轮新增，含证据）

### 4.1 属性注册完全没发生 → 所有 PropertyMeta 的 key 都是 0

证据链（全部可在源码里复现）：

1. `HaxePort/source/mvz2/LandingSceneController.hx:31~39` 用
   `system.reflection.Assembly.GetAssembly(VanillaMod/LogicMain)` 造两个"程序集"占位，
   交给 `ModLoader.Load(mod, assemblies)`。
2. `HaxePort/source/mvz2/modding/ModLoader.hx:135~142` 的 `AssemblyGetTypes()` 通过
   `Reflect.field(assembly, "GetTypes")` 调方法；而 `HaxePort/source/system/reflection/Assembly.hx`
   **只有 name / GetAssembly / GetExecutingAssembly 三个成员，没有 `GetTypes`** →
   `Reflect.field` 返回 null → `return []`。
3. 于是 `ModLoader.hx:169~170` 的 `PropertyMapper.InitPropertyMaps(nsp, types)` 遍历空数组 →
   `PropertyMapper.InitTypePropertyMaps` 从不执行 → 所有 `PropertyMeta<T>` 都停在
   `PropertyKey<T>(0,0,…)` 的 `key == 0`。
4. `HaxePort/source/pvzengine/PropertyDictionary.hx:18~70` 的存储是 `Map<Int, Dynamic>`，
   键就是 `key.Key` → **所有属性共用 0 号槽位、互相覆盖**。
5. 实测计数（`verify_startup/export/windows/bin/boot-trace.log`）：
   - `Trying to set a property with an invalid key!` **16331 条**
     （`PropertyDictionary.hx:29~32` 的 `if (key.Key == 0)` 告警，直接证明 4.）
   - `Property with name ... is not registered.` **8563 条**
     （`PropertyMapper.hx:178`，证明注册表里一个全名都没有）
   - `Cannot find entity behaviour with ID mvz2:*` **1986 条**
     （`EntityDefinition.hx:78`，因为 behaviour 定义靠 `AssemblyGetTypes` 扫描
     `@:autoEntityBehaviourDefinition(...)` 注册，扫描列表为空 → 全部缺失）
   - `Property registry metadata of type ... is not available at runtime` **0 条**
     —— 说明**连 `PropertyMapper.InitTypePropertyMaps` 都没进去过**（否则每个类型都会告警一次）。
     这是 4.3 的最强证据。

同一根因还解释了：`AssemblyHasCustomAttribute(..., "ModGlobalCallbacksAttribute")`、
`AssemblyGetCustomAttributes(..., "DefinitionAttribute")` 恒为 false/[]。

**这条根因不在本工作包目录内**（属 modding / core shim 工作包），见 §六.1。

### 4.2 `MainManager.hx:308` 的兜底调用也是空表

```
HaxePort/source/mvz2/managers/MainManager.hx:308
    PropertyMapper.InitPropertyMaps(BuiltinNamespace, []);
```

注释写着"Haxe 无等价反射清单，改由各逻辑模块自行注册"，但**全仓没有任何模块真的调用
`InitTypePropertyMaps`**（grep `InitTypePropertyMaps` 只有 `PropertyMapper.hx` 自己的定义和
`InitPropertyMaps` 的循环）。所以这条兜底也是空转。

### 4.3 编译期元数据完全没被采集

`PropertyMapper.hx:12~37` 的注释已经写明了：
调用点写的是 `@:propertyRegistryRegion(...)`（带冒号 = 编译器元数据），运行期 `haxe.rtti.Meta` 读不到。
同理 `@:autoXxxDefinition(...)` 也只存在于编译期。

工程里现有元数据规模（`grep -rho '@:[a-zA-Z]*Definition[a-zA-Z]*' source/`）：

```
368 @:autoEntityBehaviourDefinition     195 @:autoBuffDefinition
 44 @:autoStageDefinition                35 @:autoIZombieLayoutDefinition
 29 @:randomChinaEventDefinition         27 @:autoArtifactDefinition
 26 @:autoOptionWidgetDefinition         20 @:autoCommandDefinition
 19 @:autoHeldItemBehaviourDefinition    15 @:autoShellDefinition
 14 @:autoPlacementDefinition            13 @:autoHeldItemDefinition
  9 @:autoAreaDefinition                  8 @:autoNoteDefinition
  7 @:autoSeedOptionDefinition            7 @:autoGridDefinition
  5 @:autoArmorBehaviourDefinition        4 @:autoRechargeDefinition
  3 @:autoMapElementBehaviourDefinition   2 @:autoSpawnDefinition
```

**共 850+ 个定义类需要被扫描注册。** 这些只能在宏里用 `Context.getModule` 遍历 + `Context.getType`
读 `@:autoXxxDefinition` 的 `metadata` 拿到（`@:` 元数据在宏里是可见的）。

---

## 五、下一步（按优先级）

> 本工作包能修的启动链路空引用已经全部修完（§一.9~14）。以下剩余项**都被跨域根因挡住**或需要别的
> 工作包配合。

1. **【阻塞，非本包】属性注册 / 定义扫描缺失**（§四、§六.1）。这是 release exit 139 的唯一剩余根因，
   也是"看起来能跑、实际语义全错"的来源。**必须在它修掉之后**，启动链路才能继续往
   `StartGame()`（`main.InitLoad()` / `DisplayPage(Splash)` / 主题曲）走。
2. `ModelManager.modelShotRoot/modelShotPositionTransform/modelShotCamera`、`TalkManager.portraitRoot/portraitPrefab`
   仍未注入（§二 上一轮表格）。这两处依赖 §六.3 的渲染层与 §六.4 的相机决策，
   在启动链路不经过（模型截图/立绘预览），列为后续。
3. `unity.Transform` 的 `.transform` 自赋值（§六.5）只覆盖了构造函数路径；
   若后续有用 `Type.createEmptyInstance` 造 Transform 的地方需要单独处理。
4. **`MainSceneUI.dialog` 等对话框对象图目前是手写的**（`buildDialog` / `buildInputNameDialog` /
   `buildDeleteUserDialog`）。工作包②的 `ScenePrefabLoader`（`source/mvz2/scenes/ScenePrefab*.hx`，
   本轮期间正在并行开发）已经能按 `assets/scene_prefabs/scenes/Main.json` 重建整棵场景树——
   **场景转换正式接入后，这三处手写对象图应当删除，改由 prefab 数据注入**，
   否则两套来源会互相冲突（手写图缺 prefab 里的真实布局/字段值）。

## 六、跨域缺陷（需要别的 agent / 决策者配合）

1. **【最高优先级】属性注册 / 定义扫描整体缺失**（详见 §四.1~4.3）。
   **本轮实测确认：这是 release `exit 139` 的唯一剩余根因**（§3.2）。需要：
   - 给 `source/system/reflection/Assembly.hx` 补 `GetTypes/IsAbstract/HasCustomAttribute/GetCustomAttributes/InvokeConstructor`；
   - 数据源由**编译期宏**生成（像 `verify/coverage/CoverageCheck.run()` 那样 `Context.getModule` 遍历
     `source/` 全部模块，收集 `@:autoXxxDefinition(...)` / `@:ModGlobalCallbacksAttribute` /
     `@:propertyRegistryRegion(...)` / `@:propertyRegistry(...)`；`@:` 元数据只在宏里可见，
     运行期 `haxe.rtti.Meta` 读不到——这一点本轮又实测确认了一遍）。
   - **宏的接线点是本任务最难的一环**：真实构建的 `hxml` 里只有
     `--macro lime._internal.macros.DefineMacro.run()` / `--macro openfl.utils._internal.ExtraParamsMacro.include()`
     / `--macro flixel.system.macros.FlxDefines.run()` / `--macro keep("Main")`，
     而 `Project.xml` 明确不允许改。本轮实测：**Haxe 不会自动读取 classpath 目录或工作目录里的
     `extraParams.hxml`**（`-cp src` 与 cwd 两种写法都验证过，`-D` 没有生效）。
     可行的接线点有三个，需要决策者定：
     a) 在 `source/` 里放一个已有模块，让 `Main` 通过 `--macro` 之外的方式触发（如 `@:build` 宏挂在
        `MainManager` 上）——不需要改 Project.xml；
     b) 由 `lime build` 的 `--macro` 追加（需要改 Project.xml，被明令禁止）；
     c) 改成**运行期注册表**：不用宏，而是让每个定义类自己在一张表里登记（工作量大但无接线问题）。
   - 影响的文件（跨域，非本包）：`source/system/reflection/Assembly.hx`、
     `source/mvz2/modding/ModLoader.hx:131~170`、`source/mvz2/managers/MainManager.hx:308`、
     `source/pvzengine/PropertyMapper.hx:10~97`。
   - 判据：修好后 boot-trace 里 `Trying to set a property with an invalid key!`（现 16331 条）、
     `Property with name ... is not registered.`（现 8563 条）、
     `Cannot find entity behaviour with ID mvz2:*`（现 1986 条）应当**大幅下降或归零**。
2. **`unity.UnityObject.Instantiate` 不复制序列化字段**（`source/unity/UnityObject.hx:44~51`）。
   **本轮已修**（§一.11）：改成整棵子树深拷贝 + 引用重映射。已知残余差异写在代码的 PORT-NOTE 里：
   只复制 `null/Bool/Int/Float/String/Array/UnityObject` 值类别，结构体包装类型
   （`unity.Color/Vector2/Vector3` 等 abstract over class）保持构造函数默认值，
   `FlxSignal`/`UnityEvent` 保持克隆体自己的实例（Unity 本来也不序列化事件）。
   受影响调用点已不再崩：`SoundManager.hx:46/76`、`TalkManager.hx:53`、
   `ElementListUI/ElementList/ElementArray.CreateItem`、`HPBarCanvasController`、`MovingBlueprintList` 等。
   **注意**：`LevelController.hx:351/1888`、`MapController.hx:181`、`ModelBuilder.hx:32` 等
   原本依赖"Instantiate 返回近似空对象"的路径现在会真的深拷贝模板，
   需要别的 agent 在关卡/模型链路回归时确认语义（Unity 本来就是这个行为，理论上更正确）。
3. **没有把 `unity.GameObject` 层级渲染到 flixel 显示列表的层**（`unity/ui/*` 全是逻辑 shim，
   `Graphic.Rebuild()` 空实现）。即使启动全绿，画面也是纯黑 → **"用户可见界面"被
   "prefab UI → 渲染层"的资源/转换缺口挡住**。这是工作包②（关卡/UI 场景与 prefab 序列化数据）的范畴。
4. `ModelManager.modelShotCamera` / `MainSceneController.uiCamera` 都依赖"场景里真的存在一个 Camera 对象"。
   **`MainSceneController.uiCamera` 本轮已按 `Assets/Prefabs/Camera.prefab` 造出实例并注入**
   （§一.14）；`ModelManager.modelShotCamera` 仍未注入（不在启动链路）。
   长期看需要决策：继续用 `unity.Camera` shim 还是把这些路径改成 flixel FlxCamera 等价物。
5. **`unity.Transform` 的 `transform` 字段从未自赋值**（`source/unity/Transform.hx`，**本轮已修**）。
   Unity 语义：`Transform` 是 `Component`，`transform.transform` 返回自身。
   shim 里 `Component.transform` 是普通可写字段，`GameObject` 构造时会给自己挂的默认 Transform
   赋 `transform`（`GameObject.hx:19~21`），但**那个 Transform 自己**的 `transform` 仍是 null。
   实测后果：`ElementListUI.hx:18` 的 `_template.transform.parent` 空引用。
   同类风险：全仓有 124 处 `.transform` 读取，任何对"Transform 实例本身"调用 `.transform` 的路径都会崩。
   本包已修（`Transform.new()` 里自赋值），但**凡是绕过构造函数创建的 Transform**
   （`Type.createEmptyInstance` 等）仍需要各自注意。
6. **`MainGameScene.hx` 与工作包②的 `ScenePrefabLoader` 存在职责重叠**（见 §五.4）。
   `source/mvz2/scenes/ScenePrefabLoader.hx` / `ScenePrefabInjector.hx` 本轮期间由另一 agent 并行新增
   （文件时间戳 14:48~14:51），`verify/scenes/ScenePrefabSmokeMain.hx` 是其自检。
   `ScenePrefabInjector` 的设计目标正是"给手工构造的对象图补 [SerializeField]"，
   但**它没有接入 `MainGameScene`**（grep 无引用）。建议：场景转换正式接入时，
   由 `ScenePrefabInjector` 或 `ScenePrefabLoader.InstantiateScene("Main", ...)` 取代
   `MainGameScene` 的手写 `build*()`，两边不要长期并存。
