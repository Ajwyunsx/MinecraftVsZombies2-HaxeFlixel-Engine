// Ported from: Assets/Scripts/Vanilla/GameContent/RandomChinaEvents/RedstoneReadyEvent.cs
package mvz2.gamecontent.randomchinaevents;

import mvz2.gamecontent.pickups.VanillaPickupID;
import mvz2.vanilla.localization.VanillaStrings;
import mvz2.vanilla.randomchina.RandomChinaEventDefinition;
import pvzengine.entities.Entity;
import tools.RandomGenerator;
import unity.Mathf;
import unity.Vector3;

@:randomChinaEventDefinition(VanillaRandomChinaEventNames.redstoneReady)
class RedstoneReadyEvent extends RandomChinaEventDefinition
{
    public function new(nsp:String, path:String)
    {
        super(nsp, path, NAME, DESCRIPTION);
    }
    public override function Run(contraption:Entity, rng:RandomGenerator):Void
    {
        var redstoneCount = 20;
        var level = contraption.Level;
        for (i in 0...redstoneCount)
        {
            var radius = rng.Next(0, 0.2);
            var angle = rng.Next(0, 360 * Mathf.Deg2Rad);
            var horizontal = Mathf.Cos(angle);
            var vertical = Mathf.Sin(angle);
            var x = horizontal * radius;
            var z = vertical * radius;

            var y = level.GetGroundY(x, z);
            var pos = new Vector3(contraption.Position.x + x, y + 10, contraption.Position.z + z);
            // C#: contraption.Spawn(...)?.Let(e => { e.Velocity = ...; });
            var e = contraption.Spawn(VanillaPickupID.redstone, pos);
            if (e != null)
            {
                e.Velocity = new Vector3(x * 20, 4, z * 20);
            }
        }
    }
    @:translateMsg("随机瓷器事件名称", VanillaStrings.CONTEXT_RANDOM_CHINA_EVENT_NAME)
    public static inline var NAME:String = "红石俱备";
    @:translateMsg("随机瓷器事件描述", VanillaStrings.CONTEXT_RANDOM_CHINA_EVENT_DESCRIPTION)
    public static inline var DESCRIPTION:String = "生成20个红石";
}
