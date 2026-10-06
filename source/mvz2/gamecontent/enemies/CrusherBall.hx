// Ported from: Assets/Scripts/Vanilla/GameContent/Enemies/Chapter6/CrusherBall.cs
package mvz2.gamecontent.enemies;

import mvz2.vanilla.audios.VanillaSoundID;
import mvz2.vanilla.entities.VanillaEntityBehaviourNames;
import mvz2.vanilla.entities.VanillaEntityExt;
import pvzengine.definitions.EntityBehaviourDefinition;
import pvzengine.entities.Entity;
import pvzengine.entities.EntityCollision;
import pvzengine.entities.EntityCollisionHelper;
import pvzengine.entities.EntityTypes;
using mvz2.vanilla.entities.VanillaColliderExt;
using mvz2logic.entities.LogicEntityExt;

@:autoEntityBehaviourDefinition(VanillaEntityBehaviourNames.crusherBall)
class CrusherBall extends EntityBehaviourDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
    }

    public override function Init(entity:Entity):Void
    {
        super.Init(entity);
        entity.CollisionMaskHostile |= EntityCollisionHelper.MASK_CART;
    }

    public override function PostCollision(collision:EntityCollision, state:Int):Void
    {
        super.PostCollision(collision, state);
        if (state == EntityCollisionHelper.STATE_EXIT)
            return;
        if (!collision.Collider.IsForMain())
            return;
        var other = collision.Other;
        var bale = collision.Entity;
        if (!bale.IsHostile(other))
            return;

        if (other.Type == EntityTypes.CART)
        {
            other.Die(bale);
            other.PlaySound(VanillaSoundID.smash);
        }
        else if (other.IsVulnerableEntity())
        {
            HellChariot.Crush(bale, collision.OtherCollider);
        }
    }
}
