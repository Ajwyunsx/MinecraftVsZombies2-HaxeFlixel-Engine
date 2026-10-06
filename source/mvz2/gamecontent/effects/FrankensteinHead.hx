// Ported from: Assets/Scripts/Vanilla/GameContent/Effects/Chapter1/FrankensteinHead.cs
package mvz2.gamecontent.effects;

import mvz2.vanilla.entities.VanillaEntityExt;
import pvzengine.entities.Entity;
import unity.Vector3;
import mvz2.gamecontent.effects.VanillaEffectID.VanillaEffectNames;
using mvz2.vanilla.entities.VanillaEntityExt;

@:autoEntityBehaviourDefinition(VanillaEffectNames.frankensteinHead)
class FrankensteinHead extends EffectBehaviour
{
    // #region 公有方法
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
    }
    public override function Update(entity:Entity):Void
    {
        super.Update(entity);
        entity.RenderRotation += new Vector3(0, 0, -entity.Velocity.x);
    }
    public override function PostContactGround(entity:Entity, velocity:Vector3):Void
    {
        super.PostContactGround(entity, velocity);
        if (entity.IsAboveCloud())
            return;
        var vel = entity.Velocity;
        vel.y *= -0.4;
        entity.Velocity = vel;
    }
    public static function SetSteelPhase(entity:Entity, steel:Bool):Void
    {
        entity.SetModelProperty("Steel", steel);
    }
    // #endregion
}
