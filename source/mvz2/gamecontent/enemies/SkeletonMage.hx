// Ported from: Assets/Scripts/Vanilla/GameContent/Enemies/Chapter4/SkeletonMage.cs
package mvz2.gamecontent.enemies;

import mvz2.gamecontent.detections.DispenserDetector;
import mvz2.gamecontent.entities.AIEntityBehaviour;
import mvz2.gamecontent.projectiles.VanillaProjectileID;
import mvz2.vanilla.audios.VanillaSoundID;
import mvz2.vanilla.detection.Detector;
import mvz2.vanilla.entities.VanillaEntityExt;
import mvz2.vanilla.entities.VanillaEntityProps;
import mvz2.vanilla.projectiles.VanillaProjectileExt;
import mvz2.vanilla.properties.VanillaEntityPropertyMeta;
import mvz2logic.entities.LogicEnemyStates;
import mvz2logic.entities.LogicEntityExt;
import mvz2logic.level.LogicLevelExt;
import pvzengine.NamespaceID;
import pvzengine.entities.Entity;
import pvzengine.modifiers.NamespaceIDModifier;
import pvzengine.modifiers.SetOperator;
import tools.FrameTimer;
using mvz2.vanilla.entities.VanillaEntityProps;
using mvz2.vanilla.projectiles.VanillaProjectileExt;
using mvz2logic.entities.LogicEntityProps;
using tools.EnumerableExt;

