// Ported from: Assets/Scripts/Vanilla/GameContent/RandomChinaEvents/WrathOfTheSmallEvent.cs
package mvz2.gamecontent.randomchinaevents;

import mvz2.gamecontent.projectiles.VanillaProjectileID;
import mvz2.vanilla.audios.VanillaSoundID;
import mvz2.vanilla.localization.VanillaStrings;
import mvz2.vanilla.randomchina.RandomChinaEventDefinition;
import mvz2logic.level.LevelPositions;
import pvzengine.entities.Entity;
import tools.RandomGenerator;
import unity.Vector3;
using mvz2logic.entities.LogicEntityExt;

@:randomChinaEventDefinition(VanillaRandomChinaEventNames.wrathOfTheSmall)
class WrathOfTheSmallEvent extends RandomChinaEventDefinition
{
    public function new(nsp:String, path:String)
    {
        super(nsp, path, NAME, DESCRIPTION);
    }
    public override function Run(contraption:Entity, rng:RandomGenerator):Void
    {
        var level = contraption.Level;
        var randomLane = rng.Next(0, level.GetMaxLaneCount());
        var z = level.GetEntityLaneZ(randomLane);
        var x = LevelPositions.GetBorderX(false);
        var y = level.GetGroundY(x, z);
        var pos = new Vector3(x, y, z);
        // C#: contraption.Spawn(...)?.Let(e => { e.Velocity = Vector3.right * 3; });
        var snowball = contraption.Spawn(VanillaProjectileID.largeSnowball, pos);
        if (snowball != null)
        {
            snowball.Velocity = Vector3.right * 3;
        }
        contraption.PlaySound(VanillaSoundID.odd);
    }
    @:translateMsg("随机瓷器事件名称", VanillaStrings.CONTEXT_RANDOM_CHINA_EVENT_NAME)
    public static inline var NAME:String = "小型之怒";
    @:translateMsg("随机瓷器事件描述", VanillaStrings.CONTEXT_RANDOM_CHINA_EVENT_DESCRIPTION)
    public static inline var DESCRIPTION:String = "在随机一行的最左侧生成一个大雪球";
}
