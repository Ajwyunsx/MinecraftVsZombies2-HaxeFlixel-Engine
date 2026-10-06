// Ported from: Assets/Scripts/Engine/Base/Callbacks/ICallbackRunner.cs
package pvzengine.callbacks;

interface ICallbackRunner
{
    public function RunCallback<TArgs>(callbackType:CallbackType<TArgs>, args:TArgs):Void;
    public function RunCallbackWithResult<TArgs>(callbackType:CallbackType<TArgs>, args:TArgs, result:CallbackResult):Void;
    public function RunCallbackWithResultFiltered<TArgs>(callbackType:CallbackType<TArgs>, args:TArgs, result:CallbackResult, filter:Dynamic):Void;
    public function RunCallbackFiltered<TArgs>(callbackType:CallbackType<TArgs>, args:TArgs, filter:Dynamic):Void;
}
