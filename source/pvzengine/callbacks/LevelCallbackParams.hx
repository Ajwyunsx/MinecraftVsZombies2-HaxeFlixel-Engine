// Ported from: Assets/Scripts/Engine/Level/Callbacks/LevelCallbacks.cs (struct LevelCallbackParams)
// PORT-NOTE: 上层以 `import pvzengine.callbacks.LevelCallbackParams;` 引用它（14 个文件），故独立成模块
//   （原因见 LevelCallbacks.hx 文件头说明）。
package pvzengine.callbacks;

import pvzengine.level.LevelEngine;

class LevelCallbackParams
{
	public var level:LevelEngine;

	public function new(level:LevelEngine)
	{
		this.level = level;
	}
}
