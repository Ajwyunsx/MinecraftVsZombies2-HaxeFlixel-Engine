// Ported from: Assets/Scripts/Vanilla/GameContent/Contraptions/Chapter3/StoneShield.cs
package mvz2.gamecontent.contraptions;

import mvz2.gamecontent.buffs.VanillaBuffID;
import mvz2.gamecontent.buffs.contraptions.IronCurtainBuff;
import mvz2.gamecontent.detections.SphereDetector;
import mvz2.vanilla.audios.VanillaSoundID;
import mvz2.vanilla.detection.Detector;
import pvzengine.collisions.FactionTarget;
import mvz2.vanilla.entities.VanillaEntityExt;
import mvz2logic.entities.LogicEntityExt;
import pvzengine.auras.AuraEffect;
import pvzengine.auras.AuraEffectDefinition;
import pvzengine.auras.IBuffTarget;
import pvzengine.buffs.BuffExt;
import pvzengine.entities.Entity;
import pvzengine.entities.EntityTypes;
using mvz2logic.entities.LogicEntityExt;
using mvz2logic.entities.LogicEntityProps;

@:autoEntityBehaviourDefinition(VanillaContraptionNames.stoneShield)
class StoneShield extends ContraptionBehaviour
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
        AddAura(new ProtectExplosionAura());
        evocationDetector = new SphereDetector(100);
        cast(evocationDetector, SphereDetector).canDetectInvisible = true;
        cast(evocationDetector, SphereDetector).includeSelf = true;
        cast(evocationDetector, SphereDetector).factionTarget = FactionTarget.Friendly;
    }
    override function OnEvoke(contraption:Entity):Void
    {
        super.OnEvoke(contraption);
        detectBuffer = [];
        evocationDetector.DetectEntities(DetectionParams.fromEntity(contraption), detectBuffer);
        for (ent in detectBuffer)
        {
            if (ent.Type == EntityTypes.PLANT)
            {
                var buff = ent.GetFirstBuff(IronCurtainBuff);
                if (buff == null)
                {
                    buff = ent.AddBuff(IronCurtainBuff);
                }
                buff.SetProperty(IronCurtainBuff.PROP_TIMEOUT, IronCurtainBuff.MAX_TIMEOUT);
            }
        }
        contraption.PlaySound(VanillaSoundID.ironCurtain);
    }
    var evocationDetector:Detector;
    var detectBuffer:Array<Entity> = [];
}

class ProtectExplosionAura extends AuraEffectDefinition
{
    public function new()
    {
        super(VanillaBuffID.Contraption.stoneShieldProtected);
    }
    public override function GetAuraTargets(auraEffect:AuraEffect, results:Array<IBuffTarget>):Void
    {
        var source = auraEffect.Source;
        var sourceEnt = source.GetEntity();
        if (sourceEnt == null)
            return;
        var grids = sourceEnt.GetGridsToTake();
        for (grid in grids)
        {
            if (grid == null)
                continue;
            var main = grid.GetMainEntity();
            if (main != null && sourceEnt.IsFriendly(main))
            {
                results.push(main);
            }
            var carrier = grid.GetCarrierEntity();
            if (carrier != null && sourceEnt.IsFriendly(carrier))
            {
                results.push(carrier);
            }
        }
    }
}
