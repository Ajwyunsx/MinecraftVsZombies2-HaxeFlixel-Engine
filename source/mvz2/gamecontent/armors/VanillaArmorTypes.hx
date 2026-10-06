// Ported from: Assets/Scripts/Vanilla/GameContent/Armors/VanillaArmorTypes.cs
package mvz2.gamecontent.armors;

import mvz2.vanilla.VanillaMod;
import pvzengine.NamespaceID;

class VanillaArmorTypes
{
    public static var helmet:NamespaceID = Get("helmet");
    public static var largeShield:NamespaceID = Get("large_shield");
    public static var smallShield:NamespaceID = Get("small_shield");
    public static var handheld:NamespaceID = Get("handheld");
    static function Get(name:String):NamespaceID
    {
        return new NamespaceID(VanillaMod.spaceName, name);
    }
}
