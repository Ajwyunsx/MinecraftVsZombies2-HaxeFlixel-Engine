// Ported from: Assets/Scripts/Logic/Armors/MetaArmorDefinition.cs
package mvz2logic.armors;

import mvz2logic.entities.LogicEntityProps;
import pvzengine.NamespaceID;
import pvzengine.armors.ArmorDefinition;
import pvzengine.collisions.ColliderConstructor;
import pvzengine.entities.Entity;

import unity.Vector3;

import mvz2logic.entities.LogicEntityExt;

class MetaArmorDefinition extends ArmorDefinition
{
	public function new(nsp:String, name:String, constructors:Array<ColliderConstructor>)
	{
		super(nsp, name, constructors);
	}

	public override function GetColliderConstructors(entity:Entity, slotID:NamespaceID):Array<ColliderConstructor>
	{
		var armorID = GetID();
		// PORT-NOTE: C# 扩展方法 entity.GetArmorOffset/GetArmorScale(...) → Haxe 静态调用（同 mvz2/gamecontent/armors/Cannon.hx 的既有写法）。
		var position = LogicEntityExt.GetArmorOffset(entity, slotID, armorID);
		var scale = LogicEntityExt.GetArmorScale(entity, slotID, armorID);
		var result:Array<ColliderConstructor> = [];
		for (cons in super.GetColliderConstructors(entity, slotID))
		{
			var newCons = cons;
			// PORT-NOTE: unity.Vector3 的 Scale 为静态方法（Haxe 无运算符/实例重载）。
			newCons.offset = Vector3.Scale(newCons.offset, scale);
			newCons.offset = newCons.offset + position;
			newCons.size = Vector3.Scale(newCons.size, scale);
			result.push(newCons);
		}
		return result;
	}
}
