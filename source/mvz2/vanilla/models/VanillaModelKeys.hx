// Ported from: Assets/Scripts/Vanilla/Frameworks/Model/VanillaModelKeys.cs
package mvz2.vanilla.models;

import mvz2.vanilla.VanillaMod;
import pvzengine.NamespaceID;

class VanillaModelKeys
{
    public static var shortCircuit:NamespaceID = Get("short_circuit");
    public static var staticParticles:NamespaceID = Get("static_particles");
    public static var dreamKeyShield:NamespaceID = Get("dream_key_shield");
    public static var nocturnal:NamespaceID = Get("nocturnal");
    public static var terrorParasitized:NamespaceID = Get("terror_parasitized");
    public static var weaknessParticles:NamespaceID = Get("weakness_particles");
    public static var dreamAlarm:NamespaceID = Get("dream_alarm");
    public static var parabotInsected:NamespaceID = Get("parabot_insected");
    public static var knockbackWave:NamespaceID = Get("knockback_wave");
    public static var mindSwap:NamespaceID = Get("mind_swap");
    public static var witherParticles:NamespaceID = Get("wither_particles");
    public static var divineShield:NamespaceID = Get("divine_shield");
    public static var vulnerable:NamespaceID = Get("vulnerable");
    public static var goldenGrid:NamespaceID = Get("golden_grid");

    public static var glowingParticles:NamespaceID = Get("glowing_particles");
    public static var gravelOnFace:NamespaceID = Get("gravel_on_face");
    public static var candleCursed:NamespaceID = Get("candle_cursed");
    public static var petrifiedFeet:NamespaceID = Get("petrified_feet");
    public static var blueprintLock:NamespaceID = Get("blueprint_lock");
    public static var brokenTile:NamespaceID = Get("broken_tile");
    public static var psychicShackled:NamespaceID = Get("psychic_shackled");
    public static var burning:NamespaceID = Get("burning");
    static function Get(name:String):NamespaceID
    {
        return new NamespaceID(VanillaMod.spaceName, name);
    }
}
