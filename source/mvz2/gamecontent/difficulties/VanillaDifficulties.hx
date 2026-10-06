// Ported from: Assets/Scripts/Vanilla/GameContent/Difficulties/VanillaDifficulties.cs
package mvz2.gamecontent.difficulties;

import mvz2.vanilla.VanillaMod;
import pvzengine.NamespaceID;

class VanillaDifficulties
{
    public static var easy:NamespaceID = Get("easy");
    public static var normal:NamespaceID = Get("normal");
    public static var hard:NamespaceID = Get("hard");
    public static function Get(name:String):NamespaceID
    {
        return new NamespaceID(VanillaMod.spaceName, name);
    }
}
