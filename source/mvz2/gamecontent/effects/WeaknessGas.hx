// Ported from: Assets/Scripts/Vanilla/GameContent/Effects/Chapter2/WeaknessGas.cs
package mvz2.gamecontent.effects;

import mvz2.vanilla.entities.VanillaEntityExt;
import mvz2logic.entities.LogicEntityExt;
import pvzengine.entities.Entity;
import pvzengine.entities.EntityCollision;
import pvzengine.entities.EntityCollisionHelper;
import pvzengine.entities.EntitySourceReference;
import pvzengine.entities.EntityTypes;
import mvz2.gamecontent.effects.VanillaEffectID.VanillaEffectNames;
using mvz2.vanilla.entities.VanillaEntityExt;

@:autoEntityBehaviourDefinition(VanillaEffectNames.weaknessGas)
class WeaknessGas extends EffectBehaviour
{
    // #region 公有方法
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
    }
    public override function Init(entity:Entity):Void
    {
        super.Init(entity);
        entity.CollisionMaskHostile |=
            EntityCollisionHelper.MASK_PLANT |
            EntityCollisionHelper.MASK_ENEMY |
            EntityCollisionHelper.MASK_BOSS |
            EntityCollisionHelper.MASK_OBSTACLE |
            EntityCollisionHelper.MASK_PROJECTILE |
            EntityCollisionHelper.MASK_EFFECT;
    }
    public override function PostCollision(collision:EntityCollision, state:Int):Void
    {
        super.PostCollision(collision, state);
        var entity = collision.Entity;
        var other = collision.Other;
        if (state == EntityCollisionHelper.STATE_EXIT)
            return;
        if (GasBehaviour.IsDisappearing(entity))
            return;
        if (other.IsDead)
            return;
        if (other.Type != EntityTypes.ENEMY)
            return;
        other.InflictWeakness(150, new EntitySourceReference(entity));
    }
    // #endregion
}
