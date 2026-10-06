# 关卡/UI prefab 序列化数据管线 —— 调查笔记

工作包：② 关卡/UI prefab 序列化数据管线。
只记录事实（附证据行号），结论在最后。分段追加。

## 1. 现状：移植层只有「模型 prefab」有数据来源

- `tools_build/build_models.py` → `assets/models_manifest.json` + `assets/model_prefabs/**/*.json`。
- 运行期 `mvz2/models/ModelPrefabLoader.hx`（+ `ModelPrefabData` / `ModelPrefabContext` /
  `ModelPrefabFieldApplier` / `ModelPrefabComponentTypes`）按节点表重建 GameObject 层级并写字段。
- 它只覆盖 `Assets/GameContent/Assets/mvz2/models/**/*.prefab`（Addressables 标签 `Model`）。
- 关卡/UI prefab（`Assets/Prefabs/**`）与场景（`Assets/GameContent/Scenes/*.unity`）**没有任何**转换。

## 2. 场景 = prefab 实例（关键事实）

`Assets/GameContent/Scenes/Main.unity` 全文只有 5 个文档：
- `!u!29/104/157/196`（Occlusion/Render/Lightmap/NavMesh 设置，与运行期无关）
- `!u!1001 &8313639528170640764` = **MainGame.prefab 的一个 PrefabInstance**（guid
  `c2155d664cb21df42928315f9ff6c02b` → `Assets/Prefabs/MainGame.prefab`），
  外加 3 条 `m_Modifications`（把 `m_Name` 改成 `MainGame`）与 2 条 `m_AddedComponents`
  （`!u!114 &8313639528170640767/768`，`m_GameObject: {fileID: 8313639528170640765}` 即实例根）。
- `!u!1660057539` SceneRoots → 该实例。

`Assets/GameContent/Scenes/Level.unity` 同样只有 1 个 PrefabInstance
（`&7205253809994275433`，源 guid `9d8919103acb38b42be34804da617729` → `Assets/Prefabs/Level/Level.prefab`），
modifications 只改 `m_Name`（→`Level`）与 `m_IsActive`（→`0`）。

**结论：场景本身没有额外数据；要转换的其实是 `Assets/Prefabs/**` 的 prefab 图。**
场景文件只需记录「哪个 prefab + 根节点覆盖值」。

## 3. 优先字段的真实来源（逐个查证）

### 3.1 `GridController.size` —— 有真值 ✅

- C#：`Assets/Scripts/MVZ2/Grids/GridController.cs:236` `[SerializeField] private Vector2 size;`
- 数据：`Assets/Prefabs/Level/Grid.prefab:55`（script guid `8bab90e1a9c25324cbcc21e59508834d`）
  ```
  size: {x: 0.8, y: 0.8}
  ```
- 消费链：`Lane.prefab` 的 ElementList `_template` 指向 `Grid.prefab` 的实例
  （`Prefabs/Level/Lane.prefab:78` `_template: {fileID: 1307240081318352291}`，
  `:81` `PrefabInstance` → guid `28d3c52e6dcb031479123c61e22546ae` = `Grid.prefab`），
  `LaneController.InitGrids` 通过 `grids.updateList` 克隆模板 → 每个 Grid 都带 size=(0.8,0.8)。
- 后果（现状）：`size` 为 (0,0) →
  `SetDisplaySection`/`SetColliderBevel` 拿到零尺寸；
  `TransformWorld2ColliderPosition` 里 `slope = BevelHeight / size.x` 除零（Inf/NaN）；
  `lossySize.x/y` 为 0 → `colliderX/colliderY` = Inf/NaN → 拾取判定全错。

### 3.2 `LevelUIPreset` 的 4 个 hintArrow offset —— 有真值 ✅

- C#：`Assets/Scripts/View/Level/LevelUIPreset.cs`（script guid `97699913659d70548a705a92f8efbaca`）
- 数据：`Assets/Prefabs/Level/UI/UIPreset.prefab`（`!u!114 &8895750592136595875`）
  ```
  hintArrowOffsetBlueprint:  {x: 24, y: -108}
  hintArrowOffsetPickaxe:    {x: 0,  y: -72}
  hintArrowOffsetStarshard:  {x: 0,  y: 72}
  hintArrowOffsetTrigger:    {x: 0,  y: 0}
  hintArrowAngleBlueprint: 0
  hintArrowAnglePickaxe: 0
  hintArrowAngleStarshard: 180
  hintArrowAngleTrigger: 0
  ```
