// Ported from: Assets/Scripts/Vanilla/GameContent/Enemies/Melee/Spider_MeleeBehaviour.cs
package mvz2.gamecontent.enemies;

import mvz2.vanilla.entities.VanillaEntityBehaviourNames;
import mvz2.vanilla.entities.VanillaEntityExt;
import pvzengine.entities.Entity;

@:autoEntityBehaviourDefinition(VanillaEntityBehaviourNames.spider_Melee)
class Spider_MeleeBehaviour extends EnemyMeleeBehaviour
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
    }
    override function ValidateMeleeTarget(enemy:Entity, target:Null<Entity>):Bool
    {
        if (!super.ValidateMeleeTarget(enemy, target))
            return false;
        if (Spider.CanClimb(enemy, target))
            return false;
        return true;
    }
}
