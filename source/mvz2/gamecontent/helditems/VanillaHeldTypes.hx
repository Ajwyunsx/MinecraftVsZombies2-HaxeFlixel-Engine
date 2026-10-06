// Ported from: Assets/Scripts/Vanilla/GameContent/HeldItems/Definitions/VanillaHeldTypes.cs
package mvz2.gamecontent.helditems;

import mvz2.vanilla.VanillaMod;
import pvzengine.NamespaceID;

// PORT-NOTE: 原文件包含两个顶层类（VanillaHeldItemNames、VanillaHeldTypes），按 PORTING.md
// “文件中多个顶层类时，主类用文件名，其余类放同文件底部” 的规则保留在同一模块中。

class VanillaHeldItemNames
{
    public static inline var forcePad:String = "force_pad";
    public static inline var skywardBeacon:String = "skyward_beacon";
    public static inline var brickCannon:String = "brick_cannon";
    public static inline var breakoutBoard:String = "breakout_board";
    public static inline var blueprintPickup:String = "blueprint_pickup";
    public static inline var combat:String = "combat";
}

class VanillaHeldTypes
{
    public static var forcePad:NamespaceID = Get(VanillaHeldItemNames.forcePad);
    public static var skywardBeacon:NamespaceID = Get(VanillaHeldItemNames.skywardBeacon);
    public static var brickCannon:NamespaceID = Get(VanillaHeldItemNames.brickCannon);
    public static var breakoutBoard:NamespaceID = Get(VanillaHeldItemNames.breakoutBoard);
    public static var blueprintPickup:NamespaceID = Get(VanillaHeldItemNames.blueprintPickup);
    public static var combat:NamespaceID = Get(VanillaHeldItemNames.combat);
    public static function Get(name:String):NamespaceID
    {
        return new NamespaceID(VanillaMod.spaceName, name);
    }
}
