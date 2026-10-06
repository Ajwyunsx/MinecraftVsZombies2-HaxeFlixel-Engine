// Ported from: Assets/Scripts/Logic/Grids/GridLayerDefinition.cs
package mvz2logic.grids;

import mvz2logic.definitions.LogicDefinitionTypes;
import mvz2logic.resources.SpriteReference;
import pvzengine.NamespaceID;
import pvzengine.base.Definition;
import unity.Color;

class GridLayerDefinition extends Definition
{
	public function new(nsp:String, name:String, almanacTag:Null<NamespaceID>)
	{
		super(nsp, name);
		AlmanacTag = almanacTag;
	}
	public override function GetDefinitionType():String return LogicDefinitionTypes.GRID_LAYER;
	// C#: public NamespaceID? AlmanacTag { get; set; }
	public var AlmanacTag:Null<NamespaceID>;
	// C#: public Color HPBarColor { get; set; }
	public var HPBarColor:Color = new Color(0, 0, 0, 0); // PORT-NOTE: C# Color 为 struct，default 为 (0,0,0,0) 透明黑；显式初始化避免 abstract-over-class 的 null 解引用
	// C#: public SpriteReference? HPBarIcon { get; set; }
	public var HPBarIcon:Null<SpriteReference>;
}
