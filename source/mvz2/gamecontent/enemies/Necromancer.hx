// Ported from: Assets/Scripts/Vanilla/GameContent/Enemies/Chapter1/Necromancer.cs
package mvz2.gamecontent.enemies;

import mvz2.gamecontent.entities.AIEntityBehaviour;
import mvz2.vanilla.audios.VanillaSoundID;
import mvz2.vanilla.enemies.VanillaEnemyStates;
import mvz2.vanilla.entities.VanillaEntityExt;
import mvz2.vanilla.properties.VanillaEntityPropertyMeta;
import mvz2logic.entities.LogicEntityExt;
import mvz2logic.level.LogicLevelExt;
import pvzengine.NamespaceID;
import pvzengine.damages.DeathInfo;
import pvzengine.entities.Entity;
import tools.FrameTimer;
import unity.Vector3;
import mvz2logic.entities.LogicEnemyStates;
using mvz2.vanilla.enemies.VanillaEnemyProps;
using mvz2.vanilla.entities.VanillaEntityExt;
using mvz2.vanilla.entities.VanillaEntityProps;
using mvz2logic.entities.LogicEntityExt;

@:autoEntityBehaviourDefinition(VanillaEnemyNames.necromancer)
class Necromancer extends AIEntityBehaviour
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
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
        var attackSpeed = entity.GetAttackSpeed();
        if (stateTimer.RunToExpiredAndNotNull(attackSpeed))
        {
            if (entity.State == STATE_CAST)
            {
                EndCasting(entity);
            }
            else
            {
                if (!CheckBuildable(entity))
                {
                    stateTimer.ResetTime(BUILD_DETECT_TIME);
                }
                else
                {
                    StartCasting(entity);
                    BuildBoneWalls(entity);
                }
            }
        }
    }
    public override function PostDeath(entity:Entity, info:DeathInfo):Void
    {
        super.PostDeath(entity, info);
        if (entity.IsCasting())
        {
            EndCasting(entity);
        }
    }
    public static function SetStateTimer(entity:Entity, timer:FrameTimer):Void
    {
        entity.SetBehaviourFieldNS(ID, PROP_STATE_TIMER, timer);
    }
    public static function GetStateTimer(entity:Entity):Null<FrameTimer>
    {
        return entity.GetBehaviourFieldNS(ID, PROP_STATE_TIMER);
    }

    function StartCasting(entity:Entity):Void
    {
        entity.SetCasting(true);
        entity.PlaySound(VanillaSoundID.reviveCast);
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

    function CheckBuildable(entity:Entity):Bool
    {
        return entity.Level.FindEntities(VanillaEnemyID.boneWall).length < MAX_BONE_WALL_COUNT;
    }

    function BuildBoneWalls(entity:Entity):Void
    {
        var level = entity.Level;
        var startLine = -2;
        var endLine = 2;
        var lane = entity.GetLane();
        if (lane == 0)
        {
            endLine = 0;
        }
        if (lane == level.GetMaxLaneCount() - 1)
        {
            startLine = 0;
        }

        for (i in startLine...(endLine + 1))
        {
            var x = entity.Position.x + level.GetGridWidth() * 1.5 * entity.GetFacingX();
            var z = entity.Position.z + level.GetGridHeight() * i * 0.5;
            var y = level.GetGroundY(x, z);
            var wallPos = new Vector3(x, y, z);
            entity.SpawnWithParams(VanillaEnemyID.boneWall, wallPos);
        }
    }
    //region 常量
    static inline var CAST_COOLDOWN:Int = 300;
    static inline var CAST_TIME:Int = 30;
    static inline var BUILD_DETECT_TIME:Int = 30;
    static inline var MAX_BONE_WALL_COUNT:Int = 15;
    public static inline var STATE_MELEE_ATTACK:Int = LogicEnemyStates.MELEE_ATTACK;
    public static inline var STATE_CAST:Int = LogicEnemyStates.CAST;
    public static var ID:NamespaceID = VanillaEnemyID.necromancer;
    public static var PROP_STATE_TIMER:VanillaEntityPropertyMeta<FrameTimer> = new VanillaEntityPropertyMeta<FrameTimer>("StateTimer");
    //endregion 常量
}
