// Ported from: Assets/Scripts/Logic/HeldItems/HeldItemInfo.cs (interface IHeldItemPropertyContainer)
package mvz2logic.helditems;

import pvzengine.PropertyKey;

// PORT-NOTE: C# 中 LogicHeldItemProps 的扩展方法（CannotCancel/SetCannotCancel 等）靠 `using MVZ2Logic.HeldItems` 生效，
// Haxe 用 @:using 还原实例调用形式（既有调用点 `builder.SetCannotCancel(true)`、`info.CannotCancel()`）。
@:using(mvz2logic.level.LogicHeldItemProps)
interface IHeldItemPropertyContainer
{
	function GetProperty<T>(key:PropertyKey<T>):Null<T>;
	function SetProperty<T>(key:PropertyKey<T>, value:T):Void;
}
