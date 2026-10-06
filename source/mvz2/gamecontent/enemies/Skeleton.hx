// Ported from: Assets/Scripts/Vanilla/GameContent/Enemies/Chapter1/Skeleton.cs
package mvz2.gamecontent.enemies;

import mvz2.gamecontent.detections.DispenserDetector;
import mvz2.gamecontent.entities.AIEntityBehaviour;
import mvz2.vanilla.detection.Detector;
import mvz2.vanilla.entities.VanillaEntityExt;
import mvz2.vanilla.projectiles.VanillaProjectileExt;
import mvz2.vanilla.properties.VanillaEntityPropertyMeta;
import mvz2logic.entities.LogicEnemyStates;
import mvz2logic.entities.LogicEntityExt;
import mvz2logic.level.LogicLevelExt;
import pvzengine.entities.Entity;
import unity.Mathf;
using mvz2.vanilla.entities.VanillaEntityProps;
using mvz2.vanilla.projectiles.VanillaProjectileExt;
using mvz2.vanilla.entities.VanillaEntityExt;

@:autoEntityBehaviourDefinition(VanillaEnemyNames.skeleton)
class Skeleton extends AIEntityBehaviour
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
        detector = new DispenserDetector();
        cast(detector, DispenserDetector).ignoreHighEnemy = true;
        cast(detector, DispenserDetector).ignoreLowEnemy = true;
    }
    override function UpdateAI(enemy:Entity):Void
    {
        super.UpdateAI(enemy);
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

        switch (enemy.State)
        {
            case STATE_RANGED_ATTACK:
                PullBow(enemy);
            default:
                UnleaseBow(enemy);
        }
    }
    override function UpdateLogic(entity:Entity):Void
    {
        super.UpdateLogic(entity);
        entity.SetAnimationFloat("BowBlend", 1 - Mathf.Pow(1 - GetBowPower(entity) / BOW_POWER_MAX, 2));
        entity.SetAnimationBool("ArrowVisible", !GetBowFired(entity));
    }
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
    function PullBow(entity:Entity):Void
    {
        var bowFired = GetBowFired(entity);
        var bowPower = GetBowPower(entity);
        if (!bowFired)
        {
            bowPower += Std.int(entity.GetAttackSpeed() * BOW_POWER_PULL_SPEED);
            if (bowPower >= BOW_POWER_MAX)
            {
                bowPower = BOW_POWER_MAX;
                SetBowFired(entity, true);

                ShootArrow(entity);
            }
        }
        else
        {
            bowPower -= Std.int(entity.GetAttackSpeed() * BOW_POWER_RESTORE_SPEED);
            if (bowPower <= 0)
            {
                bowPower = 0;
                SetBowFired(entity, false);
            }
        }
        SetBowPower(entity, bowPower);
    }
    function UnleaseBow(enemy:Entity):Void
    {
        SetBowFired(enemy, false);
        var bowPower = GetBowPower(enemy);
        if (bowPower > 0)
        {
            bowPower -= Std.int(enemy.GetAttackSpeed() * BOW_POWER_RESTORE_SPEED);
            // PORT-NOTE: C# Mathf.Max(int,int) 重载在 Haxe 中改名为 Mathf.MaxInt（bowPower 为 Int）。
            bowPower = Mathf.MaxInt(bowPower, 0);
        }
        SetBowPower(enemy, bowPower);
    }
    function ShootArrow(entity:Entity):Void
    {
        // C#: entity.ShootProjectile()?.Let(e => { ... })
        var e = entity.ShootProjectile();
        if (e != null)
        {
            if (IsArrowFlame(entity))
            {
                e.HellfireIgnite(entity, false);
            }
        }
    }
    public static function GetBowPower(enemy:Entity):Int return enemy.GetProperty(PROP_BOW_POWER);
    public static function SetBowPower(enemy:Entity, value:Int):Void enemy.SetProperty(PROP_BOW_POWER, value);
    public static function GetBowFired(enemy:Entity):Bool return enemy.GetProperty(PROP_BOW_FIRED);
    public static function SetBowFired(enemy:Entity, value:Bool):Void enemy.SetProperty(PROP_BOW_FIRED, value);
    public static function IsArrowFlame(enemy:Entity):Bool return enemy.GetProperty(PROP_FLAME);
    public static function SetArrowFlame(enemy:Entity, value:Bool):Void enemy.SetProperty(PROP_FLAME, value);
    var detector:Detector;
    public static var PROP_BOW_FIRED:VanillaEntityPropertyMeta<Bool> = new VanillaEntityPropertyMeta<Bool>("bowFired");
    public static var PROP_BOW_POWER:VanillaEntityPropertyMeta<Int> = new VanillaEntityPropertyMeta<Int>("bowPower");
    public static var PROP_FLAME:VanillaEntityPropertyMeta<Bool> = new VanillaEntityPropertyMeta<Bool>("flame");
    public static inline var STATE_WALK:Int = LogicEnemyStates.WALK;
    public static inline var STATE_RANGED_ATTACK:Int = LogicEnemyStates.RANGED_ATTACK;
    public static inline var BOW_POWER_PULL_SPEED:Int = 100;
    public static inline var BOW_POWER_RESTORE_SPEED:Int = 1000;
    public static inline var BOW_POWER_MAX:Int = 10000;
}
