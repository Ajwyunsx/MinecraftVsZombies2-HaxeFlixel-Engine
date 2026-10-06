# 渲染桥收尾与保真（工作包：渲染桥核心）—— 执行记录

> 分段落盘。姊妹笔记：`render_bridge_work.md`（本包上一轮的设计与决策）、
> `ui_render_findings.md`（uGUI 层）、`sprite_pipeline_work.md`（unity.Sprite → FlxFrame）、
> `black_screen_report.md`（黑屏量化验证，已确认非黑像素 0.040% → 30.757%）。

---

## 0. 本轮开工状态（2026-10-05 21:00）

黑屏**已修复**（验证 agent 实测：非黑像素 30.757%、18000 帧 30s 无崩溃）。
剩余问题是画面为**白色占位块**。本包上一轮已落地的文件：

| 文件 | 状态 |
|---|---|
| `source/unity/RenderBridge.hx` | 新增（登记渲染器/相机，每帧同步） |
| `source/unity/Camera.hx` | 重写（FlxCamera 桥 + 底色 + Y 翻转） |
| `source/unity/SortingLayer.hx` | 重写（20 个工程排序层） |
| `source/unity/GameObject.hx` | 改（`AddComponent` 登记渲染器） |
| `source/unity/UnityObject.hx` | 改（`destroy` 递归摘除子树） |
| `verify/renderbridge/RenderBridgeSmokeMain.hx` + `tools_build/check_render_bridge.sh` | 新增（71 项断言，neko 全过） |

本轮聚焦「保真」：找出并修掉让画面**不准确**的语义缺陷。

---

## 1. 本轮修掉的保真缺陷

### 1.1 【严重】`unity.Quaternion.Euler` / `eulerAngles` 是空实现

`source/unity/Quaternion.hx:18~26`（本轮开工时）：

```haxe
public var eulerAngles(get, never):Vector3;
function get_eulerAngles():Vector3 {
    // TODO-PORT: full Quaternion->Euler conversion
    return new Vector3(0, 0, 0);          // ← 恒返回零
}
public static function Euler(x:Float, y:Float, z:Float):Quaternion {
    // TODO-PORT: full Euler->Quaternion conversion
    return identity;                       // ← 恒返回单位四元数
}
```

**影响面**（`Transform.eulerAngles` 的 getter/setter 直接依赖它们）：

| 调用点 | 后果 |
|---|---|
| `source/unity/Transform.hx:14` `get_eulerAngles()` | 任何 `transform.eulerAngles` 读回 (0,0,0) |
| `source/unity/Transform.hx:16` `set_eulerAngles(v)` | 任何 `transform.eulerAngles = v` 静默无效 |
| `source/unity/Transform.hx:72~74` `Rotate(x,y,z)` | 旋转完全无效 |
| `mvz2/models/RotationLocker.hx:16` | 模型朝向锁失效 |
| `mvz2/models/KnockbackWaveModel.hx:31` | 粒子朝向失效 |
| `mvz2/models/NightmareGlassModel.hx:20/46` | 碎片旋转的存/取都变成零 |
| `mvz2/ui/map/MapUI.hx:56` | 地图拖拽箭头角度失效 |
| `mvz2/chaptertransition/ChapterTransition.hx:12` | 章节切换轮盘旋转失效 |
| `mvz2/gamecontent/projectiles/LargeArrow.hx:32` | 箭矢朝向失效 |

**修法**：按 Unity 文档的 **ZXY 内旋**约定补齐 `QuaternionMath.fromEulerZXY` /
`toEulerZXY`（`q = qY * qX * qZ`，即 Inspector 里 Rotation (x,y,z) 的语义）。
`eulerAngles` 返回每个分量 ∈ [0,360)，与 Unity 一致。±90° 万向锁分支记 `TODO-PORT`
（工程内没有该姿态：所有旋转都是绕单轴的小角度）。

### 1.2 【严重】世界空间 SpriteRenderer 的排序键用错了

`source/mvz2/ui/UiRenderer.hx:231~237`（本轮开工时）直接拿**裸的 `sortingLayerID`** 比大小：

```haxe
keys.sort(function(a, b) {
    if (a.layer != b.layer) return a.layer < b.layer ? -1 : 1;   // ← 有符号比较
    ...
});
```

Unity 的层 ID 是 `uniqueID` 的哈希，**无符号序**才对应层级顺序。实测错序：

| 层 | ID（有符号） | 无符号 | 层级序号 | 裸比较排位 | 正确排位 |
|---|---|---|---|---|---|
| Background | -2057763135 | 2237204161 | 0 | 2 | **0** |
| Default | 0 | 0 | 8 | **1** | 8 |
| Foreground | -4036897 | 4254708015 | 9 | 8 | 9 |
| Talk | 1660876549 | 1660876549 | 14 | 3 | 14 |
| ScreenCover | 1206696159 | 1206696159 | 19 | **4** | 19 |

