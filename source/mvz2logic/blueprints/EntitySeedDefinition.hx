// Ported from: Assets/Scripts/Logic/Blueprints/EntitySeedDefinition.cs
package mvz2logic.blueprints;

import mvz2logic.definitions.LogicDefinitionTypes;
import pvzengine.base.Definition;

class EntitySeedDefinition extends Definition
{
	public function new(nsp:String, name:String, blueprintName:String, blueprintTooltip:String)
	{
		super(nsp, name);
		BlueprintName = blueprintName;
		BlueprintTooltip = blueprintTooltip;
	}
	public override function GetDefinitionType():String return LogicDefinitionTypes.ENTITY_SEED;
	// C#: public string BlueprintName { get; set; }
	public var BlueprintName:String;
	// C#: public string BlueprintTooltip { get; set; }
	public var BlueprintTooltip:String;
}
