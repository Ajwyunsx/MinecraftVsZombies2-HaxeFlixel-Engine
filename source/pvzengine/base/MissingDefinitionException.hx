// Ported from: Assets/Scripts/Engine/Base/Definitions/MissingDefinitionException.cs
package pvzengine.base;

// PORT-NOTE: C# 的 3 个构造函数重载（/message/message+inner）在 Haxe 中合并为一个可选参数构造函数，
// 调用形式 `new MissingDefinitionException(msg)` 与 C# 一致；基类 Exception → haxe.Exception。
class MissingDefinitionException extends haxe.Exception
{
    public function new(?message:String = null, ?innerException:haxe.Exception = null)
    {
        super(message, innerException);
    }
}
