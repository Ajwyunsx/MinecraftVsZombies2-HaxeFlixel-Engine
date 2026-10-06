// Ported from: Assets/Scripts/Vanilla/GameContent/Bosses/BossResistance/BossResistance_TheGiant.cs
package mvz2.gamecontent.bosses;

import mvz2.vanilla.entities.VanillaEntityBehaviourNames;
import pvzengine.callbacks.CallbackResult;
import pvzengine.damages.DamageInput;

@:autoEntityBehaviourDefinition(VanillaEntityBehaviourNames.bossResistance_TheGiant)
class BossResistance_TheGiant extends BossResistance
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
    }
    override public function PreTakeDamage(damageInfo:DamageInput, result:CallbackResult):Void
    {
        var entity = damageInfo.Entity;
        var malleable = TheGiant.GetMalleable(entity);
        if (malleable >= 0)
        {
            damageInfo.Multiply(1 - malleable / TheGiant.MAX_MALLEABLE_DAMAGE);
        }
        super.PreTakeDamage(damageInfo, result);
    }
}
