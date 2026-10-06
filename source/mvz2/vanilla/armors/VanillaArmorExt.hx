// Ported from: Assets/Scripts/Vanilla/GameContent/Armors/VanillaArmorExt.cs
package mvz2.vanilla.armors;

import mvz2.gamecontent.buffs.armors.ArmorDamageColorBuff;
import mvz2.vanilla.callbacks.VanillaLevelCallbacks;
import mvz2.vanilla.callbacks.VanillaLevelCallbacks.PreArmorTakeDamageParams;
import mvz2.vanilla.callbacks.VanillaLevelCallbacks.PostArmorTakeDamageParams;
import mvz2.vanilla.entities.VanillaEntityExt;
// PORT-NOTE: C# 的 AddTickHealing(this Entity, float) 移植为 FragmentExt 中的静态方法，调用点沿用扩展方法风格。
using mvz2.vanilla.effects.FragmentExt;
import mvz2.vanilla.entities.IDestroyBySpikesEntityBehaviour.IDestroyBySpikesArmorBehaviour;
import pvzengine.armors.Armor;
import pvzengine.damages.ArmorDamageResult;
import pvzengine.damages.ArmorDestroyInfo;
import pvzengine.damages.DamageInput;
import pvzengine.damages.DamageStates;
import pvzengine.damages.HealInput;
import pvzengine.damages.HealOutput;
import pvzengine.callbacks.CallbackResult;
import pvzengine.entities.Entity;
import pvzengine.level.ILevelSourceReference;
import unity.Mathf;

// PORT-NOTE: C# 扩展方法 → 以 Armor 为首参的静态方法（PORTING.md §扩展方法）。
class VanillaArmorExt
{
    public static function DamageBlink(armor:Armor):Void
    {
        if (armor != null && !armor.HasBuff(ArmorDamageColorBuff))
            armor.AddBuff(ArmorDamageColorBuff);
    }
    public static function SetModelDamagePercent(armor:Armor):Void
    {
        SetModelDamagePercentWithHealth(armor, armor.Health, armor.GetMaxHealth());
    }
    // PORT-NOTE: Haxe has no method overloading; renamed overload to SetModelDamagePercentWithHealth.
    public static function SetModelDamagePercentWithHealth(armor:Armor, health:Float, maxHealth:Float):Void
    {
        SetModelDamagePercentValue(armor, 1 - health / maxHealth);
    }
    // PORT-NOTE: Haxe has no method overloading; renamed overload to SetModelDamagePercentValue.
    public static function SetModelDamagePercentValue(armor:Armor, percent:Float):Void
    {
        armor.SetModelProperty("DamagePercent", percent);
    }

    static function PreArmorTakeDamage(armor:Armor, input:DamageInput, result:ArmorDamageResult):Int
    {
        var callbackResult = new CallbackResult(DamageStates.CONTINUE);
        if (!callbackResult.IsBreakRequested)
        {
            var param = new PreArmorTakeDamageParams(input, armor, result);
            input.Entity.Level.Triggers.RunCallbackWithResultFiltered(VanillaLevelCallbacks.PRE_ARMOR_TAKE_DAMAGE, param, callbackResult, armor.Definition.GetID());
        }
        return callbackResult.GetValue();
    }
    static function PostArmorTakeDamage(armor:Armor, result:ArmorDamageResult):Void
    {
        var param = new PostArmorTakeDamageParams(result);
        result.Entity.Level.Triggers.RunCallbackFiltered(VanillaLevelCallbacks.POST_ARMOR_TAKE_DAMAGE, param, armor.Definition.GetID());
    }
    public static function TakeDamage(armor:Armor, info:DamageInput):Null<ArmorDamageResult>
    {
        // PORT-NOTE: C# 的 static Armor.Exists(Armor?) 因与实例方法 Exists() 同名，在 Haxe 中更名为 Armor.ExistsArmor。
        if (!Armor.ExistsArmor(armor))
            return null;

        var entity = info.Entity;
        var shell = armor.GetShellDefinition();
        var result = new ArmorDamageResult(info, armor, shell);

        var damageState = PreArmorTakeDamage(armor, info, result);
        if (damageState == DamageStates.BREAK)
        {
            return null;
        }
        else if (damageState == DamageStates.RETURN)
        {
            return result;
        }

        if (shell != null)
        {
            shell.EvaluateDamage(info);
        }

        // Apply Damage
        var amount = info.Amount;
        if (amount > 0)
        {
            var hpBefore = armor.Health;
            armor.Health -= amount;

            result.Amount = amount;
            result.SpendAmount = Mathf.Min(hpBefore, amount);
            result.Fatal = hpBefore > 0 && armor.Health <= 0;
            if (result.Fatal)
            {
                var destroyInfo = new ArmorDestroyInfo(entity, armor, armor.Slot, info.Effects, info.Source, result);
                armor.Destroy(destroyInfo);
            }
        }
        else
        {
            result.Amount = amount;
            result.SpendAmount = amount;
        }

        if (result.HasDamageAmount())
        {
            PostArmorTakeDamage(armor, result);
        }

        return result;
    }
    public static function HealEffects(armor:Armor, amount:Float, source:Null<ILevelSourceReference>):Null<HealOutput>
    {
        var result = HealSourced(armor, amount, source);
        if (result == null)
            return null;
        if (result.RealAmount >= 0)
        {
            armor.Owner.AddTickHealing(result.RealAmount);
        }
        return result;
    }
    public static function HealSourced(armor:Armor, amount:Float, source:Null<ILevelSourceReference>):Null<HealOutput>
    {
        return VanillaEntityExt.HealFromInput(new HealInput(amount, armor.Owner, armor, source));
    }
    // #region 尖刺摧毁
    public static function TryDestroyBySpikes(armor:Armor, source:Entity):Bool
    {
        var destroyed = false;
        var definition = armor.Definition;
        var count = definition.GetBehaviourCount();
        for (i in 0...count)
        {
            var behaviour = definition.GetBehaviourAt(i);
            if (!Std.isOfType(behaviour, IDestroyBySpikesArmorBehaviour))
                continue;
            var entityBehaviour:IDestroyBySpikesArmorBehaviour = cast behaviour;
            if (entityBehaviour.CanBeDestroyedBySpikes(armor, source))
            {
                entityBehaviour.DestroyBySpikes(armor, source);
                destroyed = true;
            }
        }
        return destroyed;
    }
    // #endregion
}
