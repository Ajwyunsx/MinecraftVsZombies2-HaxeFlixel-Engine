// Ported from: Assets/Scripts/Engine/Level/Callbacks/LevelCallbacks.cs (struct EntityCallbackParams)
// PORT-NOTE: 上层以 `import pvzengine.callbacks.EntityCallbackParams;` 引用它（42 个文件，如
//   mvz2/gamecontent/artifacts/BrokenLantern.hx），故独立成模块。
//   注意：mvz2logic/level/LogicLevelExt.hx 写的是 `import pvzengine.callbacks.LevelCallbacks.EntityCallbackParams;`
//   （模块路径形式）；Haxe 同一包内不允许同名类型重复出现，两种 import 无法同时满足，
//   此处以多数调用点的 `pvzengine.callbacks.EntityCallbackParams` 为准（整合阶段需调整该文件的 import）。
package pvzengine.callbacks;

import pvzengine.entities.Entity;

class EntityCallbackParams
{
	public var entity:Entity;

	public function new(entity:Entity)
	{
		this.entity = entity;
	}
}
