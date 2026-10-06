// Ported from: Assets/Scripts/Vanilla/GameContent/RandomChinaEvents/Pokers/AceOfSpadesEvent.cs
package mvz2.gamecontent.randomchinaevents;

import mvz2.gamecontent.pickups.VanillaPickupID;
import mvz2.vanilla.localization.VanillaStrings;
import pvzengine.entities.Entity;

@:randomChinaEventDefinition(VanillaRandomChinaEventNames.aceOfSpades)
class AceOfSpadesEvent extends AceAbstractEvent
{
    public function new(nsp:String, path:String)
    {
        super(nsp, path, NAME, DESCRIPTION);
    }
    override function Transform(target:Entity, china:Entity):Void
    {
        china.Spawn(VanillaPickupID.starshard, target.Position);
    }
    @:translateMsg("随机瓷器事件名称", VanillaStrings.CONTEXT_RANDOM_CHINA_EVENT_NAME)
    public static inline var NAME:String = "黑桃A";
    @:translateMsg("随机瓷器事件描述", VanillaStrings.CONTEXT_RANDOM_CHINA_EVENT_DESCRIPTION)
    public static inline var DESCRIPTION:String = "将所有怪物和掉落物变为星之碎片";
}
