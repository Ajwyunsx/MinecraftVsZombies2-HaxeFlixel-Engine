// Ported from: Assets/Scripts/Vanilla/GameContent/Contraptions/Chapter5/GunpowderBarrel.cs
package mvz2.gamecontent.contraptions;

import mvz2.gamecontent.buffs.entities.WhiteFlashBuff;
import mvz2.gamecontent.damages.VanillaDamageEffects;
import mvz2.gamecontent.effects.Explosion;
import mvz2.gamecontent.pickups.VanillaPickupID;
import mvz2.vanilla.audios.VanillaSoundID;
import mvz2.vanilla.callbacks.VanillaLevelCallbacks;
import mvz2.vanilla.entities.VanillaEntityExt;
import mvz2.vanilla.entities.VanillaEntityProps;
import mvz2.vanilla.properties.VanillaEntityPropertyMeta;
import mvz2logic.entities.IDeathEffectsBehaviour;
import mvz2logic.entities.LogicEntityExt;
import mvz2logic.level.LogicLevelExt;
import pvzengine.EngineEntityProps;
import pvzengine.callbacks.EntityCallbackParams;
import pvzengine.damages.DamageEffectList;
import pvzengine.damages.DeathInfo;
import pvzengine.entities.Entity;
import pvzengine.modifiers.ColorModifier;
import tools.FrameTimer;
import unity.Color;
import unity.Mathf;
using mvz2.gamecontent.difficulties.VanillaDifficultyLevelProps;
using mvz2.vanilla.entities.VanillaEntityExt;
using mvz2.vanilla.entities.VanillaEntityProps;
using mvz2.vanilla.pickups.VanillaPickupExt;
using mvz2.vanilla.pickups.VanillaPickupProps;
using mvz2logic.entities.LogicEntityExt;
import mvz2.vanilla.pickups.VanillaPickupProps;

@:autoEntityBehaviourDefinition(VanillaContraptionNames.gunpowderBarrel)
class GunpowderBarrel extends ContraptionBehaviour implements IDeathEffectsBehaviour
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
        AddModifier(new ColorModifier(EngineEntityProps.COLOR_OFFSET, PROP_COLOR_OFFSET));
    }
    public override function Init(entity:Entity):Void
    {
        super.Init(entity);

        var productionTimer = new FrameTimer(entity.RNG.Next(PRODUCTION_TIME_START_MIN, PRODUCTION_TIME_START_MAX));
        SetProductionTimer(entity, productionTimer);

        if (entity.Level.IsIZombie())
        {
            entity.SetCanDeactive(false);
        }
    }
    override function UpdateAI(entity:Entity):Void
    {
        super.UpdateAI(entity);
        if (!entity.Level.IsIZombie())
        {
            ProductionUpdate(entity);
        }
    }
    override function UpdateLogic(entity:Entity):Void
    {
        super.UpdateLogic(entity);
        entity.SetModelProperty("Furious", IsFurious(entity));
    }
    public function DeathEffects(entity:Entity, deathInfo:DeathInfo):Void
    {
        var damage = entity.GetDamage() * entity.Level.GetGunpowderDamageMultiplier();

        if (entity.Level.IsIZombie())
        {
            damage = entity.GetDamage() * I_ZOMBIE_EXPLOSION_DAMAGE_MULTIPLIER;
        }
        var range = entity.GetRange();
        var effects = new DamageEffectList([VanillaDamageEffects.EXPLOSION, VanillaDamageEffects.DAMAGE_BODY_AFTER_ARMOR_BROKEN, VanillaDamageEffects.MUTE]);
        entity.ExplodeAgainstFriendly(entity.GetCenter(), range, entity.GetFaction(), damage, effects);

        Explosion.Spawn(entity, entity.GetCenter(), range);

        entity.PlaySound(VanillaSoundID.explosion);

        entity.Level.Triggers.RunCallbackFiltered(VanillaLevelCallbacks.POST_CONTRAPTION_DETONATE, new EntityCallbackParams(entity), entity.GetDefinitionID());
    }
    public override function CanEvoke(entity:Entity):Bool
    {
        if (IsFurious(entity))
            return false;
        return super.CanEvoke(entity);
    }
    override function OnEvoke(entity:Entity):Void
    {
        super.OnEvoke(entity);
        SetFurious(entity, true);
        WhiteFlashBuff.AddToEntity(entity, 15);
        entity.PlaySound(VanillaSoundID.fuse);
    }
    public static function GetProductionTimer(entity:Entity):Null<FrameTimer> return entity.GetBehaviourField(PROP_PRODUCTION_TIMER);
    public static function SetProductionTimer(entity:Entity, timer:FrameTimer):Void entity.SetBehaviourField(PROP_PRODUCTION_TIMER, timer);
    public static function IsFurious(entity:Entity):Bool return entity.GetBehaviourField(PROP_FURIOUS);
    public static function SetFurious(entity:Entity, value:Bool):Void entity.SetBehaviourField(PROP_FURIOUS, value);
    function ProductionUpdate(entity:Entity):Void
    {
        var productionTimer = GetProductionTimer(entity);
        if (productionTimer == null)
            return;
        productionTimer.Run(entity.GetProduceSpeed());
        if (entity.Level.IsNoEnergy())
        {
            productionTimer.Frame = productionTimer.MaxFrame;
        }

        var color = entity.GetProperty(PROP_COLOR_OFFSET);
        var colorValue = color.a;
        if (productionTimer.Frame < 30)
        {
            colorValue = Mathf.Lerp(1, 0, productionTimer.Frame / 30);
        }
        else
        {
            colorValue = Mathf.Max(0, colorValue - 1 / 30);
        }
        color.r = 1;
        color.g = 1;
        color.b = 1;
        color.a = colorValue;
        entity.SetProperty(PROP_COLOR_OFFSET, color);

        if (productionTimer.Expired)
        {
            var pickupID = IsFurious(entity) ? VanillaPickupID.furiousGunpowder : VanillaPickupID.gunpowder;
            if (entity.IsFriendlyEntity())
            {
                var spawnParams = entity.GetSpawnParams();
                spawnParams.SetProperty(VanillaEntityProps.DAMAGE, entity.GetDamage());
                spawnParams.SetProperty(VanillaEntityProps.RANGE, entity.GetRange());
                entity.Produce(pickupID);
                entity.PlaySound(VanillaSoundID.throwSound);
            }
            else
            {
                var redstoneDefinition = entity.Level.Content.GetEntityDefinition(pickupID);
                var energyValue = redstoneDefinition != null ? VanillaPickupProps.GetEnergyValueOfDefinition(redstoneDefinition) : 50;
                entity.Level.AddEnergy(-energyValue);
            }
            productionTimer.ResetTime(PRODUCTION_TIME);
        }
    }
    public static inline var PRODUCTION_TIME_START_MIN:Int = 90;
    public static inline var PRODUCTION_TIME_START_MAX:Int = 360;
    public static inline var PRODUCTION_TIME:Int = 1080;
    public static inline var I_ZOMBIE_EXPLOSION_DAMAGE_MULTIPLIER:Float = 3;
    static var PROP_PRODUCTION_TIMER:VanillaEntityPropertyMeta<FrameTimer> = new VanillaEntityPropertyMeta<FrameTimer>("ProductionTimer");
    static var PROP_FURIOUS:VanillaEntityPropertyMeta<Bool> = new VanillaEntityPropertyMeta<Bool>("fury");
    static var PROP_COLOR_OFFSET:VanillaEntityPropertyMeta<Color> = new VanillaEntityPropertyMeta<Color>("color_offset");
}
