// Ported from: Assets/Scripts/Engine/Base/Callbacks/CallbackRegistry.cs
package pvzengine.callbacks;

import pvzengine.IGameTriggerSystem;
import pvzengine.callbacks.ITrigger;

class CallbackRegistry
{
    public function new(triggers:IGameTriggerSystem)
    {
        Triggers = triggers;
    }
    // #region 公有方法
    public function ApplyCallbacks():Void
    {
        for (trigger in triggers)
        {
            Triggers.AddTrigger(trigger);
        }
    }
    public function RevertCallbacks():Void
    {
        for (trigger in triggers)
        {
            Triggers.RemoveTrigger(trigger);
        }
    }
    public function AddTrigger(trigger:ITrigger):Void
    {
        triggers.push(trigger);
    }
    // #endregion

    // #region 属性字段
    public var Triggers(default, null):IGameTriggerSystem;
    public var triggers:Array<ITrigger> = [];
    // #endregion
}
