// Ported from: Assets/Scripts/Vanilla/GameContent/RandomChinaEvents/BindingChainsEvent.cs
package mvz2.gamecontent.randomchinaevents;

import mvz2.gamecontent.areas.Palace;
import mvz2.vanilla.audios.VanillaSoundID;
import mvz2.vanilla.localization.VanillaStrings;
import mvz2.vanilla.randomchina.RandomChinaEventDefinition;
import pvzengine.entities.Entity;
import tools.RandomGenerator;
using mvz2logic.entities.LogicEntityExt;

@:randomChinaEventDefinition(VanillaRandomChinaEventNames.bindingChains)
class BindingChainsEvent extends RandomChinaEventDefinition
{
    public function new(nsp:String, path:String)
    {
        super(nsp, path, NAME, DESCRIPTION);
    }
    public override function Run(contraption:Entity, rng:RandomGenerator):Void
    {
        var level = contraption.Level;
        var seedPacks = Palace.GetBlueprintsToLock(level);
        Palace.LockRandomBlueprints(level, seedPacks, 3, rng);
        contraption.PlaySound(VanillaSoundID.locked);
    }
    @:translateMsg("随机瓷器事件名称", VanillaStrings.CONTEXT_RANDOM_CHINA_EVENT_NAME)
    public static inline var NAME:String = "魂缚锁链";
    @:translateMsg("随机瓷器事件描述", VanillaStrings.CONTEXT_RANDOM_CHINA_EVENT_DESCRIPTION)
    public static inline var DESCRIPTION:String = "暂时锁定随机3个蓝图";
}
