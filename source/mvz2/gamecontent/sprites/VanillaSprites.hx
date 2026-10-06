// Ported from: Assets/Scripts/Vanilla/GameContent/Sprites/VanillaSprites.cs
package mvz2.gamecontent.sprites;

import mvz2.vanilla.VanillaMod;
import mvz2logic.resources.SpriteReference;
import pvzengine.NamespaceID;

class VanillaSprites
{
    public static var starshardDefault:SpriteReference = Get("starshards/default");
    public static var combat:SpriteReference = Get("ui/combat");
    public static var snipenserLife:SpriteReference = Get("ui/snipenser_life");
    static function Get(name:String):SpriteReference
    {
        var id = new NamespaceID(VanillaMod.spaceName, name);
        return new SpriteReference(id);
    }
}
