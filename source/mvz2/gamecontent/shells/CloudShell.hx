// Ported from: Assets/Scripts/Vanilla/GameContent/Shells/CloudShell.cs
package mvz2.gamecontent.shells;

import mvz2.gamecontent.damages.VanillaDamageEffects;
import mvz2.gamecontent.shells.VanillaShellID.VanillaShellNames;
import mvz2.vanilla.audios.VanillaSoundID;
import mvz2.vanilla.shells.VanillaShellProps;
import pvzengine.damages.DamageInput;
import pvzengine.shells.ShellDefinition;

@:autoShellDefinition(VanillaShellNames.cloud)
class CloudShell extends ShellDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
        SetProperty(VanillaShellProps.HIT_SOUND, VanillaSoundID.cloth);
    }
    public override function EvaluateDamage(damageInfo:DamageInput):Void
    {
        super.EvaluateDamage(damageInfo);
        if (damageInfo.Effects.HasEffect(VanillaDamageEffects.IMPACT))
        {
            damageInfo.Multiply(0.5);
        }
        if (damageInfo.Effects.HasEffect(VanillaDamageEffects.FIRE))
        {
            damageInfo.Multiply(0.5);
        }
    }
}
