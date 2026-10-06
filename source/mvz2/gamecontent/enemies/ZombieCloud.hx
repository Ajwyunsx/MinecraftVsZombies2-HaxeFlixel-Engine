// Ported from: Assets/Scripts/Vanilla/GameContent/Enemies/Chapter5/ZombieCloud.cs
package mvz2.gamecontent.enemies;

import mvz2.gamecontent.buffs.VanillaBuffID;
import mvz2.gamecontent.buffs.enemies.FlyBuff;
import mvz2.gamecontent.contraptions.TeslaCoil;
import mvz2.gamecontent.damages.VanillaDamageEffects;
import mvz2.gamecontent.effects.VanillaEffectID;
import mvz2.gamecontent.entities.AIEntityBehaviour;
import mvz2.vanilla.audios.VanillaSoundID;
import mvz2.vanilla.callbacks.VanillaLevelCallbacks;
import mvz2.vanilla.entities.VanillaEntityExt;
import mvz2logic.level.LogicLevelExt;
import pvzengine.EngineEntityProps;
import pvzengine.buffs.BuffExt;
import pvzengine.callbacks.CallbackResult;
import pvzengine.damages.DamageInput;
import pvzengine.damages.DeathInfo;
import pvzengine.entities.Entity;
import unity.Color;
import unity.Color32;
import unity.Vector3;
using mvz2.vanilla.entities.VanillaEntityExt;
using mvz2.vanilla.entities.VanillaEntityProps;
using mvz2logic.entities.LogicEntityExt;
using mvz2logic.entities.LogicEntityProps;

@:autoEntityBehaviourDefinition(VanillaEnemyNames.zombieCloud)
class ZombieCloud extends AIEntityBehaviour
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
        AddTrigger(VanillaLevelCallbacks.PRE_APPLY_STATUS_EFFECT, PreEntitySlowCallback, VanillaBuffID.Enemy.slow);
    }
    public override function Init(entity:Entity):Void
    {
        super.Init(entity);
        var buff = entity.AddBuff(FlyBuff);
        buff.SetProperty(FlyBuff.PROP_TARGET_HEIGHT, 80);
        buff.SetProperty(FlyBuff.PROP_WORKS_ON_FROZEN, true);
    }
    override function UpdateAI(entity:Entity):Void
    {
        super.UpdateAI(entity);
        var variant = entity.GetVariant();
        if (variant == ZombieCloud.VARIANT_NORMAL || variant == ZombieCloud.VARIANT_THUNDER)
        {
            if (entity.IsSecondsInterval(0.25))
            {
                var x = entity.RNG.NextFloat() * 32 - 16;
                var pos = entity.Position + new Vector3(x, 0, 0);
                entity.Spawn(VanillaEffectID.zombieCloudRaindrop, pos);
            }
        }
        if (variant == ZombieCloud.VARIANT_THUNDER)
        {
            if (entity.IsSecondsInterval(3))
            {
                var position = entity.Position;
                position.y = entity.Level.GetGroundY(position);
                TeslaCoil.Shock(entity, entity.GetDamage() * THUNDER_DAMAGE_MULTIPLIER, entity.GetFaction(), THUNDER_SHOCK_RADIUS, position);
                TeslaCoil.CreateArc(entity, entity.Position, position);
                entity.PlaySound(VanillaSoundID.thunder);
            }
        }
        if (variant == ZombieCloud.VARIANT_SNOW)
        {
            if (entity.IsSecondsInterval(0.25))
            {
                var x = entity.RNG.NextFloat() * 32 - 16;
                var pos = entity.Position + new Vector3(x, 0, 0);
                entity.Spawn(VanillaEffectID.zombieCloudSnowflake, pos);
            }
        }
    }
    public override function PreTakeDamage(input:DamageInput, result:CallbackResult):Void
    {
        super.PreTakeDamage(input, result);
        if (input.HasEffect(VanillaDamageEffects.LIGHTNING))
        {
            ChangeVariant(input.Entity, VARIANT_THUNDER);
            input.Multiply(0);
            result.Break();
            return;
        }
        if (input.HasEffect(VanillaDamageEffects.ICE))
        {
            ChangeVariant(input.Entity, VARIANT_SNOW);
            input.Multiply(0);
            result.Break();
            return;
        }
    }
    public override function PostDeath(entity:Entity, info:DeathInfo):Void
    {
        super.PostDeath(entity, info);
        var param = entity.GetSpawnParams();
        param.SetProperty(EngineEntityProps.TINT, GetSmokeColor(entity));
        entity.Spawn(VanillaEffectID.smokeCluster, entity.GetCenter(), param);
        entity.Remove();
    }
    public static function ChangeVariant(entity:Entity, variant:Int):Void
    {
        if (entity.GetVariant() == variant)
            return;
        entity.SetVariant(variant);
        var param = entity.GetSpawnParams();
        param.SetProperty(EngineEntityProps.TINT, GetSmokeColor(entity));
        entity.Spawn(VanillaEffectID.smokeCluster, entity.GetCenter(), param);
    }
    static function GetSmokeColor(entity:Entity):Color
    {
        switch (entity.GetVariant())
        {
            case VARIANT_THUNDER:
                return SMOKE_COLOR_THUNDER;
            case VARIANT_SNOW:
                return SMOKE_COLOR_SNOW;
        }
        return SMOKE_COLOR_NORMAL;
    }
    function PreEntitySlowCallback(param:PreApplyStatusEffectParams, result:CallbackResult):Void
    {
        var entity = param.entity;
        if (!entity.IsEntityOf(VanillaEnemyID.zombieCloud))
            return;
        ChangeVariant(entity, VARIANT_SNOW);
        result.SetFinalValue(false);
    }
    public static inline var VARIANT_NORMAL:Int = 0;
    public static inline var VARIANT_THUNDER:Int = 1;
    public static inline var VARIANT_SNOW:Int = 2;

    public static inline var THUNDER_DAMAGE_MULTIPLIER:Float = 1;
    public static inline var THUNDER_SHOCK_RADIUS:Float = 20;
    public static var SMOKE_COLOR_NORMAL:Color = cast new Color32(241, 191, 227, 255);
    public static var SMOKE_COLOR_THUNDER:Color = cast new Color32(54, 54, 54, 255);
    public static var SMOKE_COLOR_SNOW:Color = cast new Color32(191, 228, 241, 255);
}
