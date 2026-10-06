// Ported from: Assets/Scripts/Vanilla/GameContent/Seeds/HeavyWeaponNuke.cs
package mvz2.gamecontent.seeds;

import mvz2.gamecontent.buffs.enemies.RedstoneCarrierBuff;
import mvz2.gamecontent.contraptions.Nuke;
import mvz2.gamecontent.damages.VanillaDamageEffects;
import mvz2.gamecontent.seeds.VanillaBlueprintID.VanillaBlueprintNames;
import mvz2.vanilla.entities.VanillaEntityExt;
import mvz2logic.blueprints.SeedOptionDefinition;
import mvz2logic.entities.LogicEntityExt;
import mvz2logic.level.LogicLevelExt;
import pvzengine.damages.DamageEffectList;
import pvzengine.entities.EngineEntityProps;
import pvzengine.entities.SpawnParams;
import pvzengine.level.LevelEngine;
import pvzengine.seedpacks.SeedDefinition;
import pvzengine.seedpacks.SeedPack;
import unity.Color;

@:autoSeedOptionDefinition(VanillaBlueprintNames.heavyWeaponNuke)
class HeavyWeaponNuke extends SeedOptionDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
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
        var deathEffects = new DamageEffectList(VanillaDamageEffects.INSTA_KILL, VanillaDamageEffects.MUTE, VanillaDamageEffects.NO_DEATH_EFFECTS, VanillaDamageEffects.REMOVE_ON_DEATH);

        for (ent in level.FindEntities(e -> LogicEntityExt.IsHostileEntity(e)))
        {
            ent.RemoveBuffs(RedstoneCarrierBuff);
            VanillaEntityExt.DieOrRemove(ent, deathEffects, null);
        }

        var smokeSpawnParam = new SpawnParams();
        smokeSpawnParam.SetProperty(EngineEntityProps.TINT, new Color(0, 0.5, 0, 1));
        var position = level.GetLawnCenter();
        Nuke.ExplodeEffectsAt(level, position, null, smokeSpawnParam);
    }
}
