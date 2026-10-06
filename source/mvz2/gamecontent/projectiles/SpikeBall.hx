// Ported from: Assets/Scripts/Vanilla/GameContent/Projectiles/Chapter2/SpikeBall.cs
package mvz2.gamecontent.projectiles;

import mvz2.gamecontent.damages.VanillaDamageEffects;
import mvz2.gamecontent.effects.VanillaEffectID;
import mvz2.vanilla.audios.VanillaSoundID;
import mvz2.vanilla.detection.Detection;
import mvz2.vanilla.entities.VanillaEntityExt;
import mvz2.vanilla.entities.VanillaEntityProps;
import mvz2logic.entities.LogicEntityExt;
import pvzengine.damages.DamageEffectList;
import pvzengine.definitions.EntityBehaviourDefinition;
import pvzengine.entities.Entity;
import unity.Vector3;
using mvz2.vanilla.entities.VanillaEntityExt;
using mvz2.vanilla.entities.VanillaEntityProps;
using mvz2logic.entities.LogicEntityExt;

@:autoEntityBehaviourDefinition(VanillaProjectileNames.spikeBall)
class SpikeBall extends EntityBehaviourDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
    }
    public override function Init(entity:Entity):Void
    {
        super.Init(entity);
        entity.CollisionMaskHostile = 0;
        entity.CollisionMaskFriendly = 0;
    }
    public override function PostContactGround(entity:Entity, velocity:Vector3):Void
    {
        super.PostContactGround(entity, velocity);
        var position = entity.Position;
        position.y = entity.GetGroundY();
        var param = entity.GetSpawnParams();
        param.SetProperty(VanillaEntityProps.DAMAGE, entity.GetDamage());
        // C#: entity.Spawn(...)?.Let(spike => { ... })
        var spike = entity.Spawn(VanillaEffectID.giantSpike, position, param);
        if (spike != null)
        {
            spike.PlaySound(VanillaSoundID.giantSpike);
            for (target in entity.Level.FindEntities(enemy -> IsEnemyAndInRange(spike, enemy)))
            {
                target.TakeDamage(spike.GetDamage(), new DamageEffectList([VanillaDamageEffects.IGNORE_ARMOR]), spike);
            }
        }
        entity.Remove();
    }
    function IsEnemyAndInRange(self:Entity, target:Entity):Bool
    {
        if (!target.IsVulnerableEntity())
            return false;
        if (!Detection.CanDetect(target))
            return false;
        if (!self.IsHostile(target))
            return false;
        if (!self.GetBounds().IntersectsOptimized(target.GetBounds()))
            return false;
        return true;
    }
}
