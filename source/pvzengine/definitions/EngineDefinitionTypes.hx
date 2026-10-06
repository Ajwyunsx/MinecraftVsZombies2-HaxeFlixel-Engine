// Ported from: Assets/Scripts/Engine/Level/Definitions/EngineDefinitionTypes.cs
package pvzengine.definitions;

// PORT-NOTE: C# `public static class EngineDefinitionTypes { public const string X = "y"; }` →
// Haxe 全静态类 + static inline var（与工程内其它静态类一致，不声明构造函数）。
class EngineDefinitionTypes
{
    public static inline var BUFF:String = "buff";
    public static inline var ARMOR:String = "armor";
    public static inline var ARMOR_BEHAVIOUR:String = "armor_behaviour";
    public static inline var ENTITY:String = "entity";
    public static inline var ENTITY_BEHAVIOUR:String = "entity_behaviour";
    public static inline var SEED:String = "seed";
    public static inline var RECHARGE:String = "recharge";
    public static inline var SHELL:String = "shell";
    public static inline var PLACEMENT:String = "placement";
    public static inline var AREA:String = "area";
    public static inline var STAGE:String = "stage";
    public static inline var GRID:String = "grid";
    public static inline var SPAWN:String = "spawn";
    public static inline var DIFFICULTY:String = "difficulty";
}
