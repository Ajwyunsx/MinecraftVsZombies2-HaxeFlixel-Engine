// Ported from: Assets/Scripts/Engine/Level/Damage/DamageEffectList.cs
package pvzengine.damages;

import pvzengine.NamespaceID;

class DamageEffectList
{
    // PORT-NOTE: C# 为 `DamageEffectList(params NamespaceID[] effects)`。既有调用点同时存在
    //   * `new DamageEffectList([a, b])`（传数组）
    //   * `new DamageEffectList(a, b, c)` / `new DamageEffectList(a)` / `new DamageEffectList()`（可变参数）
    // Haxe 没有 params；用 haxe.Rest<Dynamic> 收集后归一化，使以上所有形式都能编译并得到等价的 effects 数组。
    public function new(effects:haxe.Rest<Dynamic>)
    {
        this.effects = normalize(effects);
    }
    private static function normalize(args:Array<Dynamic>):Array<NamespaceID>
    {
        if (args == null || args.length == 0)
            return [];
        if (args.length == 1)
        {
            var first = args[0];
            if (first == null)
                return [];
            if (Std.isOfType(first, Array))
                return cast first;
            return [cast first];
        }
        return cast args;
    }
    public function GetEffects():Array<NamespaceID>
    {
        return effects;
    }
    public function HasEffect(effect:NamespaceID):Bool
    {
        return effects.contains(effect);
    }
    private var effects:Array<NamespaceID>;
}
