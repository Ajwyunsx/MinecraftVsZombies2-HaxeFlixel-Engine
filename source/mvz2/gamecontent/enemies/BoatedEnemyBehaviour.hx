// Ported from: Assets/Scripts/Vanilla/GameContent/Enemies/BoatedEnemyBehaviour.cs
package mvz2.gamecontent.enemies;

import mvz2.gamecontent.buffs.enemies.BoatBuff;
import mvz2.gamecontent.entities.AIEntityBehaviour;
import mvz2.vanilla.entities.VanillaEntityBehaviourNames;
import mvz2.vanilla.entities.VanillaEntityExt;
import mvz2.vanilla.properties.VanillaEntityPropertyMeta;
import mvz2logic.level.LogicLevelExt;
import pvzengine.buffs.BuffExt;
import pvzengine.entities.Entity;

@:autoEntityBehaviourDefinition(VanillaEntityBehaviourNames.boatedEnemy)
class BoatedEnemyBehaviour extends AIEntityBehaviour
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
    }
    public override function Init(entity:Entity):Void
    {
        super.Init(entity);
        if (entity.GetProperty(PROP_SPAWN_WITH_BOAT))
        {
            var level = entity.Level;
            var lane = entity.GetLane();
            if (level.IsWaterLane(lane) || level.IsAirLane(lane))
            {
                entity.AddBuff(BoatBuff);
                entity.SetModelProperty("HasBoat", true);
            }
        }
    }
    override function UpdateLogic(entity:Entity):Void
    {
        super.UpdateLogic(entity);
        entity.SetModelProperty("HasBoat", entity.HasBuff(BoatBuff));
    }
    public static var PROP_SPAWN_WITH_BOAT:VanillaEntityPropertyMeta<Bool> = new VanillaEntityPropertyMeta<Bool>("spawn_with_boat", true);
}
