// Ported from: Assets/Scripts/Vanilla/GameContent/Contraptions/Chapter1/Punchton.cs
package mvz2.gamecontent.contraptions;

import mvz2.gamecontent.buffs.enemies.PunchtonAchievementBuff;
import mvz2.gamecontent.damages.VanillaDamageEffects;
import mvz2.gamecontent.detections.PunchtonDetector;
import mvz2.gamecontent.effects.VanillaEffectID;
import mvz2.gamecontent.models.VanillaModelID;
import mvz2.vanilla.audios.VanillaSoundID;
import mvz2.vanilla.contraptions.VanillaContraptionStates;
import mvz2.vanilla.detection.Detector;
import mvz2.vanilla.entities.VanillaEntityExt;
import mvz2.vanilla.properties.VanillaEntityPropertyMeta;
import mvz2.vanilla.unlocks.VanillaUnlockID;
import mvz2logic.Global;
import mvz2logic.entities.LogicEntityExt;
import mvz2logic.level.LogicLevelExt;
import mvz2logic.level.LevelPositions;
import pvzengine.NamespaceID;
import pvzengine.buffs.BuffExt;
import pvzengine.collisions.IEntityCollider;
import pvzengine.damages.DamageEffectList;
import pvzengine.entities.Entity;
import pvzengine.entities.EntityTypes;
import tools.FrameTimer;
using mvz2.vanilla.entities.VanillaColliderExt;
using mvz2.vanilla.entities.VanillaEntityExt;
using mvz2.vanilla.entities.VanillaEntityProps;
using mvz2logic.entities.LogicContraptionProps;
using mvz2logic.entities.LogicEntityExt;

