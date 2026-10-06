// Ported from: Assets/Scripts/Engine/Level/Modifiers/IModifierProvider.cs
package pvzengine.modifiers;

import flixel.util.FlxSignal.FlxTypedSignal;
import pvzengine.IPropertyKey;

interface IModifierProvider
{
	/** 获取所有被修改过的属性键。 */
	function GetModifiedProperties():Array<IPropertyKey>;
	/** 获取修改某个属性的所有修饰器。 */
	function GetModifiersForProperty(name:IPropertyKey, results:Array<ModifierSourceItem>):Void;
	// PORT-NOTE: C# `event Action<IPropertyKey>? OnModifiedPropertyNeedsUpdate` 移植为 FlxTypedSignal。
	public var OnModifiedPropertyNeedsUpdate:FlxTypedSignal<IPropertyKey->Void>;
}
