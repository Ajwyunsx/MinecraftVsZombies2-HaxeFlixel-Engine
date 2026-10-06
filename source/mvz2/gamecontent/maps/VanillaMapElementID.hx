// Ported from: Assets/Scripts/Vanilla/GameContent/Maps/VanillaMapElementID.cs
package mvz2.gamecontent.maps;

import mvz2.vanilla.VanillaMod;
import pvzengine.NamespaceID;

class VanillaMapElementNames
{
    public static inline var dreamKey:String = "dream_key";
    public static inline var nightmareBox:String = "nightmare_box";
}

class VanillaMapElementID
{
    public static var dreamKey:NamespaceID = Get(VanillaMapElementNames.dreamKey);
    public static var nightmareBox:NamespaceID = Get(VanillaMapElementNames.nightmareBox);
    static function Get(name:String):NamespaceID
    {
        return new NamespaceID(VanillaMod.spaceName, name);
    }
}
