// Ported from: Assets/Scripts/Vanilla/GameContent/Enemies/States/SkeletonStatue_StateBehaviour.cs
package mvz2.gamecontent.enemies;

import mvz2.gamecontent.buffs.entities.StoneEyeSlowingBuff;
import mvz2.vanilla.entities.VanillaEntityBehaviourNames;
import pvzengine.buffs.BuffExt;
import pvzengine.entities.Entity;
import mvz2.gamecontent.enemies.EnemyStateBehaviour;

@:autoEntityBehaviourDefinition(VanillaEntityBehaviourNames.skeletonStatue_State)
class SkeletonStatue_StateBehaviour extends EnemyStateBehaviour
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
    }
    override function GetPassiveState(enemy:Entity):Int
    {
        var state = super.GetPassiveState(enemy);
        if (state < 0)
        {
            if (SkeletonStatue.IsReviving(enemy))
            {
                state = SkeletonStatue.STATE_REVIVING;
            }
        }
        return state;
    }
    override function GetActiveState(enemy:Entity):Int
    {
        if (enemy.HasBuff(StoneEyeSlowingBuff))
            return EnemyStateBehaviour.STATE_IDLE;
        return super.GetActiveState(enemy);
    }
}
