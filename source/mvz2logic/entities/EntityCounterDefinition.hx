// Ported from: Assets/Scripts/Logic/Entities/EntityCounterDefinition.cs
package mvz2logic.entities;

import mvz2logic.definitions.LogicDefinitionTypes;
import pvzengine.base.Definition;

class EntityCounterDefinition extends Definition
{
	public function new(nsp:String, name:String, counterName:String)
	{
		super(nsp, name);
		CounterName = counterName;
	}
	public override function GetDefinitionType():String return LogicDefinitionTypes.ENTITY_COUNTER;
	// C#: public string CounterName { get; set; }
	public var CounterName:String;
}