@:autoEntityBehaviourDefinition(VanillaContraptionNames.punchton)
class Punchton extends ContraptionBehaviour
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
        detector = new PunchtonDetector(false);
        punchDetector = new PunchtonDetector(true);
        cast(punchDetector, PunchtonDetector).canDetectInvisible = true;
        evokedDetector = new PunchtonDetector(true);
        cast(evokedDetector, PunchtonDetector).canDetectInvisible = true;
        cast(evokedDetector, PunchtonDetector).infiniteRange = true;
    }

    public override function Init(entity:Entity):Void
    {
        super.Init(entity);
        SetStateTimer(entity, new FrameTimer());
    }
    override function UpdateAI(entity:Entity):Void
    {
        super.UpdateAI(entity);
        if (!entity.IsEvoked())
        {
            AttackUpdate(entity);
            return;
        }
        EvokedUpdate(entity);
    }
    override function UpdateLogic(entity:Entity):Void
    {
        super.UpdateLogic(entity);
        entity.SetAnimationInt("ArmState", GetArmState(entity));
        entity.SetAnimationFloat("Extension", GetArmExtension(entity));
        entity.SetAnimationFloat("FixBlend", GetArmFixBlend(entity));
    }

    override function OnEvoke(entity:Entity):Void
    {
        super.OnEvoke(entity);
        var timer = GetStateTimer(entity);
        if (timer != null)
            timer.ResetTime(30);
        entity.State = STATE_IDLE;
        entity.SetEvoked(true);
    }
    function AttackUpdate(entity:Entity):Void
    {
        if (entity.State == STATE_IDLE)
        {
            var extension = GetArmExtension(entity);
            extension = extension * 0.5;
            SetArmExtension(entity, extension);

            if (detector.DetectExists(DetectionParams.fromEntity(entity)))
            {
                var timer = GetStateTimer(entity);
                if (timer != null)
                    timer.ResetTime(30);
                entity.State = STATE_PUNCH;
                Punch(entity);
            }
        }
        else if (entity.State == STATE_PUNCH)
        {
            var extension = GetArmExtension(entity);
            extension = extension * 0.5 + entity.GetRange() * 0.5;
            SetArmExtension(entity, extension);

            var timer = GetStateTimer(entity);
            if (timer.RunToExpiredAndNotNull())
            {
                timer.ResetTime(RESTORE_TIME);
                entity.State = STATE_BROKEN;

                // Spawn droken piston palm.
                var direction = entity.GetFacingDirection();
                var position = entity.Position + direction * extension;
                // C#: entity.Level.Spawn(...)?.Let(e => { ... })
                var effect = entity.Level.Spawn(VanillaEffectID.brokenArmor, position, entity);
                if (effect != null)
                {
                    effect.Velocity = direction * -5;
                    effect.SetDisplayScale(entity.GetDisplayScale());
                    effect.ChangeModel(VanillaModelID.pistonPalm);
                }
            }
        }
        else if (entity.State == STATE_BROKEN)
        {
            var extension = GetArmExtension(entity);
            extension = extension * 0.5;
            SetArmExtension(entity, extension);

            var timer = GetStateTimer(entity);
            if (timer.RunToExpiredAndNotNull())
            {
                timer.Reset();
                entity.State = STATE_IDLE;
            }
        }
    }
    function Punch(entity:Entity):Void
    {
        entity.PlaySound(VanillaSoundID.impact);
        detectBuffer = [];
        punchDetector.DetectMultiple(DetectionParams.fromEntity(entity), detectBuffer);
        for (collider in detectBuffer)
        {
            collider.TakeDamage(entity.GetDamage(), new DamageEffectList([VanillaDamageEffects.IGNORE_ARMOR, VanillaDamageEffects.IMPACT, VanillaDamageEffects.MUTE]), entity);

            var ent = collider.Entity;
            if (collider.IsForMain() && ent.Type == EntityTypes.ENEMY)
            {
                ent.Velocity += entity.GetFacingDirection() * 20 * ent.GetStrongKnockbackMultiplier();
                CheckAchievement(ent);
            }
        }
    }
    function EvokedUpdate(entity:Entity):Void
    {
        if (entity.State == STATE_IDLE)
        {
            var extension = GetArmExtension(entity);
            extension = extension * 0.5;
            SetArmExtension(entity, extension);

            var timer = GetStateTimer(entity);
            if (timer.RunToExpiredAndNotNull())
            {
                LongPunch(entity);
                timer.ResetTime(30);
                entity.State = STATE_PUNCH;
            }
        }
        else if (entity.State == STATE_PUNCH)
        {
            var extension = GetArmExtension(entity);
            extension = extension * 0.5 + 1400 * 0.5;
            SetArmExtension(entity, extension);

            var timer = GetStateTimer(entity);
            if (timer.RunToExpiredAndNotNull())
            {
                timer.Reset();
                entity.State = STATE_IDLE;
                entity.SetEvoked(false);
            }
        }
    }
    function LongPunch(entity:Entity):Void
    {
        entity.PlaySound(VanillaSoundID.impact);
        detectBuffer = [];
        evokedDetector.DetectMultiple(DetectionParams.fromEntity(entity), detectBuffer);
        for (collider in detectBuffer)
        {
            collider.TakeDamage(entity.GetDamage() * EVOKED_DAMAGE_MULTIPLIER, new DamageEffectList([VanillaDamageEffects.IGNORE_ARMOR, VanillaDamageEffects.IMPACT, VanillaDamageEffects.MUTE]), entity);
            var ent = collider.Entity;
            if (ent.Type == EntityTypes.ENEMY)
            {
                var pos = ent.Position;
                pos.x = LevelPositions.GetBorderX(!entity.IsFacingLeft());
                ent.Position = pos;
            }
        }
    }
    function GetArmState(entity:Entity):Int
    {
        if (entity.IsEvoked() && entity.State == STATE_IDLE)
            return 2;
        if (entity.State == STATE_BROKEN)
            return 1;
        return 0;
    }
    function GetArmFixBlend(entity:Entity):Float
    {
        if (entity.State != STATE_BROKEN)
            return 1;
        var timer = GetStateTimer(entity);
        return timer != null ? timer.GetPassedPercentage() : 0;
    }
    public function GetArmExtension(entity:Entity):Float return entity.GetBehaviourFieldNS(ID, PROP_ARM_EXTENSION);
    public function SetArmExtension(entity:Entity, value:Float):Void entity.SetBehaviourFieldNS(ID, PROP_ARM_EXTENSION, value);
    public function GetStateTimer(entity:Entity):Null<FrameTimer> return entity.GetBehaviourFieldNS(ID, PROP_STATE_TIMER);
    public function SetStateTimer(entity:Entity, timer:FrameTimer):Void entity.SetBehaviourFieldNS(ID, PROP_STATE_TIMER, timer);
    function CheckAchievement(entity:Entity):Void
    {
        if (entity.Type != EntityTypes.ENEMY)
            return;
        if (entity.HasBuff(PunchtonAchievementBuff) && !entity.Level.IsIZombie())
        {
            Global.Saves.Unlock(VanillaUnlockID.doubleTrouble);
            Global.Saves.SaveToFile(); // 完成成就后保存游戏。
        }
        else
        {
            entity.AddBuff(PunchtonAchievementBuff);
        }
    }
    public static inline var RESTORE_TIME:Int = 600;
    public static inline var EVOKED_DAMAGE_MULTIPLIER:Float = 5;
    public static inline var STATE_IDLE:Int = VanillaContraptionStates.IDLE;
    public static inline var STATE_PUNCH:Int = VanillaContraptionStates.PUNCHTON_PUNCH;
    public static inline var STATE_BROKEN:Int = VanillaContraptionStates.PUNCHTON_BROKEN;
    static var ID:NamespaceID = VanillaContraptionID.punchton;
    public static var PROP_ARM_EXTENSION:VanillaEntityPropertyMeta<Float> = new VanillaEntityPropertyMeta<Float>("ArmExtension");
    public static var PROP_STATE_TIMER:VanillaEntityPropertyMeta<FrameTimer> = new VanillaEntityPropertyMeta<FrameTimer>("StateTimer");
    var detector:Detector;
    var punchDetector:Detector;
    var evokedDetector:Detector;
    var detectBuffer:Array<IEntityCollider> = [];
}
