// Ported from: Assets/Scripts/Vanilla/GameContent/Obstacles/GargoyleStatue.cs
package mvz2.gamecontent.obstacles;

import mvz2.gamecontent.buffs.entities.TemporaryUpdateBeforeGameBuff;
import mvz2.gamecontent.obstacles.VanillaObstacleID.VanillaObstacleNames;
import mvz2.vanilla.audios.VanillaSoundID;
import mvz2logic.entities.LogicEntityExt;
import pvzengine.entities.Entity;

@:autoEntityBehaviourDefinition(VanillaObstacleNames.gargoyleStatue)
class GargoyleStatue extends ObstacleBehaviour
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
    }
    public override function Init(entity:Entity):Void
    {
        super.Init(entity);
        entity.AddBuff(TemporaryUpdateBeforeGameBuff);
        entity.TriggerAnimation("Rise");
        LogicEntityExt.PlaySound(entity, VanillaSoundID.dirtRise);
    }
}
