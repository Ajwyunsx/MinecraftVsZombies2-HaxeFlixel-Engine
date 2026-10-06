// Ported from: Assets/Scripts/Vanilla/GameContent/Pickups/ClearPickup/ClearPickup.cs
package mvz2.gamecontent.pickups;

import mvz2.gamecontent.models.VanillaModelID;
import mvz2.vanilla.audios.VanillaSoundID;
import mvz2.vanilla.pickups.VanillaPickupExt;
import mvz2.vanilla.pickups.VanillaPickupProps;
import mvz2logic.entities.LogicEntityExt;
import mvz2logic.level.LogicStageProps;
import mvz2logic.models.SortingLayers;
import pvzengine.NamespaceID;
import pvzengine.definitions.EntityBehaviourDefinition;
import pvzengine.entities.Entity;
import pvzengine.entities.SpawnParams;
import pvzengine.level.LevelEngine;
import unity.Mathf;
import unity.Vector2;
import unity.Vector3;
using mvz2.vanilla.pickups.VanillaPickupExt;
using mvz2.vanilla.pickups.VanillaPickupProps;
using mvz2logic.entities.LogicEntityProps;
using mvz2logic.level.LevelPositions;

@:autoEntityBehaviourDefinition(VanillaPickupNames.clearPickup)
class ClearPickup extends EntityBehaviourDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
    }
    public override function Init(entity:Entity):Void
    {
        super.Init(entity);
        var modelID = GetPickupModelID(entity);
        entity.ChangeModel(modelID);

        var level = entity.Level;
        if (!level.IsRerun)
        {
            var noteID = level.GetEndNoteID();
            if (NamespaceID.IsValid(noteID))
            {
                entity.SetProperty(VanillaPickupProps.REMOVE_ON_COLLECT, true);
            }
        }
        if (entity.ModelID == VanillaModelID.mapPickup)
        {
            entity.SetCollectSound(VanillaSoundID.pick);
        }
    }
    public override function Update(pickup:Entity):Void
    {
        super.Update(pickup);
        var level = pickup.Level;
        var shadowAlpha:Float = 1;
        var gravity:Float = 1;
        if (pickup.IsCollected())
        {
            var collectedTime = pickup.GetCollectedTime();
            var moveTime = level.GetSecondTicks(3);
            var timePercent:Float = collectedTime / moveTime;
            var targetPos = GetMoveTargetPosition(pickup);
            pickup.Velocity = (targetPos - pickup.Position) * 0.05;
            pickup.SetScale(Vector3.one * Mathf.Lerp(1, 3, timePercent));
            pickup.SetDisplayScale(Vector3.one * Mathf.Lerp(1, 3, timePercent));
            pickup.SetSortingLayer(SortingLayers.collectedPickups);
            pickup.SetSortingOrder(9999);

            shadowAlpha = 0;
            gravity = 0;
        }
        pickup.SetShadowAlpha(shadowAlpha);
        pickup.SetGravity(gravity);
    }
    private function GetMoveTargetPosition(entity:Entity):Vector3
    {
        var level = entity.Level;
        // PORT-NOTE: C# 将 Vector2 隐式转换为 Vector3，移植层显式补 z=0。
        var slotPosition2D = level.GetScreenCenterPosition() + Vector2.down * (entity.GetSize().y * entity.GetFinalDisplayScale().y * 0.5);
        var slotPosition = new Vector3(slotPosition2D.x, slotPosition2D.y, 0);
        return new Vector3(slotPosition.x, slotPosition.y - COLLECTED_Z - 15, COLLECTED_Z);
    }
    private function GetPickupModelID(entity:Entity):NamespaceID
    {
        var level = entity.Level;
        if (level.IsRerun)
            return VanillaModelID.moneyChest;
        var model = level.GetClearPickupModel();
        return model != null ? model : VanillaModelID.blueprintPickup;
    }
    public static function Produce(level:LevelEngine, position:Vector3, ?spawner:Null<Entity>):Null<Entity>
    {
        var param = new SpawnParams();
        param.SetProperty(VanillaPickupProps.CONTENT_ID, level.GetClearPickupContentID());
        return VanillaPickupExt.ProduceOnLevel(level, VanillaPickupID.clearPickup, position, spawner, param);
    }
    private static inline var COLLECTED_Z:Float = 0;
}
