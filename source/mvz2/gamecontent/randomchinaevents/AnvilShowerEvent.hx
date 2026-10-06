// Ported from: Assets/Scripts/Vanilla/GameContent/RandomChinaEvents/AnvilShowerEvent.cs
package mvz2.gamecontent.randomchinaevents;

import mvz2.gamecontent.contraptions.VanillaContraptionID;
import mvz2.vanilla.localization.VanillaStrings;
import mvz2.vanilla.randomchina.RandomChinaEventDefinition;
import pvzengine.entities.Entity;
import pvzengine.entities.EntityTypes;
import tools.RandomGenerator;
using mvz2.vanilla.entities.VanillaEntityExt;

@:randomChinaEventDefinition(VanillaRandomChinaEventNames.anvilShower)
class AnvilShowerEvent extends RandomChinaEventDefinition
{
    public function new(nsp:String, path:String)
    {
        super(nsp, path, NAME, DESCRIPTION);
    }
    public override function Run(contraption:Entity, rng:RandomGenerator):Void
    {
        var level = contraption.Level;
        for (enemy in level.FindEntities(function(e) return e.Type == EntityTypes.ENEMY && e.IsHostile(contraption) && e.ExistsAndAlive()))
        {
            var column = enemy.GetColumn();
            var lane = enemy.GetLane();
            var grid = level.GetGrid(column, lane);
            if (grid != null)
            {
                var pos = grid.GetEntityPosition();
                pos.y = 600;
                contraption.SpawnWithParams(VanillaContraptionID.anvil, pos);
            }
        }
    }
    @:translateMsg("随机瓷器事件名称", VanillaStrings.CONTEXT_RANDOM_CHINA_EVENT_NAME)
    public static inline var NAME:String = "铁砧雨";
    @:translateMsg("随机瓷器事件描述", VanillaStrings.CONTEXT_RANDOM_CHINA_EVENT_DESCRIPTION)
    public static inline var DESCRIPTION:String = "每个敌怪头顶生成一个铁砧";
}
