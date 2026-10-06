// Ported from: Assets/Scripts/Vanilla/GameContent/Projectiles/Chapter6/CannonMissile.cs
package mvz2.gamecontent.projectiles;

import mvz2.vanilla.properties.VanillaEntityPropertyMeta;
import pvzengine.definitions.EntityBehaviourDefinition;
import pvzengine.entities.Entity;
import tools.FrameTimer;
import tools.Ticks;
import unity.Vector3;

@:autoEntityBehaviourDefinition(VanillaProjectileNames.cannonMissile)
class CannonMissile extends EntityBehaviourDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
    }
    public override function Init(entity:Entity):Void
    {
        super.Init(entity);
        SetTimer(entity, new FrameTimer(GetFallTime(entity)));
    }
    public override function Update(entity:Entity):Void
    {
        super.Update(entity);
        if (IsFalling(entity))
            return;
        var timer = GetTimer(entity);
        if (pvzengine.TimerHelper.RunToExpiredOrNull(timer))
        {
            SetFalling(entity, true);
            var velocity = entity.Velocity;
            velocity = Vector3.down * velocity.magnitude;
            entity.Velocity = velocity;

            var position = GetTargetPosition(entity);
            position.y = entity.Level.GetGroundY(position.x, position.z) - velocity.y * GetFallTime(entity);
            entity.Position = position;
        }
    }
    public static function IsFalling(entity:Entity):Bool return entity.GetProperty(PROP_FALLING);
    public static function SetFalling(entity:Entity, value:Bool):Void entity.SetProperty(PROP_FALLING, value);
    public static function GetFallTime(entity:Entity):Int return entity.GetProperty(PROP_FALL_TIME);
    public static function SetFallTime(entity:Entity, value:Int):Void entity.SetProperty(PROP_FALL_TIME, value);
    public static function GetTimer(entity:Entity):Null<FrameTimer> return entity.GetProperty(PROP_TIMER);
    public static function SetTimer(entity:Entity, value:Null<FrameTimer>):Void entity.SetProperty(PROP_TIMER, value);
    public static function GetTargetPosition(entity:Entity):Vector3 return entity.GetProperty(PROP_TARGET_POSITION);
    public static function SetTargetPosition(entity:Entity, value:Vector3):Void entity.SetProperty(PROP_TARGET_POSITION, value);
    public static inline var VARIANT_NORMAL:Int = 0;
    public static inline var VARIANT_DANGER:Int = 1;
    public static var PROP_FALLING:VanillaEntityPropertyMeta<Bool> = new VanillaEntityPropertyMeta<Bool>("falling");
    public static var PROP_FALL_TIME:VanillaEntityPropertyMeta<Int> = new VanillaEntityPropertyMeta<Int>("fall_time", Ticks.FromSeconds(1));
    public static var PROP_TIMER:VanillaEntityPropertyMeta<FrameTimer> = new VanillaEntityPropertyMeta<FrameTimer>("timer");
    public static var PROP_TARGET_POSITION:VanillaEntityPropertyMeta<Vector3> = new VanillaEntityPropertyMeta<Vector3>("target_position");
}
