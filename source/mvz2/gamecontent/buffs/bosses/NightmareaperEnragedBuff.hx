// Ported from: Assets/Scripts/Vanilla/GameContent/Buffs/Boss/Chapter2/NightmareaperEnragedBuff.cs
package mvz2.gamecontent.buffs.bosses;

import mvz2.gamecontent.buffs.VanillaBuffNames;
import mvz2.vanilla.entities.VanillaEntityProps;
import pvzengine.definitions.BuffDefinition;
import pvzengine.entities.EngineEntityProps;
import pvzengine.modifiers.BooleanModifier;

@:autoBuffDefinition(VanillaBuffNames.Boss_nightmareaperEnraged)
class NightmareaperEnragedBuff extends BuffDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
        AddModifier(new BooleanModifier(VanillaEntityProps.INVISIBLE, true));
        AddModifier(new BooleanModifier(EngineEntityProps.INVINCIBLE, true));
    }
}
