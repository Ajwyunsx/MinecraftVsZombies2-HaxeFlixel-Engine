// Ported from: Assets/Scripts/Vanilla/GameContent/Projectiles/Chapter3/SeijaBullet.cs
package mvz2.gamecontent.projectiles;

import mvz2.vanilla.properties.VanillaEntityPropertyMeta;
import pvzengine.definitions.EntityBehaviourDefinition;
import pvzengine.entities.Entity;
import tools.FrameTimer;

@:autoEntityBehaviourDefinition(VanillaProjectileNames.seijaBullet)
class SeijaBullet extends EntityBehaviourDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
    }
    public override function Init(entity:Entity):Void
    {
        super.Init(entity);
        SetStateChangeTimer(entity, new FrameTimer(15));
    }
    public override function Update(projectile:Entity):Void
    {
        super.Update(projectile);
        if (projectile.State < 2)
        {
            var timer = GetStateChangeTimer(projectile);
            if (timer.RunToExpiredAndNotNull())
            {
                timer.Reset();
                projectile.State++;
                SetDark(projectile, !IsDark(projectile));
            }
        }


        var vel = projectile.Velocity;
        var targetSpeed = IsDark(projectile) ? DARK_SPEED : LIGHT_SPEED;
        var magnitude = vel.magnitude;
        magnitude = magnitude * 0.9 + targetSpeed * 0.1;
        vel = vel.normalized * magnitude;
        projectile.Velocity = vel;
    }
    public static function SetDark(bullet:Entity, value:Bool):Void
    {
        bullet.SetProperty(PROP_DARK, value);
        bullet.SetModelProperty("Dark", value);
    }
    public static function IsDark(bullet:Entity):Bool return bullet.GetProperty(PROP_DARK);
    public static function SetStateChangeTimer(bullet:Entity, value:FrameTimer):Void bullet.SetProperty(PROP_STATE_CHANGE_TIMER, value);
    public static function GetStateChangeTimer(bullet:Entity):Null<FrameTimer> return bullet.GetProperty(PROP_STATE_CHANGE_TIMER);
    public static var PROP_DARK:VanillaEntityPropertyMeta<Bool> = new VanillaEntityPropertyMeta<Bool>("Dark");
    public static var PROP_STATE_CHANGE_TIMER:VanillaEntityPropertyMeta<FrameTimer> = new VanillaEntityPropertyMeta<FrameTimer>("StateChangeTimer");
    public static inline var LIGHT_SPEED:Float = 3;
    public static inline var DARK_SPEED:Float = 10;
}
