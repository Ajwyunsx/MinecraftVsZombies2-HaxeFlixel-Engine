// Ported from: Assets/Scripts/Vanilla/GameContent/Buffs/Contraption/Chapter2/DreamCrystalEvocationBuff.cs
package mvz2.gamecontent.buffs.contraptions;

import mvz2.gamecontent.buffs.VanillaBuffNames;
import mvz2.gamecontent.detections.SphereDetector;
import mvz2.vanilla.detection.Detector;
import mvz2.vanilla.entities.VanillaEntityExt;
import mvz2.vanilla.properties.VanillaBuffPropertyMeta;
import pvzengine.buffs.Buff;
import pvzengine.collisions.FactionTarget;
import pvzengine.definitions.BuffDefinition;
import pvzengine.entities.EngineEntityProps;
import pvzengine.entities.Entity;
import pvzengine.modifiers.BooleanModifier;
import mvz2.vanilla.detection.Detector.DetectionParams;

@:autoBuffDefinition(VanillaBuffNames.Contraption_dreamCrystalEvocation)
class DreamCrystalEvocationBuff extends BuffDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
        healDetector = new SphereDetector(100);
        cast(healDetector, SphereDetector).canDetectInvisible = true;
        cast(healDetector, SphereDetector).factionTarget = cast FactionTarget.Friendly;
        AddModifier(new BooleanModifier(EngineEntityProps.INVINCIBLE, true));
    }
    public override function PostAdd(buff:Buff):Void
    {
        super.PostAdd(buff);
        buff.SetProperty(PROP_TIMEOUT, MAX_TIMEOUT);
    }
    public override function PostUpdate(buff:Buff):Void
    {
        super.PostUpdate(buff);
        var contraption = buff.GetEntity();
        if (contraption == null)
            return;
        healBuffer.resize(0);
        healDetector.DetectEntities(DetectionParams.fromEntity(contraption), healBuffer);
        for (target in healBuffer)
        {
            VanillaEntityExt.HealEffects(target, HEAL_PER_FRAME, contraption);
        }
        var time = buff.GetProperty(PROP_TIMEOUT);
        time--;
        if (time <= 0)
        {
            buff.Remove();
        }
        buff.SetProperty(PROP_TIMEOUT, time);
    }
    public static var PROP_TIMEOUT:VanillaBuffPropertyMeta<Int> = new VanillaBuffPropertyMeta<Int>("Timeout");
    public static inline var MAX_TIMEOUT:Int = 150;
    public static inline var HEAL_PER_FRAME:Float = 20;
    var healBuffer:Array<Entity> = [];
    var healDetector:Detector;
}