- 消费链：`LevelUIPreset.hx:283/289/295/301` → `hintArrow.SetTarget(target, offset*0.01, angle)`。
  4 个 angle 同样是 [SerializeField]，也是零值（angle 0 是合法值，Starshard 的 180 才是真值）。
- 注意：`UIPreset.prefab` 是 `Level.prefab` 里两个实例（standalone/mobile）的源；
  `Level.prefab` 里对应的是 **stripped 文档**（只有 `m_Script`，没有字段），
  所以真值必须从 `UIPreset.prefab` 取（若从 Level.prefab 解析，走 prefab 合并后同样能得到）。

**实测（合并后的 `Level.prefab`，即场景里实际生效的值）**：
```
UIPresetStandalone(节点 295)  Blueprint(24,-108)  Pickaxe(0,-72)  Starshard(0,72)   Trigger(0,-72)  angles 0/0/180/0
UIPresetMobile    (节点 857)  Blueprint(160,-27.5) Pickaxe(0,72)  Starshard(0,72)   Trigger(0,72)   angles 90/180/180/180
```
（与 `UIPreset.prefab` 的裸值不同，因为 `Level.prefab` 里的 PrefabInstance 覆盖了这些字段；
导出取的是**场景实际生效值**，正确。）

### 3.3 `LevelCamera.cameraShakeOffset` —— **没有** prefab 真值 ❌

- C#：`Assets/Scripts/MVZ2/Cameras/LevelCamera.cs:91` `private Vector3 cameraShakeOffset;`
  **没有 `[SerializeField]`**（对比 `:87-90` 的 cameraAnchor/cameraPosition 都有）。
- 即 C# 侧该字段初值就是 `Vector3.zero`，只能由 `ShakeOffset` setter 写入
  （`LevelController.hx:2813` `levelCamera.ShakeOffset = toVector3(Shakes.GetShake2D())`）。
- 所以移植层的 `= new Vector3(0,0,0)` **已经等价于 C# 行为**，不需要注入。
  但 `cameraAnchor` / `cameraPosition` 是序列化的（`Level.prefab` `!u!114 &7788294606768908441`：
  `cameraAnchor: {x: 0, y: 0.5}`、`cameraPosition: {x: 0, y: 3, z: -10}`），
  随后被 `LevelController.SetCameraPosition` 覆盖（覆盖是完整的：`cameraHousePosition` /
  `cameraLawnPosition` / `cameraChoosePosition` 都有 C# 初值，见 3.4）。

### 3.4 LevelController 的相机字段（C# 自带初值，不缺数据）

`Assets/Scripts/MVZ2/Level/LevelController/LevelController_Camera.cs:101-126`：
`cameraLimitX=2.2`、`cameraLeftSpaceMobile=2.2`、`cameraLeftSpaceStandalone=0`、
`cameraHousePosition=(0,3,-10)`、`cameraHouseAnchor=(0,0.5)`、
`cameraLawnPosition=(10.2,3,-10)`、`cameraLawnAnchor=(1,0.5)`、
`cameraChoosePosition=(14,3,-10)`、`cameraChooseAnchor=(1,0.5)`。
prefab 里是否覆盖需看 `Level.prefab` 的 LevelController 文档（见 4.2）。

## 4. 移植层当前缺失的构造点（进关卡的真正阻塞）

- `LevelManager.GotoLevelSceneAsync`（`mvz2/level/LevelManager.hx:209`）→
  `Scene.LoadSceneAsync("Level")` → `SceneManager.scenes` 里**没有注册 "Level"**
  （`InitState.hx:64-68` 只注册 Landing/Main，注释明说「需要 LevelController 的场景图
  （含大量 prefab 引用）转换完成后再登记」）。
- 即使注册，`LevelController.InitGridControllers` → `gridLayout.InitGridViews` →
  `lanes.updateList(...)`，而 `lanes`（`ElementList`）是 `[SerializeField]`，移植层为 null；
  `ElementList.CreateItem()` 用 `UnityObject.Instantiate(_template, ...)`，`_template` 也是 null。
  **即：Lane/Grid 子树在移植层完全没有对象图。**
- 同理 `gridLayout` / `levelCamera` / `ui` / `cameraRoot` 等 `[SerializeField]` 引用
  （`LevelController.hx:1742/576/2646/574`）在移植层都是 null。

