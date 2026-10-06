// Ported from: Assets/Scripts/Vanilla/GameContent/Effects/Chapter3/SeijaCameraFrame.cs
package mvz2.gamecontent.effects;

import mvz2.gamecontent.buffs.contraptions.StoneEyeChargedBuff;
import mvz2.gamecontent.contraptions.StoneEye_Evoke;
import mvz2.gamecontent.contraptions.VanillaContraptionID;
import mvz2.gamecontent.detections.CameraFlashDetector;
import mvz2.vanilla.audios.VanillaSoundID;
import mvz2.vanilla.detection.Detector;
import mvz2.vanilla.entities.VanillaEntityExt;
import mvz2.vanilla.entities.VanillaEntityProps;
import mvz2logic.entities.LogicEntityExt;
import pvzengine.EngineEntityProps;
import pvzengine.buffs.BuffExt;
import pvzengine.entities.Entity;
import pvzengine.entities.EntitySourceReference;
import pvzengine.entities.EntityTypes;
import unity.Color;
import mvz2.gamecontent.effects.VanillaEffectID.VanillaEffectNames;
import mvz2.vanilla.detection.Detector.DetectionParams;
using mvz2logic.entities.LogicEntityProps;
using mvz2.vanilla.entities.VanillaEntityExt;
using mvz2logic.entities.LogicEntityExt;

@:autoEntityBehaviourDefinition(VanillaEffectNames.seijaCameraFrame)
class SeijaCameraFrame extends EffectBehaviour
{
    // #region 公有方法
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
        flashDetector = new CameraFlashDetector();
    }
    public override function Update(entity:Entity):Void
    {
        super.Update(entity);
        if (entity.Timeout == 30)
        {
            detectBuffer.resize(0);
            flashDetector.DetectEntities(DetectionParams.fromEntity(entity), detectBuffer);
            var soundPlayed = false;
            for (target in detectBuffer)
            {
                if (target.Type == EntityTypes.PLANT)
                {
                    if (VanillaEntityProps.CanDeactive(target))
                    {
                        switch (entity.GetVariant())
                        {
                            case VARIANT_DISABLE:
                                VanillaEntityExt.ShortCircuit(target, 300, new EntitySourceReference(entity));
                                if (!soundPlayed)
                                {
                                    target.PlaySound(VanillaSoundID.powerOff);
                                    soundPlayed = true;
                                }
                            case VARIANT_PETRIFY:
                                if (target.IsEntityOf(VanillaContraptionID.stoneEye))
                                {
                                    if (!target.HasBuff(StoneEyeChargedBuff))
                                    {
                                        target.AddBuff(StoneEyeChargedBuff);
                                    }
                                    else
                                    {
                                        target.RemoveBuffs(StoneEyeChargedBuff);
                                        StoneEye_Evoke.FireUltimatePetrifyBeam(target);
                                    }
                                    target.PlaySound(VanillaSoundID.growBig);
                                }
                                else
                                {
                                    VanillaEntityExt.InflictPetrified(target, 900, new EntitySourceReference(entity));

                                    var spawnParams = target.GetSpawnParams();
                                    spawnParams.SetProperty(EngineEntityProps.TINT, Color.gray);
                                    target.Spawn(VanillaEffectID.smokeCluster, target.GetCenter(), spawnParams);

                                    if (!soundPlayed)
                                    {
                                        target.PlaySound(VanillaSoundID.petrified);
                                        target.PlaySound(VanillaSoundID.giantSpike);
                                        soundPlayed = true;
                                    }
                                }
                        }
                    }
                }
                else if (target.Type == EntityTypes.PROJECTILE)
                {
                    target.Remove();
                }
            }
            entity.TriggerAnimation("Flash");
            entity.PlaySound(VanillaSoundID.shutter);
        }
    }
    // #endregion

    public static inline var VARIANT_DISABLE:Int = 0;
    public static inline var VARIANT_PETRIFY:Int = 1;

    private var detectBuffer:Array<Entity> = [];
    private var flashDetector:Detector;
}
