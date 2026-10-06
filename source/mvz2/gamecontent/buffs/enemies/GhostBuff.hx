// Ported from: Assets/Scripts/Vanilla/GameContent/Buffs/Enemies/Chapter1/GhostBuff.cs
// PORT-NOTE: C# 使用可重用的 List<Buff> 缓冲（entity.GetBuffs<T>(buffer) 非分配重载）避免 GC。
// Haxe 侧 Entity 只提供返回新 Array 的 GetBuffs(定义类) 形式，故此处直接用其返回值；
// 原 buffBuffer / checkBuffer 字段不再保留（无对应 API）。
package mvz2.gamecontent.buffs.enemies;

import mvz2.gamecontent.buffs.VanillaBuffNames;
import mvz2.gamecontent.damages.VanillaDamageEffects;
import mvz2.gamecontent.stages.WhackAGhostBehaviour;
import mvz2.vanilla.callbacks.VanillaCallbackPriorities;
import mvz2.vanilla.callbacks.VanillaLevelCallbacks;
import mvz2.vanilla.entities.VanillaEntityExt;
import mvz2.vanilla.entities.VanillaEntityProps;
import mvz2.vanilla.properties.VanillaBuffPropertyMeta;
import mvz2logic.entities.HPBarVisibility;
import mvz2logic.entities.LogicEntityProps;
import mvz2logic.level.LogicLevelExt;
import pvzengine.buffs.Buff;
import pvzengine.callbacks.CallbackResult;
import pvzengine.definitions.BuffDefinition;
import pvzengine.entities.EngineEntityProps;
import pvzengine.entities.Entity;
import pvzengine.modifiers.BooleanModifier;
import pvzengine.modifiers.ColorModifier;
import pvzengine.modifiers.FloatModifier;
import pvzengine.modifiers.IntModifier;
import pvzengine.modifiers.IntegerOperator;
import pvzengine.modifiers.NumberOperator;
import unity.Color;
import unity.Mathf;
import mvz2.vanilla.callbacks.VanillaLevelCallbacks.PreTakeDamageParams;

