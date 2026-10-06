// Ported from: Assets/Scripts/Vanilla/GameContent/Damages/VanillaDamageEffects.cs
package mvz2.gamecontent.damages;

import mvz2.vanilla.VanillaMod;
import pvzengine.NamespaceID;

class VanillaDamageEffects
{
    // Armors
    public static var DAMAGE_BOTH_ARMOR_AND_BODY:NamespaceID = Get("damage_both_armor_and_body");
    public static var DAMAGE_BODY_AFTER_ARMOR_BROKEN:NamespaceID = Get("damage_body_after_armor_broken");
    public static var IGNORE_ARMOR:NamespaceID = Get("ignore_armor");

    // Elements
    public static var IMPACT:NamespaceID = Get("impact");
    public static var FIRE:NamespaceID = Get("fire");
    public static var SLICE:NamespaceID = Get("slice");
    public static var EXPLOSION:NamespaceID = Get("explosion");
    public static var ICE:NamespaceID = Get("ice");
    public static var LIGHTNING:NamespaceID = Get("lightning");
    public static var LIGHT:NamespaceID = Get("light");

    // Damage Types
    public static var PROJECTILE:NamespaceID = Get("projectile");
    public static var FALL_DAMAGE:NamespaceID = Get("fall_damage");
    public static var GRIND:NamespaceID = Get("grind");
    public static var WHACK:NamespaceID = Get("whack");
    public static var GOLD:NamespaceID = Get("gold");
    public static var ENEMY_MELEE:NamespaceID = Get("enemy_melee");
    public static var GROUND_SPIKES:NamespaceID = Get("ground_spikes");

    // Hit Effect
    public static var MUTE:NamespaceID = Get("mute");
    public static var TINY:NamespaceID = Get("tiny");
    public static var SLOW:NamespaceID = Get("slow");

    // Damage Mark
    public static var SELF_DAMAGE:NamespaceID = Get("self_damage");
    public static var TRANSFERRED:NamespaceID = Get("transferred");
    public static var NO_DAMAGE_BLINK:NamespaceID = Get("no_damage_blink");
    public static var BYPASS_BOSS_ARMOR:NamespaceID = Get("bypass_boss_armor");

    // Death Reason
    public static var SACRIFICE:NamespaceID = Get("sacrifice");
    public static var OUT_OF_BOUND:NamespaceID = Get("out_of_bound");
    public static var DROWN:NamespaceID = Get("drown");
    public static var FALL_OFF:NamespaceID = Get("fall_off");
    public static var PICKAXE:NamespaceID = Get("pickaxe");
    public static var INSTA_KILL:NamespaceID = Get("insta_kill");

    // Death Effect
    public static var REMOVE_ON_DEATH:NamespaceID = Get("remove_on_death");
    public static var NO_DEATH_EFFECTS:NamespaceID = Get("no_death_effects");
    public static var NO_NEUTRALIZE:NamespaceID = Get("no_neutralize");
    public static var NO_BROKEN_LOCK:NamespaceID = Get("no_broken_lock");
    public static var NO_REVIVAL:NamespaceID = Get("no_revival");

    public static function Get(name:String):NamespaceID
    {
        return new NamespaceID(VanillaMod.spaceName, name);
    }
}
