// Ported from: Assets/Scripts/Vanilla/GameContent/Buffs/Contraption/Chapter1/MagichestInvincibleBuff.cs
package mvz2.gamecontent.buffs.contraptions;

import mvz2.gamecontent.buffs.VanillaBuffNames;
import mvz2.vanilla.entities.VanillaEntityProps;
import pvzengine.definitions.BuffDefinition;
import pvzengine.entities.EngineEntityProps;
import pvzengine.modifiers.BooleanModifier;

// PORT-NOTE: 原 C# 文件的 AutoBuffDefinition 即引用 VanillaBuffNames.Contraption.mineTNTInvincible（疑似原工程笔误），此处保持 1:1。
@:autoBuffDefinition(VanillaBuffNames.Contraption_mineTNTInvincible)
class MagichestInvincibleBuff extends BuffDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
        AddModifier(new BooleanModifier(EngineEntityProps.INVINCIBLE, true));
        AddModifier(new BooleanModifier(VanillaEntityProps.CAN_DEACTIVE, false));
    }
}
