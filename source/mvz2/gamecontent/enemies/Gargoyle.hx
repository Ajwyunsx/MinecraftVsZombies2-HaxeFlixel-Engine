// Ported from: Assets/Scripts/Vanilla/GameContent/Enemies/Chapter1/Gargoyle.cs
package mvz2.gamecontent.enemies;

import mvz2.gamecontent.damages.VanillaDamageEffects;
import mvz2.gamecontent.entities.AIEntityBehaviour;
import mvz2.vanilla.unlocks.VanillaUnlockID;
import mvz2logic.Global;
import pvzengine.damages.DeathInfo;
import pvzengine.entities.Entity;

@:autoEntityBehaviourDefinition(VanillaEnemyNames.gargoyle)
class Gargoyle extends AIEntityBehaviour
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
    }
    public override function PostDeath(entity:Entity, info:DeathInfo):Void
    {
        super.PostDeath(entity, info);
        if (info.HasEffect(VanillaDamageEffects.PICKAXE))
        {
            Global.Saves.Unlock(VanillaUnlockID.sculptingStrike);
        }
    }
}
