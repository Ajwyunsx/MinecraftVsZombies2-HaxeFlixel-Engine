// Ported from: Assets/Scripts/Vanilla/GameContent/RandomChinaEvents/Tarots/TheTowerEvent.cs
package mvz2.gamecontent.randomchinaevents;

import mvz2.gamecontent.projectiles.VanillaProjectileID;
import mvz2.vanilla.localization.VanillaStrings;
import mvz2.vanilla.randomchina.RandomChinaEventDefinition;
import mvz2logic.level.LevelPositions;
import pvzengine.entities.Entity;
import tools.RandomGenerator;
import unity.Vector3;
using mvz2.vanilla.entities.VanillaEntityExt;

@:randomChinaEventDefinition(VanillaRandomChinaEventNames.theTower)
class TheTowerEvent extends RandomChinaEventDefinition
{
    public function new(nsp:String, path:String)
    {
        super(nsp, path, NAME, DESCRIPTION);
    }
    public override function Run(contraption:Entity, rng:RandomGenerator):Void
    {
        var tntCount = 16;
        var level = contraption.Level;
        for (i in 0...tntCount)
        {
            var x = rng.Next(LevelPositions.ATTACK_LEFT_BORDER, LevelPositions.ATTACK_RIGHT_BORDER);
            var y = rng.Next(600, 2000);
            var z = rng.Next(level.GetGridBottomZ(), level.GetGridTopZ());
            contraption.SpawnWithParams(VanillaProjectileID.flyingTNT, new Vector3(x, y, z));
        }
    }
    @:translateMsg("随机瓷器事件名称", VanillaStrings.CONTEXT_RANDOM_CHINA_EVENT_NAME)
    public static inline var NAME:String = "XVI-塔";
    @:translateMsg("随机瓷器事件描述", VanillaStrings.CONTEXT_RANDOM_CHINA_EVENT_DESCRIPTION)
    public static inline var DESCRIPTION:String = "在随机位置掉落16个TNT";
}
