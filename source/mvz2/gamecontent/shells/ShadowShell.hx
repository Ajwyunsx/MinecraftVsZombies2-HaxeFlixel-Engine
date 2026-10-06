// Ported from: Assets/Scripts/Vanilla/GameContent/Shells/ShadowShell.cs
package mvz2.gamecontent.shells;

import mvz2.gamecontent.damages.VanillaDamageEffects;
import mvz2.gamecontent.shells.VanillaShellID.VanillaShellNames;
import mvz2.vanilla.audios.VanillaSoundID;
import mvz2.vanilla.shells.VanillaShellProps;
import pvzengine.damages.DamageInput;
import pvzengine.shells.ShellDefinition;

@:autoShellDefinition(VanillaShellNames.shadow)
class ShadowShell extends ShellDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
        SetProperty(VanillaShellProps.HIT_SOUND, VanillaSoundID.splat);
    }
    public override function EvaluateDamage(damageInfo:DamageInput):Void
    {
        super.EvaluateDamage(damageInfo);
        if (damageInfo.HasEffect(VanillaDamageEffects.LIGHT) ||
            damageInfo.HasEffect(VanillaDamageEffects.FIRE) ||
            damageInfo.HasEffect(VanillaDamageEffects.LIGHTNING))
        {
            damageInfo.Multiply(1.5);
        }
    }
}