@:autoEntityBehaviourDefinition(VanillaEnemyNames.skeletonMage)
class SkeletonMage extends AIEntityBehaviour
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
        detector = new DispenserDetector();
        cast(detector, DispenserDetector).ignoreHighEnemy = true;
        cast(detector, DispenserDetector).ignoreLowEnemy = true;
        AddModifier(new NamespaceIDModifier(VanillaEntityProps.PROJECTILE_ID, SetOperator.Set, PROP_PROJECTILE_ID));
    }
    public override function Init(entity:Entity):Void
    {
        super.Init(entity);
        SetStateTimer(entity, new FrameTimer(ATTACK_CAST_TIME));
        if (entity.GetVariant() == VARIANT_RANDOM)
        {
            entity.SetVariant(mageVariants.Random(entity.RNG));
        }
    }
    override function UpdateAI(entity:Entity):Void
    {
        super.UpdateAI(entity);
        switch (entity.State)
        {
            case STATE_WALK:
                UpdateStateWalk(entity);
            case STATE_CAST:
                UpdateStateCast(entity);
            case STATE_RANGED_ATTACK:
                UpdateStateAttack(entity);
        }
    }
    override function UpdateLogic(entity:Entity):Void
    {
        super.UpdateLogic(entity);
        var enemyClass = entity.GetVariant();
        switch (enemyClass)
        {
            case VARIANT_FROST:
                entity.SetProperty(PROP_PROJECTILE_ID, VanillaProjectileID.iceBolt);
            case VARIANT_LIGHTNING:
                entity.SetProperty(PROP_PROJECTILE_ID, VanillaProjectileID.chargedBolt);
            default:
                entity.SetProperty(PROP_PROJECTILE_ID, VanillaProjectileID.fireball);
        }
    }
    function UpdateStateWalk(enemy:Entity):Void
    {
        UpdateTarget(enemy);
        var timer = GetStateTimer(enemy);
        if (timer != null)
        {
            timer.ResetTime(ATTACK_CAST_TIME);
        }
    }
    function UpdateStateCast(enemy:Entity):Void
    {
        var timer = GetStateTimer(enemy);
        if (timer == null)
            return;
        timer.Run(enemy.GetAttackSpeed());
        if (timer.Expired)
        {
            SetAttackState(enemy, ATTACK_STATE_FIRE);
            timer.ResetTime(ATTACK_FIRE_TIME);
        }
    }
    function UpdateStateAttack(enemy:Entity):Void
    {
        var timer = GetStateTimer(enemy);
        if (timer == null)
            return;
        timer.Run(enemy.GetAttackSpeed());
        if (timer.Expired)
        {
            var attackState = GetAttackState(enemy);
            if (attackState == ATTACK_STATE_FIRE)
            {
                SetAttackState(enemy, ATTACK_STATE_RESTORE);
                timer.ResetTime(ATTACK_RESTORE_TIME);
                Shoot(enemy);
            }
            else if (attackState == ATTACK_STATE_RESTORE)
            {
                UpdateTarget(enemy);
                SetAttackState(enemy, ATTACK_STATE_CAST);
                timer.ResetTime(ATTACK_CAST_TIME);
            }
        }
    }
    function UpdateTarget(enemy:Entity):Void
    {
        if (CanShoot(enemy))
        {
            if (enemy.Target != null && !ValidateTarget(enemy, enemy.Target))
            {
                enemy.Target = null;
            }
            enemy.Target = FindTarget(enemy);
        }
        else
        {
            enemy.Target = null;
        }
    }
    function Shoot(enemy:Entity):Void
    {
        var enemyClass = enemy.GetVariant();
        switch (enemyClass)
        {
            case VARIANT_FROST:
            {
                var param = enemy.GetShootParams();
                param.damage = enemy.GetDamage() * 0.2;
                param.soundID = VanillaSoundID.snow;
                enemy.ShootProjectile(param);
            }
            case VARIANT_LIGHTNING:
            {
                var param = enemy.GetShootParams();
                param.damage = enemy.GetDamage() * 0.2;
                param.soundID = null;
                param.velocity *= 0.4;
                for (i in 0...3)
                {
                    enemy.ShootProjectile(param);
                }
            }
            default:
            {
                var param = enemy.GetShootParams();
                param.damage = enemy.GetDamage() * 0.8;
                param.soundID = VanillaSoundID.fire;
                enemy.ShootProjectile(param);
            }
        }
    }
    public static function SetStateTimer(enemy:Entity, value:FrameTimer):Void enemy.SetBehaviourField(PROP_STATE_TIMER, value);
    public static function GetStateTimer(enemy:Entity):Null<FrameTimer> return enemy.GetBehaviourField(PROP_STATE_TIMER);
    public static function SetAttackState(enemy:Entity, value:Int):Void enemy.SetBehaviourField(PROP_ATTACK_STATE, value);
    public static function GetAttackState(enemy:Entity):Int return enemy.GetBehaviourField(PROP_ATTACK_STATE);
    function CanShoot(enemy:Entity):Bool
    {
        return enemy.Position.x <= enemy.Level.GetEntityColumnX(enemy.Level.GetMaxColumnCount() - 1);
    }
    function FindTarget(entity:Entity):Null<Entity>
    {
        var collider = detector.Detect(DetectionParams.fromEntity(entity));
        return collider != null ? collider.Entity : null;
    }
    function ValidateTarget(entity:Entity, target:Entity):Bool
    {
        return detector.ValidateTarget(DetectionParams.fromEntity(entity), target);
    }
    var detector:Detector;
    public static inline var STATE_WALK:Int = LogicEnemyStates.WALK;
    public static inline var STATE_CAST:Int = LogicEnemyStates.CAST;
    public static inline var STATE_RANGED_ATTACK:Int = LogicEnemyStates.RANGED_ATTACK;

    public static inline var ATTACK_STATE_CAST:Int = 0;
    public static inline var ATTACK_STATE_FIRE:Int = 1;
    public static inline var ATTACK_STATE_RESTORE:Int = 2;

    public static inline var ATTACK_CAST_TIME:Int = 5;
    public static inline var ATTACK_FIRE_TIME:Int = 5;
    public static inline var ATTACK_RESTORE_TIME:Int = 20;

    public static inline var VARIANT_RANDOM:Int = 0;
    public static inline var VARIANT_FIRE:Int = 1;
    public static inline var VARIANT_FROST:Int = 2;
    public static inline var VARIANT_LIGHTNING:Int = 3;
    public static var PROP_ATTACK_STATE:VanillaEntityPropertyMeta<Int> = new VanillaEntityPropertyMeta<Int>("attackState");
    public static var PROP_STATE_TIMER:VanillaEntityPropertyMeta<FrameTimer> = new VanillaEntityPropertyMeta<FrameTimer>("attackTimer");
    public static var PROP_PROJECTILE_ID:VanillaEntityPropertyMeta<NamespaceID> = new VanillaEntityPropertyMeta<NamespaceID>("projectile_id");
    public static var mageVariants:Array<Int> = [
        SkeletonMage.VARIANT_FIRE,
        SkeletonMage.VARIANT_FROST,
        SkeletonMage.VARIANT_LIGHTNING
    ];
}
