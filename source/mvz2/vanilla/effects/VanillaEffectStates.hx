// Ported from: Assets/Scripts/Vanilla/Frameworks/Effects/VanillaEffectStates.cs
package mvz2.vanilla.effects;

class VanillaEffectStates
{
    public static inline var IDLE:Int = 0;

    public static var BREAKOUT_BOARD_RETURN(get, never):Int;
    public static var BREAKOUT_BOARD_FIRED(get, never):Int;

    public static var HOE_TRIGGERED(get, never):Int;
    public static var HOE_DAMAGED(get, never):Int;

    public static var CRUSHING_WALLS_ENRAGED(get, never):Int;
    public static var CRUSHING_WALLS_CLOSED(get, never):Int;
    public static var CRUSHING_WALLS_STOPPED(get, never):Int;

    public static var PAGODA_LASER_EXPAND(get, never):Int;
    public static var PAGODA_LASER_SWIPE(get, never):Int;
    public static var PAGODA_LASER_SUBTRACT(get, never):Int;

    static inline function get_BREAKOUT_BOARD_RETURN():Int return PRIVATE_NUMBER + 0;
    static inline function get_BREAKOUT_BOARD_FIRED():Int return PRIVATE_NUMBER + 1;

    static inline function get_HOE_TRIGGERED():Int return PRIVATE_NUMBER + 0;
    static inline function get_HOE_DAMAGED():Int return PRIVATE_NUMBER + 1;

    static inline function get_CRUSHING_WALLS_ENRAGED():Int return PRIVATE_NUMBER + 0;
    static inline function get_CRUSHING_WALLS_CLOSED():Int return PRIVATE_NUMBER + 1;
    static inline function get_CRUSHING_WALLS_STOPPED():Int return PRIVATE_NUMBER + 2;

    static inline function get_PAGODA_LASER_EXPAND():Int return PRIVATE_NUMBER + 0;
    static inline function get_PAGODA_LASER_SWIPE():Int return PRIVATE_NUMBER + 1;
    static inline function get_PAGODA_LASER_SUBTRACT():Int return PRIVATE_NUMBER + 2;

    static inline var PRIVATE_NUMBER:Int = 10000;
}
