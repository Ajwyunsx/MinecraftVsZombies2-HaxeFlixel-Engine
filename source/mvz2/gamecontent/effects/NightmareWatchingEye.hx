// Ported from: Assets/Scripts/Vanilla/GameContent/Effects/Chapter2/NightmareWatchingEye.cs
package mvz2.gamecontent.effects;

import mvz2.vanilla.properties.VanillaEntityPropertyMeta;
import pvzengine.entities.Entity;
import tools.VectorExt;
import unity.Vector2;
import mvz2.gamecontent.effects.VanillaEffectID.VanillaEffectNames;

@:autoEntityBehaviourDefinition(VanillaEffectNames.nightmareWatchingEye)
class NightmareWatchingEye extends EffectBehaviour
{
    // #region 公有方法
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
    }
    public override function Init(entity:Entity):Void
    {
        super.Init(entity);
        SetEyeMoveCooldown(entity, 90);
    }
    public override function Update(entity:Entity):Void
    {
        super.Update(entity);
        var cooldown = GetEyeMoveCooldown(entity);
        cooldown--;
        if (cooldown <= 0)
        {
            var rng = entity.RNG;
            cooldown = rng.Next(60, 150);
            var radius = rng.NextFloat() * 1;
            var angle = rng.NextFloat() * 360;
            var target = VectorExt.RotateClockwise(Vector2.right, angle) * radius;
            SetEyeTarget(entity, target);
        }
        SetEyeMoveCooldown(entity, cooldown);

        var eyeTarget = GetEyeTarget(entity);
        var eyeDirection = GetEyeDirection(entity);
        eyeDirection = eyeDirection * 0.5 + eyeTarget * 0.5;
        SetEyeDirection(entity, eyeDirection);

        entity.SetAnimationBool("Open", entity.Timeout < 0);
        entity.SetModelProperty("EyeDirection", eyeDirection);
    }
    // #endregion

    public static function GetEyeMoveCooldown(entity:Entity):Int
    {
        return entity.GetBehaviourField(PROP_EYE_MOVE_COOLDOWN);
    }
    public static function SetEyeMoveCooldown(entity:Entity, value:Int):Void
    {
        entity.SetBehaviourField(PROP_EYE_MOVE_COOLDOWN, value);
    }
    public static function GetEyeDirection(entity:Entity):Vector2
    {
        return entity.GetBehaviourField(PROP_EYE_DIRECTION);
    }
    public static function SetEyeDirection(entity:Entity, value:Vector2):Void
    {
        entity.SetBehaviourField(PROP_EYE_DIRECTION, value);
    }
    public static function GetEyeTarget(entity:Entity):Vector2
    {
        return entity.GetBehaviourField(PROP_EYE_TARGET);
    }
    public static function SetEyeTarget(entity:Entity, value:Vector2):Void
    {
        entity.SetBehaviourField(PROP_EYE_TARGET, value);
    }
    public static var PROP_EYE_DIRECTION:VanillaEntityPropertyMeta<Vector2> = new VanillaEntityPropertyMeta<Vector2>("EyeDirection");
    public static var PROP_EYE_TARGET:VanillaEntityPropertyMeta<Vector2> = new VanillaEntityPropertyMeta<Vector2>("EyeTarget");
    public static var PROP_EYE_MOVE_COOLDOWN:VanillaEntityPropertyMeta<Int> = new VanillaEntityPropertyMeta<Int>("EyeMoveCooldown");
}
