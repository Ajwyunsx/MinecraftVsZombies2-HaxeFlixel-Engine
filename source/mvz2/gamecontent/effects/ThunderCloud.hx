// Ported from: Assets/Scripts/Vanilla/GameContent/Effects/Chapter3/ThunderCloud.cs
package mvz2.gamecontent.effects;

import mvz2.gamecontent.contraptions.TeslaCoil;
import mvz2.gamecontent.damages.VanillaDamageEffects;
import mvz2.vanilla.audios.VanillaSoundID;
import mvz2.vanilla.entities.VanillaEntityExt;
import mvz2logic.entities.LogicEntityExt;
import mvz2logic.level.LogicLevelExt;
import pvzengine.damages.DamageEffectList;
import pvzengine.entities.Entity;
import tools.VectorExt;
import unity.Mathf;
import unity.Vector2;
import unity.Vector3;
import mvz2.gamecontent.effects.VanillaEffectID.VanillaEffectNames;
using mvz2.vanilla.entities.VanillaEntityProps;
using mvz2logic.entities.LogicEntityExt;

@:autoEntityBehaviourDefinition(VanillaEffectNames.thunderCloud)
class ThunderCloud extends EffectBehaviour
{
    // #region 公有方法
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
    }
    public override function Update(entity:Entity):Void
    {
        super.Update(entity);

        var size = entity.GetScaledSize();
        if (entity.Timeout > DISAPPEAR_TIMEOUT && entity.Timeout <= THUNDER_TIMEOUT)
        {
            var angle = entity.RNG.Next(360.0);
            var radius = entity.RNG.Next(Mathf.Min(size.x, size.z) * 0.5);
            var pos2D = VectorExt.RotateClockwise(Vector2.right, angle) * radius;
            var pos = entity.GetCenter() + new Vector3(pos2D.x, 0, pos2D.y);
            var targetPos = pos;
            targetPos.y = entity.Level.GetGroundY(pos.x, pos.z);
            TeslaCoil.Shock(entity, entity.GetDamage(), entity.GetFaction(), SHOCK_RADIUS, targetPos, new DamageEffectList([VanillaDamageEffects.LIGHTNING, VanillaDamageEffects.DAMAGE_BOTH_ARMOR_AND_BODY, VanillaDamageEffects.MUTE]));
            TeslaCoil.CreateArc(entity, pos, targetPos);

            Explosion.Spawn(entity, targetPos, SHOCK_RADIUS);

            if (entity.Timeout % 3 == 0)
            {
                entity.PlaySound(VanillaSoundID.thunder, entity.RNG.Next(0.75, 1.25));
                entity.PlaySound(VanillaSoundID.smash, entity.RNG.Next(0.75, 1.25), 0.5);
                entity.Level.ShakeScreen(5, 0, 3);
            }
        }

        entity.SetModelProperty("Size", size);
        entity.SetModelProperty("Stopped", entity.Timeout <= DISAPPEAR_TIMEOUT);
    }
    // #endregion

    public static inline var SHOCK_RADIUS:Float = 40;
    public static inline var THUNDER_TIMEOUT:Int = DISAPPEAR_TIMEOUT + 90;
    public static inline var DISAPPEAR_TIMEOUT:Int = 30;
}
