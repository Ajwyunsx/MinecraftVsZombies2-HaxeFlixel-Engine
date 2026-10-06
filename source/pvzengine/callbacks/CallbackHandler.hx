// Ported from: Assets/Scripts/Engine/Base/Callbacks/CallbackHandler.cs
package pvzengine.callbacks;

import pvzengine.callbacks.ITrigger;
import pvzengine.callbacks.Trigger;

// C#: internal abstract class CallbackHandlerBase<TTrigger> where TTrigger : ITrigger
// PORT-NOTE: Haxe 无 internal，改为公开类；本类为模块 CallbackHandler 的次要类型。
// PORT-NOTE: C# 用「显式接口实现」（void ICallbackHandler.AddTrigger(ITrigger)）+ 类型化的
// AddTrigger(TTrigger) 两个成员。Haxe 不允许同名字段的不同参数类型（也没有显式接口实现），
// 因此这里只保留接口签名 `AddTrigger(ITrigger)`，内部 cast 为 TTrigger（调用方都经由
// ICallbackHandler 传入，运行期类型必然匹配）。
class CallbackHandlerBase<TTrigger:ITrigger> implements ICallbackHandler
{
    public function new() {}
    public function AddTrigger(trigger:ITrigger):Void
    {
        var typed:TTrigger = cast trigger;
        // PORT-NOTE: C# 使用 lock(syncLock) 保护列表；Haxe 没有 lock（游戏主循环单线程）。
        var index = findInsertIndex(typed);
        triggers.insert(index, typed);
        triggersSnapshot = null;
    }
    public function RemoveTrigger(trigger:ITrigger):Bool
    {
        var typed:TTrigger = cast trigger;
        if (triggers.remove(typed))
        {
            triggersSnapshot = null;
            return true;
        }
        return false;
    }
    public function GetTriggersSnapshot():Array<TTrigger>
    {
        if (triggersSnapshot != null)
            return triggersSnapshot;

        return triggersSnapshot = triggers.copy();
    }
    // PORT-NOTE: C# 用 List.BinarySearch(trigger, TriggerPriorityComparer) 找到插入位置（按 Priority 升序）；
    // Haxe 的 Array 没有该方法，这里用等价的二分查找。
    private function findInsertIndex(trigger:TTrigger):Int
    {
        var lo = 0;
        var hi = triggers.length;
        while (lo < hi)
        {
            var mid = (lo + hi) >> 1;
            if (triggers[mid].Priority < trigger.Priority)
            {
                lo = mid + 1;
            }
            else
            {
                hi = mid;
            }
        }
        return lo;
    }
    public var syncLock:Dynamic = {};
    public var triggers:Array<TTrigger> = [];
    public var triggersSnapshot:Null<Array<TTrigger>>;
}

// C#: internal class TriggerPriorityComparer<T> : IComparer<T> where T : ITrigger
class TriggerPriorityComparer<T:ITrigger>
{
    public function new() {}
    public function Compare(x:T, y:T):Int
    {
        return x.Priority - y.Priority;
    }
}

// C#: internal class CallbackHandler<TArgs> : CallbackHandlerBase<Trigger<TArgs>>
class CallbackHandler<TArgs> extends CallbackHandlerBase<Trigger<TArgs>>
{
    public function new()
    {
        super();
    }
    public function Execute(args:TArgs, result:CallbackResult):Void
    {
        var currentTriggers = GetTriggersSnapshot();
        for (trigger in currentTriggers)
        {
            trigger.Action(args, result);
            if (result.IsBreakRequested)
                break;
        }
    }
    public function ExecuteFiltered(args:TArgs, filter:Dynamic, result:CallbackResult):Void
    {
        var currentTriggers = GetTriggersSnapshot();
        for (trigger in currentTriggers)
        {
            if (!IsFilterMatched(trigger.Filter, filter))
                continue;

            trigger.Action(args, result);
            if (result.IsBreakRequested)
                break;
        }
    }
    private function IsFilterMatched(triggerFilter:Dynamic, callbackFilter:Dynamic):Bool
    {
        if (triggerFilter == null || callbackFilter == null)
            return true;
        // C#: triggerFilter.Equals(callbackFilter)
        if (Reflect.hasField(triggerFilter, "Equals"))
        {
            var method:Dynamic = Reflect.field(triggerFilter, "Equals");
            if (Reflect.isFunction(method))
            {
                var result:Dynamic = Reflect.callMethod(triggerFilter, method, [callbackFilter]);
                if (Std.isOfType(result, Bool))
                    return cast result;
            }
        }
        return triggerFilter == callbackFilter;
    }
}
