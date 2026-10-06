// Ported from: Assets/Scripts/Engine/Level/Callbacks/LevelCallbacks.cs (struct StringCallbackParams)
// PORT-NOTE: 上层以 `import pvzengine.callbacks.StringCallbackParams;` 引用它（见 mvz2logic/callbacks/LogicCallbacks.hx、
//   mvz2logic/contents/globalcallbacks/DebugGlobalCallbacks.hx），故独立成模块。
//   注意：mvz2logic/games/LogicGameExt.hx 写的是 `import pvzengine.callbacks.LevelCallbacks.StringCallbackParams;`
//   （模块路径形式）；Haxe 同一包内不允许同名类型重复出现，两种 import 无法同时满足，
//   此处以多数调用点的 `pvzengine.callbacks.StringCallbackParams` 为准（整合阶段需调整该文件的 import）。
package pvzengine.callbacks;

class StringCallbackParams
{
	public var text:String;

	public function new(text:String)
	{
		this.text = text;
	}
}
