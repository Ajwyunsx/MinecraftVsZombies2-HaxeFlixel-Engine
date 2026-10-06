// Ported from: Assets/Scripts/Logic/Armors/ArmorSlotDefinition.cs
package mvz2logic.armors;

import mvz2logic.definitions.LogicDefinitionTypes;
import mvz2logic.resources.SpriteReference;
import pvzengine.base.Definition;
import unity.Color;

class ArmorSlotDefinition extends Definition
{
	public function new(nsp:String, name:String, anchor:String)
	{
		super(nsp, name);
		Anchor = anchor;
	}

	public var Anchor:String;
	public var HPBarColor:Color = new Color(0, 0, 0, 0); // PORT-NOTE: C# Color 为 struct，default 为 (0,0,0,0) 透明黑；显式初始化避免 abstract-over-class 的 null 解引用
	public var HPBarIcon:Null<SpriteReference>;

	public override function GetDefinitionType():String
	{
		return LogicDefinitionTypes.ARMOR_SLOT;
	}
}
