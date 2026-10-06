// Ported from: Assets/Scripts/Vanilla/GameContent/Enemies/Chapter4/EmperorZombie.cs
package mvz2.gamecontent.enemies;

import mvz2.gamecontent.buffs.entities.DivineShieldBuff;
import mvz2.gamecontent.detections.EmperorZombieShieldDetector;
import mvz2.gamecontent.entities.AIEntityBehaviour;
import mvz2.vanilla.audios.VanillaSoundID;
import mvz2.vanilla.detection.Detector;
import mvz2.vanilla.entities.VanillaEntityExt;
import mvz2.vanilla.properties.VanillaEntityPropertyMeta;
import mvz2logic.entities.LogicEnemyStates;
import pvzengine.NamespaceID;
import pvzengine.buffs.BuffExt;
import pvzengine.damages.DeathInfo;
import pvzengine.entities.Entity;
import tools.FrameTimer;
using mvz2.vanilla.enemies.VanillaEnemyProps;
using mvz2.vanilla.entities.VanillaEntityProps;
using mvz2logic.entities.LogicEntityExt;
using tools.EnumerableExt;

@:autoEntityBehaviourDefinition(VanillaEnemyNames.emperorZombie)
class EmperorZombie extends AIEntityBehaviour
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
        shieldDetector = new EmperorZombieShieldDetector(SHIELD_RADIUS);
    }

    public override function Init(entity:Entity):Void
    {
        super.Init(entity);
        SetStateTimer(entity, new FrameTimer(CAST_COOLDOWN));
    }
    override function UpdateAI(entity:Entity):Void
    {
        super.UpdateAI(entity);

        if (entity.IsDead)
            return;
        if (entity.State == STATE_MELEE_ATTACK)
            return;
        var stateTimer = GetStateTimer(entity);
        if (entity.State == STATE_CAST)
        {
            if (stateTimer.RunToExpiredAndNotNull(entity.GetAttackSpeed()))
            {
                EndCasting(entity);
            }
        }
        else
        {
            if (stateTimer.RunToExpiredAndNotNull(entity.GetAttackSpeed()))
            {
                detectBuffer = [];
                shieldDetector.DetectEntities(DetectionParams.fromEntity(entity), detectBuffer);
                if (detectBuffer.length <= 0)
                {
                    stateTimer.ResetTime(SHIELD_DETECT_TIME);
                }
                else
                {
                    StartCasting(entity);
                    GrantShields(entity, detectBuffer.RandomTake(10, entity.RNG));
                }
            }
        }
    }
    public override function PostDeath(entity:Entity, info:DeathInfo):Void
    {
        super.PostDeath(entity, info);
        if (entity.State == STATE_CAST)
        {
            EndCasting(entity);
        }
    }
    public static function SetStateTimer(entity:Entity, timer:FrameTimer):Void entity.SetBehaviourFieldNS(ID, PROP_STATE_TIMER, timer);
    public static function GetStateTimer(entity:Entity):Null<FrameTimer> return entity.GetBehaviourFieldNS(ID, PROP_STATE_TIMER);

    function StartCasting(entity:Entity):Void
    {
        entity.SetCasting(true);
        entity.PlaySound(VanillaSoundID.divineShieldCast);
        var stateTimer = GetStateTimer(entity);
        if (stateTimer != null)
            stateTimer.ResetTime(CAST_TIME);
    }

    function EndCasting(entity:Entity):Void
    {
        entity.SetCasting(false);
        var stateTimer = GetStateTimer(entity);
        if (stateTimer != null)
            stateTimer.ResetTime(CAST_COOLDOWN);
    }

    function GrantShields(entity:Entity, targets:Array<Entity>):Void
    {
        for (target in targets)
        {
            target.AddBuff(DivineShieldBuff);
        }
    }
    //region 常量
    public static inline var STATE_WALK:Int = LogicEnemyStates.WALK;
    public static inline var STATE_CAST:Int = LogicEnemyStates.CAST;
    public static inline var STATE_MELEE_ATTACK:Int = LogicEnemyStates.MELEE_ATTACK;
    public static inline var CAST_COOLDOWN:Int = 150;
    public static inline var CAST_TIME:Int = 30;
    public static inline var SHIELD_DETECT_TIME:Int = 30;
    public static inline var SHIELD_RADIUS:Float = 120;
    public static var ID:NamespaceID = VanillaEnemyID.necromancer;
    public static var PROP_STATE_TIMER:VanillaEntityPropertyMeta<FrameTimer> = new VanillaEntityPropertyMeta<FrameTimer>("StateTimer");
    var shieldDetector:Detector;
    var detectBuffer:Array<Entity> = [];
    //endregion 常量
}
