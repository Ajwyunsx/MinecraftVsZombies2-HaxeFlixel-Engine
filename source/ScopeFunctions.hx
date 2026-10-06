// Ported from: Assets/Scripts/Engine/Tools/ScopeFunctions.cs
// PORT-NOTE: 该类型在 C# 中位于全局命名空间（Tools 程序集），因此 Haxe 侧同样不使用 package
// （与已存在的 Log.hx / UnityHelper.hx 保持一致）。

// C# 中 `Let`/`Run` 是作用于任意对象的扩展方法（`x.Let(...)` / `x.Run(...)`）。
// PORTING.md §扩展方法：改为静态普通方法，调用点写 `ScopeFunctions.Let(x, ...)`。
class ScopeFunctions
{
	public static function Let<T>(it:T, action:T->Void):T
	{
		action(it);
		return it;
	}
	public static function Run<T, TReturn>(it:T, action:T->TReturn):TReturn
	{
		return action(it);
	}
}
