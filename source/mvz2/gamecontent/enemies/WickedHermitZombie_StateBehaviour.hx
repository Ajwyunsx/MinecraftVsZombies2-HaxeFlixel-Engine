// Ported from: Assets/Scripts/Vanilla/GameContent/Enemies/States/WickedHermitZombie_StateBehaviour.cs
package mvz2.gamecontent.enemies;

import mvz2.vanilla.detection.Detection;
import mvz2.vanilla.entities.VanillaEntityBehaviourNames;
import mvz2.vanilla.entities.VanillaEntityExt;
import pvzengine.entities.Entity;
import mvz2.gamecontent.enemies.EnemyStateBehaviour;

@:autoEntityBehaviourDefinition(VanillaEntityBehaviourNames.wickedHermitZombie_State)
class WickedHermitZombie_StateBehaviour extends EnemyStateBehaviour
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
    }
    override function GetActiveState(enemy:Entity):Int
    {
        var state = super.GetActiveState(enemy);
        if (state == EnemyStateBehaviour.STATE_WALK)
        {
            if (!WickedHermitZombie.IsWarpped(enemy))
            {
                var talismanID = WickedHermitZombie.GetTalismanZombie(enemy);
                var talisman = talismanID != null ? talismanID.GetEntity(enemy.Level) : null;
                // PORT-NOTE: C# 扩展方法 Entity.IsBehindOf(target, minDistance) → Detection.IsBehindOf(entity, target, minDistance)。
                if (talisman != null && Detection.IsBehindOf(talisman, enemy, WickedHermitZombie.TALISMAN_DISTANCE))
                {
                    state = EnemyStateBehaviour.STATE_IDLE;
                }
            }
        }
        return state;
    }
}
