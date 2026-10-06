// Ported from: PVZEngine.TimerHelper (Assets/Scripts/Engine/Level/TimerHelper.cs)
// PORT-NOTE: 本文件是移植层早期为“外部 Tools 程序集”建立的占位 shim；Engine 源码取回后，
// TimerHelper 的正典移植位于 pvzengine/TimerHelper.hx（命名空间 PVZEngine）。
// 但既有上层调用点仍以 `import tools.TimerHelper;` + `TimerHelper.NewSecondTimer(...)` 调用，
// 故保留本 shim，并把实现对齐到真正的 C# 语义。
// PORT-NOTE: 原 shim 依赖 tools.FrameTimer.FRAMES_PER_SECOND（旧 shim 自造常量）；
// 正典 FrameTimer 按 PVZEngine.Ticks（默认 30 TPS）换算，故此处改用 pvzengine.Ticks.FromSeconds。
package tools;

class TimerHelper
{
    // C#: public static FrameTimer NewSecondTimer(float seconds) => new FrameTimer(Ticks.FromSeconds(seconds));
    public static function NewSecondTimer(seconds:Float):FrameTimer
    {
        return new FrameTimer(pvzengine.Ticks.FromSeconds(seconds));
    }
}
