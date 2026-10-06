// Ported from: Assets/Scripts/Vanilla/GameContent/RandomChinaEvents/Pokers/AceAbstractEvent.cs
package mvz2.gamecontent.randomchinaevents;

import mvz2.vanilla.pickups.VanillaPickupExt;
import mvz2.vanilla.pickups.VanillaPickupProps;
import mvz2.vanilla.randomchina.RandomChinaEventDefinition;
import pvzengine.entities.Entity;
import pvzengine.entities.EntityTypes;
import tools.RandomGenerator;

// abstract
class AceAbstractEvent extends RandomChinaEventDefinition
{
    public function new(nsp:String, path:String, name:String, description:String, weight:Float = 1)
    {
        super(nsp, path, name, description, weight);
    }
    public override function Run(contraption:Entity, rng:RandomGenerator):Void
    {
        var level = contraption.Level;
        for (pickup in level.GetEntities(EntityTypes.PICKUP))
        {
            if (VanillaPickupExt.IsCollected(pickup) || VanillaPickupProps.IsImportantPickup(pickup))
                continue;
            Transform(pickup, contraption);
            pickup.Remove();
        }
        for (enemy in level.GetEntities(EntityTypes.ENEMY))
        {
            Transform(enemy, contraption);
            enemy.Remove();
        }
    }
    function Transform(target:Entity, china:Entity):Void throw "abstract"; // abstract
}
