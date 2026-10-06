// Ported from: Assets/Scripts/Vanilla/GameContent/Effects/Chapter5/CombatSmash.cs
package mvz2.gamecontent.effects;

import mvz2.gamecontent.damages.VanillaDamageEffects;
import mvz2.vanilla.audios.VanillaSoundID;
import mvz2.vanilla.entities.VanillaEntityExt;
import mvz2.vanilla.level.VanillaLevelExt;
import mvz2logic.entities.LogicEntityExt;
import pvzengine.damages.DamageEffectList;
import pvzengine.entities.Entity;
import unity.Vector3;
import mvz2.gamecontent.effects.VanillaEffectID.VanillaEffectNames;
using mvz2.vanilla.entities.VanillaEntityProps;
using mvz2logic.entities.LogicEntityExt;

@:autoEntityBehaviourDefinition(VanillaEffectNames.combatSmash)
class CombatSmash extends EffectBehaviour
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
    }
    public override function Init(entity:Entity):Void
    {
        super.Init(entity);
        var position = entity.Position;
        position.y += 1000;
        entity.Position = position;
        entity.Velocity = Vector3.down * 60;
        // C#: entity.Spawn(...)?.Let(e => { e.SetParent(entity); })
        var trail = entity.Spawn(VanillaEffectID.combatSmashTrail, entity.Position);
        if (trail != null)
        {
            trail.SetParent(entity);
        }
    }
    public override function Update(entity:Entity):Void
    {
        super.Update(entity);
        if (entity.IsOnGround)
        {
            var level = entity.Level;
            var faction = entity.GetFaction();
            var radius = entity.GetRange();
            var damage = 1800;
            var damageEffects = new DamageEffectList([VanillaDamageEffects.EXPLOSION, VanillaDamageEffects.MUTE, VanillaDamageEffects.DAMAGE_BODY_AFTER_ARMOR_BROKEN]);
            level.Explode(entity.Position, radius, faction, damage, damageEffects, entity);
            Explosion.SpawnOnLevel(level, entity.Position, radius);
            entity.PlaySound(VanillaSoundID.meteorLand);
            entity.PlaySound(VanillaSoundID.impact);
            entity.Level.ShakeScreen(15, 0, 30);
            entity.Remove();
        }
    }
}
