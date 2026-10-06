// Ported from: Assets/Scripts/Vanilla/GameContent/Buffs/Level/Debug/DebugGodmodeBuff.cs
package mvz2.gamecontent.buffs.level;

import mvz2.gamecontent.buffs.VanillaBuffNames;
import mvz2logic.level.LogicLevelProps;
import pvzengine.definitions.BuffDefinition;
import pvzengine.modifiers.BooleanModifier;

@:autoBuffDefinition(VanillaBuffNames.Level_debugGodmode)
class DebugGodmodeBuff extends BuffDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
        AddModifier(new BooleanModifier(LogicLevelProps.GODMODE, true));
    }
}
