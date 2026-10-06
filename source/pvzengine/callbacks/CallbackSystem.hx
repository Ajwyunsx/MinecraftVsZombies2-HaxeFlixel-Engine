// Ported from: Assets/Scripts/Engine/Base/Callbacks/CallbackSystem.cs
package pvzengine.callbacks;

import pvzengine.callbacks.ICallbackRunner;
import pvzengine.callbacks.CallbackType.ICallbackType;
import pvzengine.callbacks.ITrigger;

class CallbackSystem implements ICallbackRunner
{
    public function new() {}
    public function RunCallback<TArgs>(callbackType:CallbackType<TArgs>, args:TArgs):Void
    {
        RunCallbackWithResult(callbackType, args, new CallbackResult());
    }
    public function RunCallbackWithResult<TArgs>(callbackType:CallbackType<TArgs>, args:TArgs, result:CallbackResult):Void
    {
        if (handlers.exists(callbackType))
        {
            var handler = handlers.get(callbackType);
            var callbackHandler:CallbackHandler<TArgs> = cast handler;
            callbackHandler.Execute(args, result);
        }
    }
    public function RunCallbackFiltered<TArgs>(callbackType:CallbackType<TArgs>, args:TArgs, filter:Dynamic):Void
    {
        RunCallbackWithResultFiltered(callbackType, args, new CallbackResult(), filter);
    }
    public function RunCallbackWithResultFiltered<TArgs>(callbackType:CallbackType<TArgs>, args:TArgs, result:CallbackResult, filter:Dynamic):Void
    {
        if (handlers.exists(callbackType))
        {
            var handler = handlers.get(callbackType);
            var callbackHandler:CallbackHandler<TArgs> = cast handler;
            callbackHandler.ExecuteFiltered(args, filter, result);
        }
    }

    public function AddCallback(trigger:ITrigger):Void
    {
        // C#: handlers.GetOrAdd(trigger.Type, type => type.CreateHandler())
        var handler = handlers.get(trigger.Type);
        if (handler == null)
        {
            handler = trigger.Type.CreateHandler();
            handlers.set(trigger.Type, handler);
        }
        handler.AddTrigger(trigger);
    }
    public function RemoveCallback(trigger:ITrigger):Bool
    {
        if (handlers.exists(trigger.Type))
        {
            var callbackHandler = handlers.get(trigger.Type);
            return callbackHandler.RemoveTrigger(trigger);
        }
        return false;
    }

    // PORT-NOTE: C# 为 ConcurrentDictionary<ICallbackType, ICallbackHandler>。Haxe 没有并发字典
    // （游戏主循环单线程），改用普通 Map；键为 CallbackType 实例本身（引用相等，语义与 C# 一致）。
    private var handlers:Map<ICallbackType, ICallbackHandler> = new Map<ICallbackType, ICallbackHandler>();
}
