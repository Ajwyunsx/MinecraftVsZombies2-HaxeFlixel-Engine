// Ported from: Assets/Scripts/Vanilla/GameContent/Contraptions/Upgrades/SkywardBeacon_Evoke.cs
package mvz2.gamecontent.contraptions;

import mvz2.gamecontent.effects.VanillaEffectID;
import mvz2.vanilla.entities.VanillaEntityBehaviourNames;
import mvz2.vanilla.audios.VanillaSoundID;
import mvz2.vanilla.entities.VanillaEntityExt;
import mvz2logic.entities.LogicEntityExt;
import mvz2logic.level.LogicLevelExt;
import mvz2logic.level.LevelPositions;
import pvzengine.entities.Entity;
import unity.Vector3;
using mvz2.vanilla.entities.VanillaEntityProps;
using mvz2logic.entities.LogicEntityExt;

@:autoEntityBehaviourDefinition(VanillaEntityBehaviourNames.skywardBeacon_Evoke)
class SkywardBeacon_Evoke extends ContraptionEvokeBehaviour
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
    }
    public override function Evoke(entity:Entity):Void
    {
        super.Evoke(entity);

        var sky = entity.Level.FindFirstEntity(e -> e.IsEntityOf(VanillaEffectID.skywardSky));
        if (sky == null)
        {
            var pos = new Vector3((LevelPositions.LEFT_BORDER + LevelPositions.RIGHT_BORDER) * 0.5, 0, LevelPositions.LAWN_HEIGHT * 0.5);
            entity.Spawn(VanillaEffectID.skywardSky, pos);
        }
        else
        {
            sky.Timeout = sky.GetMaxTimeout();
        }
        entity.PlaySound(VanillaSoundID.sparkle);
    }
}
