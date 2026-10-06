// Ported from: Assets/Scripts/Logic/Cursor/CursorSource.cs
package mvz2logic.cursor;

// PORT-NOTE: C# 的 CursorType 与 CursorSource 同文件；Haxe 侧同时存在
// `mvz2logic.cursor.CursorSource.CursorType` 与 `mvz2logic.cursor.CursorType` 两种引用写法，
// 因此本模块保留 enum 本体，另在 CursorType.hx 提供指向它的 typedef。
class CursorSource
{
	// abstract
	// PORT-NOTE: C# CursorSource : IComparable<CursorSource>，Haxe 无 IComparable，保留 CompareTo 方法但不实现接口。
	public function IsValid():Bool
	{
		throw "abstract";
	}
	public function SetEnabled(enabled:Bool):Void
	{
		if (enabled == Enabled)
			return;
		Enabled = enabled;
		dispatchOnEnableChanged(enabled);
	}
	// PORT-NOTE: C# event Action<bool>? OnEnableChanged -> Array<Bool->Void>
	public var OnEnableChanged:Array<Bool->Void> = [];
	private function dispatchOnEnableChanged(enabled:Bool):Void
	{
		for (f in OnEnableChanged.copy())
		{
			f(enabled);
		}
	}
	public var Enabled(default, null):Bool = true;
	// abstract
	public var CursorType(get, never):CursorType;
	private function get_CursorType():CursorType
	{
		throw "abstract";
	}
	// abstract
	public var Priority(get, never):Int;
	private function get_Priority():Int
	{
		throw "abstract";
	}

	public function CompareTo(other:CursorSource):Int
	{
		return Priority - other.Priority;
	}
}
