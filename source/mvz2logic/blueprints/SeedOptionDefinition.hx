// Ported from: Assets/Scripts/Logic/Blueprints/SeedOptionDefinition.cs
package mvz2logic.blueprints;

import mvz2logic.definitions.LogicDefinitionTypes;
import pvzengine.base.Definition;
import pvzengine.level.LevelEngine;
import pvzengine.seedpacks.SeedDefinition;
import pvzengine.seedpacks.SeedPack;

// abstract
class SeedOptionDefinition extends Definition
{
	public function new(nsp:String, name:String)
	{
		super(nsp, name);
	}
	public function Use(seedPack:SeedPack):Void
	{
	}
	// TODO-PORT: C# 重载 Use(LevelEngine level, SeedDefinition seedPack)，Haxe 不支持重载，重命名为 UseWithDefinition
	public function UseWithDefinition(level:LevelEngine, seedPack:SeedDefinition):Void
	{
	}
	public function Update(seedPack:SeedPack, rechargeSpeed:Float):Void
	{
	}
	public override function GetDefinitionType():String return LogicDefinitionTypes.SEED_OPTION;
}
