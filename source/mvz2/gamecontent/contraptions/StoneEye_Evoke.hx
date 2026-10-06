// Ported from: Assets/Scripts/Vanilla/GameContent/Contraptions/Chapter6/StoneEye_Evoke.cs
package mvz2.gamecontent.contraptions;

import mvz2.gamecontent.buffs.contraptions.StoneEyeChargedBuff;
import mvz2.gamecontent.effects.PetrifyLaser;
import mvz2.gamecontent.effects.VanillaEffectID;
import mvz2.vanilla.entities.VanillaEntityBehaviourNames;
import mvz2.vanilla.entities.VanillaEntityExt;
import pvzengine.EngineEntityProps;
import pvzengine.buffs.BuffExt;
import pvzengine.entities.Entity;
import unity.Vector3;
using mvz2.vanilla.entities.VanillaEntityExt;

@:autoEntityBehaviourDefinition(VanillaEntityBehaviourNames.stoneEye_Evoke)
class StoneEye_Evoke extends ContraptionEvokeBehaviour
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
    }
    public override function Evoke(entity:Entity):Void
    {
        super.Evoke(entity);
        if (entity.HasBuff(StoneEyeChargedBuff))
        {
            entity.RemoveBuffs(StoneEyeChargedBuff);
            FireUltimatePetrifyBeam(entity);
        }
        else
        {
            var offset = StoneEye.rayOffset;
            offset.x *= entity.GetFacingX();
            var sourcePosition = entity.Position + offset;

            var laserID = VanillaEffectID.petrifyLaser;
            entity.SpawnWithParams(laserID, sourcePosition);
        }
    }
    public static function FireUltimatePetrifyBeam(entity:Entity):Void
    {
        var offset = StoneEye.rayOffset;
        offset.x *= entity.GetFacingX();
        var sourcePosition = entity.Position + offset;

        var laserID = VanillaEffectID.petrifyLaser;
        var param = entity.GetSpawnParams();
        param.SetProperty(EngineEntityProps.DISPLAY_SCALE, new Vector3(1, 100, 1));
        param.SetProperty(EngineEntityProps.SCALE, new Vector3(1, 100, 100));
        param.SetProperty(PetrifyLaser.PROP_ULTIMATE, true);
        entity.Spawn(laserID, sourcePosition, param);
    }
}
