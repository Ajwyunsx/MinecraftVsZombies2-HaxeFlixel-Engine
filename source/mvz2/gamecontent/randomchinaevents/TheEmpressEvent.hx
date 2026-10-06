// Ported from: Assets/Scripts/Vanilla/GameContent/RandomChinaEvents/Tarots/TheEmpressEvent.cs
package mvz2.gamecontent.randomchinaevents;

import mvz2.gamecontent.effects.Miner;
import mvz2.gamecontent.effects.VanillaEffectID;
import mvz2.vanilla.audios.VanillaSoundID;
import mvz2.vanilla.localization.VanillaStrings;
import mvz2.vanilla.randomchina.RandomChinaEventDefinition;
import pvzengine.entities.Entity;
import tools.RandomGenerator;
import unity.Vector3;
using mvz2.vanilla.entities.VanillaEntityExt;
using mvz2logic.entities.LogicEntityExt;

@:randomChinaEventDefinition(VanillaRandomChinaEventNames.theEmpress)
class TheEmpressEvent extends RandomChinaEventDefinition
{
    public function new(nsp:String, path:String)
    {
        super(nsp, path, NAME, DESCRIPTION);
    }
    public override function Run(contraption:Entity, rng:RandomGenerator):Void
    {
        // PORT-NOTE: C# Vector3 为值类型，Haxe unity.Vector3 为引用包装，显式构造副本避免改写器械自身位置。
        var pos = new Vector3(contraption.Position.x, contraption.Position.y, contraption.Position.z);
        pos.z -= 8;
        pos.y = contraption.Level.GetGroundY(pos.x, pos.z);
        var param = contraption.GetSpawnParams();
        param.SetProperty(Miner.PROP_WORKS_ALL_DAY, true);
        // C#: contraption.Spawn(...)?.Let(m => { m.Timeout = 5400; });
        var miner = contraption.Spawn(VanillaEffectID.miner, pos, param);
        if (miner != null)
        {
            miner.Timeout = 5400;
        }
        contraption.PlaySound(VanillaSoundID.teslaConstruction);
    }
    @:translateMsg("随机瓷器事件名称", VanillaStrings.CONTEXT_RANDOM_CHINA_EVENT_NAME)
    public static inline var NAME:String = "III-女皇";
    @:translateMsg("随机瓷器事件描述", VanillaStrings.CONTEXT_RANDOM_CHINA_EVENT_DESCRIPTION)
    public static inline var DESCRIPTION:String = "生成一个全天工作的矿场，持续3分钟";
}
