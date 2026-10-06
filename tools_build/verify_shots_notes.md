# 渲染层攻坚 · 工作包【验证：构建 + 运行 + 截图 + 像素统计（黑屏判定）】

> 分段笔记。**最终结论见 `black_screen_report.md`。**

## 0. 开工状态（2026-10-05 18:55）

- 仓库根 `HaxePort/`，`source/` 正被 **5 个并行 coder agent** 改动（渲染层攻坚 5 路）。
  桌面截图可见编排面板：「渲染层攻坚5路(黑屏) 0/5」，#1~#5 全部「进行中」。
- 本机正在跑的进程：`cl.exe` 11~20 个（有 agent 在编译）、`MVZ2.exe`（共享窗口，另一个 agent 起的）。
- **共享 `export/windows` 被竞争**，故本工作包使用隔离工程
  `tools_build/verify_shot/`（复制自 `verify_startup/`，只把 source/icon 改相对路径、去掉 943MB `<assets>`，
  运行期用目录联接指回 `HaxePort/assets`）。

## 1. 本工作包新增的工具

| 文件 | 作用 |
|---|---|
| `tools_build/grab_shot.ps1` | PowerShell 截屏：默认抓 `MVZ2.exe` **主窗口客户区**（DPI 感知 + ClientToScreen），`-FullScreen` 抓全屏。**ASCII-only 源码**（PS 5.1 按 GBK 读 `.ps1`） |
| `tools_build/analyze_shot.py` | 纯标准库 PNG 解码（zlib + 5 种 filter 反演）→ 非黑像素比例 / 颜色桶 / 32x18 网格连通区域数 / 主要颜色分布 |
| `tools_build/run_shot.sh` | 隔离工程「运行 + 定时截屏 + boot-trace」一键复验 |
| `tools_build/verify_shot/` | 隔离构建工程 |

### 工具自检（保证结论可信）

```
python tools_build/analyze_shot.py tools_build/shots/_selftest_black.png tools_build/shots/_selftest_mixed.png
== _selftest_black.png ==   非黑像素 0 / 3072 = 0.000%    颜色桶 0    区域 0     ← 纯黑图判定正确
== _selftest_mixed.png ==   非黑像素 532 / 3072 = 17.318% 颜色桶 2    区域 2     ← 两个色块判定正确
```

截屏链路自检：全屏抓取 2560x1440 成功，桌面非黑 99.928% / 1040 色桶（**不是**「截屏全黑」的假阴性）。

## 2. 类型检查

| 时点 | neko | cpp |
|---|---|---|
| 19:00（渲染层改动前） | exit 0 | exit 0（模块 2486） |
| 20:20（渲染桥落地后） | exit 0 | exit 0（模块 **2493**） |

## 3. 复验轨迹（全部实测）

| 时点 | 产物 md5 | 客户区非黑像素 | 区域数 | 判定 |
|---|---|---|---|---|
| 19:05 共享 | （旧） | 7.300%（含标题栏） | 1 | **全黑** |
| 19:25 隔离 | `70b30351…` | **0.040%** | 3 | **全黑**（非黑=鼠标光标） |
| 19:29 隔离 | `975e442b…` | **0.040%** | 3 | **全黑**（帧转换有了，未进显示列表） |
| **20:25 隔离** | `2ec19f2a…` | **30.757%** | **6** | **黑屏消失** |
| 20:13 共享（交叉复验） | `6b673638…` | **30.759%** | **6** | **黑屏消失** |

## 4. 关键中间态（供后续排查）

- `source/mvz2/ui/UiRenderer.hx`（19:33 出现）是缺失的显示列表层：
  `install(root)` 里 `FlxG.state.add(instance)`，把 uGUI 树转成 FlxGroup 成员。
- `source/unity/RenderBridge.hx`（19:56 出现）是世界空间 SpriteRenderer 的桥。
- 19:41~19:57 期间 `source/` 在多个中间态编译错之间反复
  （`Unexpected keyword "default"`、`Type not found : AnimManifest` / `unity.RenderBridge` /
  `mvz2.animations.AnimatorAutoUpdater`），无法构建 —— 属并行写入的正常现象。
- **19:37:43 `MainSceneState.hx`** 加入 `uiRenderer = UiRenderer.install(scene.root);` 是转折点。

## 5. 剩余缺口（已写进报告 §4）

对话框的 `Image` 有真实 sprite 引用（`mvz2:init/form`、`mvz2:init/button`，数据齐、贴图在），
但 `MainGameScene.buildDialog()` 是**手工构造的对象图**、`CustomDialog` **不在 `PAGE_PREFABS` 表里**，
因此没经过 `ScenePrefabFieldApplier` 的 `ModelPrefabAssetsBridge.ApplyImageSprite` 路径
→ `Image.sprite` 恒 null → `UiRenderer` 退化成 1×1 白块（`applySolid`）。

TMP 字体（`Fonts/mojangles/minecraft_font.asset`）尚未转换，对话框文字不可见。
