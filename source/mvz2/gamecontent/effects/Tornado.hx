// Ported from: Assets/Scripts/Vanilla/GameContent/Effects/Chapter5/Tornado.cs
package mvz2.gamecontent.effects;

import mvz2.gamecontent.buffs.entities.ClearGridOnLandBuff;
import mvz2.gamecontent.contraptions.GridFire;
import mvz2.vanilla.audios.VanillaSoundID;
import mvz2.vanilla.entities.IBeBlownBehaviour;
import mvz2.vanilla.entities.VanillaEntityExt;
import mvz2.vanilla.properties.VanillaEntityPropertyMeta;
import mvz2logic.entities.LogicEntityExt;
import mvz2logic.entities.LogicEntityProps;
import mvz2logic.level.LogicLevelExt;
import pvzengine.definitions.EntityBehaviourDefinition;
import pvzengine.entities.Entity;
import pvzengine.entities.EntityCollision;
import pvzengine.entities.EntityCollisionHelper;
import pvzengine.modifiers.BooleanModifier;
import unity.Vector3;
import mvz2.gamecontent.effects.VanillaEffectID.VanillaEffectNames;
using mvz2.vanilla.entities.VanillaEntityExt;
using mvz2logic.entities.LogicEntityExt;
using mvz2logic.entities.LogicEntityProps;

@:autoEntityBehaviourDefinition(VanillaEffectNames.tornado)
class Tornado extends EntityBehaviourDefinition implements IBeBlownBehaviour
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
        AddModifier(new BooleanModifier(LogicEntityProps.IS_LIGHT_SOURCE, PROP_IS_LIGHT_SOURCE));
    }
    public override function Init(entity:Entity):Void
    {
        super.Init(entity);
        entity.Level.AddLoopSoundEntity(VanillaSoundID.tornado, entity.ID);
        var mask = EntityCollisionHelper.MASK_PLANT | EntityCollisionHelper.MASK_ENEMY | EntityCollisionHelper.MASK_EFFECT;
        entity.CollisionMaskHostile |= mask;
        entity.CollisionMaskFriendly |= mask;
        UpdateVariant(entity);
    }
    public override function Update(entity:Entity):Void
    {
        super.Update(entity);
        UpdateVariant(entity);
        if (entity.GetVariant() == VARIANT_FIRE)
        {
            var grid = entity.GetGrid();
            if (grid != null)
            {
                var param = entity.GetSpawnParams();
                GridFire.Spawn(grid, entity, param);
            }
        }
    }

    private function UpdateVariant(entity:Entity):Void
    {
        var variant = entity.GetVariant();
        entity.SetProperty(PROP_IS_LIGHT_SOURCE, variant == VARIANT_FIRE);
    }
    public override function PostCollision(collision:EntityCollision, state:Int):Void
    {
        super.PostCollision(collision, state);
        if (state == EntityCollisionHelper.STATE_EXIT)
            return;
        var other = collision.Other;
        var self = collision.Entity;
        if (other.IsVulnerableEntity())
        {
            other.Velocity += Vector3.up * 1.5;
            if (!other.HasBuff(ClearGridOnLandBuff))
            {
                other.AddBuff(ClearGridOnLandBuff);
            }
        }
        else if (self.GetVariant() == VARIANT_NORMAL && other.IsEntityOf(VanillaEffectID.dragonFireBreath))
        {
            self.SetVariant(VARIANT_FIRE);
        }
    }
    public function BeBlown(entity:Entity, source:Entity):Void
    {
        var newVelocity = source.GetFacingDirection();
        newVelocity *= entity.Velocity.magnitude;
        entity.Velocity = newVelocity;
    }
    public static inline var VARIANT_NORMAL:Int = 0;
    public static inline var VARIANT_FIRE:Int = 1;
    public static var PROP_IS_LIGHT_SOURCE:VanillaEntityPropertyMeta<Bool> = new VanillaEntityPropertyMeta<Bool>("is_light_source");
}
