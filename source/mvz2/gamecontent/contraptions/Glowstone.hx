// Ported from: Assets/Scripts/Vanilla/GameContent/Contraptions/Chapter1/Glowstone.cs
package mvz2.gamecontent.contraptions;

import mvz2.gamecontent.buffs.VanillaBuffID;
import mvz2.gamecontent.buffs.contraptions.GlowstoneEvokeBuff;
import mvz2.gamecontent.effects.VanillaEffectID;
import mvz2.gamecontent.projectiles.VanillaProjectileID;
import mvz2.vanilla.audios.VanillaSoundID;
import mvz2.vanilla.entities.VanillaEntityExt;
import mvz2logic.entities.LogicEntityExt;
import mvz2logic.level.LogicLevelExt;
import pvzengine.auras.AuraEffect;
import pvzengine.auras.AuraEffectDefinition;
import pvzengine.auras.IBuffTarget;
import pvzengine.buffs.BuffExt;
import pvzengine.entities.Entity;
import pvzengine.entities.EntitySourceReference;
import pvzengine.entities.EntityTypes;
using mvz2.vanilla.entities.VanillaEntityExt;
using mvz2.vanilla.entities.VanillaEntityProps;
using mvz2logic.entities.LogicEntityExt;

@:autoEntityBehaviourDefinition(VanillaContraptionNames.glowstone)
class Glowstone extends ContraptionBehaviour
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
        AddAura(new GlowstoneAura());
    }
    public override function Init(entity:Entity):Void
    {
        super.Init(entity);
        entity.PlaySound(VanillaSoundID.glowstone);
        entity.UpdateShineRing();
    }
    override function UpdateLogic(entity:Entity):Void
    {
        super.UpdateLogic(entity);
        entity.UpdateShineRing();
    }
    override function OnEvoke(entity:Entity):Void
    {
        super.OnEvoke(entity);
        entity.AddBuff(GlowstoneEvokeBuff);
        entity.Level.Spawn(VanillaEffectID.stunningFlash, entity.GetCenter(), entity);
        var stunned = false;
        for (target in entity.Level.GetEntities())
        {
            if (target.Type == EntityTypes.ENEMY && target.IsHostile(entity) && target.CanDeactive())
            {
                target.Stun(150);
                stunned = true;
            }
            else if (target.Type == EntityTypes.PLANT && target.IsCharmed())
            {
                target.RemoveCharm(new EntitySourceReference(entity));
                target.PlaySound(VanillaSoundID.mindClear);
            }
            else if (target.IsEntityOf(VanillaProjectileID.compellingOrb) && target.IsHostile(entity))
            {
                target.Die();
            }
        }
        if (stunned)
        {
            entity.PlaySound(VanillaSoundID.stunned);
        }
    }
}

class GlowstoneAura extends AuraEffectDefinition
{
    public function new()
    {
        super(VanillaBuffID.Contraption.glowstoneProtected, 4);
    }

    public override function GetAuraTargets(auraEffect:AuraEffect, results:Array<IBuffTarget>):Void
    {
        if (!Std.isOfType(auraEffect.Source, Entity))
            return;
        var source:Entity = cast auraEffect.Source;
        if (source == null)
            return;
        detectBuffer.clear();
        var level = auraEffect.Level;
        level.GetIlluminatiingEntitiesNonAlloc(source, detectBuffer);
        for (id in detectBuffer.keys())
        {
            var ent = level.FindEntityByID(id);
            if (!ent.ExistsAndAlive() || !ent.IsVulnerableEntity())
                continue;
            results.push(ent);
        }
    }
    var detectBuffer:Map<haxe.Int64, Bool> = new Map();
}
