// Ported from: Assets/Scripts/Vanilla/GameContent/Buffs/Level/Debug/DebugStarshardBuff.cs
package mvz2.gamecontent.buffs.level;

import mvz2.gamecontent.buffs.VanillaBuffNames;
import pvzengine.buffs.Buff;
import pvzengine.definitions.BuffDefinition;

@:autoBuffDefinition(VanillaBuffNames.Level_debugStarshard)
class DebugStarshardBuff extends BuffDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
    }
    public override function PostUpdate(buff:Buff):Void
    {
        super.PostUpdate(buff);
        buff.Level.AddStarshardCount(5);
    }
}
