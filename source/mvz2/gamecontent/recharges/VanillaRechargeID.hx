// Ported from: Assets/Scripts/Vanilla/GameContent/Recharges/VanillaRechargeID.cs
package mvz2.gamecontent.recharges;

import mvz2.vanilla.VanillaMod;
import pvzengine.NamespaceID;

class VanillaRechargeNames
{
    public static inline var none:String = "none";
    public static inline var shortTime:String = "short";
    public static inline var longTime:String = "long";
    public static inline var veryLongTime:String = "very_long";
}

class VanillaRechargeID
{
    public static var none:NamespaceID = Get(VanillaRechargeNames.none);
    public static var shortTime:NamespaceID = Get(VanillaRechargeNames.shortTime);
    public static var longTime:NamespaceID = Get(VanillaRechargeNames.longTime);
    public static var veryLongTime:NamespaceID = Get(VanillaRechargeNames.veryLongTime);
    static function Get(name:String):NamespaceID
    {
        return new NamespaceID(VanillaMod.spaceName, name);
    }
}
