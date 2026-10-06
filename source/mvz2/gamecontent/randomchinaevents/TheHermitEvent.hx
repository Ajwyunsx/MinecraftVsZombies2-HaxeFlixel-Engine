// Ported from: Assets/Scripts/Vanilla/GameContent/RandomChinaEvents/Tarots/TheHermitEvent.cs
package mvz2.gamecontent.randomchinaevents;

import mvz2.gamecontent.contraptions.VanillaContraptionID;
import mvz2.vanilla.audios.VanillaSoundID;
import mvz2.vanilla.localization.VanillaStrings;
import mvz2.vanilla.randomchina.RandomChinaEventDefinition;
import pvzengine.entities.Entity;
import tools.RandomGenerator;
using mvz2.vanilla.entities.VanillaEntityExt;
using mvz2logic.entities.LogicEntityExt;

@:randomChinaEventDefinition(VanillaRandomChinaEventNames.theHermit)
class TheHermitEvent extends RandomChinaEventDefinition
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
                if (grid != null && grid.CanSpawnEntity(VanillaContraptionID.mineTNT))
                {
                    var pos = grid.GetEntityPosition();
                    contraption.SpawnWithParams(VanillaContraptionID.mineTNT, pos);
                }
            }
        }
        contraption.PlaySound(VanillaSoundID.dirtRise);
    }
    @:translateMsg("随机瓷器事件名称", VanillaStrings.CONTEXT_RANDOM_CHINA_EVENT_NAME)
    public static inline var NAME:String = "IX-隐者";
    @:translateMsg("随机瓷器事件描述", VanillaStrings.CONTEXT_RANDOM_CHINA_EVENT_DESCRIPTION)
    public static inline var DESCRIPTION:String = "用地雷TNT填满战场";
}
