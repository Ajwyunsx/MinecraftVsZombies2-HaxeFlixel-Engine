// Ported from: Assets/Scripts/Vanilla/GameContent/Contraptions/Chapter2/Anvil.cs
package mvz2.gamecontent.contraptions;

import mvz2.gamecontent.damages.VanillaDamageEffects;
import mvz2.gamecontent.detections.CollisionDetector;
import mvz2.vanilla.audios.VanillaSoundID;
import mvz2.vanilla.detection.Detector;
import mvz2.vanilla.entities.VanillaEntityExt;
import mvz2logic.entities.LogicEntityExt;
import pvzengine.collisions.IEntityCollider;
import pvzengine.damages.DamageEffectList;
import pvzengine.entities.Entity;
import pvzengine.entities.EntityCollision;
import pvzengine.entities.EntityCollisionHelper;
import unity.Mathf;
import unity.Vector3;
using mvz2.vanilla.entities.VanillaColliderExt;
using mvz2logic.entities.LogicEntityExt;
using mvz2logic.entities.LogicEntityProps;

@:autoEntityBehaviourDefinition(VanillaContraptionNames.anvil)
class Anvil extends ContraptionBehaviour
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
        smashDetector = new CollisionDetector(true);
    }
    public override function Init(entity:Entity):Void
    {
        super.Init(entity);
        entity.CollisionMaskFriendly |= EntityCollisionHelper.MASK_PLANT | EntityCollisionHelper.MASK_ENEMY | EntityCollisionHelper.MASK_OBSTACLE | EntityCollisionHelper.MASK_BOSS;
        entity.CollisionMaskHostile |= EntityCollisionHelper.MASK_PLANT | EntityCollisionHelper.MASK_ENEMY | EntityCollisionHelper.MASK_OBSTACLE | EntityCollisionHelper.MASK_BOSS;
    }
    public override function PostCollision(collision:EntityCollision, state:Int):Void
    {
        super.PostCollision(collision, state);
        if (state != EntityCollisionHelper.STATE_ENTER)
            return;
        if (!collision.Collider.IsForMain())
            return;
        var anvil = collision.Entity;
        if (anvil.Velocity == Vector3.zero)
            return;
        var other = collision.Other;
        if (!CanSmash(anvil, other))
            return;
        var damageModifier = Mathf.Clamp(anvil.Velocity.magnitude, 0, 1);
        collision.OtherCollider.TakeDamage(1800 * damageModifier, new DamageEffectList([VanillaDamageEffects.IMPACT, VanillaDamageEffects.MUTE, VanillaDamageEffects.DAMAGE_BOTH_ARMOR_AND_BODY]), anvil);
    }
    public override function CanEvoke(entity:Entity):Bool
    {
        return false;
    }
    public override function PostContactGround(anvil:Entity, velocity:Vector3):Void
    {
        super.PostContactGround(anvil, velocity);

        if (velocity != Vector3.zero)
        {
            smashBuffer = [];
            smashDetector.DetectMultiple(DetectionParams.fromEntity(anvil), smashBuffer);
            for (target in smashBuffer)
            {
                var other = target.Entity;
                if (CanSmash(anvil, other))
                {
                    var damageModifier = Mathf.Clamp(velocity.magnitude, 0, 1);
                    target.TakeDamage(1800 * damageModifier, new DamageEffectList([VanillaDamageEffects.IMPACT, VanillaDamageEffects.MUTE, VanillaDamageEffects.DAMAGE_BOTH_ARMOR_AND_BODY]), anvil);
                }
            }
        }

        anvil.PlaySound(VanillaSoundID.anvil);

        var grids = anvil.GetGridsToTake();
        for (grid in grids)
        {
            if (grid == null)
                continue;
            var selfGridLayers = anvil.GetGridLayersToTake();
            if (selfGridLayers != null)
            {
                for (layer in selfGridLayers)
                {
                    var ent = grid.GetLayerEntity(layer);
                    if (ent != null && CanSmash(anvil, ent))
                    {
                        ent.Die(new DamageEffectList([VanillaDamageEffects.IMPACT, VanillaDamageEffects.INSTA_KILL]), anvil, null);
                    }
                }
            }
        }
    }
    public static function CanSmash(anvil:Entity, other:Entity):Bool
    {
        if (other == anvil)
            return false;
        if (!other.IsVulnerableEntity())
            return false;
        if (anvil.IsHostile(other))
            return true;
        var selfGridLayers = anvil.GetGridLayersToTake();
        var otherGridLayers = other.GetGridLayersToTake();
        if (selfGridLayers == null || otherGridLayers == null)
            return false;
        return Lambda.exists(selfGridLayers, l -> Lambda.has(otherGridLayers, l));
    }
    var smashBuffer:Array<IEntityCollider> = [];
    var smashDetector:Detector;
}
