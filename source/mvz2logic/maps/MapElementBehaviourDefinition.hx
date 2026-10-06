// Ported from: Assets/Scripts/Logic/Maps/MapElementBehaviourDefinition.cs
package mvz2logic.maps;

import mvz2logic.definitions.LogicDefinitionTypes;
import pvzengine.base.Definition;

// abstract
class MapElementBehaviourDefinition extends Definition
{
	public function new(nsp:String, name:String)
	{
		super(nsp, name);
	}
	public function OnClick(element:IMapElement):Void
	{

	}
	public override function GetDefinitionType():String
	{
		return LogicDefinitionTypes.MAP_ELEMENT_BEHAVIOUR;
	}
}
