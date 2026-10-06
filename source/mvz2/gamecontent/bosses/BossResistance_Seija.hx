// Ported from: Assets/Scripts/Vanilla/GameContent/Bosses/BossResistance/BossResistance_Seija.cs
package mvz2.gamecontent.bosses;

import mvz2.vanilla.entities.VanillaEntityBehaviourNames;
import pvzengine.callbacks.CallbackResult;
import pvzengine.damages.DamageInput;
@:autoEntityBehaviourDefinition(VanillaEntityBehaviourNames.bossResistance_Seija)
class BossResistance_Seija extends BossResistance
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
    }
    override public function PreTakeDamage(damageInfo:DamageInput, result:CallbackResult):Void
    {
        var boss = damageInfo.Entity;
        if (damageInfo.Amount >= 600)
        {
            if (Seija.CanUseFabric(boss))
            {
                Seija.UseFabric(boss);
            }
        }
        if (boss.State == Seija.STATE_FABRIC)
        {
            result.SetFinalValue(false);
            return;
        }
        super.PreTakeDamage(damageInfo, result);
    }
}
