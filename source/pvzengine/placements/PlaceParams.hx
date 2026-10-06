// Ported from: Assets/Scripts/Engine/Level/Placements/PlaceParams.cs
package pvzengine.placements;

import pvzengine.PropertyDictionary;
import pvzengine.PropertyKey;

class PlaceParams
{
	// PORT-NOTE: Haxe 4.3 不再为无构造函数的类自动生成默认构造函数，C# 的隐式默认构造需显式写出。
	public function new() {}
	public function SetProperty<T>(key:PropertyKey<T>, value:T):Void properties.SetProperty(key, value);
	public function GetProperty<T>(key:PropertyKey<T>):T return properties.GetProperty(key);
	private var properties:PropertyDictionary = new PropertyDictionary();
}
