// Ported from: Assets/Scripts/Vanilla/GameContent/Enemies/Chapter6/Hacker.cs
package mvz2.gamecontent.enemies;

import mvz2.gamecontent.detections.HackerDetector;
import mvz2.gamecontent.effects.VanillaEffectID;
import mvz2.gamecontent.entities.AIEntityBehaviour;
import mvz2.vanilla.audios.VanillaSoundID;
import mvz2.vanilla.detection.Detector;
import mvz2.vanilla.entities.VanillaEntityExt;
import mvz2.vanilla.grids.VanillaGridLayers;
import mvz2.vanilla.properties.VanillaEntityPropertyMeta;
import mvz2logic.entities.LogicEnemyStates;
import mvz2logic.entities.LogicEntityExt;
import mvz2logic.grids.LogicGridExt;
import mvz2logic.level.LogicLevelExt;
import pvzengine.EngineEntityProps;
import pvzengine.entities.Entity;
import pvzengine.entities.EntitySourceReference;
import tools.FrameTimer;
import tools.Ticks;
import tools.TimerHelper;
import unity.Color;
import mvz2.vanilla.enemies.VanillaEnemyStates;
using mvz2.vanilla.entities.VanillaEntityExt;
using mvz2.vanilla.entities.VanillaEntityProps;
using mvz2logic.entities.LogicEntityExt;

@:autoEntityBehaviourDefinition(VanillaEnemyNames.hacker)
class Hacker extends AIEntityBehaviour
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
    }
    override function UpdateAI(enemy:Entity):Void
    {
        super.UpdateAI(enemy);
        switch (enemy.State)
        {
            case STATE_HACK:
                UpdateHack(enemy);
            default:
                UpdateNotHack(enemy);
        }
    }
    function UpdateHack(enemy:Entity):Void
    {
        var timer = GetHackTimer(enemy);
        if (timer == null)
        {
            timer = TimerHelper.NewSecondTimer(HACK_DURATION_SECONDS);
            SetHackTimer(enemy, timer);
        }
        if (timer.RunToExpired(enemy.GetAttackSpeed()))
        {
            FindAndHack(enemy);
            timer.Reset();
        }
    }
    function UpdateNotHack(enemy:Entity):Void
    {
        var timer = GetHackTimer(enemy);
        if (timer != null)
        {
            timer.Reset();
        }
    }
    public static function FindAndHack(enemy:Entity):Void
    {
        var facingX = enemy.GetFacingX();
        var column = enemy.GetColumn();
        var target = detector.DetectEntityWithTheMost(DetectionParams.fromEntity(enemy), function(t)
        {
            var value = (t.GetColumn() - column) * facingX * 100;
            var grid = t.GetGrid();
            if (grid != null)
            {
                if (t.IsTakingGridLayer(grid, VanillaGridLayers.protector))
                    value += 1;
                else if (t.IsTakingGridLayer(grid, VanillaGridLayers.main))
                    value += 0;
                else if (t.IsTakingGridLayer(grid, VanillaGridLayers.carrier))
                    value += -1;
            }
            return value;
        });
        if (target == null)
            return;
        Hack(enemy, target);
    }
    public static function Hack(enemy:Entity, target:Entity):Void
    {
        enemy.PlaySound(VanillaSoundID.dataStream);
        target.PlaySound(VanillaSoundID.powerOff);
        target.ShortCircuit(Ticks.FromSeconds(HACK_EFFECT_DURATION_SECONDS), new EntitySourceReference(enemy));

        var param = target.GetSpawnParams();
        param.SetProperty(EngineEntityProps.TINT, Color.green);
        target.Spawn(VanillaEffectID.binaryParticles, target.GetCenter(), param);
    }
    public static function CanHack(enemy:Entity):Bool
    {
        return enemy.Position.x <= enemy.Level.GetEntityColumnX(enemy.Level.GetMaxColumnCount() - 1) && detector.DetectExists(DetectionParams.fromEntity(enemy));
    }
    public static function GetHackTimer(enemy:Entity):Null<FrameTimer> return enemy.GetBehaviourField(PROP_HACK_TIMER);
    public static function SetHackTimer(enemy:Entity, value:Null<FrameTimer>):Void enemy.SetBehaviourField(PROP_HACK_TIMER, value);
    static var detector:Detector = makeDetector();

    static function makeDetector():Detector
    {
        var d:Detector = new HackerDetector();
        cast(d, HackerDetector).canDetectInvisible = false;
        return d;
    }
    public static inline var HACK_DURATION_SECONDS:Float = 8;
    public static inline var HACK_EFFECT_DURATION_SECONDS:Float = 32;
    public static var PROP_HACK_TIMER:VanillaEntityPropertyMeta<FrameTimer> = new VanillaEntityPropertyMeta<FrameTimer>("hack_timer");
    public static inline var STATE_WALK:Int = LogicEnemyStates.WALK;
    public static inline var STATE_HACK:Int = VanillaEnemyStates.HACKER_HACK;
}
