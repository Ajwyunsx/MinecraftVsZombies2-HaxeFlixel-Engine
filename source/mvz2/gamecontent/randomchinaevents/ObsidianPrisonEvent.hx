// Ported from: Assets/Scripts/Vanilla/GameContent/RandomChinaEvents/ObsidianPrisonEvent.cs
package mvz2.gamecontent.randomchinaevents;

import mvz2.gamecontent.contraptions.VanillaContraptionID;
import mvz2.vanilla.localization.VanillaStrings;
import mvz2.vanilla.randomchina.RandomChinaEventDefinition;
import pvzengine.entities.Entity;
import pvzengine.entities.EntityTypes;
import tools.RandomGenerator;
using mvz2.vanilla.entities.VanillaEntityExt;

@:randomChinaEventDefinition(VanillaRandomChinaEventNames.obsidianPrison)
class ObsidianPrisonEvent extends RandomChinaEventDefinition
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
            for (i in 0...5)
            {
                var column = enemy.GetColumn();
                var lane = enemy.GetLane();
                switch (i)
                {
                    case 1:
                        lane--;
                    case 2:
                        column++;
                    case 3:
                        lane++;
                    case 4:
                        column--;
                }

                if (column >= 0 && column < level.GetMaxColumnCount() && lane >= 0 && lane < level.GetMaxLaneCount())
                {
                    var grid = level.GetGrid(column, lane);
                    if (grid != null && grid.CanSpawnEntity(VanillaContraptionID.obsidian))
                    {
                        var pos = grid.GetEntityPosition();
                        contraption.SpawnWithParams(VanillaContraptionID.obsidian, pos);
                    }
                }
            }
        }
    }
    @:translateMsg("随机瓷器事件名称", VanillaStrings.CONTEXT_RANDOM_CHINA_EVENT_NAME)
    public static inline var NAME:String = "黑曜石囚牢";
    @:translateMsg("随机瓷器事件描述", VanillaStrings.CONTEXT_RANDOM_CHINA_EVENT_DESCRIPTION)
    public static inline var DESCRIPTION:String = "用黑曜石困住所有敌怪";
}
