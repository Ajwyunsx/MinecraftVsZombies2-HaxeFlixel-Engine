// Ported from: Assets/Scripts/Vanilla/GameContent/Seeds/HeavyWeaponFlashbang.cs
package mvz2.gamecontent.seeds;

import mvz2.gamecontent.effects.VanillaEffectID;
import mvz2.gamecontent.seeds.VanillaBlueprintID.VanillaBlueprintNames;
import mvz2.vanilla.audios.VanillaSoundID;
import mvz2.vanilla.entities.VanillaEntityExt;
import mvz2.vanilla.entities.VanillaEntityProps;
import mvz2logic.blueprints.SeedOptionDefinition;
import mvz2logic.entities.LogicEntityExt;
import mvz2logic.level.LogicLevelExt;
import pvzengine.level.LevelEngine;
import pvzengine.seedpacks.SeedDefinition;
import pvzengine.seedpacks.SeedPack;

@:autoSeedOptionDefinition(VanillaBlueprintNames.heavyWeaponFlashbang)
class HeavyWeaponFlashbang extends SeedOptionDefinition
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
        var pos = level.GetLawnCenter();
        level.Spawn(VanillaEffectID.stunningFlash, pos, null);
        var stunned = false;
        for (target in level.FindEntities(e -> LogicEntityExt.IsVulnerableEntity(e) && LogicEntityExt.IsHostileEntity(e) && VanillaEntityProps.CanDeactive(e)))
        {
            VanillaEntityExt.Stun(target, 150);
            stunned = true;
        }
        if (stunned)
        {
            LogicLevelExt.PlaySound(level, VanillaSoundID.stunned);
        }
    }
}
