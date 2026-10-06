// Ported from: Assets/Scripts/Vanilla/Frameworks/Entities/VanillaCounterTagID.cs
package mvz2.vanilla.entities;

import mvz2.vanilla.VanillaMod;
import pvzengine.NamespaceID;

class VanillaCounterTagID
{
    public static var lowEnemy:NamespaceID = Get("low_enemy");
    public static var flyingEnemy:NamespaceID = Get("flying_enemy");

    static function Get(name:String):NamespaceID
    {
        return new NamespaceID(VanillaMod.spaceName, name);
    }
}
