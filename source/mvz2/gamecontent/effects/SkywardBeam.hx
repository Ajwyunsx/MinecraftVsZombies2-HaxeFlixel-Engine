// Ported from: Assets/Scripts/Vanilla/GameContent/Effects/Chapter5/SkywardBeam.cs
package mvz2.gamecontent.effects;

import mvz2.gamecontent.damages.VanillaDamageEffects;
import mvz2.vanilla.audios.VanillaSoundID;
import mvz2.vanilla.entities.VanillaColliderExt;
import mvz2.vanilla.entities.VanillaEntityExt;
import mvz2logic.entities.LogicEntityExt;
import pvzengine.collisions.IEntityCollider;
import pvzengine.collisions.level.OverlapParams;
import pvzengine.damages.DamageEffectList;
import pvzengine.entities.Entity;
import pvzengine.entities.EntityCollisionHelper;
import mvz2.gamecontent.effects.VanillaEffectID.VanillaEffectNames;
using mvz2.vanilla.entities.VanillaEntityProps;
using mvz2.vanilla.entities.VanillaColliderExt;
using mvz2logic.entities.LogicEntityExt;

@:autoEntityBehaviourDefinition(VanillaEffectNames.skywardBeam)
class SkywardBeam extends EffectBehaviour
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
    }
    public override function Init(entity:Entity):Void
    {
        super.Init(entity);
        entity.CollisionMaskHostile |= EntityCollisionHelper.MASK_VULNERABLE;
        targetBuffer.resize(0);
        var overlapParam = OverlapParams.Hostile(entity.GetFaction(), EntityCollisionHelper.MASK_VULNERABLE);
        entity.Level.OverlapBoxNonAlloc(entity.GetCenter(), entity.GetScaledSize(), overlapParam, targetBuffer);
        var damage = entity.GetDamage();
        var effectList = new DamageEffectList([VanillaDamageEffects.LIGHT]);
        for (collider in targetBuffer)
        {
            collider.TakeDamage(damage, effectList, entity);
        }
        entity.PlaySound(VanillaSoundID.lightbeam);
    }
    private var targetBuffer:Array<IEntityCollider> = [];
}