即 `Default(0)` 会被排到 `Background` 之前（应之后）、`ScreenCover` 排到 `Talk` 之前（应之后）。
**修法**：改用 `SortingLayer.SortKeyOf(layerID, sortingOrder)`（层序号 → 打包排序键）。
层序来自 `ProjectSettings/TagManager.asset` 的 `m_SortingLayers` 声明顺序。

### 1.3 旋转没有同步到渲染对象

`RenderBridge.syncOne` 原先只同步 `visible` / `scale` / `flip` / `alpha`，**漏了旋转**，
因此即使 1.1 修好，`transform.eulerAngles.z` 也传不到 `FlxSprite.angle`。
**修法**：补 `target.angle = -tr.eulerAngles.z`（Unity 逆时针 vs Flixel 顺时针，取负号），
并在 `UiRenderer.updateSpriteRenderer` 里跟随 `renderSprite.angle`。

### 1.4 【根因】`UiEntryKind` 的枚举成员遮蔽了同名类 → 所有 `Image` 退化成白块

这是「白色占位块」的**真正根因**（不是 hxcpp 的 `Std.isOfType` 有 bug —— 已用 cpp 探针
`ProbeIsOfType` 实测排除：Dynamic 与静态类型的 `Std.isOfType` 在 cpp 上都正确）。

`source/mvz2/ui/UiRenderer.hx` 底部声明：

```haxe
enum abstract UiEntryKind(Int) {
    var None = 0;
    var Image = 1;            // ← 与 unity.ui.Image 同名
    var Solid = 2;
    var Text = 3;             // ← 与 unity.ui.Text 同名
    var SpriteRenderer = 4;   // ← 与 unity.SpriteRenderer 同名
}
```

Haxe 的**模块作用域**会把 `enum abstract` 的成员提升为模块级名字，于是它们**遮蔽**了
`unity.ui.Image` / `unity.ui.Text` / `unity.SpriteRenderer` 这三个类名。在
`UiRenderer.renderNode` 里：

```haxe
if (uiText == null && Std.isOfType(c, Text))     // ← Text 解析成整数 3
```

`Std.isOfType(x, 3)` 的类型参数被当成整数 → 判定恒为 false。
**实测后果**：18 个 `unity.ui.Image` 一个都进不了取帧分支，全部退化成 1×1 白图拉伸。

诊断证据（`rb_before` 运行，boot-trace）：

```
UI 渲染统计：可见项=15 / 成员=22（Graphic=23 文本=0 纯色=0 世界精灵=0 跳过=67）
UI Image 诊断：有 sprite=0 sprite 为 null=0 取帧失败=0      ← 两个计数都为 0 = 分支根本没进
```

**修法**：把枚举成员改名，从根上消除遮蔽 ——
`None→Empty`、`Image→ImageGraphic`、`Solid→SolidRect`、`Text→Label`、`SpriteRenderer→WorldSprite`。
同时在 `renderNode` 保留 `unity.ui.Text` 这类**全限定名**作为二次保险（对值位置的遮蔽同样有效）。

> **可复用的教训**：Haxe 模块里**任何**顶层名字（含 `enum abstract` 成员）都会进入模块作用域，
> 与 `import` 进来的同名类冲突时**静默遮蔽**，且编译器不报错。
> 判别方法：`grep` 本模块的顶层声明名，与它 import 的类名取交集。

---

## 4. 另一个保真缺口：手工对象图绕过渲染器登记

`unity.GameObject.AddComponent` 是本包新增的**唯一**渲染器登记点（`RenderBridge.registerRenderer`），
但移植层有三处**手工 `new` + 直接 push 组件表**的路径绕过了它：

| 文件:行 | 说明 |
|---|---|
| `source/mvz2/states/MainGameScene.hx:730` | `attach()`：MainGame 场景的手写对象图（`buildDialog` 等） |
| `source/mvz2/states/InitState.hx:95` | Landing 场景的 `attach()` |
| `source/mvz2/scenes/ScenePrefabLoader.hx` / `ModelPrefabLoader.hx` | **走 `AddComponent`**，已登记 ✅ |

未登记的 `SpriteRenderer` 不会被 `RenderBridge` 同步，其 `visible` / `scale` / `angle`
永远停在默认值 —— 即「`SetActive(false)` 了还画着」「缩放不跟随 Transform」。
**修法**：两处 `attach()` 补上与 `AddComponent` 相同的登记（幂等，重复登记会跳过）。

## 5. 对话框白块：手工对象图缺 `Image.sprite`（已接线）

