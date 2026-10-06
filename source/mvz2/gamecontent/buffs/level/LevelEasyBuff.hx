// Ported from: Assets/Scripts/Vanilla/GameContent/Buffs/Level/Difficulty/LevelEasyBuff.cs
package mvz2.gamecontent.buffs.level;

import mvz2.gamecontent.buffs.VanillaBuffID;
import mvz2.gamecontent.buffs.VanillaBuffNames;
import mvz2.gamecontent.difficulties.VanillaDifficultyLevelProps;
import mvz2.gamecontent.enemies.VanillaEnemyID;
import mvz2.vanilla.entities.VanillaEntityExt;
import mvz2logic.blueprints.LogicBlueprintID;
import mvz2logic.level.LogicStageProps;
import pvzengine.auras.AuraEffect;
import pvzengine.auras.AuraEffectDefinition;
import pvzengine.buffs.IBuffTarget;
import pvzengine.definitions.BuffDefinition;
import pvzengine.entities.EntityTypes;
import pvzengine.modifiers.BooleanModifier;
import pvzengine.modifiers.FloatModifier;
import pvzengine.modifiers.IntModifier;
import pvzengine.modifiers.IntegerOperator;
import pvzengine.modifiers.NamespaceIDModifier;
import pvzengine.modifiers.NumberOperator;
import pvzengine.modifiers.SetOperator;

@:autoBuffDefinition(VanillaBuffNames.Level_levelEasy)
class LevelEasyBuff extends BuffDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
        AddAura(new BlueprintAura());
        AddAura(new ContraptionAura());
        AddAura(new ArmorAura());
        AddModifier(new FloatModifier(LogicStageProps.CONVEY_SPEED, NumberOperator.Multiply, 1.5));

        AddModifier(new FloatModifier(VanillaDifficultyLevelProps.GUNPOWDER_DAMAGE_MULTIPLIER, NumberOperator.Multiply, 0.66666666666));

        AddModifier(new IntModifier(VanillaDifficultyLevelProps.NAPSTABLOOK_PARALYSIS_TIME, IntegerOperator.Add, -22));
        AddModifier(new IntModifier(VanillaDifficultyLevelProps.MOTHER_TERROR_EGG_COUNT, IntegerOperator.Add, -1));
        AddModifier(new IntModifier(VanillaDifficultyLevelProps.PARASITIZED_TERROR_COUNT, IntegerOperator.Add, -1));
        AddModifier(new FloatModifier(VanillaDifficultyLevelProps.REVERSE_SATELLITE_DAMAGE_MULTIPLIER, NumberOperator.AddMultiple, -1));
        AddModifier(new IntModifier(VanillaDifficultyLevelProps.SKELETON_HORSE_JUMP_TIMES, IntegerOperator.Add, -1));
        AddModifier(new IntModifier(VanillaDifficultyLevelProps.WICKED_HERMIT_ZOMBIE_STUN_TIME, IntegerOperator.Add, 75));
        AddModifier(new FloatModifier(VanillaDifficultyLevelProps.WISP_FLY_DAMAGE_MULTIPLIER, NumberOperator.Multiply, 0.66666666666));

        AddModifier(new BooleanModifier(VanillaDifficultyLevelProps.FRANKENSTEIN_NO_STEEL, true));

        AddModifier(new IntModifier(VanillaDifficultyLevelProps.SLENDERMAN_FATE_CHOICE_COUNT, IntegerOperator.Add, 1));
        AddModifier(new IntModifier(VanillaDifficultyLevelProps.SLENDERMAN_MAX_FATE_TIMES, IntegerOperator.Add, -1));

        AddModifier(new FloatModifier(VanillaDifficultyLevelProps.CRUSHING_WALLS_SPEED, NumberOperator.Add, -1));
        AddModifier(new FloatModifier(VanillaDifficultyLevelProps.NIGHTMAREAPER_SPIN_DAMAGE, NumberOperator.Add, -10));
        AddModifier(new IntModifier(VanillaDifficultyLevelProps.NIGHTMAREAPER_TIMEOUT, IntegerOperator.Add, 900));

        AddModifier(new FloatModifier(VanillaDifficultyLevelProps.WITHER_REGENERATION, NumberOperator.Set, 0));

        AddModifier(new NamespaceIDModifier(VanillaDifficultyLevelProps.LOCKED_CHEST_SPIT_BLUEPRINT_ID, SetOperator.Set, LogicBlueprintID.FromEntity(VanillaEnemyID.zombie)));

        AddModifier(new FloatModifier(VanillaDifficultyLevelProps.STARSHARD_CARRIER_COUNTER_INCREAMENT, NumberOperator.Multiply, 2));
        AddModifier(new FloatModifier(VanillaDifficultyLevelProps.REDSTONE_CARRIER_COUNTER_INCREAMENT, NumberOperator.Multiply, 2));
    }
}

// PORT-NOTE: C# 嵌套类 LevelEasyBuff.BlueprintAura → Haxe 模块子类型，访问路径一致。
class BlueprintAura extends AuraEffectDefinition
{
    public function new()
    {
        super(VanillaBuffID.SeedPack.easyBlueprint, 30);
    }

    public override function GetAuraTargets(auraEffect:AuraEffect, results:Array<IBuffTarget>):Void
    {
        var level = auraEffect.Source.GetLevel();
        for (seed in level.GetAllSeedPacks())
        {
            if (seed == null)
                continue;
            results.push(seed);
        }
    }
}

class ContraptionAura extends AuraEffectDefinition
{
    public function new()
    {
        super(VanillaBuffID.Contraption.easyContraption, 4);
    }

    public override function GetAuraTargets(auraEffect:AuraEffect, results:Array<IBuffTarget>):Void
    {
        var level = auraEffect.Source.GetLevel();
        // C#: results.AddRange(level.GetEntities(EntityTypes.PLANT));（Haxe 侧逐项 push）
        for (entity in level.GetEntities(EntityTypes.PLANT))
        {
            results.push(entity);
        }
    }
}

class ArmorAura extends AuraEffectDefinition
{
    public function new()
    {
        super(VanillaBuffID.Armor.easyArmor);
    }

    public override function GetAuraTargets(auraEffect:AuraEffect, results:Array<IBuffTarget>):Void
    {
        var level = auraEffect.Source.GetLevel();
        // C#: level.GetEntities(EntityTypes.ENEMY).Select(e => e.GetMainArmor()).OfType<Armor>()
        for (entity in level.GetEntities(EntityTypes.ENEMY))
        {
            var armor = VanillaEntityExt.GetMainArmor(entity);
            if (armor == null)
                continue;
            results.push(armor);
        }
    }
}
