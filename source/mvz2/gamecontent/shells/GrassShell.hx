// Ported from: Assets/Scripts/Vanilla/GameContent/Shells/GrassShell.cs
package mvz2.gamecontent.shells;

import mvz2.gamecontent.damages.VanillaDamageEffects;
import mvz2.gamecontent.shells.VanillaShellID.VanillaShellNames;
import mvz2.vanilla.audios.VanillaSoundID;
import mvz2.vanilla.shells.VanillaShellProps;
import pvzengine.damages.DamageInput;
import pvzengine.shells.ShellDefinition;

@:autoShellDefinition(VanillaShellNames.grass)
class GrassShell extends ShellDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
        SetProperty(VanillaShellProps.HIT_SOUND, VanillaSoundID.grass);
        SetProperty(VanillaShellProps.SLICE_CRITICAL, true);
    }
    public override function EvaluateDamage(damageInfo:DamageInput):Void
    {
        super.EvaluateDamage(damageInfo);
        if (damageInfo.Effects.HasEffect(VanillaDamageEffects.FIRE))
        {
            damageInfo.Multiply(2);
        }
        if (damageInfo.Effects.HasEffect(VanillaDamageEffects.SLICE))
        {
            damageInfo.Multiply(2);
        }
    }
}
