# 域10 集成验证 · 分段笔记（最终轮）

> 最终结论落盘到 `integration_report.md` + `black_screen_report.md`。本文件只做过程留痕。

## 1. 基线（2026-10-05 22:15，开工时点）

### 1.1 环境快照

- 正在跑的进程：`cl.exe` ×2（其他域在编译）、`haxe.exe` ×2（类型检查）、`MVZ2.exe` ×1（pid 13840，21:52 共享产物，**尚未含 22:08 的 `UiRenderer.hx` 改动**）。
- `source/` 最新 mtime：`source/mvz2/ui/UiRenderer.hx` 22:08:33；其后依次 `mvz2/animations/AnimatorAutoUpdater.hx` 21:47:45、`mvz2/states/MainSceneState.hx` 21:41:34。
- `tools_build/*_findings.md` 最新：`scene_inject_findings.md` 21:56、`ui_render_findings.md` 21:55、`render_bridge_findings.md` 21:31。
- 共享产物 `export/windows/bin/MVZ2.exe`：30,386,688 B，mtime 21:52。

### 1.2 画面基线（live 截屏 + 像素统计）

命令：
```bash
powershell -NoProfile -ExecutionPolicy Bypass -File tools_build/grab_shot.ps1 -Out tools_build/shots/base10_t0.png
PYTHONIOENCODING=utf-8 python tools_build/analyze_shot.py tools_build/shots/base10_t0.png
```

结果（`tools_build/shots/base10_t0.png`，1280x720 客户区）：

```
尺寸            1280x720
非黑像素        383936 / 921600 = 41.660%
颜色桶数量      30
非空网格区域数  3（32x18 网格，4 邻域连通）
主要颜色        #f0f0f0 41.62%, #101010 0.02%, #b0b0c0 0.01%, ...
```

对照历史（`black_screen_report.md` §3）：`after3_*` = 30.757%（6 区域）、`rb_after_t*` = 41.695%（4 区域）。
即**黑屏修复保持**，非黑像素从 30.757% 进一步升到 41.660%。

### 1.3 启动日志基线

`export/windows/bin/boot-trace.log`（21:56，273 行，`[error]` 20 处）：

- 全部 `[error]` 都是**既有非致命项**（`加载Sprites/Models花费的时间` 等被 `Debug.LogError` 复用的耗时输出 + 无网络时「更新赞助者名单」Null Object Reference）。
- 关键诊断行（**当前核心缺口**）：
  ```
  [step] UI 渲染统计：可见项=28 / 成员=35（Graphic=36 文本=0 纯色=0 世界精灵=0 跳过=63），取帧失败=0
  [step] UI 快照：可见项=28 成员=35 Graphic=36(有Rect=35) 文本=0 纯色=0 世界精灵=0 跳过=63
         updateGraphic调用=0 Image有sprite=0 Image无sprite=0 Image取帧失败=0
         类=[unity.tmpro.TextMeshProUGUI=14,unity.ui.Image=22]
  [step] UI Image 诊断：有 sprite=0 sprite 为 null=0 取帧失败=0
  [step]   Graphic 挂在非 RectTransform 上（前 1 个）：MainGame/MainScene/UI/ScreenCover [unity.ui.Image tr=unity.Transform]
  ```
  → **`Image有sprite + Image无sprite = 0 ≠ Image 总数 22`**：说明 22 个 `unity.ui.Image` 一个都没被
  `updateGraphic` 计入（`updateGraphic调用=0`），画面上的白块来自另一条路径。这正是「白块占位」的观测点。

### 1.4 告警计数基线

待跑 `count_boot_warnings.py`。
