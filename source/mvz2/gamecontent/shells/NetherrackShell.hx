// Ported from: Assets/Scripts/Vanilla/GameContent/Shells/NetherrackShell.cs
package mvz2.gamecontent.shells;

import mvz2.gamecontent.damages.VanillaDamageEffects;
import mvz2.gamecontent.shells.VanillaShellID.VanillaShellNames;
import mvz2.vanilla.audios.VanillaSoundID;
import mvz2.vanilla.shells.VanillaShellProps;
import pvzengine.damages.DamageInput;
import pvzengine.shells.ShellDefinition;

@:autoShellDefinition(VanillaShellNames.netherrack)
class NetherrackShell extends ShellDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
        SetProperty(VanillaShellProps.HIT_SOUND, VanillaSoundID.netherrackBreak);
        SetProperty(VanillaShellProps.BLOCKS_SLICE, true);
        SetProperty(VanillaShellProps.BLOCKS_FIRE, true);
    }
    public override function EvaluateDamage(damageInfo:DamageInput):Void
    {
        super.EvaluateDamage(damageInfo);
        if (damageInfo.Effects.HasEffect(VanillaDamageEffects.FIRE))
        {
            damageInfo.Multiply(0);
        }
        if (damageInfo.Effects.HasEffect(VanillaDamageEffects.IMPACT))
        {
            damageInfo.Multiply(20);
        }
    }
}
