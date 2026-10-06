// Ported from: Assets/Scripts/Vanilla/Frameworks/Entities/WaterInteraction.cs
package mvz2.vanilla.entities;

class WaterInteraction
{
    public static inline var NONE:Int = 0;
    public static inline var REMOVE:Int = 1;
    public static inline var DROWN:Int = 2;
    public static inline var FLOAT:Int = 3;

    public static inline var ACTION_REMOVE:Int = 0;
    public static inline var ACTION_ENTER:Int = 1;
    public static inline var ACTION_EXIT:Int = 2;
}

class AirInteraction
{
    public static inline var NONE:Int = 0;
    public static inline var REMOVE:Int = 1;
    public static inline var FALL_OFF:Int = 2;
    public static inline var FLOAT:Int = 3;

    public static inline var ACTION_REMOVE:Int = 0;
    public static inline var ACTION_ENTER:Int = 1;
    public static inline var ACTION_EXIT:Int = 2;
}
