// Ported from: Assets/Scripts/Engine/Level/Callbacks/LevelCallbacks.cs (struct EmptyCallbackParams)
// PORT-NOTE: C# 中该结构体与 LevelCallbacks 同处 LevelCallbacks.cs；上层以 `import pvzengine.callbacks.EmptyCallbackParams;`
//   引用它（见 mvz2logic/callbacks/LogicCallbacks.hx、mvz2logic/saves/LogicSaveExt.hx 等），
//   且 Haxe 不允许同一包内出现第二个同名类型，故独立成模块（详见 LevelCallbacks.hx 文件头说明）。
// PORT-NOTE: C# struct → Haxe class（PORTING.md）。
package pvzengine.callbacks;

class EmptyCallbackParams
{
	public function new() {}
}
