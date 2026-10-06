// Ported from: Assets/Scripts/Vanilla/Frameworks/Enemies/VanillaEnemyStates.cs
package mvz2.vanilla.enemies;

class VanillaEnemyStates
{
    public static var NAPSTABLOOK_ANGRY(get, never):Int;

    public static var SPIDER_CLIMB(get, never):Int;

    public static var SKELETON_HORSE_JUMP(get, never):Int;
    public static var SKELETON_HORSE_GALLOP(get, never):Int;
    public static var SKELETON_HORSE_LAND(get, never):Int;

    public static var MUTANT_ZOMBIE_SMASH(get, never):Int;
    public static var MUTANT_ZOMBIE_THROW(get, never):Int;

    public static var UFO_STAY(get, never):Int;
    public static var UFO_ACT(get, never):Int;

    public static var POP_CAPTAIN_SMASH_DOWN(get, never):Int;
    public static var POP_CAPTAIN_SMASH_UP(get, never):Int;

    public static var SKELETON_STATUE_REVIVING(get, never):Int;

    public static var HACKER_HACK(get, never):Int;

    static inline function get_NAPSTABLOOK_ANGRY():Int return PRIVATE_NUMBER + 0;
    static inline function get_SPIDER_CLIMB():Int return PRIVATE_NUMBER + 0;
    static inline function get_SKELETON_HORSE_JUMP():Int return PRIVATE_NUMBER + 0;
    static inline function get_SKELETON_HORSE_GALLOP():Int return PRIVATE_NUMBER + 1;
    static inline function get_SKELETON_HORSE_LAND():Int return PRIVATE_NUMBER + 2;
    static inline function get_MUTANT_ZOMBIE_SMASH():Int return PRIVATE_NUMBER + 0;
    static inline function get_MUTANT_ZOMBIE_THROW():Int return PRIVATE_NUMBER + 1;
    static inline function get_UFO_STAY():Int return PRIVATE_NUMBER + 0;
    static inline function get_UFO_ACT():Int return PRIVATE_NUMBER + 1;
    static inline function get_POP_CAPTAIN_SMASH_DOWN():Int return PRIVATE_NUMBER + 0;
    static inline function get_POP_CAPTAIN_SMASH_UP():Int return PRIVATE_NUMBER + 1;
    static inline function get_SKELETON_STATUE_REVIVING():Int return PRIVATE_NUMBER + 0;
    static inline function get_HACKER_HACK():Int return PRIVATE_NUMBER + 0;

    static inline var PRIVATE_NUMBER:Int = 10000;
}
