// Ported from: Assets/Scripts/Vanilla/GameContent/Buffs/Entity/Chapter6/CursedCandleBuff.cs
package mvz2.gamecontent.buffs.entities;

import mvz2.gamecontent.buffs.VanillaBuffNames;
import mvz2.gamecontent.contraptions.Nuke;
import mvz2.gamecontent.damages.VanillaDamageEffects;
import mvz2.gamecontent.effects.Explosion;
import mvz2.gamecontent.effects.VanillaEffectID;
import mvz2.gamecontent.models.VanillaModelID;
import mvz2.vanilla.audios.VanillaSoundID;
import mvz2.vanilla.callbacks.VanillaLevelCallbacks;
import mvz2.vanilla.level.VanillaLevelExt;
import mvz2.vanilla.models.VanillaModelKeys;
import mvz2.vanilla.properties.VanillaBuffPropertyMeta;
import mvz2logic.entities.LogicEntityExt;
import mvz2logic.entities.LogicEntityProps;
import mvz2logic.models.LogicModelHelper;
import pvzengine.buffs.Buff;
import pvzengine.callbacks.CallbackResult;
import pvzengine.callbacks.LevelCallbacks;
import pvzengine.damages.DamageEffectList;
import pvzengine.definitions.BuffDefinition;
import pvzengine.modifiers.BooleanModifier;
import tools.FrameTimer;
import tools.TimerHelper;
import unity.Mathf;
import pvzengine.callbacks.LevelCallbacks.EntityDeathParams;
using mvz2.vanilla.entities.VanillaEntityExt;

@:autoBuffDefinition(VanillaBuffNames.Entity_cursedCandle)
class CursedCandleBuff extends BuffDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
        AddModelInsertion(LogicModelHelper.ANCHOR_CENTER, VanillaModelKeys.candleCursed, VanillaModelID.candleCursed);
        AddModifier(new BooleanModifier(LogicEntityProps.REMOVE_ON_DEATH, true));
        AddModifier(new BooleanModifier(LogicEntityProps.NO_DEATH_EFFECTS, true));
        AddTrigger(LevelCallbacks.POST_ENTITY_DEATH, PostEntityDeathCallback);
    }
    public override function OnCreate(buff:Buff):Void
    {
        super.OnCreate(buff);
        SetTimer(buff, TimerHelper.NewSecondTimer(DAMAGE_INTERVAL_SECONDS));
    }
    public override function PostUpdate(buff:Buff):Void
    {
        super.PostUpdate(buff);
        var timer = GetTimer(buff);
        if (timer.RunToExpiredAndNotNull())
        {
            var entity = buff.GetEntity();
            if (entity != null)
            {
                var damageEffects = new DamageEffectList([VanillaDamageEffects.FIRE, VanillaDamageEffects.IGNORE_ARMOR]);
                entity.TakeDamage(GetFireDamage(buff), damageEffects, entity);
                entity.Spawn(VanillaEffectID.cursedFireburn, entity.GetCenter());
            }
            timer.Reset();
        }
    }
    private function PostEntityDeathCallback(param:EntityDeathParams, result:CallbackResult):Void
    {
        var entity = param.entity;
        var damage:Float = 0;
        var range:Float = 0;
        var evoked = false;
        for (buff in entity.GetBuffs(CursedCandleBuff))
        {
            damage += GetExplosionDamage(buff);
            range = Mathf.Max(GetExplosionRange(buff), range);
            evoked = IsEvoked(buff) || evoked;
        }
        if (damage <= 0 || range <= 0)
            return;
        var center = entity.GetCenter();
        if (evoked)
        {
            var damageEffects = new DamageEffectList([VanillaDamageEffects.EXPLOSION, VanillaDamageEffects.DAMAGE_BODY_AFTER_ARMOR_BROKEN, VanillaDamageEffects.MUTE, VanillaDamageEffects.NO_DEATH_EFFECTS, VanillaDamageEffects.REMOVE_ON_DEATH]);

            var damageOutputs = entity.ExplodeAgainstFriendly(center, range, entity.GetFaction(), damage, damageEffects);
            VanillaLevelExt.ClearExplosionCorpses(damageOutputs);

            Nuke.ExplodeEffects(entity);
        }
        else
        {
            var damageEffects = new DamageEffectList([VanillaDamageEffects.EXPLOSION, VanillaDamageEffects.DAMAGE_BODY_AFTER_ARMOR_BROKEN, VanillaDamageEffects.MUTE]);

            entity.ExplodeAgainstFriendly(center, range, entity.GetFaction(), damage, damageEffects);

            Explosion.Spawn(entity, center, range);
            LogicEntityExt.PlaySound(entity, VanillaSoundID.explosion);
            entity.Level.ShakeScreen(10, 0, 15);
        }
        entity.RemoveBuffs(CursedCandleBuff);
    }
    public static function IsEvoked(buff:Buff):Bool return buff.GetProperty(PROP_EVOKED);
    public static function SetEvoked(buff:Buff, value:Bool):Void buff.SetProperty(PROP_EVOKED, value);
    public static function GetFireDamage(buff:Buff):Float return buff.GetProperty(PROP_FIRE_DAMAGE);
    public static function SetFireDamage(buff:Buff, value:Float):Void buff.SetProperty(PROP_FIRE_DAMAGE, value);
    public static function GetExplosionDamage(buff:Buff):Float return buff.GetProperty(PROP_EXPLOSION_DAMAGE);
    public static function SetExplosionDamage(buff:Buff, value:Float):Void buff.SetProperty(PROP_EXPLOSION_DAMAGE, value);
    public static function GetExplosionRange(buff:Buff):Float return buff.GetProperty(PROP_EXPLOSION_RANGE);
    public static function SetExplosionRange(buff:Buff, value:Float):Void buff.SetProperty(PROP_EXPLOSION_RANGE, value);
    public static function GetTimer(buff:Buff):Null<FrameTimer> return buff.GetProperty(PROP_TIMER);
    public static function SetTimer(buff:Buff, value:Null<FrameTimer>):Void buff.SetProperty(PROP_TIMER, value);
    public static inline var DAMAGE_INTERVAL_SECONDS:Float = 1;
    public static var PROP_TIMER:VanillaBuffPropertyMeta<FrameTimer> = new VanillaBuffPropertyMeta<FrameTimer>("timer");
    public static var PROP_EVOKED:VanillaBuffPropertyMeta<Bool> = new VanillaBuffPropertyMeta<Bool>("evoked");
    public static var PROP_FIRE_DAMAGE:VanillaBuffPropertyMeta<Float> = new VanillaBuffPropertyMeta<Float>("fire_damage");
    public static var PROP_EXPLOSION_DAMAGE:VanillaBuffPropertyMeta<Float> = new VanillaBuffPropertyMeta<Float>("explosion_damage");
    public static var PROP_EXPLOSION_RANGE:VanillaBuffPropertyMeta<Float> = new VanillaBuffPropertyMeta<Float>("explosion_range");
}
