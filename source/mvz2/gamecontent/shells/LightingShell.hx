// Ported from: Assets/Scripts/Vanilla/GameContent/Shells/LightingShell.cs
package mvz2.gamecontent.shells;

import mvz2.gamecontent.damages.VanillaDamageEffects;
import mvz2.gamecontent.shells.VanillaShellID.VanillaShellNames;
import mvz2.vanilla.armors.VanillaArmorExt;
import mvz2.vanilla.audios.VanillaSoundID;
import mvz2.vanilla.callbacks.VanillaCallbackPriorities;
import mvz2.vanilla.callbacks.VanillaLevelCallbacks;
import mvz2.vanilla.entities.VanillaEntityExt;
import mvz2.vanilla.shells.VanillaShellProps;
import pvzengine.callbacks.CallbackResult;
import pvzengine.damages.DamageStates;
import pvzengine.shells.ShellDefinition;

@:autoShellDefinition(VanillaShellNames.lightning)
class LightingShell extends ShellDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
        SetProperty(VanillaShellProps.HIT_SOUND, VanillaSoundID.energyShieldHit);
        AddTrigger(VanillaLevelCallbacks.PRE_BODY_TAKE_DAMAGE, PreBodyTakeDamageCallback, VanillaCallbackPriorities.LATE);
        AddTrigger(VanillaLevelCallbacks.PRE_ARMOR_TAKE_DAMAGE, PreArmorTakeDamageCallback, VanillaCallbackPriorities.LATE);
    }
    function PreBodyTakeDamageCallback(param:PreBodyTakeDamageParams, result:CallbackResult):Void
    {
        var input = param.input;
        var shell = input.Entity.GetShellDefinition();
        if (shell != this || !input.HasEffect(VanillaDamageEffects.LIGHTNING))
            return;
        VanillaEntityExt.HealEffectsSourced(input.Entity, input.Amount, input.Source);
        result.SetFinalValue(DamageStates.BREAK);
    }
    function PreArmorTakeDamageCallback(param:PreArmorTakeDamageParams, result:CallbackResult):Void
    {
        var input = param.input;
        var armor = param.armor;
        var shell = armor.GetShellDefinition();
        if (shell != this || !input.HasEffect(VanillaDamageEffects.LIGHTNING))
            return;
        VanillaArmorExt.HealEffects(armor, input.Amount, input.Source);
        result.SetFinalValue(DamageStates.BREAK);
    }
}
