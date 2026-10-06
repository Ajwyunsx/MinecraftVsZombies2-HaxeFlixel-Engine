// Ported from: Assets/Scripts/Vanilla/GameContent/Shells/SandShell.cs
package mvz2.gamecontent.shells;

import mvz2.gamecontent.shells.VanillaShellID.VanillaShellNames;
import mvz2.vanilla.audios.VanillaSoundID;
import mvz2.vanilla.shells.VanillaShellProps;
import pvzengine.shells.ShellDefinition;

@:autoShellDefinition(VanillaShellNames.sand)
class SandShell extends ShellDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
        SetProperty(VanillaShellProps.HIT_SOUND, VanillaSoundID.sand);
    }
}
