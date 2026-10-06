// Ported from: Assets/Scripts/View/SortingLayerPicker.cs
package mvz2;

import unity.SortingLayer;

// [Serializable]
class SortingLayerPicker
{
	public var id:Int;

	public function new(?id:Int = 0)
	{
		this.id = id;
	}

	public var Name(get, never):String;
	function get_Name():String return SortingLayer.IDToName(id);

	// C# 隐式转换 operator int(SortingLayerPicker)
	public static function toInt(layerPicker:SortingLayerPicker):Int return layerPicker.id;
}
