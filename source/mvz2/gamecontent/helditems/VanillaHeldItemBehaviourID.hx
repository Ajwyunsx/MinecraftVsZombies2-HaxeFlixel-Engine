// Ported from: Assets/Scripts/Vanilla/GameContent/HeldItems/Behaviours/VanillaHeldItemBehaviourID.cs
package mvz2.gamecontent.helditems;

import mvz2.vanilla.VanillaMod;
import pvzengine.NamespaceID;

// PORT-NOTE: 原文件包含两个顶层类（VanillaHeldItemBehaviourNames、VanillaHeldItemBehaviourID），
// 按 PORTING.md “文件中多个顶层类时，主类用文件名，其余类放同文件底部” 的规则保留在同一模块中。

class VanillaHeldItemBehaviourNames
{
    public static inline var pickaxe:String = "pickaxe";
    public static inline var starshard:String = "starshard";
    public static inline var trigger:String = "trigger";
    public static inline var sword:String = "sword";
    public static inline var forcePad:String = "force_pad";
    public static inline var brickCannon:String = "brick_cannon";
    public static inline var skywardBeacon:String = "skyward_beacon";
    public static inline var breakoutBoard:String = "breakout_board";
    public static inline var blueprintPickup:String = "blueprint_pickup";
    public static inline var classicBlueprint:String = "classic_blueprint";
    public static inline var conveyorBlueprint:String = "conveyor_blueprint";
    public static inline var combat:String = "combat";

    public static inline var rightMouseCancel:String = "right_mouse_cancel";
    public static inline var triggerCart:String = "triggerCart";
    public static inline var pickup:String = "pickup";
    public static inline var selectBlueprint:String = "select_blueprint";
    public static inline var putOutFire:String = "put_out_fire";
    public static inline var emptyHandEntity:String = "empty_hand_entity";
    public static inline var digEnemy:String = "dig_enemy";
}

class VanillaHeldItemBehaviourID
{
    public static var pickaxe:NamespaceID = Get(VanillaHeldItemBehaviourNames.pickaxe);
    public static var starshard:NamespaceID = Get(VanillaHeldItemBehaviourNames.starshard);
    public static var trigger:NamespaceID = Get(VanillaHeldItemBehaviourNames.trigger);
    public static var sword:NamespaceID = Get(VanillaHeldItemBehaviourNames.sword);
    public static var forcePad:NamespaceID = Get(VanillaHeldItemBehaviourNames.forcePad);
    public static var skywardBeacon:NamespaceID = Get(VanillaHeldItemBehaviourNames.skywardBeacon);
    public static var brickCannon:NamespaceID = Get(VanillaHeldItemBehaviourNames.brickCannon);
    public static var breakoutBoard:NamespaceID = Get(VanillaHeldItemBehaviourNames.breakoutBoard);
    public static var blueprintPickup:NamespaceID = Get(VanillaHeldItemBehaviourNames.blueprintPickup);
    public static var classicBlueprint:NamespaceID = Get(VanillaHeldItemBehaviourNames.classicBlueprint);
    public static var conveyorBlueprint:NamespaceID = Get(VanillaHeldItemBehaviourNames.conveyorBlueprint);
    public static var combat:NamespaceID = Get(VanillaHeldItemBehaviourNames.combat);

    public static var rightMouseCancel:NamespaceID = Get(VanillaHeldItemBehaviourNames.rightMouseCancel);
    public static var triggerCart:NamespaceID = Get(VanillaHeldItemBehaviourNames.triggerCart);
    public static var pickup:NamespaceID = Get(VanillaHeldItemBehaviourNames.pickup);
    public static var selectBlueprint:NamespaceID = Get(VanillaHeldItemBehaviourNames.selectBlueprint);
    public static var putOutFire:NamespaceID = Get(VanillaHeldItemBehaviourNames.putOutFire);
    public static var emptyHandEntity:NamespaceID = Get(VanillaHeldItemBehaviourNames.emptyHandEntity);
    public static var digEnemy:NamespaceID = Get(VanillaHeldItemBehaviourNames.digEnemy);
    public static function Get(name:String):NamespaceID
    {
        return new NamespaceID(VanillaMod.spaceName, name);
    }
}
