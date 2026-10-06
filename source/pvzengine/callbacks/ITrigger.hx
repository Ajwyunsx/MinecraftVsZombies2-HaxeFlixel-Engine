// Ported from: Assets/Scripts/Engine/Base/Callbacks/ITrigger.cs
package pvzengine.callbacks;

import pvzengine.callbacks.CallbackType.ICallbackType;

interface ITrigger
{
    public var Type(get, never):ICallbackType;
    public var Priority(get, never):Int;
}
