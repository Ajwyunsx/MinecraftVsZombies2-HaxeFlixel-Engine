// Ported from: Assets/Scripts/Vanilla/GameContent/RandomChinaEvents/Tarots/TheHangedManEvent.cs
package mvz2.gamecontent.randomchinaevents;

import mvz2.gamecontent.enemies.VanillaEnemyID;
import mvz2.vanilla.localization.VanillaStrings;
import mvz2.vanilla.randomchina.RandomChinaEventDefinition;
import pvzengine.entities.Entity;
import tools.RandomGenerator;
import unity.Vector3;

@:randomChinaEventDefinition(VanillaRandomChinaEventNames.theHangedMan)
class TheHangedManEvent extends RandomChinaEventDefinition
{
    public function new(nsp:String, path:String)
    {
        super(nsp, path, NAME, DESCRIPTION);
    }
    public override function Run(contraption:Entity, rng:RandomGenerator):Void
    {
        for (i in 0...6)
        {
            var level = contraption.Level;
            var x = level.GetEnemySpawnX();
            var z = level.GetEntityLaneZ(rng.Next(level.GetMaxLaneCount()));
            var y = level.GetGroundY(x, z);
            var pos = new Vector3(x, y, z);
            level.Spawn(VanillaEnemyID.reverseSatellite, pos, contraption);
        }
    }
    @:translateMsg("随机瓷器事件名称", VanillaStrings.CONTEXT_RANDOM_CHINA_EVENT_NAME)
    public static inline var NAME:String = "XII-倒吊人";
    @:translateMsg("随机瓷器事件描述", VanillaStrings.CONTEXT_RANDOM_CHINA_EVENT_DESCRIPTION)
    public static inline var DESCRIPTION:String = "生成6个反则卫星";
}
