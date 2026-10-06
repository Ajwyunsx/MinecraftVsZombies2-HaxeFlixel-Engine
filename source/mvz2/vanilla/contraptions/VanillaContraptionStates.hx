// Ported from: Assets/Scripts/Vanilla/Frameworks/Contraptions/VanillaContraptionStates.cs
package mvz2.vanilla.contraptions;

class VanillaContraptionStates
{
    public static inline var IDLE:Int = 0;

    public static var PUNCHTON_PUNCH(get, never):Int;
    public static var PUNCHTON_BROKEN(get, never):Int;

    public static var MAGICHEST_OPEN(get, never):Int;
    public static var MAGICHEST_EAT(get, never):Int;
    public static var MAGICHEST_LOMS(get, never):Int;
    public static var MAGICHEST_CLOSE(get, never):Int;

    public static var PISTENSER_SEED(get, never):Int;

    public static var TOTENSER_FIRE_BREATH(get, never):Int;

    public static var TESLA_COIL_ATTACK(get, never):Int;

    public static var DEVOURER_GHOST(get, never):Int;

    public static var DESIRE_POT_EVOKED(get, never):Int;

    public static var JEWELED_PAGODA_ASCENT(get, never):Int;
    public static var JEWELED_PAGODA_LASER(get, never):Int;
    public static var JEWELED_PAGODA_DISAPPEAR(get, never):Int;

    public static var COMMAND_BLOCK_WORKING(get, never):Int;

    public static var TRANSFENSER_SHOOTER(get, never):Int;
    public static var TRANSFENSER_TO_AIMER(get, never):Int;
    public static var TRANSFENSER_AIMER(get, never):Int;
    public static var TRANSFENSER_TO_SHOOTER(get, never):Int;

    public static var AMETHYST_PYLON_ATTACK(get, never):Int;

    public static var BRICK_CANNON_RELOAD(get, never):Int;
    public static var BRICK_CANNON_LAUNCH(get, never):Int;

    static inline function get_PUNCHTON_PUNCH():Int return PRIVATE_NUMBER + 0;
    static inline function get_PUNCHTON_BROKEN():Int return PRIVATE_NUMBER + 1;
    static inline function get_MAGICHEST_OPEN():Int return PRIVATE_NUMBER + 0;
    static inline function get_MAGICHEST_EAT():Int return PRIVATE_NUMBER + 1;
    static inline function get_MAGICHEST_LOMS():Int return PRIVATE_NUMBER + 2;
    static inline function get_MAGICHEST_CLOSE():Int return PRIVATE_NUMBER + 3;
    static inline function get_PISTENSER_SEED():Int return PRIVATE_NUMBER + 0;
    static inline function get_TOTENSER_FIRE_BREATH():Int return PRIVATE_NUMBER + 0;
    static inline function get_TESLA_COIL_ATTACK():Int return PRIVATE_NUMBER + 1;
    static inline function get_DEVOURER_GHOST():Int return PRIVATE_NUMBER + 0;
    static inline function get_DESIRE_POT_EVOKED():Int return PRIVATE_NUMBER + 1;
    static inline function get_JEWELED_PAGODA_ASCENT():Int return PRIVATE_NUMBER + 0;
    static inline function get_JEWELED_PAGODA_LASER():Int return PRIVATE_NUMBER + 1;
    static inline function get_JEWELED_PAGODA_DISAPPEAR():Int return PRIVATE_NUMBER + 2;
    static inline function get_COMMAND_BLOCK_WORKING():Int return PRIVATE_NUMBER + 0;
    static inline function get_TRANSFENSER_SHOOTER():Int return IDLE;
    static inline function get_TRANSFENSER_TO_AIMER():Int return PRIVATE_NUMBER + 0;
    static inline function get_TRANSFENSER_AIMER():Int return PRIVATE_NUMBER + 1;
    static inline function get_TRANSFENSER_TO_SHOOTER():Int return PRIVATE_NUMBER + 2;
    static inline function get_AMETHYST_PYLON_ATTACK():Int return PRIVATE_NUMBER + 0;
    static inline function get_BRICK_CANNON_RELOAD():Int return PRIVATE_NUMBER + 0;
    static inline function get_BRICK_CANNON_LAUNCH():Int return PRIVATE_NUMBER + 1;

    static inline var PRIVATE_NUMBER:Int = 10000;
}
