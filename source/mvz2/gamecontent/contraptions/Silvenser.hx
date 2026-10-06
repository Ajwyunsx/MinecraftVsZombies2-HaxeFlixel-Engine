// Ported from: Assets/Scripts/Vanilla/GameContent/Contraptions/Chapter2/Silvenser.cs
package mvz2.gamecontent.contraptions;

import mvz2.gamecontent.buffs.projectiles.ProjectileWaitBuff;
import mvz2.vanilla.audios.VanillaSoundID;
import mvz2.vanilla.detection.Detection;
import mvz2.vanilla.entities.VanillaEntityExt;
import mvz2.vanilla.entities.VanillaEntityProps;
import mvz2.vanilla.properties.VanillaEntityPropertyMeta;
import mvz2logic.entities.LogicEntityExt;
import pvzengine.NamespaceID;
import pvzengine.buffs.BuffExt;
import pvzengine.entities.Entity;
import tools.FrameTimer;
import unity.Mathf;
import unity.Quaternion;
import unity.Vector3;
using mvz2.vanilla.entities.VanillaEntityExt;
using mvz2.vanilla.entities.VanillaEntityProps;
using mvz2logic.entities.LogicContraptionProps;
using mvz2logic.entities.LogicEntityExt;
using tools.EnumerableExt;

@:autoEntityBehaviourDefinition(VanillaContraptionNames.silvenser)
class Silvenser extends DispenserFamily
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
    }

    public override function Init(entity:Entity):Void
    {
        super.Init(entity);
        InitShootTimer(entity);
        var evocationTimer = new FrameTimer(EVOCATION_DURATION);
        SetEvocationTimer(entity, evocationTimer);
    }
    override function UpdateAI(entity:Entity):Void
    {
        super.UpdateAI(entity);
        ShootTick(entity);
        EvokedUpdate(entity);
    }

    override function OnEvoke(entity:Entity):Void
    {
        super.OnEvoke(entity);
        var entities = entity.Level.FindEntities((e:Entity) -> e.IsVulnerableEntity() && !e.IsDead && Detection.CanDetect(e) && e.IsHostile(entity)).RandomTake(EVOCATION_MAX_TARGET_COUNT, entity.RNG);
        var positions = [for (e in entities) e.GetCenter()];
        if (positions.length > 0)
        {
            var evocationTimer = GetEvocationTimer(entity);
            if (evocationTimer != null)
                evocationTimer.Reset();
            entity.SetEvoked(true);

            SetEvocationTargetPositions(entity, positions);
            entity.PlaySound(VanillaSoundID.spellCard);
        }
    }
    public static function GetEvocationTimer(entity:Entity):Null<FrameTimer>
    {
        return entity.GetBehaviourFieldNS(ID, PROP_EVOCATION_TIMER);
    }
    public static function SetEvocationTimer(entity:Entity, timer:FrameTimer):Void
    {
        entity.SetBehaviourFieldNS(ID, PROP_EVOCATION_TIMER, timer);
    }
    public static function GetEvocationTargetPositions(entity:Entity):Null<Array<Vector3>>
    {
        return entity.GetBehaviourFieldNS(ID, PROP_EVOCATION_TARGET_POSITIONS);
    }
    public static function SetEvocationTargetPositions(entity:Entity, timer:Array<Vector3>):Void
    {
        entity.SetBehaviourFieldNS(ID, PROP_EVOCATION_TARGET_POSITIONS, timer);
    }
    function EvokedUpdate(entity:Entity):Void
    {
        var evocationPositions = GetEvocationTargetPositions(entity);
        if (evocationPositions == null || evocationPositions.length <= 0)
        {
            entity.SetEvoked(false);
            return;
        }
        var knivesPerEnemy = Std.int(MAX_EVOCATION_KNIFE_COUNT / evocationPositions.length);
        var layers = Mathf.CeilToInt(knivesPerEnemy / EVOCATION_KNIVES_PER_LAYER);
        var knivesPerLayer = Std.int(knivesPerEnemy / layers);

        var interval = EVOCATION_DURATION / knivesPerLayer;
        var anglePerSpawn = 180 / knivesPerLayer;
        var anglePerFrame = anglePerSpawn / interval;

        var evocationTimer = GetEvocationTimer(entity);
        if (evocationTimer != null)
        {
            evocationTimer.Run();
            for (frame in evocationTimer.IteratePassedFrames(interval))
            {
                for (target in evocationPositions)
                {
                    for (layer in 0...layers)
                    {
                        var layerRadius = EVOCATION_RADIUS + layer * 24;
                        for (dir in 0...2)
                        {
                            var deg = frame * anglePerFrame;

                            if (dir == 1)
                            {
                                deg += 180;
                            }

                            var direction = Quaternion.Euler(0, deg, 0) * Vector3.right;
                            var posOffset = direction * layerRadius;
                            var knifePos = target + posOffset;

                            var param = entity.GetSpawnParams();
                            param.SetProperty(VanillaEntityProps.DAMAGE, entity.GetDamage() * EVOCATION_DAMAGE_MULTIPLIER);
                            var projectileID = entity.GetProjectileID();
                            if (projectileID != null)
                            {
                                var proj = entity.Spawn(projectileID, knifePos, param);
                                // C#: ?.Let(e => { ... })
                                if (proj != null)
                                {
                                    proj.Velocity = direction * -10;
                                    var buff = proj.AddBuff(ProjectileWaitBuff);
                                    buff.SetProperty(ProjectileWaitBuff.PROP_TIMEOUT, 90);
                                }
                            }
                        }
                    }
                }
            }
            if (evocationTimer.Expired)
            {
                entity.SetEvoked(false);
            }
        }
    }
    public static inline var EVOCATION_MAX_TARGET_COUNT:Int = 10;
    public static inline var MAX_EVOCATION_KNIFE_COUNT:Int = 45;
    public static inline var EVOCATION_DURATION:Int = 30;
    public static inline var EVOCATION_KNIVES_PER_LAYER:Int = 30;
    public static inline var EVOCATION_RADIUS:Float = 100;
    public static inline var EVOCATION_DAMAGE_MULTIPLIER:Float = 2;
    public static var PROP_EVOCATION_TIMER:VanillaEntityPropertyMeta<FrameTimer> = new VanillaEntityPropertyMeta<FrameTimer>("EvocationTimer");
    public static var PROP_EVOCATION_TARGET_POSITIONS:VanillaEntityPropertyMeta<Array<Vector3>> = new VanillaEntityPropertyMeta<Array<Vector3>>("EvocationTargetPositions");

    public static var ID:NamespaceID = VanillaContraptionID.silvenser;
}
