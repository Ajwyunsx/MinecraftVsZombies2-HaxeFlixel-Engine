// Ported from: Assets/Scripts/Vanilla/GameContent/Talks/VanillaTalkID.cs
package mvz2.gamecontent.talk;

import mvz2.vanilla.VanillaMod;
import pvzengine.NamespaceID;

class VanillaTalkNames
{
    public static inline var tutorial:String = "tutorial";
    public static inline var starshardTutorial:String = "starshard_tutorial";
    public static inline var triggerTutorial:String = "trigger_tutorial";
    public static inline var halloween7:String = "halloween_7";
    public static inline var halloweenFinal:String = "halloween_final";
    public static inline var castle7Boss:String = "castle_7_boss";
    public static inline var palace11Boss:String = "palace_11_boss";
}

class VanillaTalkID
{
    public static var tutorial:NamespaceID = Get(VanillaTalkNames.tutorial);
    public static var starshardTutorial:NamespaceID = Get(VanillaTalkNames.starshardTutorial);
    public static var triggerTutorial:NamespaceID = Get(VanillaTalkNames.triggerTutorial);
    public static var halloween7:NamespaceID = Get(VanillaTalkNames.halloween7);
    public static var halloweenFinal:NamespaceID = Get(VanillaTalkNames.halloweenFinal);
    public static var castle7Boss:NamespaceID = Get(VanillaTalkNames.castle7Boss);
    public static var palace11Boss:NamespaceID = Get(VanillaTalkNames.palace11Boss);
    static function Get(name:String):NamespaceID
    {
        return new NamespaceID(VanillaMod.spaceName, name);
    }
}
