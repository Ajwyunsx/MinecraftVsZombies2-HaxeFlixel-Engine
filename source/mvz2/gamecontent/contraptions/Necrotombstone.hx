// Ported from: Assets/Scripts/Vanilla/GameContent/Contraptions/Chapter4/Necrotombstone.cs
package mvz2.gamecontent.contraptions;

import mvz2.gamecontent.buffs.enemies.NecrotombstoneRisingBuff;
import mvz2.gamecontent.enemies.SkeletonMage;
import mvz2.gamecontent.enemies.VanillaEnemyID;
import mvz2.vanilla.audios.VanillaSoundID;
import mvz2.vanilla.entities.VanillaEntityExt;
import mvz2.vanilla.properties.VanillaEntityPropertyMeta;
import mvz2logic.entities.LogicEntityExt;
import mvz2logic.entities.LogicEntityProps;
import mvz2logic.level.LogicLevelExt;
import pvzengine.buffs.BuffExt;
import pvzengine.entities.Entity;
import tools.FrameTimer;
using mvz2.vanilla.entities.VanillaEntityExt;
using mvz2.vanilla.entities.VanillaEntityProps;
using mvz2logic.entities.LogicEntityExt;
using tools.EnumerableExt;

@:autoEntityBehaviourDefinition(VanillaContraptionNames.necrotombstone)
class Necrotombstone extends ContraptionBehaviour
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
    }
    public override function Init(entity:Entity):Void
    {
        super.Init(entity);
        SetProductionTimer(entity, new FrameTimer(SPAWN_INTERVAL));
    }
    override function UpdateAI(entity:Entity):Void
    {
        super.UpdateAI(entity);
        ProductionUpdate(entity);
    }
    override function OnEvoke(entity:Entity):Void
    {
        super.OnEvoke(entity);
        var pos = entity.Position;
        pos.y = entity.GetGroundY() - 100;
        var mageClass = SkeletonMage.mageVariants.Random(entity.RNG);
        for (i in 0...MAGE_COUNT)
        {
            var param = entity.GetSpawnParams();
            param.SetProperty(LogicEntityProps.VARIANT, mageClass);
            // C#: entity.Spawn(...)?.Let(e => { ... })
            var e = entity.Spawn(VanillaEnemyID.skeletonMage, pos, param);
            if (e != null)
            {
                e.AddBuff(NecrotombstoneRisingBuff);
                e.UpdateModel();

                e.PlaySound(VanillaSoundID.dirtRise);
                e.PlaySound(VanillaSoundID.boneWallBuild);
            }
        }
    }
    public static function GetProductionTimer(entity:Entity):Null<FrameTimer> return entity.GetBehaviourField(PROP_PRODUCTION_TIMER);
    public static function SetProductionTimer(entity:Entity, timer:FrameTimer):Void entity.SetBehaviourField(PROP_PRODUCTION_TIMER, timer);
    function ProductionUpdate(entity:Entity):Void
    {
        var productionTimer = GetProductionTimer(entity);
        if (productionTimer == null)
            return;
        if (!entity.Level.IsCleared)
        {
            productionTimer.Run(entity.GetProduceSpeed());
        }
        if (productionTimer.Expired)
        {
            if (SkeletonOutOfLimit(entity))
            {
                productionTimer.Frame = RECHECK_INTERVAL;
            }
            else
            {
                var pos = entity.Position;
                pos.y = entity.GetGroundY() - 100;
                // C#: entity.SpawnWithParams(...)?.Let(e => { ... })
                var e = entity.SpawnWithParams(VanillaEnemyID.skeletonWarrior, pos);
                if (e != null)
                {
                    e.AddBuff(NecrotombstoneRisingBuff);
                    e.UpdateModel();

                    e.PlaySound(VanillaSoundID.dirtRise);
                }

                productionTimer.ResetTime(SPAWN_INTERVAL);
            }
        }
    }
    function SkeletonOutOfLimit(entity:Entity):Bool
    {
        return entity.Level.GetEntityCount(VanillaEnemyID.skeletonWarrior) >= SKELETON_LIMIT;
    }
    public static inline var SKELETON_LIMIT:Int = 30;
    public static inline var SPAWN_INTERVAL:Int = 450;
    public static inline var RECHECK_INTERVAL:Int = 60;
    public static inline var MAGE_COUNT:Int = 3;
    static var PROP_PRODUCTION_TIMER:VanillaEntityPropertyMeta<FrameTimer> = new VanillaEntityPropertyMeta<FrameTimer>("ProductionTimer");
}
