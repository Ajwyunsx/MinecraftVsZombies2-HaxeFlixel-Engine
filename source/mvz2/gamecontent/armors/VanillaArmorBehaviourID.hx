// Ported from: Assets/Scripts/Vanilla/GameContent/Armors/VanillaArmorBehaviourID.cs
package mvz2.gamecontent.armors;

import mvz2.vanilla.VanillaMod;
import pvzengine.NamespaceID;

class VanillaArmorBehaviourNames
{
    public static inline var damageState3:String = "damage_state_3";
    public static inline var reflectiveBarrier:String = "reflective_barrier";
    public static inline var umbrellaShield:String = "umbrella_shield";
    public static inline var cannon:String = "cannon";
    public static inline var destroyAfterHalfHP:String = "destroy_after_half_hp";
}

class VanillaArmorBehaviourID
{
    public static var damageState3:NamespaceID = Get(VanillaArmorBehaviourNames.damageState3);
    public static var reflectiveBarrier:NamespaceID = Get(VanillaArmorBehaviourNames.reflectiveBarrier);
    public static var umbrellaShield:NamespaceID = Get(VanillaArmorBehaviourNames.umbrellaShield);
    public static var cannon:NamespaceID = Get(VanillaArmorBehaviourNames.cannon);
    public static var destroyAfterHalfHP:NamespaceID = Get(VanillaArmorBehaviourNames.destroyAfterHalfHP);
    static function Get(name:String):NamespaceID
    {
        return new NamespaceID(VanillaMod.spaceName, name);
    }
}
