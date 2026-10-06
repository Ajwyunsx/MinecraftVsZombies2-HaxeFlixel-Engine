// Ported from: Assets/Scripts/Vanilla/GameContent/Enemies/Animation/Hacker_AnimationBehaviour.cs
package mvz2.gamecontent.enemies;

import mvz2.vanilla.entities.VanillaEntityBehaviourNames;
import mvz2.vanilla.enemies.VanillaEnemyStates;
import pvzengine.entities.Entity;
import mvz2.gamecontent.enemies.HumanoidAnimationBehaviour;

@:autoEntityBehaviourDefinition(VanillaEntityBehaviourNames.hacker_Animation)
class Hacker_AnimationBehaviour extends HumanoidAnimationBehaviour
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
    }
    public override function UpdateAnimationParameters(entity:Entity, state:Int):Void
    {
        super.UpdateAnimationParameters(entity, state);
        var timer = Hacker.GetHackTimer(entity);
        entity.SetAnimationFloat("HackProgress", timer != null ? timer.GetPassedPercentage() : 0);
    }
    override function ModifyAnimationParameters(entity:Entity, state:Int, parameters:AnimationParameters):AnimationParameters
    {
        parameters = super.ModifyAnimationParameters(entity, state, parameters);
        if (state == STATE_HACK)
        {
            parameters.walkState = HumanoidAnimationBehaviour.WALK_STATE_NONE;
            parameters.armState = HumanoidAnimationBehaviour.ARM_STATE_SPECIAL_1;
        }
        return parameters;
    }
    public static inline var STATE_HACK:Int = VanillaEnemyStates.HACKER_HACK;
}
