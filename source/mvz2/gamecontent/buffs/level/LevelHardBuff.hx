// Ported from: Assets/Scripts/Vanilla/GameContent/Buffs/Level/Difficulty/LevelHardBuff.cs
package mvz2.gamecontent.buffs.level;

import mvz2.gamecontent.buffs.VanillaBuffID;
import mvz2.gamecontent.buffs.VanillaBuffNames;
import mvz2.gamecontent.difficulties.VanillaDifficultyLevelProps;
import mvz2.gamecontent.enemies.VanillaEnemyID;
import mvz2logic.blueprints.LogicBlueprintID;
import mvz2logic.level.LogicLevelProps;
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

@:autoBuffDefinition(VanillaBuffNames.Level_levelHard)
class LevelHardBuff extends BuffDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
        AddModifier(new BooleanModifier(LogicLevelProps.NO_CARTS, true));

        AddModifier(new FloatModifier(VanillaDifficultyLevelProps.GUNPOWDER_DAMAGE_MULTIPLIER, NumberOperator.Multiply, 2));
        AddModifier(new FloatModifier(VanillaDifficultyLevelProps.ELASTIC_CLOUD_BOUNCE_DAMAGE_MULTIPLIER, NumberOperator.Multiply, 1.5));

        AddModifier(new FloatModifier(LogicLevelProps.SPAWN_POINTS_POWER, NumberOperator.AddMultiple, 0.2));
        AddModifier(new IntModifier(VanillaDifficultyLevelProps.NAPSTABLOOK_PARALYSIS_TIME, IntegerOperator.Multiply, 2));
        AddModifier(new FloatModifier(VanillaDifficultyLevelProps.GHAST_DAMAGE_MULTIPLIER, NumberOperator.Add, 1));
        AddModifier(new IntModifier(VanillaDifficultyLevelProps.MOTHER_TERROR_EGG_COUNT, IntegerOperator.Add, 1));
        AddModifier(new IntModifier(VanillaDifficultyLevelProps.PARASITIZED_TERROR_COUNT, IntegerOperator.Add, 1));
        AddModifier(new FloatModifier(VanillaDifficultyLevelProps.REVERSE_SATELLITE_DAMAGE_MULTIPLIER, NumberOperator.AddMultiple, 1));
        AddModifier(new IntModifier(VanillaDifficultyLevelProps.SKELETON_HORSE_JUMP_TIMES, IntegerOperator.Add, 1));
        AddModifier(new IntModifier(VanillaDifficultyLevelProps.WICKED_HERMIT_ZOMBIE_STUN_TIME, IntegerOperator.Add, -75));
        AddModifier(new FloatModifier(VanillaDifficultyLevelProps.WISP_FLY_DAMAGE_MULTIPLIER, NumberOperator.Multiply, 2));

        AddModifier(new BooleanModifier(VanillaDifficultyLevelProps.FRANKENSTEIN_INSTANT_STEEL, true));
        AddModifier(new FloatModifier(VanillaDifficultyLevelProps.FRANKENSTEIN_SPEED, NumberOperator.Multiply, 2));

        AddModifier(new BooleanModifier(VanillaDifficultyLevelProps.SLENDERMAN_MIND_SWAP_ZOMBIES, true));
        AddModifier(new IntModifier(VanillaDifficultyLevelProps.SLENDERMAN_FATE_CHOICE_COUNT, IntegerOperator.Add, -1));
        AddModifier(new IntModifier(VanillaDifficultyLevelProps.SLENDERMAN_MAX_FATE_TIMES, IntegerOperator.Add, 1));

        AddModifier(new FloatModifier(VanillaDifficultyLevelProps.CRUSHING_WALLS_SPEED, NumberOperator.Add, 1));
        AddModifier(new FloatModifier(VanillaDifficultyLevelProps.NIGHTMAREAPER_SPIN_DAMAGE, NumberOperator.Add, 10));
        AddModifier(new IntModifier(VanillaDifficultyLevelProps.NIGHTMAREAPER_TIMEOUT, IntegerOperator.Add, -900));

        AddModifier(new BooleanModifier(VanillaDifficultyLevelProps.WITHER_SKULL_WITHERS_TARGET, true));
        AddModifier(new BooleanModifier(VanillaDifficultyLevelProps.THE_GIANT_IS_MALLEABLE, true));

        AddModifier(new FloatModifier(VanillaDifficultyLevelProps.RED_DRAGON_FIRE_EXPLOSION_RADIUS, NumberOperator.Multiply, 2));
        AddModifier(new FloatModifier(VanillaDifficultyLevelProps.RED_DRAGON_GIANT_FIREBALL_SPEED, NumberOperator.Multiply, 3));
        AddModifier(new IntModifier(VanillaDifficultyLevelProps.RED_DRAGON_TORNADO_COUNT, IntegerOperator.Set, 3));

        AddModifier(new NamespaceIDModifier(VanillaDifficultyLevelProps.LOCKED_CHEST_SPIT_BLUEPRINT_ID, SetOperator.Set, LogicBlueprintID.FromEntity(VanillaEnemyID.ironHelmettedZombie)));
        AddModifier(new IntModifier(VanillaDifficultyLevelProps.LOCKED_CHEST_REQUIRED_STARSHARDS, IntegerOperator.Add, 1));
        AddAura(new EnemyAura());
    }
}

// PORT-NOTE: C# 嵌套类 LevelHardBuff.EnemyAura → Haxe 模块子类型，访问路径一致。
class EnemyAura extends AuraEffectDefinition
{
    public function new()
    {
        super(VanillaBuffID.Enemy.hardEnemy, 30);
    }

    public override function GetAuraTargets(auraEffect:AuraEffect, results:Array<IBuffTarget>):Void
    {
        var level = auraEffect.Source.GetLevel();
        // C#: results.AddRange(level.GetEntities(EntityTypes.ENEMY));（Haxe 侧逐项 push）
        for (entity in level.GetEntities(EntityTypes.ENEMY))
        {
            results.push(entity);
        }
    }
}