@:autoBuffDefinition(VanillaBuffNames.Enemy_ghost)
class GhostBuff extends BuffDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
        AddModifier(ColorModifier.Multiply(EngineEntityProps.TINT, PROP_TINT_MULTIPLIER));
        AddModifier(new BooleanModifier(VanillaEntityProps.ETHEREAL, PROP_ETHEREAL));
        var hpbarModifier = new IntModifier(LogicEntityProps.HP_BAR_VISIBILITY, IntegerOperator.Set, PROP_HP_BAR_VISIBLITY);
        hpbarModifier.Condition = function(m:Int) return m == HPBarVisibility.HIDDEN;
        AddModifier(hpbarModifier);
        AddModifier(new FloatModifier(LogicEntityProps.SHADOW_ALPHA, NumberOperator.Multiply, PROP_SHADOW_ALPHA));
        AddTrigger(VanillaLevelCallbacks.PRE_ENTITY_TAKE_DAMAGE, PreEntityTakeDamageCallback, VanillaCallbackPriorities.MULTIPLY);
    }
    public override function OnCreate(buff:Buff):Void
    {
        super.OnCreate(buff);
        buff.SetProperty(PROP_ETHEREAL, true);
        buff.SetProperty(PROP_SHADOW_ALPHA, SHADOW_ALPHA_MIN);
    }
    public override function PostAdd(buff:Buff):Void
    {
        super.PostAdd(buff);
        var totallyInvisible = LogicLevelExt.HasBehaviourType(buff.Level, WhackAGhostBehaviour);
        SetTotallyInvisible(buff, totallyInvisible);
        buff.SetProperty(PROP_HP_BAR_VISIBLITY, totallyInvisible ? HPBarVisibility.HIDDEN : HPBarVisibility.NORMAL);
        buff.SetProperty(PROP_TINT_MULTIPLIER, new Color(1, 1, 1, GetMinAlpha(buff)));
        UpdateIllumination(buff);
    }
    public override function PostUpdate(buff:Buff):Void
    {
        super.PostUpdate(buff);
        UpdateIllumination(buff);
    }
    private function PreEntityTakeDamageCallback(param:PreTakeDamageParams, callbackResult:CallbackResult):Void
    {
        var damageInfo = param.input;
        var entity = damageInfo.Entity;
        if (entity == null)
            return;
        if (damageInfo.Effects.HasEffect(VanillaDamageEffects.WHACK))
            return;
        var buffBuffer = entity.GetBuffs(GhostBuff);
        if (buffBuffer.length <= 0)
            return;
        if (damageInfo.HasEffect(VanillaDamageEffects.FIRE) || damageInfo.HasEffect(VanillaDamageEffects.LIGHTNING) || damageInfo.HasEffect(VanillaDamageEffects.LIGHT))
        {
            for (buff in buffBuffer)
            {
                buff.SetProperty(PROP_ETHEREAL, false);
                SetEverIlluminated(buff, true);
            }
        }
        for (buff in buffBuffer)
        {
            if (buff.GetProperty(PROP_ETHEREAL))
            {
                damageInfo.Multiply(0.1);
                break;
            }
        }
    }
    private function UpdateIllumination(buff:Buff):Void
    {
        var entity = buff.GetEntity();
        if (entity == null)
            return;
        var illuminated = LogicLevelExt.IsDay(entity.Level) || VanillaEntityExt.IsIlluminated(entity) || VanillaEntityProps.IsAIFrozen(entity);
        SetIlluminated(buff, illuminated);
    }
    public static function SetIlluminated(buff:Buff, illuminated:Bool):Void
    {
        if (illuminated)
        {
            SetEverIlluminated(buff, true);
        }
        var entity = buff.GetEntity();
        if (entity == null)
            return;
        var tintSpeed = illuminated ? TINT_SPEED : -TINT_SPEED;
        var shadowSpeed = illuminated ? SHADOW_ALPHA_SPEED : -SHADOW_ALPHA_SPEED;
        var ethereal = illuminated ? false : true;

        var tint = buff.GetProperty(PROP_TINT_MULTIPLIER);
        tint.a = Mathf.Clamp(tint.a + tintSpeed, GetMinAlpha(buff), TINT_ALPHA_MAX);

        var shadowAlpha = buff.GetProperty(PROP_SHADOW_ALPHA);
        shadowAlpha = Mathf.Clamp(shadowAlpha + shadowSpeed, SHADOW_ALPHA_MIN, SHADOW_ALPHA_MAX);

        buff.SetProperty(PROP_TINT_MULTIPLIER, tint);
        buff.SetProperty(PROP_SHADOW_ALPHA, shadowAlpha);
        buff.SetProperty(PROP_ETHEREAL, ethereal);
    }
    public static function Illuminate(buff:Buff):Void
    {
        buff.SetProperty(PROP_TINT_MULTIPLIER, Color.white);
        buff.SetProperty(PROP_SHADOW_ALPHA, SHADOW_ALPHA_MAX);
        buff.SetProperty(PROP_ETHEREAL, false);
    }
    private static function GetMinAlpha(buff:Buff):Float
    {
        if (IsTotallyInvisible(buff))
        {
            return 0;
        }
        return TINT_ALPHA_MIN;
    }
    private static function IsTotallyInvisible(buff:Buff):Bool return buff.GetProperty(PROP_TOTALLY_INVISIBLE);
    private static function SetTotallyInvisible(buff:Buff, value:Bool):Void buff.SetProperty(PROP_TOTALLY_INVISIBLE, value);
    public static function SetEverIlluminated(buff:Buff, value:Bool):Void
    {
        buff.SetProperty(PROP_EVER_ILLUMINATED, value);
    }
    public static function IsEverIlluminated(buff:Buff):Bool
    {
        return buff.GetProperty(PROP_EVER_ILLUMINATED);
    }
    public static function IsEverIlluminatedEntity(entity:Entity):Bool
    {
        // PORT-NOTE: C# 重载 IsEverIlluminated(Entity) 在 Haxe 中改名为 IsEverIlluminatedEntity。
        var checkBuffer = entity.GetBuffs(GhostBuff);
        for (buff in checkBuffer)
        {
            if (GhostBuff.IsEverIlluminated(buff))
            {
                return true;
            }
        }
        return false;
    }
    public static var PROP_TOTALLY_INVISIBLE:VanillaBuffPropertyMeta<Bool> = new VanillaBuffPropertyMeta<Bool>("totally_invisible");
    public static var PROP_HP_BAR_VISIBLITY:VanillaBuffPropertyMeta<Int> = new VanillaBuffPropertyMeta<Int>("hp_bar_visiblity");
    public static var PROP_EVER_ILLUMINATED:VanillaBuffPropertyMeta<Bool> = new VanillaBuffPropertyMeta<Bool>("EverIlluminated");
    public static var PROP_TINT_MULTIPLIER:VanillaBuffPropertyMeta<Color> = new VanillaBuffPropertyMeta<Color>("TintMultiplier");
    public static var PROP_SHADOW_ALPHA:VanillaBuffPropertyMeta<Float> = new VanillaBuffPropertyMeta<Float>("ShadowAlpha");
    public static var PROP_ETHEREAL:VanillaBuffPropertyMeta<Bool> = new VanillaBuffPropertyMeta<Bool>("Ethereal");
    public static inline var TINT_ALPHA_MIN:Float = 0.5;
    public static inline var TINT_ALPHA_MAX:Float = 1;
    public static inline var TINT_SPEED:Float = 0.02;
    public static inline var SHADOW_ALPHA_MIN:Float = 0;
    public static inline var SHADOW_ALPHA_MAX:Float = 1;
    public static inline var SHADOW_ALPHA_SPEED:Float = 0.04;
}
