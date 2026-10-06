// Ported from: Assets/Scripts/Vanilla/GameContent/RandomChinaEvents/HeavyContraptionEvent.cs
package mvz2.gamecontent.randomchinaevents;

import mvz2.gamecontent.contraptions.VanillaContraptionID;
import mvz2.vanilla.audios.VanillaSoundID;
import mvz2.vanilla.localization.VanillaStrings;
import mvz2.vanilla.randomchina.RandomChinaEventDefinition;
import pvzengine.entities.Entity;
import tools.RandomGenerator;
using mvz2.vanilla.entities.VanillaEntityExt;
using mvz2logic.entities.LogicEntityExt;

@:randomChinaEventDefinition(VanillaRandomChinaEventNames.heavyContraption)
class HeavyContraptionEvent extends RandomChinaEventDefinition
{
    public function new(nsp:String, path:String)
    {
        super(nsp, path, NAME, DESCRIPTION);
    }
    public override function Run(contraption:Entity, rng:RandomGenerator):Void
    {
        var level = contraption.Level;
        contraption.SpawnWithParams(VanillaContraptionID.snipenser, contraption.Position);
        contraption.Remove();
        contraption.PlaySound(VanillaSoundID.gunReload);
        contraption.PlaySound(VanillaSoundID.powerUp);
        contraption.PlaySound(VanillaSoundID.motor);
    }
    @:translateMsg("随机瓷器事件名称", VanillaStrings.CONTEXT_RANDOM_CHINA_EVENT_NAME)
    public static inline var NAME:String = "重装器械";
    @:translateMsg("随机瓷器事件描述", VanillaStrings.CONTEXT_RANDOM_CHINA_EVENT_DESCRIPTION)
    public static inline var DESCRIPTION:String = "变为狙击发射器";
}
