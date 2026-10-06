// Ported from: Assets/Scripts/Vanilla/GameContent/Contraptions/Chapter1/Magichest.cs
package mvz2.gamecontent.contraptions;

import mvz2.gamecontent.buffs.contraptions.MagichestInvincibleBuff;
import mvz2.gamecontent.detections.MagichestDetector;
import mvz2.gamecontent.effects.VanillaEffectID;
import mvz2.gamecontent.enemies.VanillaEnemyID;
import mvz2.gamecontent.pickups.VanillaPickupID;
import mvz2.vanilla.audios.VanillaSoundID;
import mvz2.vanilla.contraptions.VanillaContraptionStates;
import mvz2.vanilla.detection.Detector;
import mvz2.vanilla.entities.VanillaEntityExt;
import mvz2.vanilla.properties.VanillaEntityPropertyMeta;
import mvz2logic.entities.LogicEntityExt;
import mvz2logic.level.LogicLevelExt;
import pvzengine.NamespaceID;
import pvzengine.buffs.BuffExt;
import pvzengine.entities.Entity;
import tools.FrameTimer;
import unity.Color;
using mvz2.vanilla.entities.VanillaEntityExt;
using mvz2logic.entities.LogicContraptionProps;
using mvz2logic.entities.LogicEntityExt;

