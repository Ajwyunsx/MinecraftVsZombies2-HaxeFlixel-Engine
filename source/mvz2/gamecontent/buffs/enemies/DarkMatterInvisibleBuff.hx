// Ported from: Assets/Scripts/Vanilla/GameContent/Buffs/Enemies/Chapter2/DarkMatterInvisibleBuff.cs
package mvz2.gamecontent.buffs.enemies;

import mvz2.gamecontent.buffs.VanillaBuffID;
import mvz2.gamecontent.buffs.VanillaBuffNames;
import mvz2logic.entities.HPBarVisibility;
import mvz2logic.entities.LogicEntityProps;
import pvzengine.auras.AuraEffect;
import pvzengine.auras.AuraEffectDefinition;
import pvzengine.buffs.IBuffTarget;
import pvzengine.callbacks.CallbackResult;
import pvzengine.callbacks.LevelCallbacks;
import pvzengine.definitions.BuffDefinition;
import pvzengine.entities.EngineEntityProps;
import pvzengine.modifiers.BooleanModifier;
import pvzengine.modifiers.ColorModifier;
import pvzengine.modifiers.IntModifier;
import pvzengine.modifiers.IntegerOperator;
import unity.Color;
import pvzengine.callbacks.LevelCallbacks.PostGameOverParams;

@:autoBuffDefinition(VanillaBuffNames.Enemy_darkMatterInvisible)
class DarkMatterInvisibleBuff extends BuffDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
        AddModifier(ColorModifier.Multiply(EngineEntityProps.TINT, new Color(1, 1, 1, 0)));
        AddModifier(new BooleanModifier(LogicEntityProps.SHOW_HEIGHT_INDICATOR, false));
        AddModifier(new IntModifier(LogicEntityProps.HP_BAR_VISIBILITY, IntegerOperator.Set, HPBarVisibility.HIDDEN));
        AddModifier(new BooleanModifier(LogicEntityProps.SHADOW_HIDDEN, true));
        AddAura(new ArmorInvisibleAura());
        AddTrigger(LevelCallbacks.POST_GAME_OVER, PostGameOverCallback);
    }
    private function PostGameOverCallback(param:PostGameOverParams, result:CallbackResult):Void
    {
        var level = param.level;
        for (entity in level.FindEntities(function(e) return e.HasBuff(DarkMatterInvisibleBuff)))
        {
            entity.RemoveBuffs(DarkMatterInvisibleBuff);
        }
    }
}

// PORT-NOTE: C# 嵌套类 DarkMatterInvisibleBuff.ArmorInvisibleAura → Haxe 模块子类型，访问路径一致。
class ArmorInvisibleAura extends AuraEffectDefinition
{
    public function new()
    {
        super(VanillaBuffID.Armor.darkMatterArmorInvisible);
    }

    public override function GetAuraTargets(auraEffect:AuraEffect, results:Array<IBuffTarget>):Void
    {
        var entity = auraEffect.Source.GetEntity();
        if (entity == null)
            return;
        for (slot in entity.GetActiveArmorSlots())
        {
            var armor = entity.GetArmorAtSlot(slot);
            if (armor == null)
                continue;
            results.push(armor);
        }
    }
}
