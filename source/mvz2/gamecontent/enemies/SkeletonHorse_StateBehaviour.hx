// Ported from: Assets/Scripts/Vanilla/GameContent/Enemies/States/SkeletonHorse_StateBehaviour.cs
package mvz2.gamecontent.enemies;

import mvz2.vanilla.entities.VanillaEntityBehaviourNames;
import mvz2.vanilla.enemies.VanillaEnemyStates;
import pvzengine.entities.Entity;

@:autoEntityBehaviourDefinition(VanillaEntityBehaviourNames.skeletonHorse_State)
class SkeletonHorse_StateBehaviour extends EnemyStateBehaviour
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
    }
    override function GetActiveState(enemy:Entity):Int
    {
        var jumpState = SkeletonHorse.GetJumpState(enemy);
        if (jumpState == SkeletonHorse.JUMP_STATE_LAND)
        {
            return STATE_LAND;
        }
        else if (jumpState == SkeletonHorse.JUMP_STATE_JUMP)
        {
            return STATE_JUMP;
        }
        else if (SkeletonHorse.GetGallopTime(enemy) > 0)
        {
            return STATE_GALLOP;
        }
        return super.GetActiveState(enemy);
    }
    public static inline var STATE_GALLOP:Int = VanillaEnemyStates.SKELETON_HORSE_GALLOP;
    public static inline var STATE_JUMP:Int = VanillaEnemyStates.SKELETON_HORSE_JUMP;
    public static inline var STATE_LAND:Int = VanillaEnemyStates.SKELETON_HORSE_LAND;
}
