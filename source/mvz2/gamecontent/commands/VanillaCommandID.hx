// Ported from: Assets/Scripts/Vanilla/GameContent/Commands/VanillaCommandID.cs
package mvz2.gamecontent.commands;

import mvz2.vanilla.VanillaMod;
import pvzengine.NamespaceID;

class VanillaCommandNames
{
    public static inline var help:String = "help";
    public static inline var spawn:String = "spawn";
    public static inline var spawnBlueprint:String = "spawnblueprint";
    public static inline var kill:String = "kill";
    public static inline var blueprint:String = "blueprint";
    public static inline var energy:String = "energy";
    public static inline var starshard:String = "starshard";
    public static inline var recharge:String = "recharge";
    public static inline var cheat:String = "cheat";
    public static inline var repeat:String = "repeat";
    public static inline var clear:String = "clear";
    public static inline var clearLevel:String = "clearlevel";
    public static inline var save:String = "save";
    public static inline var load:String = "load";
    public static inline var artifact:String = "artifact";
    public static inline var test:String = "test";
    public static inline var unlock:String = "unlock";
    public static inline var gotolevel:String = "gotolevel";
    public static inline var chapterTransition:String = "chaptertransition";
    public static inline var izombie:String = "izombie";
}

class VanillaCommandID
{
    public static var help:NamespaceID = Get(VanillaCommandNames.help);
    public static var spawn:NamespaceID = Get(VanillaCommandNames.spawn);
    public static var spawnBlueprint:NamespaceID = Get(VanillaCommandNames.spawnBlueprint);
    public static var kill:NamespaceID = Get(VanillaCommandNames.kill);
    public static var blueprint:NamespaceID = Get(VanillaCommandNames.blueprint);
    public static var energy:NamespaceID = Get(VanillaCommandNames.energy);
    public static var starshard:NamespaceID = Get(VanillaCommandNames.starshard);
    public static var recharge:NamespaceID = Get(VanillaCommandNames.recharge);
    public static var cheat:NamespaceID = Get(VanillaCommandNames.cheat);
    public static var repeat:NamespaceID = Get(VanillaCommandNames.repeat);
    public static var clear:NamespaceID = Get(VanillaCommandNames.clear);
    public static var clearLevel:NamespaceID = Get(VanillaCommandNames.clearLevel);
    public static var save:NamespaceID = Get(VanillaCommandNames.save);
    public static var load:NamespaceID = Get(VanillaCommandNames.load);
    public static var artifact:NamespaceID = Get(VanillaCommandNames.artifact);
    public static var unlock:NamespaceID = Get(VanillaCommandNames.unlock);
    public static var gotolevel:NamespaceID = Get(VanillaCommandNames.gotolevel);
    public static var izombie:NamespaceID = Get(VanillaCommandNames.izombie);
    static function Get(name:String):NamespaceID
    {
        return new NamespaceID(VanillaMod.spaceName, name);
    }
}
