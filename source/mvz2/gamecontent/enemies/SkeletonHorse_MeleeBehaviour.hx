// Ported from: Assets/Scripts/Vanilla/GameContent/Enemies/Melee/SkeletonHorse_MeleeBehaviour.cs
package mvz2.gamecontent.enemies;

import mvz2.vanilla.entities.VanillaEntityBehaviourNames;
import mvz2.vanilla.entities.VanillaEntityExt;
import pvzengine.entities.Entity;
using mvz2.vanilla.detection.Detection;

@:autoEntityBehaviourDefinition(VanillaEntityBehaviourNames.skeletonHorse_Melee)
class SkeletonHorse_MeleeBehaviour extends EnemyMeleeBehaviour
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
    }
    override function ValidateMeleeTarget(enemy:Entity, target:Null<Entity>):Bool
    {
        if (!super.ValidateMeleeTarget(enemy, target))
            return false;
        if (!target.IsAheadOf(enemy))
            return false;
        return true;
    }
}
