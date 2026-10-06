// Ported from: Assets/Scripts/Logic/Shapes/ShapeDefinition.cs
package mvz2logic.shapes;

import mvz2logic.blueprints.IShapeDefinitionArmor;
import mvz2logic.definitions.LogicDefinitionTypes;
import pvzengine.NamespaceID;
import pvzengine.base.Definition;
import unity.Vector3;

class ShapeDefinition extends Definition
{
	public function new(nsp:String, name:String)
	{
		super(nsp, name);
	}
	public function GetArmorPosition(slotID:NamespaceID, armorID:NamespaceID):Vector3
	{
		if (Armors == null)
			return Vector3.zero;
		return Armors.GetArmorPosition(slotID, armorID);
	}
	public function GetArmorScale(slotID:NamespaceID, armorID:NamespaceID):Vector3
	{
		if (Armors == null)
			return Vector3.one;
		return Armors.GetArmorScale(slotID, armorID);
	}
	public override function GetDefinitionType():String
	{
		return LogicDefinitionTypes.SHAPE;
	}
	public var Armors:Null<IShapeDefinitionArmor>;
}
