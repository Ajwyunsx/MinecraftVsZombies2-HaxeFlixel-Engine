// Ported from: Assets/Scripts/Vanilla/GameContent/Buffs/Enemies/Chapter2/GravityPadBuff.cs
package mvz2.gamecontent.buffs.enemies;

import mvz2.gamecontent.buffs.VanillaBuffNames;
import mvz2.vanilla.enemies.VanillaEnemyProps;
import mvz2.vanilla.entities.VanillaEntityProps;
import mvz2.vanilla.modifiers.VanillaModifierPriorities;
import pvzengine.definitions.BuffDefinition;
import pvzengine.entities.EngineEntityProps;
import pvzengine.modifiers.FloatModifier;
import pvzengine.modifiers.NumberOperator;

// C# 文件名 GravityPadBuff.cs，其中顶层类名为 GravityPadGravityBuff。
@:autoBuffDefinition(VanillaBuffNames.Enemy_gravityPadGravity)
class GravityPadGravityBuff extends BuffDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
        AddModifier(new FloatModifier(EngineEntityProps.GRAVITY, NumberOperator.Add, 2, VanillaModifierPriorities.GRAVITY_PAD));
        AddModifier(new FloatModifier(VanillaEnemyProps.SPEED, NumberOperator.Multiply, 0.5));
        AddModifier(new FloatModifier(VanillaEntityProps.BLOW_MASS_OFFSET, NumberOperator.Add, 2));
    }
}
