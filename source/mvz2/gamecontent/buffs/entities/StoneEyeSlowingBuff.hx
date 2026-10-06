// Ported from: Assets/Scripts/Vanilla/GameContent/Buffs/Entity/Chapter6/StoneEyeSlowing.cs
// C# 文件名为 StoneEyeSlowing.cs，其中顶层类名为 StoneEyeSlowingBuff（Haxe 文件名与类名保持一致）。
package mvz2.gamecontent.buffs.entities;

import mvz2.gamecontent.buffs.VanillaBuffNames;
import mvz2.vanilla.enemies.VanillaEnemyProps;
import mvz2.vanilla.entities.VanillaEntityProps;
import mvz2logic.entities.LogicEntityProps;
import pvzengine.definitions.BuffDefinition;
import pvzengine.entities.EngineEntityProps;
import pvzengine.modifiers.ColorModifier;
import pvzengine.modifiers.FloatModifier;
import pvzengine.modifiers.NumberOperator;
import pvzengine.modifiers.Vector3Modifier;
import unity.Color;
import unity.Vector3;

@:autoBuffDefinition(VanillaBuffNames.Entity_stoneEyeSlowing)
class StoneEyeSlowingBuff extends BuffDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
        var hsvModifier = new Vector3Modifier(LogicEntityProps.HSV_OFFSET, NumberOperator.Add, new Vector3(0, -50, 0));
        hsvModifier.NoStack = true;
        AddModifier(hsvModifier);
        AddModifier(new FloatModifier(VanillaEnemyProps.SPEED, NumberOperator.Multiply, 0.5));
        AddModifier(new FloatModifier(VanillaEntityProps.ATTACK_SPEED, NumberOperator.Multiply, 0.5));
        var tintModifier = ColorModifier.Multiply(EngineEntityProps.TINT, new Color(1.05, 1.1, 1.05, 1));
        tintModifier.NoStack = true;
        AddModifier(tintModifier);
    }
}
