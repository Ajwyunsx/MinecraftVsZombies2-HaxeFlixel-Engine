// Ported from: Assets/Scripts/Vanilla/GameContent/RandomChinaEvents/RaceCarsEvent.cs
package mvz2.gamecontent.randomchinaevents;

import mvz2.vanilla.carts.VanillaCartExt;
import mvz2.vanilla.localization.VanillaStrings;
import mvz2.vanilla.randomchina.RandomChinaEventDefinition;
import mvz2logic.level.LevelPositions;
import pvzengine.entities.Entity;
import tools.RandomGenerator;
import unity.Vector3;

@:randomChinaEventDefinition(VanillaRandomChinaEventNames.raceCars)
class RaceCarsEvent extends RandomChinaEventDefinition
{
    public function new(nsp:String, path:String)
    {
        super(nsp, path, NAME, DESCRIPTION);
    }
    public override function Run(contraption:Entity, rng:RandomGenerator):Void
    {
        var level = contraption.Level;
        var cartRef = level.GetCartReference();
        if (cartRef == null)
            return;
        for (lane in 0...level.GetMaxLaneCount())
        {
            // C#: contraption.Spawn(...)?.Let(e => { e.TriggerCart(); });
            var cart = contraption.Spawn(cartRef, new Vector3(LevelPositions.CART_START_X, 0, level.GetEntityLaneZ(lane)));
            if (cart != null)
            {
                VanillaCartExt.TriggerCart(cart);
            }
        }
    }
    @:translateMsg("随机瓷器事件名称", VanillaStrings.CONTEXT_RANDOM_CHINA_EVENT_NAME)
    public static inline var NAME:String = "赛车";
    @:translateMsg("随机瓷器事件描述", VanillaStrings.CONTEXT_RANDOM_CHINA_EVENT_DESCRIPTION)
    public static inline var DESCRIPTION:String = "每行生成一个启动的小推车";
}
