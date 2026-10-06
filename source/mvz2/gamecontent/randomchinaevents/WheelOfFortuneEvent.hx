// Ported from: Assets/Scripts/Vanilla/GameContent/RandomChinaEvents/Tarots/WheelOfFortuneEvent.cs
package mvz2.gamecontent.randomchinaevents;

import mvz2.gamecontent.pickups.VanillaPickupID;
import mvz2.vanilla.audios.VanillaSoundID;
import mvz2.vanilla.level.VanillaLevelExt;
import mvz2.vanilla.localization.VanillaStrings;
import mvz2.vanilla.pickups.VanillaPickupProps;
import mvz2.vanilla.randomchina.RandomChinaEventDefinition;
import mvz2logic.blueprints.LogicBlueprintID;
import pvzengine.entities.Entity;
import pvzengine.entities.SpawnParams;
import tools.RandomGenerator;
using mvz2.vanilla.pickups.VanillaPickupExt;
using mvz2logic.entities.LogicEntityExt;

@:randomChinaEventDefinition(VanillaRandomChinaEventNames.wheelOfFortune)
class WheelOfFortuneEvent extends RandomChinaEventDefinition
{
    public function new(nsp:String, path:String)
    {
        super(nsp, path, NAME, DESCRIPTION);
    }
    public override function Run(contraption:Entity, rng:RandomGenerator):Void
    {
        var level = contraption.Level;
        for (i in 0...COUNT)
        {
            var spawnParams = new SpawnParams();
            var contraptionID = VanillaLevelExt.GetRandomContraptionFromPool(level, rng);
            var blueprintID = LogicBlueprintID.FromEntity(contraptionID);
            spawnParams.SetProperty(VanillaPickupProps.CONTENT_ID, blueprintID);
            contraption.Produce(VanillaPickupID.blueprintPickup, spawnParams);
        }
        contraption.PlaySound(VanillaSoundID.arcaneIntellect);
    }
    @:translateMsg("随机瓷器事件名称", VanillaStrings.CONTEXT_RANDOM_CHINA_EVENT_NAME)
    public static inline var NAME:String = "X-命运之轮";
    @:translateMsg("随机瓷器事件描述", VanillaStrings.CONTEXT_RANDOM_CHINA_EVENT_DESCRIPTION)
    public static inline var DESCRIPTION:String = "生成3张随机器械的蓝图";
    public static inline var COUNT:Int = 3;
}
