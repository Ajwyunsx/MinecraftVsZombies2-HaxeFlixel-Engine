// Ported from: Assets/Scripts/Vanilla/GameContent/RandomChinaEvents/ChinaTownEvent.cs
package mvz2.gamecontent.randomchinaevents;

import mvz2.gamecontent.contraptions.VanillaContraptionID;
import mvz2.vanilla.localization.VanillaStrings;
import mvz2.vanilla.randomchina.RandomChinaEventDefinition;
import pvzengine.entities.Entity;
import tools.RandomGenerator;
using mvz2.vanilla.entities.VanillaEntityExt;

@:randomChinaEventDefinition(VanillaRandomChinaEventNames.chinaTown)
class ChinaTownEvent extends RandomChinaEventDefinition
{
    public function new(nsp:String, path:String)
    {
        super(nsp, path, NAME, DESCRIPTION);
    }
    public override function Run(contraption:Entity, rng:RandomGenerator):Void
    {
        var level = contraption.Level;
        for (column in 0...level.GetMaxColumnCount())
        {
            for (lane in 0...level.GetMaxLaneCount())
            {
                var grid = level.GetGrid(column, lane);
                if (grid != null && grid.CanSpawnEntity(VanillaContraptionID.randomChina))
                {
                    var pos = grid.GetEntityPosition();
                    contraption.SpawnWithParams(VanillaContraptionID.randomChina, pos);
                }
            }
        }
    }
    @:translateMsg("随机瓷器事件名称", VanillaStrings.CONTEXT_RANDOM_CHINA_EVENT_NAME)
    public static inline var NAME:String = "陶瓷镇";
    @:translateMsg("随机瓷器事件描述", VanillaStrings.CONTEXT_RANDOM_CHINA_EVENT_DESCRIPTION)
    public static inline var DESCRIPTION:String = "用随机瓷器填满战场";
}
