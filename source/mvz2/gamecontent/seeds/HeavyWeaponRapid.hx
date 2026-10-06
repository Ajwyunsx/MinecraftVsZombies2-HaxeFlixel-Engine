// Ported from: Assets/Scripts/Vanilla/GameContent/Seeds/HeavyWeaponRapid.cs
package mvz2.gamecontent.seeds;

import mvz2.gamecontent.contraptions.Snipenser;
import mvz2.gamecontent.contraptions.VanillaContraptionID;
import mvz2.gamecontent.seeds.VanillaBlueprintID.VanillaBlueprintNames;
import mvz2.vanilla.audios.VanillaSoundID;
import mvz2logic.blueprints.LogicBlueprintErrors;
import mvz2logic.blueprints.SeedOptionDefinition;
import mvz2logic.entities.LogicEntityExt;
import pvzengine.entities.Entity;
import pvzengine.level.LevelEngine;
import pvzengine.seedpacks.EngineSeedProps;
import pvzengine.seedpacks.SeedDefinition;
import pvzengine.seedpacks.SeedPack;

@:autoSeedOptionDefinition(VanillaBlueprintNames.heavyWeaponRapid)
class HeavyWeaponRapid extends SeedOptionDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
    }
    public override function Update(seedPack:SeedPack, rechargeSpeed:Float):Void
    {
        super.Update(seedPack, rechargeSpeed);
        seedPack.SetProperty(EngineSeedProps.DISABLE_ID, IsValid(seedPack) ? null : LogicBlueprintErrors.invalid);
    }
    public override function Use(seedPack:SeedPack):Void
    {
        super.Use(seedPack);
        UseLevel(seedPack.Level);
    }
    // PORT-NOTE: Haxe has no method overloading; C# 重载 Use(LevelEngine, SeedDefinition) → UseWithDefinition。
    public override function UseWithDefinition(level:LevelEngine, seedDef:SeedDefinition):Void
    {
        super.UseWithDefinition(level, seedDef);
        // TODO-PORT: 原 C# 此处为 `Use(level, seedDef)` 自递归调用，疑似上游笔误，按 1:1 保留。
        UseWithDefinition(level, seedDef);
    }
    function UseLevel(level:LevelEngine):Void
    {
        var target = FindTargetEntity(level);
        if (target == null)
            return;
        Snipenser.UpgradeRapid(target);
        LogicEntityExt.PlaySound(target, VanillaSoundID.gunReload);
    }
    function FindTargetEntity(level:LevelEngine):Null<Entity>
    {
        return level.FindFirstEntity(e -> e.IsEntityOf(VanillaContraptionID.snipenser) && Snipenser.CanUpgradeRapid(e));
    }
    function IsValid(seedPack:SeedPack):Bool
    {
        var level = seedPack.Level;
        return FindTargetEntity(level) != null;
    }
}
