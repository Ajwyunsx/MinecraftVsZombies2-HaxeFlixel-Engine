// Ported from: Assets/Scripts/Vanilla/GameContent/Buffs/Projectiles/Chapter4/HellfireIgnitedBuff.cs
package mvz2.gamecontent.buffs.projectiles;

import mvz2.gamecontent.buffs.VanillaBuffNames;
import mvz2.gamecontent.damages.VanillaDamageEffects;
import mvz2.gamecontent.effects.VanillaEffectID;
import mvz2.vanilla.callbacks.VanillaLevelCallbacks;
import mvz2.vanilla.entities.VanillaEntityExt;
import mvz2.vanilla.entities.VanillaEntityProps;
import mvz2.vanilla.properties.VanillaBuffPropertyMeta;
import mvz2logic.entities.LogicEntityProps;
import pvzengine.buffs.Buff;
import pvzengine.callbacks.CallbackResult;
import pvzengine.damages.DamageEffectList;
import pvzengine.definitions.BuffDefinition;
import pvzengine.modifiers.BooleanModifier;
import pvzengine.modifiers.ColorModifier;
import pvzengine.modifiers.NumberOperator;
import pvzengine.modifiers.Vector3Modifier;
import unity.Color;
import unity.Mathf;
import unity.Vector3;
import mvz2.vanilla.callbacks.VanillaLevelCallbacks.PostProjectileHitParams;
using mvz2.vanilla.entities.VanillaEntityExt;
using mvz2.vanilla.entities.VanillaEntityProps;

@:autoBuffDefinition(VanillaBuffNames.Projectile_hellfireIgnited)
class HellfireIgnitedBuff extends BuffDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
        AddModifier(new BooleanModifier(VanillaEntityProps.IS_FIRE, true));
        AddModifier(new BooleanModifier(LogicEntityProps.IS_LIGHT_SOURCE, true));
        AddModifier(new Vector3Modifier(LogicEntityProps.LIGHT_RANGE, NumberOperator.Add, PROP_LIGHT_RANGE_ADDITION));
        AddModifier(ColorModifier.Override(LogicEntityProps.LIGHT_COLOR, PROP_LIGHT_COLOR));
        AddTrigger(VanillaLevelCallbacks.POST_PROJECTILE_HIT, PostProjectileHitCallback);
    }
    public override function PostAdd(buff:Buff):Void
    {
        super.PostAdd(buff);
        Uncurse(buff);
        UpdateLightRange(buff);
    }
    public override function PostUpdate(buff:Buff):Void
    {
        super.PostUpdate(buff);
        UpdateLightRange(buff);
    }
    private function UpdateLightRange(buff:Buff):Void
    {
        var entity = buff.GetEntity();
        var scale:Float = 1;
        if (entity != null)
        {
            var scaledSize = entity.GetScaledSize();
            var scaleVec = scaledSize / DEFAULT_SCALE;
            scale = Mathf.Max(scaleVec.x, Mathf.Max(scaleVec.y, scaleVec.z));
        }
        buff.SetProperty(PROP_LIGHT_RANGE_ADDITION, Vector3.one * 20 * scale);
    }
    private function PostProjectileHitCallback(param:PostProjectileHitParams, result:CallbackResult):Void
    {
        var hit = param.hit;
        var projectile = hit.Projectile;
        if (!projectile.HasBuff(HellfireIgnitedBuff))
            return;
        var buffs = projectile.GetBuffs(HellfireIgnitedBuff);
        var additionalDamage:Float = 0;
        var cursed = false;
        for (buff in buffs)
        {
            if (GetCursed(buff))
            {
                additionalDamage += projectile.GetDamage() * 2;
                cursed = true;
            }
            else
            {
                additionalDamage += projectile.GetDamage();
            }
        }
        if (additionalDamage <= 0)
            return;
        var target = hit.Other;
        var shield = hit.Shield;
        var armorSlot = shield != null ? shield.Slot : null;
        target.TakeDamage(additionalDamage, new DamageEffectList([VanillaDamageEffects.FIRE]), projectile, armorSlot);

        var damage = param.damage;
        var blocksFire = damage != null && VanillaEntityExt.WillDamageBlockFire(damage);

        if (!blocksFire)
        {
            var entity = projectile;
            var level = entity.Level;

            var damageEffects = new DamageEffectList([VanillaDamageEffects.FIRE, VanillaDamageEffects.MUTE]);
            var center = entity.GetCenter();
            var radius = 40;
            var faction = entity.GetFaction();
            var splashAmount = additionalDamage * 2 / 3;
            VanillaEntityExt.SplashDamage(entity, hit.Collider, center, radius, faction, splashAmount, damageEffects);

            var effectID = cursed ? VanillaEffectID.cursedFireburn : VanillaEffectID.fireburn;
            entity.Spawn(effectID, entity.Position);
        }
    }
    public static function Curse(buff:Buff):Void
    {
        SetLightColor(buff, LIGHT_COLOR_CURSED);
        SetCursed(buff, true);
    }
    public static function Uncurse(buff:Buff):Void
    {
        SetLightColor(buff, LIGHT_COLOR);
        SetCursed(buff, false);
    }
    public static function SetLightColor(buff:Buff, value:Color):Void buff.SetProperty(PROP_LIGHT_COLOR, value);
    public static function GetLightColor(buff:Buff):Color return buff.GetProperty(PROP_LIGHT_COLOR);
    public static function SetCursed(buff:Buff, value:Bool):Void buff.SetProperty(PROP_CURSED, value);
    public static function GetCursed(buff:Buff):Bool return buff.GetProperty(PROP_CURSED);
    public static var PROP_LIGHT_COLOR:VanillaBuffPropertyMeta<Color> = new VanillaBuffPropertyMeta<Color>("lightColor");
    public static var PROP_LIGHT_RANGE_ADDITION:VanillaBuffPropertyMeta<Vector3> = new VanillaBuffPropertyMeta<Vector3>("light_range_addition");
    public static var PROP_CURSED:VanillaBuffPropertyMeta<Bool> = new VanillaBuffPropertyMeta<Bool>("cursed");
    public static inline var DEFAULT_SCALE:Float = 32;
    public static var LIGHT_COLOR:Color = new Color(1, 0.5, 0);
    public static var LIGHT_COLOR_CURSED:Color = new Color(0, 1, 0);
}
