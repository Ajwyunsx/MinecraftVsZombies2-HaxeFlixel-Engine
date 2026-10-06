// Ported from: Assets/Scripts/Engine/Base/Callbacks/CallbackResult.cs
package pvzengine.callbacks;

class CallbackResult
{
    public function new(?value:Dynamic)
    {
        if (value != null)
        {
            SetValue(value);
        }
    }
    public var IsBreakRequested(default, null):Bool;
    private var value:Dynamic;
    public function SetValue(value:Dynamic):Void
    {
        this.value = value;
    }
    public function SetFinalValue(value:Dynamic):Void
    {
        SetValue(value);
        Break();
    }
    // PORT-NOTE: C# 为 `T? GetValue<T>()`，内部用 `value.TryToGeneric<T>(out var v)` 做类型检查。
    // Haxe 不支持在调用点书写显式类型参数（既有调用点全部写的是无参形式 `result.GetValue()`，
    // 见 LogicSaveExt/LogicLevelExt 等处的 PORT-NOTE），因此这里保留无参的 GetValue()，
    // 直接返回原值（调用方按 Dynamic 使用）。
    public function GetValue():Dynamic
    {
        return value;
    }
    public function Break():Void
    {
        IsBreakRequested = true;
    }
}
