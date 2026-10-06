// Ported from: Assets/Scripts/Vanilla/GameContent/Buffs/Contraption/Chapter4/LightningOrbEvokedBuff.cs
package mvz2.gamecontent.buffs.contraptions;

import mvz2.gamecontent.buffs.VanillaBuffNames;
import mvz2.gamecontent.contraptions.TNT;
import mvz2.gamecontent.damages.VanillaDamageEffects;
import mvz2.gamecontent.detections.LawnDetector;
import mvz2.vanilla.audios.VanillaSoundID;
import mvz2.vanilla.callbacks.VanillaLevelCallbacks;
import mvz2.vanilla.detection.Detector;
import mvz2.vanilla.entities.VanillaEntityExt;
import mvz2.vanilla.level.VanillaLevelExt;
import mvz2.vanilla.properties.VanillaBuffPropertyMeta;
import mvz2logic.entities.LogicEntityExt;
import pvzengine.base.ArrayBuffer;
import pvzengine.buffs.Buff;
import pvzengine.callbacks.CallbackResult;
import pvzengine.collisions.IEntityCollider;
import pvzengine.damages.DamageEffectList;
import pvzengine.definitions.BuffDefinition;
import tools.FrameTimer;
import unity.Mathf;
import mvz2.vanilla.callbacks.VanillaLevelCallbacks.PreTakeDamageParams;
import mvz2.vanilla.detection.Detector.DetectionParams;
using mvz2.vanilla.entities.VanillaColliderExt;
using mvz2logic.entities.LogicEntityExt;

@:autoBuffDefinition(VanillaBuffNames.Contraption_lightningOrbEvoked)
class LightningOrbEvokedBuff extends BuffDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
        AddTrigger(VanillaLevelCallbacks.PRE_ENTITY_TAKE_DAMAGE, PreEntityTakeDamageCallback);
        thunderDetector = new LawnDetector();
        cast(thunderDetector, LawnDetector).canDetectInvisible = true;
    }
    public override function PostAdd(buff:Buff):Void
    {
        super.PostAdd(buff);
        buff.SetProperty(PROP_TIMER, new FrameTimer(MAX_TIMEOUT));
    }
    public override function PostUpdate(buff:Buff):Void
    {
        super.PostUpdate(buff);
        var timer = buff.GetProperty(PROP_TIMER);
        var entity = buff.GetEntity();
        if (timer == null || timer.Expired)
        {
            var damage = GetTakenDamage(buff);
            damage = Mathf.Min(damage, MAX_DAMAGE);
            if (damage > 0)
            {
                var level = buff.Level;
                VanillaLevelExt.Thunder(level);
                if (entity != null)
                {
                    thunderBuffer.Clear();
                    // PORT-NOTE: C# 的 DetectMultiple(self, ArrayBuffer<IEntityCollider>) 重载在移植版中改名为 DetectMultipleIntoBuffer。
                    thunderDetector.DetectMultipleIntoBuffer(DetectionParams.fromEntity(entity), thunderBuffer);
                    for (i in 0...thunderBuffer.Count)
                    {
                        var collider = thunderBuffer.Get(i);
                        collider.TakeDamage(damage, new DamageEffectList([VanillaDamageEffects.DAMAGE_BODY_AFTER_ARMOR_BROKEN, VanillaDamageEffects.LIGHTNING]), entity);
                    }
                    var centerPos = entity.GetCenter();
                    TNT.ExplodeArcs(entity, entity.GetCenter());
                    entity.PlaySound(VanillaSoundID.thunder);
                    entity.PlaySound(VanillaSoundID.tridentThunder);
                    entity.PlaySound(VanillaSoundID.teslaAttack);
                }
            }
            buff.Remove();
        }
        else
        {
            timer.Run();
            if (entity != null && entity.IsTimeInterval(15))
            {
                var pitch = 1 + (1 - timer.Frame) / MAX_TIMEOUT;
                entity.PlaySound(VanillaSoundID.energyShield, pitch);
            }
        }
    }
    function PreEntityTakeDamageCallback(param:PreTakeDamageParams, result:CallbackResult):Void
    {
        var damage = param.input;
        var entity = damage.Entity;
        for (buff in entity.GetBuffs(LightningOrbEvokedBuff))
        {
            VanillaEntityExt.HealEffects(entity, damage.Amount, entity);
            AddTakenDamage(buff, damage.Amount);
            result.SetFinalValue(false);
        }
    }
    public static function GetTakenDamage(buff:Buff):Float return buff.GetProperty(PROP_TAKEN_DAMAGE);
    public static function SetTakenDamage(buff:Buff, value:Float):Void buff.SetProperty(PROP_TAKEN_DAMAGE, value);
    public static function AddTakenDamage(buff:Buff, value:Float):Void SetTakenDamage(buff, GetTakenDamage(buff) + value);
    public static inline var MAX_TIMEOUT:Int = 150;
    public static inline var MAX_DAMAGE:Float = 1800;
    public static var PROP_TIMER:VanillaBuffPropertyMeta<FrameTimer> = new VanillaBuffPropertyMeta<FrameTimer>("timer");
    public static var PROP_TAKEN_DAMAGE:VanillaBuffPropertyMeta<Float> = new VanillaBuffPropertyMeta<Float>("takenDamage");
    var thunderDetector:Detector;
    var thunderBuffer:ArrayBuffer<IEntityCollider> = new ArrayBuffer<IEntityCollider>(1024);
}
