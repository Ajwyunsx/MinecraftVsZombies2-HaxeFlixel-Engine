// Ported from: Assets/Scripts/Vanilla/GameContent/Effects/Chapter5/ZombieCloudSnowflake.cs
package mvz2.gamecontent.effects;

import mvz2logic.level.LogicLevelExt;
import pvzengine.definitions.EntityBehaviourDefinition;
import pvzengine.entities.Entity;
import unity.Vector3;
import mvz2.gamecontent.effects.VanillaEffectID.VanillaEffectNames;

@:autoEntityBehaviourDefinition(VanillaEffectNames.zombieCloudSnowflake)
class ZombieCloudSnowflake extends EntityBehaviourDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
    }

    public override function PostContactGround(entity:Entity, velocity:Vector3):Void
    {
        super.PostContactGround(entity, velocity);
        var position = entity.Position;
        position.y = entity.Level.GetGroundY(position.x, position.y);
        if (!entity.Level.IsAirAt(position.x, position.z) && !entity.Level.IsWaterAt(position.x, position.z))
        {
            // C#: WaterStain.UpdateStain(...)?.Let(e => { WaterStain.FreezeStain(e); })
            var stain = WaterStain.UpdateStain(entity.Level, position, entity);
            if (stain != null)
            {
                WaterStain.FreezeStain(stain);
            }
        }
        entity.Remove();
    }
}
