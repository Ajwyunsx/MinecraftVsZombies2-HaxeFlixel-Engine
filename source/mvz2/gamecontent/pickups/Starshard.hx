// Ported from: Assets/Scripts/Vanilla/GameContent/Pickups/Starshard/Starshard.cs
// PORT-NOTE: 本文件不在 missing.txt 清单内，但属于 Vanilla/GameContent/Pickups 工作包（该目录下唯一未被清理的 C# 文件），
// 故一并移植，避免该包出现缺口。
package mvz2.gamecontent.pickups;

import mvz2.vanilla.audios.VanillaSoundID;
import mvz2.vanilla.pickups.VanillaPickupExt;
import mvz2.vanilla.pickups.VanillaPickupProps;
import mvz2logic.Global;
import mvz2logic.entities.LogicEntityProps;
import mvz2logic.level.LevelPositions;
import mvz2logic.level.LogicLevelProps;
import pvzengine.EngineModelID;
import pvzengine.NamespaceID;
import pvzengine.definitions.EntityBehaviourDefinition;
import pvzengine.entities.Entity;
import unity.Mathf;
import unity.Vector3;
using mvz2.vanilla.pickups.VanillaPickupExt;
using mvz2.vanilla.pickups.VanillaPickupProps;
using mvz2logic.level.LevelPositions;

@:autoEntityBehaviourDefinition(VanillaPickupNames.starshard)
class Starshard extends EntityBehaviourDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
    }
    public override function Init(pickup:Entity):Void
    {
        super.Init(pickup);
        pickup.Level.PlaySound(VanillaSoundID.starshardAppear);

        var rng = pickup.RNG;
        var angle = rng.Next(0, 360);
        var x = Mathf.Sin(Mathf.Deg2Rad * angle);
        var z = Mathf.Cos(Mathf.Deg2Rad * angle);
        pickup.Velocity = new Vector3(x, 0, z) * 5;

        pickup.SetModelProperty("Ring1Rotation", new Vector3(rng.Next(0, 360), rng.Next(0, 360), rng.Next(0, 360)));
        pickup.SetModelProperty("Ring2Rotation", new Vector3(rng.Next(0, 360), rng.Next(0, 360), rng.Next(0, 360)));
    }
    public override function Update(pickup:Entity):Void
    {
        super.Update(pickup);
        var level = pickup.Level;
        var alpha:Float = 1;
        if (pickup.IsCollected())
        {
            var collectedTime = pickup.GetCollectedTime();
            var moveTime = level.GetSecondTicks(1);
            var vanishTime = level.GetSecondTicks(1.5);
            if (collectedTime < moveTime)
            {
                var targetPos = GetMoveTargetPosition(pickup);
                pickup.Velocity = (targetPos - pickup.Position) * 0.2;
                alpha = 1;
            }
            else
            {
                var vanishLerp = (collectedTime - moveTime) / (vanishTime - moveTime);
                pickup.SetDisplayScale(Vector3.one * Mathf.Lerp(1, 0.5, vanishLerp));
                alpha = Mathf.Lerp(1, 0, vanishLerp);
                if (collectedTime == vanishTime)
                {
                    pickup.Remove();
                }
            }
        }
        else
        {
            if (!pickup.NoLimitInScreen())
            {
                var position = pickup.Position;
                var velocity = pickup.Velocity;
                var minZ = GetMinZ(pickup);
                var maxZ = GetMaxZ(pickup);
                if ((position.z <= minZ && velocity.z < 0) || (position.z >= maxZ && velocity.z >= 0))
                {
                    velocity.z *= -1;
                }
                var minX = GetMinX();
                var maxX = GetMaxX();
                if ((position.x <= minX && velocity.x < 0) || (position.x >= maxX && velocity.x >= 0))
                {
                    velocity.x *= -1;
                }
                position.x = Mathf.Clamp(position.x, minX, maxX);
                position.z = Mathf.Clamp(position.z, minZ, maxZ);
                pickup.Position = position;
                pickup.Velocity = velocity;
            }
            if (!pickup.IsImportantPickup() && pickup.Timeout < 150)
            {
                alpha = (Mathf.Cos((1 - pickup.Timeout / 150) * 10 * 2 * Mathf.PI) + 1) * 0.5;
            }
        }
        var color = pickup.GetTint(true);
        color.a = alpha;
        pickup.SetTint(color);
    }
    private static function GetMoveTargetPosition(entity:Entity):Vector3
    {
        var level = entity.Level;
        // PORT-NOTE: C# 将 Vector2 隐式转换为 Vector3，移植层显式补 z=0。
        var slotPosition2D = level.GetStarshardEntityPosition();
        var slotPosition = new Vector3(slotPosition2D.x, slotPosition2D.y, 0);
        return new Vector3(slotPosition.x, slotPosition.y - COLLECTED_Z - 15, COLLECTED_Z);
    }
    public static function GetMinX():Float
    {
        return LevelPositions.GetPickupBorderX(false) + 10;
    }
    public static function GetMaxX():Float
    {
        return LevelPositions.GetPickupBorderX(true) - 10;
    }
    public static function GetMinZ(pickup:Entity):Float
    {
        return 40 - pickup.Position.y;
    }
    public static function GetMaxZ(pickup:Entity):Float
    {
        return LevelPositions.SCREEN_HEIGHT - 120 - pickup.Position.y;
    }
    public override function GetModelID(origin:NamespaceID):NamespaceID
    {
        var globalLevel = Global.Level;
        var level = globalLevel.GetLevel();
        if (level == null)
            return origin;

        var areaID = level.AreaID;
        var modelId = new NamespaceID(areaID.SpaceName, 'starshard.${areaID.Path}').ToModelID(EngineModelID.TYPE_ENTITY);
        return Global.Models.ModelExists(modelId) ? modelId : origin;
    }
    private static inline var COLLECTED_Z:Float = 0;
}
