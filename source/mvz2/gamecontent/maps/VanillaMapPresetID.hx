// Ported from: Assets/Scripts/Vanilla/GameContent/Maps/VanillaMapPresetID.cs
package mvz2.gamecontent.maps;

import mvz2.vanilla.VanillaMod;
import pvzengine.NamespaceID;

class VanillaMapPresetID
{
    public static var nightmare:NamespaceID = Get("nightmare");
    static function Get(name:String):NamespaceID
    {
        return new NamespaceID(VanillaMod.spaceName, name);
    }
}
