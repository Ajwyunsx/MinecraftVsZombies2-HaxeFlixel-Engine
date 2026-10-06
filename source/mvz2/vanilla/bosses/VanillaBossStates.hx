// Ported from: Assets/Scripts/Vanilla/Frameworks/Bosses/VanillaBossStates.cs
package mvz2.vanilla.bosses;

class VanillaBossStates
{
    public static inline var IDLE:Int = 0;
    public static inline var APPEAR:Int = 1;
    public static inline var STUNNED:Int = 2;
    public static inline var DEATH:Int = 3;

    public static inline var FRANKENSTEIN_JUMP:Int = PRIVATE_NUMBER + 0;
    public static inline var FRANKENSTEIN_GUN:Int = PRIVATE_NUMBER + 1;
    public static inline var FRANKENSTEIN_MISSILE:Int = PRIVATE_NUMBER + 2;
    public static inline var FRANKENSTEIN_PUNCH:Int = PRIVATE_NUMBER + 3;
    public static inline var FRANKENSTEIN_SHOCK:Int = PRIVATE_NUMBER + 4;

    public static inline var NIGHTMAREAPER_JAB:Int = PRIVATE_NUMBER + 0;
    public static inline var NIGHTMAREAPER_SPIN:Int = PRIVATE_NUMBER + 1;
    public static inline var NIGHTMAREAPER_DARKNESS:Int = PRIVATE_NUMBER + 2;
    public static inline var NIGHTMAREAPER_REVIVE:Int = PRIVATE_NUMBER + 3;
    public static inline var NIGHTMAREAPER_ENRAGE:Int = PRIVATE_NUMBER + 4;

    public static inline var SEIJA_DANMAKU:Int = PRIVATE_NUMBER + 0;
    public static inline var SEIJA_HAMMER:Int = PRIVATE_NUMBER + 1;
    public static inline var SEIJA_GAP_BOMB:Int = PRIVATE_NUMBER + 2;
    public static inline var SEIJA_CAMERA:Int = PRIVATE_NUMBER + 3;
    public static inline var SEIJA_BACKFLIP:Int = PRIVATE_NUMBER + 4;
    public static inline var SEIJA_FRONTFLIP:Int = PRIVATE_NUMBER + 5;
    public static inline var SEIJA_FABRIC:Int = PRIVATE_NUMBER + 6;

    public static inline var WITHER_CHARGE:Int = PRIVATE_NUMBER + 0;
    public static inline var WITHER_EAT:Int = PRIVATE_NUMBER + 1;
    public static inline var WITHER_SWITCH:Int = PRIVATE_NUMBER + 2;
    public static inline var WITHER_SUMMON:Int = PRIVATE_NUMBER + 3;

    public static inline var THE_GIANT_DISASSEMBLY:Int = PRIVATE_NUMBER + 0;
    public static inline var THE_GIANT_EYES:Int = PRIVATE_NUMBER + 1;
    public static inline var THE_GIANT_ROAR:Int = PRIVATE_NUMBER + 2;
    public static inline var THE_GIANT_ARMS:Int = PRIVATE_NUMBER + 3;
    public static inline var THE_GIANT_BREATH:Int = PRIVATE_NUMBER + 4;
    public static inline var THE_GIANT_PACMAN:Int = PRIVATE_NUMBER + 5;
    public static inline var THE_GIANT_SNAKE:Int = PRIVATE_NUMBER + 6;
    public static inline var THE_GIANT_FAINT:Int = PRIVATE_NUMBER + 7;
    public static inline var THE_GIANT_CHASE:Int = PRIVATE_NUMBER + 8;

    public static inline var RED_DRAGON_SPIT:Int = PRIVATE_NUMBER + 0;
    public static inline var RED_DRAGON_JUMP:Int = PRIVATE_NUMBER + 1;
    public static inline var RED_DRAGON_FLAP_WINGS:Int = PRIVATE_NUMBER + 2;
    public static inline var RED_DRAGON_EAT:Int = PRIVATE_NUMBER + 3;
    public static inline var RED_DRAGON_FIRE_BREATH:Int = PRIVATE_NUMBER + 4;
    public static inline var RED_DRAGON_LARGE_FIREBALL:Int = PRIVATE_NUMBER + 5;
    public static inline var RED_DRAGON_ROAR:Int = PRIVATE_NUMBER + 6;
    public static inline var RED_DRAGON_SPIT_UP:Int = PRIVATE_NUMBER + 7;
    public static inline var RED_DRAGON_FLY:Int = PRIVATE_NUMBER + 8;
    public static inline var RED_DRAGON_TAIL_SWIPE:Int = PRIVATE_NUMBER + 9;
    public static inline var RED_DRAGON_DEATH_ROAR:Int = PRIVATE_NUMBER + 10;
    public static inline var RED_DRAGON_DEATH_FLY:Int = PRIVATE_NUMBER + 11;

    public static inline var LOCKED_CHEST_JUMP:Int = PRIVATE_NUMBER + 0;
    public static inline var LOCKED_CHEST_CHARGE:Int = PRIVATE_NUMBER + 1;
    public static inline var LOCKED_CHEST_SMASH:Int = PRIVATE_NUMBER + 2;
    public static inline var LOCKED_CHEST_LOCK:Int = PRIVATE_NUMBER + 3;
    public static inline var LOCKED_CHEST_CRUSH_LOCK:Int = PRIVATE_NUMBER + 4;
    public static inline var LOCKED_CHEST_SPIT_TRASH:Int = PRIVATE_NUMBER + 5;
    public static inline var LOCKED_CHEST_COUGH:Int = PRIVATE_NUMBER + 6;
    public static inline var LOCKED_CHEST_SPECIAL_ATTACK:Int = PRIVATE_NUMBER + 7;
    public static inline var LOCKED_CHEST_RELEASE_SPECIAL_ATTACK:Int = PRIVATE_NUMBER + 8;
    public static inline var LOCKED_CHEST_CAMERA:Int = PRIVATE_NUMBER + 9;
    public static inline var LOCKED_CHEST_SPIT_ZOMBIE_BLUEPRINTS:Int = PRIVATE_NUMBER + 10;
    public static inline var LOCKED_CHEST_PAY_TO_WIN:Int = PRIVATE_NUMBER + 11;
    public static inline var LOCKED_CHEST_FIVE_SMASHES:Int = PRIVATE_NUMBER + 12;
    public static inline var LOCKED_CHEST_HYPERBEAM:Int = PRIVATE_NUMBER + 13;
    public static inline var LOCKED_CHEST_FOUR_SOULS:Int = PRIVATE_NUMBER + 14;

    public static inline var LOCKED_CHEST_BOMBARD:Int = PRIVATE_NUMBER + 15;
    public static inline var LOCKED_CHEST_SUMMON_WITHER:Int = PRIVATE_NUMBER + 17;
    public static inline var LOCKED_CHEST_GIANTIZE:Int = PRIVATE_NUMBER + 18;
    public static inline var LOCKED_CHEST_FIREBREATH:Int = PRIVATE_NUMBER + 19;
    public static inline var LOCKED_CHEST_TIRED:Int = PRIVATE_NUMBER + 20;

    private static inline var PRIVATE_NUMBER:Int = 10000;
}
