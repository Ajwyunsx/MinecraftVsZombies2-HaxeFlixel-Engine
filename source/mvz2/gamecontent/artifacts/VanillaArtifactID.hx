// Ported from: Assets/Scripts/Vanilla/GameContent/Artifacts/VanillaArtifactID.cs
package mvz2.gamecontent.artifacts;

import mvz2.vanilla.VanillaMod;
import pvzengine.NamespaceID;

class VanillaArtifactNames
{
    public static inline var almanac:String = "almanac";
    public static inline var hoe:String = "hoe";
    public static inline var dreamKey:String = "dream_key";
    public static inline var theCreaturesHeart:String = "the_creatures_heart";

    public static inline var dreamButterfly:String = "dream_butterfly";
    public static inline var sweetSleepPillow:String = "sweet_sleep_pillow";
    public static inline var pagodaBranch:String = "pagoda_branch";
    public static inline var darkMatter:String = "dark_matter";
    public static inline var bottledBlackhole:String = "bottled_blackhole";

    public static inline var smartPhone:String = "smart_phone";
    public static inline var invertedMirror:String = "inverted_mirror";
    public static inline var miracleMalletReplica:String = "miracle_mallet_replica";
    public static inline var netherStar:String = "nether_star";
    public static inline var brokenLantern:String = "broken_lantern";

    public static inline var manipulativeTalismans:String = "manipulative_talismans";
    public static inline var greedyVacuum:String = "greedy_vacuum";
    public static inline var lightbomb:String = "lightbomb";
    public static inline var eyeOfTheGiant:String = "eye_of_the_giant";

    public static inline var ufoToy:String = "ufo_toy";
    public static inline var dowsingRods:String = "dowsing_rods";
    public static inline var sorcerersScroll:String = "sorcerers_scroll";
    public static inline var dragonTooth:String = "dragon_tooth";

    public static inline var controlRod:String = "control_rod";
    public static inline var ghostlyCart:String = "ghostly_cart";
    public static inline var censerOfForgotten:String = "censer_of_forgotten";
    public static inline var brokenLock:String = "broken_lock";
    public static inline var magmaStone:String = "magma_stone";
}

class VanillaArtifactID
{
    public static var almanac:NamespaceID = Get(VanillaArtifactNames.almanac);
    public static var dreamKey:NamespaceID = Get(VanillaArtifactNames.dreamKey);
    public static var theCreaturesHeart:NamespaceID = Get(VanillaArtifactNames.theCreaturesHeart);
    public static var dreamButterfly:NamespaceID = Get(VanillaArtifactNames.dreamButterfly);

    public static var sweetSleepPillow:NamespaceID = Get(VanillaArtifactNames.sweetSleepPillow);
    public static var darkMatter:NamespaceID = Get(VanillaArtifactNames.darkMatter);
    public static var hoe:NamespaceID = Get(VanillaArtifactNames.hoe);
    public static var pagodaBranch:NamespaceID = Get(VanillaArtifactNames.pagodaBranch);
    public static var bottledBlackhole:NamespaceID = Get(VanillaArtifactNames.bottledBlackhole);

    public static var smartPhone:NamespaceID = Get(VanillaArtifactNames.smartPhone);
    public static var invertedMirror:NamespaceID = Get(VanillaArtifactNames.invertedMirror);
    public static var miracleMalletReplica:NamespaceID = Get(VanillaArtifactNames.miracleMalletReplica);
    public static var netherStar:NamespaceID = Get(VanillaArtifactNames.netherStar);
    public static var brokenLantern:NamespaceID = Get(VanillaArtifactNames.brokenLantern);

    public static var manipulativeTalismans:NamespaceID = Get(VanillaArtifactNames.manipulativeTalismans);
    public static var greedyVacuum:NamespaceID = Get(VanillaArtifactNames.greedyVacuum);
    public static var lightbomb:NamespaceID = Get(VanillaArtifactNames.lightbomb);
    public static var eyeOfTheGiant:NamespaceID = Get(VanillaArtifactNames.eyeOfTheGiant);

    public static var ufoToy:NamespaceID = Get(VanillaArtifactNames.ufoToy);
    public static var dowsingRods:NamespaceID = Get(VanillaArtifactNames.dowsingRods);
    public static var sorcerersScroll:NamespaceID = Get(VanillaArtifactNames.sorcerersScroll);
    public static var dragonTooth:NamespaceID = Get(VanillaArtifactNames.dragonTooth);

    public static var controlRod:NamespaceID = Get(VanillaArtifactNames.controlRod);
    public static var ghostlyCart:NamespaceID = Get(VanillaArtifactNames.ghostlyCart);
    public static var censerOfForgotten:NamespaceID = Get(VanillaArtifactNames.censerOfForgotten);
    public static var brokenLock:NamespaceID = Get(VanillaArtifactNames.brokenLock);
    public static var magmaStone:NamespaceID = Get(VanillaArtifactNames.magmaStone);
    static function Get(name:String):NamespaceID
    {
        return new NamespaceID(VanillaMod.spaceName, name);
    }
    public static function GetUnlockID(artifactID:NamespaceID):NamespaceID
    {
        return new NamespaceID(artifactID.SpaceName, 'artifact.${artifactID.Path}');
    }
}
