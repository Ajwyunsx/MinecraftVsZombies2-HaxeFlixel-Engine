// Ported from: Assets/Scripts/Vanilla/GameContent/Effects/Chapter3/MutantZombieWeapon.cs
package mvz2.gamecontent.effects;

import mvz2.vanilla.entities.VanillaEntityExt;
import pvzengine.entities.Entity;
import unity.Vector3;
import mvz2.gamecontent.effects.VanillaEffectID.VanillaEffectNames;
using mvz2.vanilla.entities.VanillaEntityExt;

@:autoEntityBehaviourDefinition(VanillaEffectNames.mutantZombieWeapon)
class MutantZombieWeapon extends EffectBehaviour
{
    // #region 公有方法
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
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
    // #endregion
}
