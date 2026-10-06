// Ported from: Assets/Scripts/Vanilla/GameContent/Areas/VanillaAreaModelPresets.cs
package mvz2.gamecontent.areas;

class VanillaAreaModelPresets
{
    public static inline var defaultPreset:String = "default";
}

// PORT-NOTE: C# 嵌套静态类 VanillaAreaModelPresets.Dream → Haxe 模块子类型。
// 因同包内已存在模块 Dream.hx，子类型不能再叫 Dream（会触发 "Type name ... is redefined"），故改名为 DreamPresets。
class DreamPresets
{
    public static inline var nightmare:String = "nightmare";
}
