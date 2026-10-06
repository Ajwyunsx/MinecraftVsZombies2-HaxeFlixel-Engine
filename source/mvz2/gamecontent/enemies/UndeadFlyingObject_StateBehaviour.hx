// Ported from: Assets/Scripts/Vanilla/GameContent/Enemies/States/UndeadFlyingObject_StateBehaviour.cs
package mvz2.gamecontent.enemies;

import mvz2.vanilla.entities.VanillaEntityBehaviourNames;
import pvzengine.entities.Entity;

@:autoEntityBehaviourDefinition(VanillaEntityBehaviourNames.undeadFlyingObject_State)
class UndeadFlyingObject_StateBehaviour extends EnemyStateBehaviour
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
    }
    override function GetActiveState(enemy:Entity):Int
    {
        return UndeadFlyingObject.GetUFOState(enemy);
    }
}
