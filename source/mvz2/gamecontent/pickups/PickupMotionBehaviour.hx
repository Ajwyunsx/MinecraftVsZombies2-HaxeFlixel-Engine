// Ported from: Assets/Scripts/Vanilla/GameContent/Pickups/Behaviours/PickupMotionBehaviour.cs
package mvz2.gamecontent.pickups;

import mvz2.vanilla.entities.VanillaEntityBehaviourNames;
import mvz2.vanilla.pickups.VanillaPickupExt;
import mvz2.vanilla.pickups.VanillaPickupProps;
import mvz2.vanilla.properties.VanillaEntityPropertyMeta;
import mvz2logic.entities.LogicEntityProps;
import mvz2logic.entities.PickupDestination;
import mvz2logic.level.LevelPositions;
import mvz2logic.level.LogicLevelExt;
import mvz2logic.models.SortingLayers;
import pvzengine.definitions.EntityBehaviourDefinition;
import pvzengine.entities.EngineEntityProps;
import pvzengine.entities.Entity;
import pvzengine.modifiers.BooleanModifier;
import pvzengine.modifiers.ColorModifier;
import unity.Color;
import unity.Mathf;
import unity.Vector2;
import unity.Vector3;
using mvz2.vanilla.pickups.VanillaPickupExt;
using mvz2.vanilla.pickups.VanillaPickupProps;
using mvz2logic.entities.LogicEntityProps;
using mvz2logic.level.LevelPositions;

@:autoEntityBehaviourDefinition(VanillaEntityBehaviourNames.pickupMotion)
class PickupMotionBehaviour extends EntityBehaviourDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
        AddModifier(ColorModifier.Multiply(EngineEntityProps.TINT, PROP_TINT_MULT));
        AddModifier(new BooleanModifier(LogicEntityProps.SHADOW_HIDDEN, PROP_SHADOW_HIDDEN));
    }
    public override function Update(pickup:Entity):Void
    {
        super.Update(pickup);
        var level = pickup.Level;
        var alpha:Float = 1;
        var shadowHidden = false;
        if (pickup.IsCollected())
        {
            var collectedTime = pickup.GetCollectedTime();
            var moveTime = level.GetSecondTicks(1);
            var vanishTime = level.GetSecondTicks(1.5);
            if (collectedTime < moveTime)
            {
                // C#: float timePercent = collectedTime / (float)moveTime;（原代码中该变量未被使用）
                var timePercent:Float = collectedTime / moveTime;
                var targetPos = GetMoveTargetPosition(pickup);
                pickup.Velocity = (targetPos - pickup.Position) * 0.2;
                alpha = 1;
            }
            else
            {
                if (collectedTime == moveTime)
                {
                    // PORT-NOTE: RemoveEnergyDelayedEntity 定义在外部 PVZEngine 程序集中（本仓库无其源码），按调用写法保留。
                    level.RemoveEnergyDelayedEntity(pickup);
                    level.RemoveDelayedMoney(pickup);
                }

                var vanishLerp = (collectedTime - moveTime) / (vanishTime - moveTime);
                pickup.SetDisplayScale(Vector3.one * Mathf.Lerp(1, 0.5, vanishLerp));
                alpha = Mathf.Lerp(1, 0, vanishLerp);
                if (collectedTime == vanishTime)
                {
                    pickup.Remove();
                }
            }
            shadowHidden = true;

            pickup.SetSortingLayer(SortingLayers.collectedPickups);
            pickup.SetSortingOrder(9999);
            if (pickup.GetPickupDestination() == PickupDestination.MONEY)
            {
                pickup.SetSortingLayer(SortingLayers.money);
            }
            else
            {
                pickup.SetSortingLayer(SortingLayers.frontUI);
            }
        }
        var color = GetTintMultiplier(pickup);
        color.a = alpha;
        SetTintMultiplier(pickup, color);
        SetShadowAlpha(pickup, shadowHidden);
    }
    private static function GetMoveTargetPosition(entity:Entity):Vector3
    {
        // PORT-NOTE: C# 的 LevelPositions 返回 Vector3，移植层返回 Vector2（Unity 有 Vector2→Vector3 隐式转换），此处显式补 z=0。
        var slotPosition2D:Vector2;
        var targetZ:Float;
        var level = entity.Level;
        var dest = entity.GetPickupDestination();
        switch (dest)
        {
            case PickupDestination.MONEY:
                slotPosition2D = level.GetMoneyPanelEntityPosition();
                targetZ = COLLECTED_Z_MONEY;
            default:
                slotPosition2D = level.GetEnergySlotEntityPosition();
                targetZ = COLLECTED_Z_ENERGY;
        }
        return GetMoveTargetPositionFromSlot(new Vector3(slotPosition2D.x, slotPosition2D.y, 0), targetZ);
    }
    // C#: GetMoveTargetPosition(Vector3 target, float targetZ)
    // PORT-NOTE: Haxe 不支持重载，重命名为 GetMoveTargetPositionFromSlot。
    private static function GetMoveTargetPositionFromSlot(target:Vector3, targetZ:Float):Vector3
    {
        return new Vector3(target.x, target.y - targetZ - 15, targetZ);
    }
    public static function GetTintMultiplier(entity:Entity):Color return entity.GetBehaviourField(PROP_TINT_MULT);
    public static function SetTintMultiplier(entity:Entity, value:Color):Void entity.SetBehaviourField(PROP_TINT_MULT, value);
    public static function IsShadowHidden(entity:Entity):Bool return entity.GetBehaviourField(PROP_SHADOW_HIDDEN);
    public static function SetShadowAlpha(entity:Entity, value:Bool):Void entity.SetBehaviourField(PROP_SHADOW_HIDDEN, value);
    private static var PROP_TINT_MULT:VanillaEntityPropertyMeta<Color> = new VanillaEntityPropertyMeta<Color>("tint_mult", Color.white);
    private static var PROP_SHADOW_HIDDEN:VanillaEntityPropertyMeta<Bool> = new VanillaEntityPropertyMeta<Bool>("shadow_hidden");
    private static inline var COLLECTED_Z_MONEY:Float = -100;
    private static inline var COLLECTED_Z_ENERGY:Float = 480;
}
