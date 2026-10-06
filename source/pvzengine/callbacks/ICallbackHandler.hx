// Ported from: Assets/Scripts/Engine/Base/Callbacks/CallbackHandler.cs (interface ICallbackHandler)
package pvzengine.callbacks;

import pvzengine.callbacks.ITrigger;

// C# 原文：`internal interface ICallbackHandler`
// PORT-NOTE: Haxe 没有 internal，改为普通公开接口；且 Haxe 要求「模块路径 == 主类型名」才能被 import，
// 因此把原文件中的 4 个类型（ICallbackHandler / CallbackHandlerBase / CallbackHandler / TriggerPriorityComparer）
// 拆分为独立模块：ICallbackHandler.hx、CallbackHandler.hx（其余两个为其次要类型）。
interface ICallbackHandler
{
    public function AddTrigger(trigger:ITrigger):Void;
    public function RemoveTrigger(trigger:ITrigger):Bool;
}
