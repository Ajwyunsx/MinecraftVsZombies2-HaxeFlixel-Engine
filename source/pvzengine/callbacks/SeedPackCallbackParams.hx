// Ported from: Assets/Scripts/Engine/Level/Callbacks/LevelCallbacks.cs (struct SeedPackCallbackParams)
// PORT-NOTE: C# 中该结构体与 LevelCallbacks 同处 LevelCallbacks.cs。工程内暂无调用点 import 它，
//   但仍独立成模块，以避免与 LevelCallbacks 模块中的其它参数结构体产生同名冲突（原因见 LevelCallbacks.hx 文件头说明）。
package pvzengine.callbacks;

import pvzengine.seedpacks.SeedPack;

class SeedPackCallbackParams
{
	public var seedPack:SeedPack;

	public function new(seedPack:SeedPack)
	{
		this.seedPack = seedPack;
	}
}