⇒ 要让关卡跑起来，必须能从 prefab 数据**重建 Level 整棵对象图**，而不是逐个手写字段。
这正是本工作包的核心产出（不只导出字段，还要有 prefab 实例化能力）。

## 5. 转换器实测（build_scene.py，2026-10-05）

```
python HaxePort/tools_build/build_scene.py --report      # 约 49 秒
```
输出：`assets/scene_manifest.json`（2 场景 + 147 prefab）+ `assets/scene_prefabs/**/*.json`（149 文件，13MB）。

关键校验（`scene_prefabs/scenes/Level.json`，节点号 = 该文件里的下标）：
```
节点 535 Grid          MVZ2.Grids.GridController  size = {t:Vector2, v:[0.8,0.8]}      ✅ 3.1
节点 295 UIPresetStandalone LevelUIPreset         hintArrowOffset* = (24,-108)/(0,-72)/(0,72)/(0,-72) ✅ 3.2
节点 857 UIPresetMobile     LevelUIPreset         hintArrowOffset* = (160,-27.5)/(0,72)/(0,72)/(0,72) ✅ 3.2
节点 11  Camera        MVZ2.Cameras.LevelCamera   cameraAnchor=(0,0.5) cameraPosition=(0,3,-10)      ✅ 3.3
节点 30  Grids         MVZ2.Grids.GridLayoutController lanes = {n:19, c:1}
节点 534 Lane          MVZ2.Grids.LaneController  grids = {n:534,c:2}（ElementList）_template = {n:535}(Grid) ✅
```

### 5.1 已知数据问题（继承自 build_models.py，非本脚本引入）

Unity 生成的这批 prefab 里存在**悬空引用**（`{fileID, guid}` 在源文件里找不到对应对象，
Unity 侧同样解析不了）。`build_models.py` 已做保守回退（同类唯一候选 → recovered，
否则跳过 → dangling）。实测计数：
```
Main 场景   dangling 858  recovered 23
Level 场景  dangling 641  recovered  5
全部 149 项 dangling 1517 recovered 28
```
这些悬空引用绝大多数是冗余覆盖（把 transform 归零、把列表重指向本文件副本），
但如果某个**组件引用**（例如 `_template`、`gridLayout`）落在悬空里，运行期会拿不到对象。
**运行期必须对每个字段解析结果做 null 检查并记录**（`ScenePrefabLoader` 的
`unresolvedRefs` 统计），不能静默当成「值就是 null」。

### 5.2 未映射字段（69 种 / 6282 次）

导出时未在 `UI_COMPONENT_FIELDS` 里给出映射的字段全部记入清单 `unmappedFields`
（不静默丢弃）。主要类别：
- `TMPro.TextMeshPro*` 的渲染细节（m_enableKerning / m_isOrthographic / m_colorMode /
  m_enableExtraPadding / _SortingLayer* / m_maskType）：移植层 TMP shim 无对应字段。
- `AudioSource` 的 3D 空间细节（Spatialize / Pan2D / Bypass* / rolloff*Curve 等）：无 3D 音频。
- `SpriteMask` 的 Front/Back sorting 分档、`Outline.m_Softness`、`Canvas` 的编辑器字段。
- `TMP_InputField` 的 m_TextViewport / m_VerticalScrollbar 等：shim 部分覆盖。
以上都是**渲染/编辑器细节**，不影响游戏逻辑；数量已从初版 9031 降到 6282（补了 30 余条映射）。

### 5.3 Unity 包内置组件的 guid 反查（26 个）

`Assets/Prefabs/**` 里 26 个脚本 guid 在工程内查不到 `.cs.meta`（来自 Unity 包）。
已按「组件文档的字段集合 + 引用目标类型」反查确认并登记在 `UNITY_PACKAGE_SCRIPTS`
（例如 `fe87c0e1…` = `UnityEngine.UI.Image`：同时带 m_Sprite/m_FillAmount/m_Type；
`2da0c512…` = `TMPro.TMP_InputField`：`Prefabs/UI/Widgets/InputField.prefab` 的
m_TextComponent 指向 TextMeshProUGUI 且带 m_GlobalFontAsset，ugui 的 InputField 必须是 UI.Text）。
未确认的只剩 `UnityEngine.EventSystems.PhysicsRaycaster`（无 shim，运行期记 unknownComponents）。
