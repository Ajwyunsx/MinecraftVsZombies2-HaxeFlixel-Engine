// Ported from: Assets/Scripts/Vanilla/GameContent/Buffs/Level/Debug/DebugEnergyBuff.cs
package mvz2.gamecontent.buffs.level;

import mvz2.gamecontent.buffs.VanillaBuffNames;
import pvzengine.buffs.Buff;
import pvzengine.definitions.BuffDefinition;

@:autoBuffDefinition(VanillaBuffNames.Level_debugEnergy)
class DebugEnergyBuff extends BuffDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
    }
    public override function PostUpdate(buff:Buff):Void
    {
        super.PostUpdate(buff);
        buff.Level.AddEnergy(9990);
    }
}
