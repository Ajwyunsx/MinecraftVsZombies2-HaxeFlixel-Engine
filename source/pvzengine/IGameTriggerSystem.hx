// Ported from: Assets/Scripts/Engine/Base/Interfaces/IGameTriggerSystem.cs
package pvzengine;

import pvzengine.callbacks.ICallbackRunner;
import pvzengine.callbacks.ITrigger;

interface IGameTriggerSystem extends ICallbackRunner
{
    public function AddTrigger(trigger:ITrigger):Void;
    public function RemoveTrigger(trigger:ITrigger):Bool;
}
