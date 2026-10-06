// Ported from: Assets/Scripts/Engine/Base/Callbacks/Trigger.cs
package pvzengine.callbacks;

import pvzengine.callbacks.CallbackType.ICallbackType;
import pvzengine.callbacks.ITrigger;

class Trigger<TArgs> implements ITrigger
{
    public function new(type:CallbackType<TArgs>, action:TArgs->CallbackResult->Void, priority:Int, ?filter:Dynamic)
    {
        this.type = type;
        Action = action;
        this.priority = priority;
        Filter = filter;
    }
    // C#: `public CallbackType<TArgs> Type { get; }` + 显式实现 `ICallbackType ITrigger.Type => Type;`
    // PORT-NOTE: Haxe 用「协变返回类型的只读属性」同时满足两者。
    public var Type(get, never):CallbackType<TArgs>;
    inline function get_Type():CallbackType<TArgs> return type;
    public var Action(default, null):TArgs->CallbackResult->Void;
    // PORT-NOTE: ITrigger.Priority 声明为 (get, never)，实现必须使用相同的访问器形式。
    public var Priority(get, never):Int;
    inline function get_Priority():Int return priority;
    public var Filter(default, null):Dynamic;
    private var type:CallbackType<TArgs>;
    private var priority:Int;
}
