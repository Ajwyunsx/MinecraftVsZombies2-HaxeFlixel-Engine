// Ported from: Assets/Scripts/Logic/Blueprints/OptionSeed.cs
// PORT-NOTE: 源文件 namespace 为 MVZ2Logic.Seeds，按 namespace→package 规则放在 mvz2logic.seeds 包。
package mvz2logic.seeds;

import mvz2logic.blueprints.LogicSeedProps;
import mvz2logic.blueprints.SeedTypes;
import mvz2logic.games.LogicGameDefinitionsExt;
import pvzengine.NamespaceID;
import pvzengine.seedpacks.EngineSeedProps;
import pvzengine.seedpacks.SeedDefinition;
import pvzengine.seedpacks.SeedPack;

class OptionSeed extends SeedDefinition
{
	public function new(nsp:String, name:String, cost:Int)
	{
		super(nsp, name);
		SetProperty(LogicSeedProps.SEED_TYPE, SeedTypes.OPTION);
		SetProperty(LogicSeedProps.SEED_OPTION_ID, new NamespaceID(nsp, name));
		SetProperty(EngineSeedProps.COST, (cast cost : Float));
	}
	public override function Update(seedPack:SeedPack, rechargeSpeed:Float):Void
	{
		super.Update(seedPack, rechargeSpeed);
		var optionID = LogicSeedProps.GetSeedOptionID(seedPack.Definition);
		if (optionID == null)
			return;
		var optionDef = LogicGameDefinitionsExt.GetSeedOptionDefinition(seedPack.Level.Content, optionID);
		if (optionDef == null)
			return;
		optionDef.Update(seedPack, rechargeSpeed);
	}
}