@:autoEntityBehaviourDefinition(VanillaContraptionNames.magichest)
class Magichest extends ContraptionBehaviour
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
        openDetector = new MagichestDetector(40);
        eatDetector = new MagichestDetector();
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
        entity.SetAnimationBool("Open", IsOpen(entity));
        entity.SetAnimationBool("Flash", GetFlashVisible(entity));
    }

    public override function CanEvoke(entity:Entity):Bool
    {
        return super.CanEvoke(entity) && (entity.State == STATE_IDLE || entity.State == STATE_OPEN);
    }
    override function OnEvoke(entity:Entity):Void
    {
        super.OnEvoke(entity);
        entity.SetEvoked(true);
    }
    public static function GetStateTimer(entity:Entity):Null<FrameTimer>
    {
        return entity.GetBehaviourFieldNS(ID, PROP_STATE_TIMER);
    }
    public static function SetStateTimer(entity:Entity, timer:FrameTimer):Void
    {
        entity.SetBehaviourFieldNS(ID, PROP_STATE_TIMER, timer);
    }
    public static function GetFlashVisible(entity:Entity):Bool
    {
        return entity.GetBehaviourFieldNS(ID, PROP_FLASH_VISIBLE);
    }
    public static function SetFlashVisible(entity:Entity, timer:Bool):Void
    {
        entity.SetBehaviourFieldNS(ID, PROP_FLASH_VISIBLE, timer);
    }
    public static function Eat(entity:Entity, target:Entity):Void
    {
        entity.SetModelProperty("FlashScale", target.GetScaledSize());
        entity.SetModelProperty("FlashSourcePosition", target.GetCenter());
        target.RemoveDie();
        SetFlashVisible(entity, true);
        entity.AddBuff(MagichestInvincibleBuff);
        entity.PlaySound(VanillaSoundID.magical);
    }
    function AttackUpdate(entity:Entity):Void
    {
        switch (entity.State)
        {
            case STATE_IDLE:
            {
                if (openDetector.DetectExists(DetectionParams.fromEntity(entity)))
                {
                    entity.State = STATE_OPEN;
                    entity.PlaySound(VanillaSoundID.chestOpen);
                    var stateTimer = GetStateTimer(entity);
                    if (stateTimer != null)
                        stateTimer.ResetTime(15);
                }
            }

            case STATE_OPEN:
            {
                var stateTimer = GetStateTimer(entity);
                if (!openDetector.DetectExists(DetectionParams.fromEntity(entity)))
                {
                    entity.State = STATE_IDLE;
                    entity.PlaySound(VanillaSoundID.chestClose);
                }
                else
                {
                    if (stateTimer.RunToExpiredAndNotNull())
                    {
                        var nearest = eatDetector.DetectEntityWithTheLeast(DetectionParams.fromEntity(entity), e -> (e.GetCenter() - entity.Position).magnitude);
                        if (nearest != null)
                        {
                            Eat(entity, nearest);
                            entity.State = STATE_EAT;
                            stateTimer.ResetTime(30);
                        }
                    }
                }
            }

            case STATE_EAT:
            {
                var stateTimer = GetStateTimer(entity);
                if (stateTimer.RunToExpiredAndNotNull())
                {
                    entity.State = STATE_CLOSE;
                    stateTimer.ResetTime(30);
                    entity.PlaySound(VanillaSoundID.chestClose);
                }
            }

            case STATE_CLOSE:
            {
                var stateTimer = GetStateTimer(entity);
                if (stateTimer.RunToExpiredAndNotNull())
                {
                    if (!entity.Level.IsIZombie())
                    {
                        entity.Level.Spawn(VanillaPickupID.starshard, entity.Position, entity);
                    }
                    entity.Remove();
                    var smoke = entity.Level.Spawn(VanillaEffectID.smokeCluster, entity.GetCenter(), entity);
                    // C#: ?.Let(e => { e.SetTint(...); })
                    if (smoke != null)
                    {
                        smoke.SetTint(new Color(1, 0.8, 1, 1));
                    }
                }
            }
        }
    }
    function EvokedUpdate(entity:Entity):Void
    {
        switch (entity.State)
        {
            case STATE_IDLE:
            {
                entity.State = STATE_OPEN;
                entity.PlaySound(VanillaSoundID.chestOpen);
                var stateTimer = GetStateTimer(entity);
                if (stateTimer != null)
                    stateTimer.ResetTime(15);
            }

            case STATE_OPEN:
            {
                var stateTimer = GetStateTimer(entity);
                if (stateTimer.RunToExpiredAndNotNull())
                {
                    entity.State = STATE_LOMS;
                    stateTimer.ResetTime(90);
                    entity.TriggerAnimation("Loms");
                }
            }

            case STATE_LOMS:
            {
                var stateTimer = GetStateTimer(entity);
                if (stateTimer != null)
                {
                    stateTimer.Run();
                    if (stateTimer.PassedFrame(30))
                    {
                        var ghast = entity.SpawnWithParams(VanillaEnemyID.ghast, entity.GetCenter());
                        entity.PlaySound(VanillaSoundID.fireCharge);
                    }
                    if (stateTimer.Expired)
                    {
                        entity.State = STATE_IDLE;
                        entity.PlaySound(VanillaSoundID.chestClose);
                        entity.SetEvoked(false);
                    }
                }
            }
        }
    }
    function IsOpen(entity:Entity):Bool
    {
        return entity.State == STATE_OPEN || entity.State == STATE_EAT || entity.State == STATE_LOMS;
    }
    public static var ID:NamespaceID = VanillaContraptionID.magichest;
    public static var PROP_FLASH_VISIBLE:VanillaEntityPropertyMeta<Bool> = new VanillaEntityPropertyMeta<Bool>("FlashVisible");
    public static var PROP_STATE_TIMER:VanillaEntityPropertyMeta<FrameTimer> = new VanillaEntityPropertyMeta<FrameTimer>("StateTimer");
    public static inline var STATE_IDLE:Int = VanillaContraptionStates.IDLE;
    public static inline var STATE_OPEN:Int = VanillaContraptionStates.MAGICHEST_OPEN;
    public static inline var STATE_EAT:Int = VanillaContraptionStates.MAGICHEST_EAT;
    public static inline var STATE_CLOSE:Int = VanillaContraptionStates.MAGICHEST_CLOSE;
    public static inline var STATE_LOMS:Int = VanillaContraptionStates.MAGICHEST_LOMS;
    var openDetector:Detector;
    var eatDetector:Detector;
}
