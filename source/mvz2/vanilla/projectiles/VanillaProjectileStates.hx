// Ported from: Assets/Scripts/Vanilla/Frameworks/Properties/VanillaProjectileStates.cs
package mvz2.vanilla.projectiles;

class VanillaProjectileStates
{
    public static inline var IDLE:Int = 0;

    public static var COMPELLING_ORB_FLY(get, never):Int;
    static inline function get_COMPELLING_ORB_FLY():Int return PRIVATE_NUMBER + 0;

    static inline var PRIVATE_NUMBER:Int = 10000;
}
