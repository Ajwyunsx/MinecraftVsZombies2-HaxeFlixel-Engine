// Ported from: Assets/Scripts/Vanilla/GameContent/Buffs/Contraption/Chapter3/StoneShieldProtected.cs
package mvz2.gamecontent.buffs.contraptions;

import mvz2.gamecontent.buffs.VanillaBuffNames;
import mvz2.gamecontent.damages.VanillaDamageEffects;
import mvz2.vanilla.callbacks.VanillaLevelCallbacks;
import pvzengine.callbacks.CallbackResult;
import pvzengine.definitions.BuffDefinition;
import mvz2.vanilla.callbacks.VanillaLevelCallbacks.PreTakeDamageParams;

@:autoBuffDefinition(VanillaBuffNames.Contraption_stoneShieldProtected)
class StoneShieldProtected extends BuffDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
        // PORT-NOTE: C# 为 AddTrigger(VanillaLevelCallbacks.PRE_ENTITY_TAKE_DAMAGE, PreEntityTakeDamageCallback, priority: -100)。
        // Haxe 无命名参数（也没有默认参数可选传），此处按 filter/priority 的声明顺序把优先级放在第 3 个参数位。
        AddTrigger(VanillaLevelCallbacks.PRE_ENTITY_TAKE_DAMAGE, PreEntityTakeDamageCallback, -100);
    }
    function PreEntityTakeDamageCallback(param:PreTakeDamageParams, result:CallbackResult):Void
    {
        var damageInfo = param.input;
        var entity = damageInfo.Entity;
        if (!entity.HasBuff(StoneShieldProtected))
            return;
        if (damageInfo.Effects.HasEffect(VanillaDamageEffects.EXPLOSION))
        {
            result.SetFinalValue(false);
        }
    }
}
