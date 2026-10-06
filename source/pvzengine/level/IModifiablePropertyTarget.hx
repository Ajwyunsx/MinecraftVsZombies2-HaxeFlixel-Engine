// Ported from: Assets/Scripts/Engine/Level/Modifiers/IModifiablePropertyTarget.cs
// PORT-NOTE: 该 C# 文件位于 Level/Modifiers/ 目录，但其 namespace 为 PVZEngine.Level，
// 因此按「包名以 namespace 为准」的规则放在 pvzengine/level/ 下。
package pvzengine.level;

import pvzengine.IPropertyKey;

interface IModifiablePropertyTarget
{
	/**
	 * 在属性表中不存在某一属性时，退化而返回的某些数值。
	 * @param name 属性键。
	 * @param value 返回的数值。
	 * @return 是否成功返回。
	 */
	// PORT-NOTE: C# `out object? value` 移植为 Haxe 的引用容器结构 `{ value:Dynamic }`（与既有的 TryGetProperty 调用点一致）。
	// 注意：`{var value:Dynamic}` 不是合法的 Haxe 匿名结构类型语法（字段默认可写，无需 `var`）。
	// 以下文件使用了该非法写法，需要一并改为 `{ value:Dynamic }`：
	//   mvz2/globalgames/GlobalGame.hx:41、pvzengine/armors/Armor.hx:280、
	//   pvzengine/grids/LawnGrid.hx:496、pvzengine/seedpacks/SeedPack.hx:312
	function GetFallbackProperty(name:IPropertyKey, value:{ value:Dynamic }):Bool;
	/**
	 * 在某个属性发生变动时触发的回调。
	 * @param name 属性键。
	 * @param beforeValue 该属性之前的值。
	 * @param afterValue 该属性之后的值。
	 * @param triggersEvaluation 是否会触发某些属性的重新评估。如最大生命值变化后，当前生命值等比例缩放。
	 */
	function OnPropertyChanged(name:IPropertyKey, beforeValue:Dynamic, afterValue:Dynamic, triggersEvaluation:Bool):Void;
}
