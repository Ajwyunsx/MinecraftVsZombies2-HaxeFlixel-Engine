// Ported from: Assets/Scripts/Vanilla/GameContent/Effects/Chapter4/SkyBackground.cs
package mvz2.gamecontent.effects;

import mvz2.gamecontent.buffs.VanillaBuffID;
import mvz2.gamecontent.buffs.level.SpiritUniverseNightBuff;
import mvz2.vanilla.entities.VanillaEntityBehaviourNames;
import mvz2.vanilla.entities.VanillaEntityExt;
import mvz2.vanilla.properties.VanillaEntityPropertyMeta;
import mvz2logic.entities.LogicEntityExt;
import mvz2logic.level.LogicLevelExt;
import pvzengine.EngineEntityProps;
import pvzengine.PropertyMeta;
import pvzengine.auras.AuraEffect;
import pvzengine.auras.AuraEffectDefinition;
import pvzengine.auras.IBuffTarget;
import pvzengine.buffs.Buff;
import pvzengine.definitions.EntityBehaviourDefinition;
import pvzengine.entities.Entity;
import pvzengine.modifiers.ColorModifier;
import tools.Ticks;
import unity.Color;
import unity.Mathf;

@:autoEntityBehaviourDefinition(VanillaEntityBehaviourNames.skyBackground)
class SkyBackground extends EntityBehaviourDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
        AddModifier(ColorModifier.Multiply(EngineEntityProps.TINT, PROP_TINT_MULTIPLIER));
        AddAura(new SkyBackgroundNightAura());
    }

    public override function Update(entity:Entity):Void
    {
        super.Update(entity);
        var disappearing = (entity.Timeout >= 0 && entity.Timeout < 30) || entity.Level.IsGameOver() || !entity.Level.IsGameStarted();
        var propertyKey = disappearing ? PROP_FADE_OUT_SPEED : PROP_FADE_IN_SPEED;
        var speedPerSecond = entity.GetProperty(propertyKey);
        // PORT-NOTE: C# Ticks.FromPerSecond(float) 属于外部 Tools 程序集，Haxe 侧尚未建立该 shim，
        // 其语义为「每秒值 → 每帧值」，这里内联为等价的除法。
        var speed = speedPerSecond / Ticks.TICKS_PER_SECOND;

        var tintMulti = GetTintMultiplier(entity);
        tintMulti.a = Mathf.Clamp01(tintMulti.a + speed);
        SetTintMultiplier(entity, tintMulti);
    }
    public static function GetTintMultiplier(entity:Entity):Color return entity.GetProperty(PROP_TINT_MULTIPLIER);
    public static function SetTintMultiplier(entity:Entity, color:Color):Void entity.SetProperty(PROP_TINT_MULTIPLIER, color);

    public static var PROP_TINT_MULTIPLIER:PropertyMeta<Color> = new VanillaEntityPropertyMeta<Color>("tint_multiplier", new Color(1, 1, 1, 0));
    public static var PROP_FADE_IN_SPEED:PropertyMeta<Float> = new VanillaEntityPropertyMeta<Float>("fade_in_speed", 1);
    public static var PROP_FADE_OUT_SPEED:PropertyMeta<Float> = new VanillaEntityPropertyMeta<Float>("fade_out_speed", -1);
}

// PORT-NOTE: C# 的嵌套类 SkyBackground.NightAura 提升为模块级类（Haxe 不支持嵌套类）；
// 因为 SkywardSky 也有同名的 NightAura，为避免同包重名，重命名为 SkyBackgroundNightAura。
class SkyBackgroundNightAura extends AuraEffectDefinition
{
    public function new()
    {
        super(VanillaBuffID.Level.spiritUniverseNight);
    }

    public override function GetAuraTargets(auraEffect:AuraEffect, results:Array<IBuffTarget>):Void
    {
        results.push(auraEffect.Level);
    }

    public override function UpdateTargetBuff(effect:AuraEffect, target:IBuffTarget, buff:Buff):Void
    {
        super.UpdateTargetBuff(effect, target, buff);
        var entity = effect != null && effect.Source != null ? effect.Source.GetEntity() : null;
        if (!entity.ExistsAndAlive())
            return;
        var alpha = entity.GetTint().a;
        var color = Color.Lerp(Color.white, Color.black, alpha);
        SpiritUniverseNightBuff.SetBackgroundLightMultiplier(buff, color);
    }
}