黑屏报告 §4 的结论是「`Image.sprite` 恒为 null → 面板退化成 1×1 白块」。根因不是渲染层，
而是**两套对象图来源并存**：

| 来源 | 是否写序列化字段 | 实例 |
|---|---|---|
| `ScenePrefabLoader.InstantiateInto`（读 JSON） | ✅ 写（含 `Image.sprite`） | `PAGE_PREFABS` 里的 15 个页面 |
| `MainGameScene` 手写 `build*()` | ❌ **从不写** | `CustomDialog` / `InputNameDialog` / `DeleteUserDialog` |

实测诊断（本轮 `rb_before` 运行，boot-trace）：

```
[step] UI 渲染统计：可见项=15 / 成员=22（Graphic=23 文本=0 纯色=0 世界精灵=0 跳过=67），取帧失败=0
[step] UI Image 诊断：有 sprite=0 sprite 为 null=0 取帧失败=0
```

`有 sprite=0` + `sprite 为 null=0` = **没有任何 Image 带 sprite**，且连"被检查过"都没有
（手工对象图里 `Image` 挂的是普通 `Transform` 而非 `RectTransform`，
`UiRenderer.renderNode` 会把它计入 `跳过=67`）。

**数据是齐的**（`assets/scene_prefabs/Prefabs/UI/Dialogs/CustomDialog.json`）：

```json
"Background" 节点的 UnityEngine.UI.Image:
  "sprite": { "asset": { "guid": "ecdea1f2d39df2049be852b3107d40a4", "fileID": "21300000",
              "path": "GameContent/Assets/mvz2/sprites/init/form.png", "address": "mvz2:init/form" } }
"TextButton" 节点: mvz2:init/button
```

**修法**（与 `boot_findings.md` §五.4 的建议一致）：三个 `build*Dialog()` 改为
先建根节点与控制器组件，再交给 `ScenePrefabLoader.InstantiateInto(key, root, null, false)`
接管（根对象保留手工 `new` 的组件，子节点与全部序列化字段由数据补齐）。
数据缺失时返回 `-1`，退回原手写路径，保证启动仍可用。

新增私有辅助 `MainGameScene.injectDialogPrefab(root, key)`；`prefabInjectionFailures` /
`prefabInjectionFields` 沿用既有诊断计数。

## 6. 进度

- [x] §1.1 Quaternion Euler 换算（ZXY）
- [x] §1.2 排序键改用 `SortingLayer.SortKeyOf`
- [x] §1.3 旋转同步（RenderBridge → FlxSprite.angle）
- [x] §1.4 手工对象图的渲染器登记缺口（`MainGameScene.attach` / `InitState.attach`）
- [x] §5 对话框 prefab 注入（修白块）
- [x] §7 neko（exit 0）+ cpp 全覆盖（exit 0，`模块总数=2493 类型化成功=2493 失败=0`）
- [x] §7 冒烟测试 **109 项全过**（neko + cpp 双目标，`tools_build/check_render_bridge.sh`）
- [ ] §8 构建 + 运行 + 截图 + 像素统计（进行中）

## 7. 验证

### 7.1 类型检查

```
neko:  exit 0   [DefinitionRegistry] 候选模块=932 收录类型=933 跳过=0
cpp :  exit 0   [CoverageCheck] 模块总数=2493 类型化成功=2493 失败=0
```

### 7.2 渲染桥冒烟测试（`bash tools_build/check_render_bridge.sh [--neko]`）

**109 项断言全过**（neko 与 cpp 双目标）。覆盖：

| 组 | 内容 |
|---|---|
| A 排序层 | 20 层的名字↔ID 互查（逐条对照 `TagManager.asset`）、层级顺序、`SortKeyOf` 的主键/次键关系 |
| B 坐标 | `ScreenToWorldPoint` 的 **Y 轴方向**（屏幕顶部→世界 y 为正）、往返一致性、相机移动跟随、`ViewportToWorldPoint` |
| C 底色 | `backgroundColor` → `FlxG.cameras.bgColor`（含全透明不覆盖） |
| D PPU | 正交尺寸 → 每世界单位像素数；透视退化；`orthographicSize=0` 不除零 |
| E 渲染同步 | `lossyScale` 级联到 `renderSprite.scale`、`SetActive(false)`（含祖先）、`enabled`、排序层双向收敛、alpha/flip |
| **E2 旋转** | `Quaternion.Euler`/`eulerAngles` 的 ZXY 往返（8 组角度）、负角归一化到 [0,360)、`Transform.Rotate` 累加、**→ `FlxSprite.angle` 取负** |
| F 销毁 | `destroy` 递归标记子树 + 从父级 `children` 摘除（显示列表据此淘汰） |

### 7.3 画面（隔离工程 `tools_build/verify_rb`，避开并行 agent 的 `verify_shot` 竞争）

见 §8。
