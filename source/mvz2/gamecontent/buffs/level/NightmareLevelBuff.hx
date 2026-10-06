// Ported from: Assets/Scripts/Vanilla/GameContent/Buffs/Level/Chapter2/NightmareLevelBuff.cs
package mvz2.gamecontent.buffs.level;

import mvz2.gamecontent.buffs.VanillaBuffNames;
import mvz2.gamecontent.carts.NyanCat;
import mvz2.gamecontent.carts.VanillaCartID;
import mvz2.vanilla.audios.VanillaSoundID;
import mvz2.vanilla.level.VanillaAreaProps;
import mvz2logic.level.LogicStageProps;
import pvzengine.buffs.Buff;
import pvzengine.definitions.BuffDefinition;
import pvzengine.level.LevelEngine;
import pvzengine.modifiers.BlendOperator;
import pvzengine.modifiers.ColorModifier;
import pvzengine.modifiers.NamespaceIDModifier;
import pvzengine.modifiers.SetOperator;
import unity.Color;

@:autoBuffDefinition(VanillaBuffNames.Level_nightmareLevel)
class NightmareLevelBuff extends BuffDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
        AddModifier(new NamespaceIDModifier(LogicStageProps.CLEAR_SOUND, SetOperator.Set, VanillaSoundID.agnoy));
        AddModifier(new ColorModifier(VanillaAreaProps.WATER_COLOR, BlendOperator.One, BlendOperator.Zero, new Color(0.89, 0, 0, 1)));
        AddModifier(new ColorModifier(VanillaAreaProps.WATER_COLOR_CENSORED, BlendOperator.One, BlendOperator.Zero, new Color(0, 0, 0.5, 1)));
    }
    public override function PostAdd(buff:Buff):Void
    {
        super.PostAdd(buff);
        UpdateAllNyanCats(buff.Level);
    }
    public override function PostRemove(buff:Buff):Void
    {
        // PORT-NOTE: C# 此处误调用 base.PostAdd(buff)（原代码如此），1:1 保留。
        super.PostAdd(buff);
        UpdateAllNyanCats(buff.Level);
    }
    public static function UpdateAllNyanCats(level:LevelEngine):Void
    {
        for (cat in level.FindEntities(VanillaCartID.nyanCat))
        {
            NyanCat.UpdateNyaightmareToLevel(cat);
        }
    }
}
