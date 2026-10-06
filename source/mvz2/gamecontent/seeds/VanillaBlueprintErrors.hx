// Ported from: Assets/Scripts/Vanilla/GameContent/Seeds/VanillaBlueprintErrors.cs
package mvz2.gamecontent.seeds;

import mvz2.vanilla.VanillaMod;
import pvzengine.NamespaceID;

class VanillaBlueprintErrors
{
    public static var tutorial:NamespaceID = Get("tutorial");
    public static var decrepify:NamespaceID = Get("decrepify");
    public static var locked:NamespaceID = Get("locked");
    static function Get(name:String):NamespaceID
    {
        return new NamespaceID(VanillaMod.spaceName, name);
    }
}
