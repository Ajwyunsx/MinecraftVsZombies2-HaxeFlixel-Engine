// Ported from: Assets/Scripts/Vanilla/GameContent/Enemies/States/Hacker_StateBehaviour.cs
package mvz2.gamecontent.enemies;

import mvz2.vanilla.entities.VanillaEntityBehaviourNames;
import pvzengine.entities.Entity;

@:autoEntityBehaviourDefinition(VanillaEntityBehaviourNames.hacker_State)
class Hacker_StateBehaviour extends EnemyStateBehaviour
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
    }
    override function GetActiveState(enemy:Entity):Int
    {
        if (Hacker.CanHack(enemy))
        {
            return Hacker.STATE_HACK;
        }
        return super.GetActiveState(enemy);
    }
}
