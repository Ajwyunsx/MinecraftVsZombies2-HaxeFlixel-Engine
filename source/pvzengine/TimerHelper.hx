// Ported from: Assets/Scripts/Engine/Level/TimerHelper.cs
// PORT-NOTE: 本类是 PVZEngine 中针对 Tools.FrameTimer 的扩展方法集合（C# `using Tools;`，
//   FrameTimer 见 Tools/Timer/FrameTimer.cs，移植层的实现位于 tools/FrameTimer.hx）。
//
// PORT-NOTE: 由于移植层既有的 tools/FrameTimer.hx 是最小重实现（累计帧语义，未提供
//   Precision / FrameFraction / LastFrameFraction 成员），当原始实现依赖这些成员时，
//   这里改为转发到该 shim 已提供的等价能力并标注 TODO-PORT。
package pvzengine;

import haxe.Int64;
import pvzengine.entities.Entity;
import tools.FrameTimer;
import unity.Mathf;

class TimerHelper
{
	public static function IteratePassedFrames(timer:FrameTimer, interval:Float):Array<Float>
	{
		// TODO-PORT: C# 依据 LastFrame / LastFrameFraction / Precision / FrameFraction 计算跨过的区间；
		// tools.FrameTimer 未提供这些成员，改为转发到 FrameTimer.IteratePassedFrames（同等能力）。
		return [for (frame in timer.IteratePassedFrames(Std.int(interval))) (frame : Float)];
	}
	public static function GetMaxSeconds(timer:FrameTimer):Float
	{
		return Ticks.ToSeconds(timer.MaxFrame);
	}
	public static function SetSeconds(timer:FrameTimer, seconds:Float):Void
	{
		var frames = seconds * Ticks.GetTPS();
		timer.Frame = Mathf.FloorToInt(frames);
		// TODO-PORT: C# 同时设置 FrameFraction = FloorToInt((frames % 1) * Precision)；
		// tools.FrameTimer 未提供 FrameFraction / Precision。
	}
	public static function ResetSeconds(timer:FrameTimer, seconds:Float):Void
	{
		timer.ResetTime(Ticks.FromSeconds(seconds));
	}
	public static function PassedSeconds(timer:FrameTimer, seconds:Float):Bool
	{
		return timer.PassedFrame(Ticks.FromSeconds(seconds));
	}
	public static function PassedSecondsFromMax(timer:FrameTimer, seconds:Float):Bool
	{
		return timer.PassedFrameFromMax(Ticks.FromSeconds(seconds));
	}
	public static function PassedIntervalSeconds(timer:FrameTimer, seconds:Float):Bool
	{
		return timer.PassedInterval(Ticks.FromSeconds(seconds));
	}
	public static function RunToExpiredOrNull(timer:Null<FrameTimer>, speed:Float = 1):Bool
	{
		// C#: [NotNullWhen(false)] 参数特性在 Haxe 中无对应语义，仅保留空值语义。
		// PORT-NOTE: 按 C# 原逻辑实现（timer 为空返回 true），不再转发到 FrameTimer 的实例方法。
		if (timer == null)
			return true;
		return timer.RunToExpired(speed);
	}

	public static function RunToExpiredAndNotNull(timer:Null<FrameTimer>, speed:Float = 1):Bool
	{
		if (timer == null)
			return false;
		return timer.RunToExpired(speed);
	}

	public static function NewSecondTimer(seconds:Float):FrameTimer
	{
		return new FrameTimer(Ticks.FromSeconds(seconds));
	}
	public static function IsSecondsInterval(entity:Entity, seconds:Float, offset:Float = 0):Bool
	{
		return entity.IsTimeInterval(Int64.ofInt(Ticks.FromSeconds(seconds)), Int64.ofInt(Ticks.FromSeconds(offset)));
	}
}
