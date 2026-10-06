// Ported from: Assets/Scripts/Engine/Level/Modifiers/IModifierSource.cs
package pvzengine.modifiers;

import pvzengine.PropertyKey;

interface IModifierSource
{
	function GetProperty<T>(name:PropertyKey<T>):Null<T>;
}
