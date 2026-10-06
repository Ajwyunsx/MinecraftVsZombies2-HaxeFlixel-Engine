// Ported from: Assets/Scripts/Vanilla/GameContent/Archives/VanillaArchiveBackgrounds.cs
package mvz2.gamecontent.maps;

import mvz2.vanilla.VanillaMod;
import mvz2logic.resources.SpriteReference;
import pvzengine.NamespaceID;

class VanillaArchiveBackgrounds
{
    public static var nightmare:SpriteReference = Get("misc/nightmare");
    static function Get(name:String):SpriteReference
    {
        return new SpriteReference(new NamespaceID(VanillaMod.spaceName, name));
    }
}
