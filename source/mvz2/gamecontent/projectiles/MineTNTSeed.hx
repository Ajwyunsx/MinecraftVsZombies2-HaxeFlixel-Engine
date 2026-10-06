// Ported from: Assets/Scripts/Vanilla/GameContent/Projectiles/Chapter1/MineTNTSeed.cs
package mvz2.gamecontent.projectiles;

import mvz2.gamecontent.contraptions.MineTNT;
import mvz2.gamecontent.contraptions.VanillaContraptionID;
import mvz2logic.grids.LogicGridExt;
import pvzengine.definitions.EntityBehaviourDefinition;
import pvzengine.entities.Entity;
import unity.Vector3;

@:autoEntityBehaviourDefinition(VanillaProjectileNames.mineTNTSeed)
class MineTNTSeed extends EntityBehaviourDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
    }
    public override function Init(entity:Entity):Void
    {
        super.Init(entity);
        entity.CollisionMaskHostile = 0;
        entity.CollisionMaskFriendly = 0;
    }
    public override function PostContactGround(entity:Entity, velocity:Vector3):Void
    {
        super.PostContactGround(entity, velocity);
        var level = entity.Level;
        var column = entity.GetColumn();
        var lane = level.GetNearestEntityLane(entity.Position.z);
        var grid = level.GetGrid(column, lane);
        if (grid != null && grid.CanSpawnEntity(VanillaContraptionID.mineTNT))
        {
            var x = level.GetEntityColumnX(column);
            var z = level.GetEntityLaneZ(lane);
            var y = level.GetGroundY(x, z);
            // C#: level.Spawn(...)?.Let(e => { MineTNT.GetRiseTimer(e)?.Let(timer => { timer.Frame = 31; }); })
            var e = level.Spawn(VanillaContraptionID.mineTNT, new Vector3(x, y, z), entity);
            if (e != null)
            {
                var timer = MineTNT.GetRiseTimer(e);
                if (timer != null)
                {
                    timer.Frame = 31;
                }
            }
        }
        entity.Remove();
    }
}
