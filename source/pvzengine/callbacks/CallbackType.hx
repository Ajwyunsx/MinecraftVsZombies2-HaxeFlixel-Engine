// Ported from: Assets/Scripts/Engine/Base/Callbacks/CallbackType.cs
package pvzengine.callbacks;

// C#: interface ICallbackType { internal ICallbackHandler CreateHandler(); }
// PORT-NOTE: Haxe 没有 internal 访问级别，改为普通公开成员。
// PORT-NOTE: 本类型是模块 pvzengine.callbacks.CallbackType 的次要类型，
// 跨模块引用需写 `import pvzengine.callbacks.CallbackType.ICallbackType;`（Haxe 的模块解析规则）。
interface ICallbackType
{
    public function CreateHandler():ICallbackHandler;
}

// C#: public sealed class CallbackType<TArgs> : ICallbackType
// PORT-NOTE: Haxe 的 final 相当于 C# sealed（既有调用点以 `new CallbackType()` / `new CallbackType<X>()` 构造）。
final class CallbackType<TArgs> implements ICallbackType
{
    public function new() {}
    public function CreateHandler():ICallbackHandler
    {
        return new CallbackHandler<TArgs>();
    }
}
