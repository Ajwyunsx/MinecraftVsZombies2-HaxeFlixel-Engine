// Ported from: Assets/Scripts/Vanilla/GameContent/RandomChinaEvents/Tarots/TheChariotEvent.cs
package mvz2.gamecontent.randomchinaevents;

import mvz2.gamecontent.projectiles.VanillaProjectileID;
import mvz2.vanilla.audios.VanillaSoundID;
import mvz2.vanilla.localization.VanillaStrings;
import mvz2.vanilla.randomchina.RandomChinaEventDefinition;
import pvzengine.entities.Entity;
import pvzengine.entities.EntityTypes;
import tools.RandomGenerator;
using mvz2.vanilla.entities.VanillaEntityProps;
using mvz2.vanilla.projectiles.VanillaProjectileExt;
using mvz2logic.entities.LogicEntityExt;

@:randomChinaEventDefinition(VanillaRandomChinaEventNames.theChariot)
class TheChariotEvent extends RandomChinaEventDefinition
{
    public function new(nsp:String, path:String)
    {
        super(nsp, path, NAME, DESCRIPTION);
    }
    public override function Run(contraption:Entity, rng:RandomGenerator):Void
    {
        var level = contraption.Level;
        for (enemy in level.FindEntities(function(e) return e.Type == EntityTypes.ENEMY && contraption.IsHostile(e) && e.ExistsAndAlive()))
        {
            var pos = enemy.GetCenter();
            var param = contraption.GetShootParams();
            param.projectileID = VanillaProjectileID.missile;
            param.position = contraption.GetCenter();
            param.velocity = (pos - param.position).normalized * 20;
            param.damage = contraption.GetDamage() * 2;
            contraption.ShootProjectile(param);
        }
        contraption.PlaySound(VanillaSoundID.missile);
    }
    @:translateMsg("随机瓷器事件名称", VanillaStrings.CONTEXT_RANDOM_CHINA_EVENT_NAME)
    public static inline var NAME:String = "VII-战车";
    @:translateMsg("随机瓷器事件描述", VanillaStrings.CONTEXT_RANDOM_CHINA_EVENT_DESCRIPTION)
    public static inline var DESCRIPTION:String = "向每个敌怪发射一枚导弹";
}
