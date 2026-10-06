// Ported from: Assets/Scripts/Vanilla/GameContent/RandomChinaEvents/AncientEgyptEvent.cs
package mvz2.gamecontent.randomchinaevents;

import mvz2.gamecontent.buffs.level.AncientEgyptBuff;
import mvz2.gamecontent.enemies.VanillaSpawnID;
import mvz2.vanilla.audios.VanillaSoundID;
import mvz2.vanilla.localization.VanillaStrings;
import mvz2.vanilla.randomchina.RandomChinaEventDefinition;
import pvzengine.entities.Entity;
import tools.RandomGenerator;
using mvz2logic.entities.LogicEntityExt;

@:randomChinaEventDefinition(VanillaRandomChinaEventNames.ancientEgypt)
class AncientEgyptEvent extends RandomChinaEventDefinition
{
    public function new(nsp:String, path:String)
    {
        super(nsp, path, NAME, DESCRIPTION);
    }
    public override function Run(contraption:Entity, rng:RandomGenerator):Void
    {
        var level = contraption.Level;
        level.AddBuff(AncientEgyptBuff);
        if (!level.IsAllEnemiesCleared() && !level.IsCleared)
        {
            for (lane in 0...level.GetMaxLaneCount())
            {
                mvz2logic.level.LogicLevelExt.SpawnEnemyByID(level, VanillaSpawnID.mummy, lane);
            }
        }
        contraption.PlaySound(VanillaSoundID.lowQualityEgypt);
    }
    @:translateMsg("随机瓷器事件名称", VanillaStrings.CONTEXT_RANDOM_CHINA_EVENT_NAME)
    public static inline var NAME:String = "神秘埃及";
    @:translateMsg("随机瓷器事件描述", VanillaStrings.CONTEXT_RANDOM_CHINA_EVENT_DESCRIPTION)
    public static inline var DESCRIPTION:String = "每行召唤一个木乃伊，然后……";
}
