// Ported from: Assets/Scripts/Vanilla/GameContent/Carts/VanillaCartID.cs
package mvz2.gamecontent.carts;

import mvz2.vanilla.VanillaMod;
import pvzengine.NamespaceID;

class VanillaCartNames
{
    public static inline var minecart:String = "minecart";
    public static inline var pumpkinCarriage:String = "pumpkin_carriage";
    public static inline var nyanCat:String = "nyan_cat";
    public static inline var bowlChariot:String = "bowl_chariot";
    public static inline var ballista:String = "ballista";
    public static inline var unzanFist:String = "unzan_fist";
    public static inline var corpseCart:String = "corpse_cart";
}

class VanillaCartID
{
    public static var minecart:NamespaceID = Get(VanillaCartNames.minecart);
    public static var pumpkinCarriage:NamespaceID = Get(VanillaCartNames.pumpkinCarriage);
    public static var nyanCat:NamespaceID = Get(VanillaCartNames.nyanCat);
    public static var bowlChariot:NamespaceID = Get(VanillaCartNames.bowlChariot);
    public static var ballista:NamespaceID = Get(VanillaCartNames.ballista);
    public static var unzanFist:NamespaceID = Get(VanillaCartNames.unzanFist);
    public static var corpseCart:NamespaceID = Get(VanillaCartNames.corpseCart);
    static function Get(name:String):NamespaceID
    {
        return new NamespaceID(VanillaMod.spaceName, name);
    }
}
