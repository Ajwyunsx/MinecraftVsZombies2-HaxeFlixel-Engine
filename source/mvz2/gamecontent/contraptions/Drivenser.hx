// Ported from: Assets/Scripts/Vanilla/GameContent/Contraptions/Chapter2/Drivenser.cs
package mvz2.gamecontent.contraptions;

import mvz2.gamecontent.effects.VanillaEffectID;
import mvz2.gamecontent.projectiles.VanillaProjectileID;
import mvz2.vanilla.audios.VanillaSoundID;
import mvz2.vanilla.entities.VanillaEntityExt;
import mvz2.vanilla.properties.VanillaEntityPropertyMeta;
import mvz2logic.entities.LogicEntityExt;
import mvz2logic.level.LogicLevelExt;
import pvzengine.NamespaceID;
import pvzengine.entities.Entity;
import tools.FrameTimer;
import unity.Mathf;
using mvz2.vanilla.entities.VanillaEntityProps;
using mvz2.vanilla.projectiles.VanillaProjectileExt;
using mvz2logic.entities.LogicContraptionProps;
using mvz2logic.entities.LogicEntityExt;

@:autoEntityBehaviourDefinition(VanillaContraptionNames.drivenser)
class Drivenser extends DispenserFamily
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
    }

    public override function Init(entity:Entity):Void
    {
        super.Init(entity);
        InitShootTimer(entity);
        SetRepeatTimer(entity, new FrameTimer(15));
        if (entity.Level.IsIZombie())
        {
            SetUpgradeLevel(entity, I_ZOMBIE_LEVEL);
        }
    }
    override function UpdateAI(entity:Entity):Void
    {
        super.UpdateAI(entity);
        if (!entity.IsEvoked())
        {
            ShootTick(entity);
            var repeatCount = GetRepeatCount(entity);
            if (repeatCount > 0)
            {
                var repeatTimer = GetRepeatTimer(entity);
                if (repeatTimer.RunToExpiredAndNotNull(entity.GetAttackSpeed()))
                {
                    Shoot(entity);
                    SetRepeatCount(entity, repeatCount - 1);
                    repeatTimer.Reset();
                }
            }
        }
        else
        {
            var shootTimer = DispenserFamily.GetShootTimer(entity);
            if (shootTimer.RunToExpiredAndNotNull())
            {
                entity.TriggerAnimation("Shoot");
                var shootParams = entity.GetShootParams();
                shootParams.projectileID = VanillaProjectileID.largeArrow;
                shootParams.damage = entity.GetDamage() * 30;
                shootParams.soundID = VanillaSoundID.spellCard;
                shootParams.velocity = shootParams.velocity.normalized;
                entity.ShootProjectile(shootParams);

                var repeatCount = GetRepeatCount(entity);
                repeatCount--;
                SetRepeatCount(entity, repeatCount);
                if (repeatCount <= 0)
                {
                    entity.SetEvoked(false);
                }
                shootTimer.ResetTime(GetTimerTime(entity));
            }
        }
        var blockerBlend = GetBlockerBlend(entity);
        blockerBlend = blockerBlend * 0.5 + GetUpgradeLevel(entity) * 0.5;
        SetBlockerBlend(entity, blockerBlend);
    }
    override function UpdateLogic(entity:Entity):Void
    {
        super.UpdateLogic(entity);
        var blend = GetBlockerBlend(entity);
        entity.SetModelProperty("Level", GetUpgradeLevel(entity));
        entity.SetAnimationFloat("BlockerBlend", blend);
        entity.SetAnimationFloat("RotateSpeed", blend + 1);
    }
    public override function OnShootTick(entity:Entity):Void
    {
        var count = GetUpgradeLevel(entity) + 1;
        SetRepeatCount(entity, count);
        var repeatTimer = GetRepeatTimer(entity);
        if (repeatTimer != null)
        {
            repeatTimer.ResetTime(Mathf.FloorToInt(15 / count));
            repeatTimer.Frame = 0;
        }
    }

    override function OnEvoke(entity:Entity):Void
    {
        super.OnEvoke(entity);
        entity.SetEvoked(true);
        SetRepeatCount(entity, 5);
    }
    public static function GetRepeatTimer(entity:Entity):Null<FrameTimer> return entity.GetBehaviourFieldNS(ID, PROP_REPEAT_TIMER);
    public static function SetRepeatTimer(entity:Entity, timer:FrameTimer):Void entity.SetBehaviourFieldNS(ID, PROP_REPEAT_TIMER, timer);

    public static function GetRepeatCount(entity:Entity):Int return entity.GetBehaviourFieldNS(ID, PROP_REPEAT_COUNT);
    public static function SetRepeatCount(entity:Entity, count:Int):Void entity.SetBehaviourFieldNS(ID, PROP_REPEAT_COUNT, count);

    public static function GetUpgradeLevel(entity:Entity):Int return entity.GetBehaviourFieldNS(ID, PROP_UPGRADE_LEVEL);
    public static function SetUpgradeLevel(entity:Entity, value:Int):Void entity.SetBehaviourFieldNS(ID, PROP_UPGRADE_LEVEL, value);

    public static function GetBlockerBlend(entity:Entity):Float return entity.GetBehaviourFieldNS(ID, PROP_BLOCKER_BLEND);
    public static function SetBlockerBlend(entity:Entity, value:Float):Void entity.SetBehaviourFieldNS(ID, PROP_BLOCKER_BLEND, value);

    public static function CanUpgrade(drivenser:Entity):Bool
    {
        return drivenser.IsEntityOf(VanillaContraptionID.drivenser) && drivenser.IsFriendlyEntity() && GetUpgradeLevel(drivenser) < MAX_UPGRADE_LEVEL;
    }
    public static function Upgrade(drivenser:Entity):Void
    {
        if (!drivenser.IsEntityOf(VanillaContraptionID.drivenser))
            return;
        SetUpgradeLevel(drivenser, GetUpgradeLevel(drivenser) + 1);
        drivenser.PlaySound(VanillaSoundID.mechanism);
        drivenser.Level.Spawn(VanillaEffectID.gearParticles, drivenser.Position, drivenser);
    }
    public static inline var MAX_UPGRADE_LEVEL:Int = 4;
    public static inline var I_ZOMBIE_LEVEL:Int = 2;
    static var ID:NamespaceID = VanillaContraptionID.drivenser;
    public static var PROP_REPEAT_TIMER:VanillaEntityPropertyMeta<FrameTimer> = new VanillaEntityPropertyMeta<FrameTimer>("RepeatTimer");
    public static var PROP_REPEAT_COUNT:VanillaEntityPropertyMeta<Int> = new VanillaEntityPropertyMeta<Int>("RepeatCount");
    public static var PROP_UPGRADE_LEVEL:VanillaEntityPropertyMeta<Int> = new VanillaEntityPropertyMeta<Int>("UpgradeLevel");
    public static var PROP_BLOCKER_BLEND:VanillaEntityPropertyMeta<Float> = new VanillaEntityPropertyMeta<Float>("BlockerBlend");
}
