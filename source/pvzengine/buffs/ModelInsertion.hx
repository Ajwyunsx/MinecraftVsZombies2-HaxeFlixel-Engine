// Ported from: Assets/Scripts/Engine/Level/Buffs/ModelInsertion.cs
// PORT-NOTE: 上层有 5 个文件以 `import pvzengine.models.ModelInsertion;` 引用本类（C# 命名空间为 PVZEngine.Buffs，
//   见 EntityController.hx / Model.hx / GridController.hx 等），故本类保留在 pvzengine.buffs，
//   并在 pvzengine.models 下提供同名 typedef 别名，两种 import 均可用。
package pvzengine.buffs;

import pvzengine.NamespaceID;

class ModelInsertion
{
	public function new(anchorName:String, key:NamespaceID, modelID:NamespaceID)
	{
		this.anchorName = anchorName;
		this.key = key;
		this.modelID = modelID;
	}
	public var anchorName:String;
	public var key:NamespaceID;
	public var modelID:NamespaceID;
}
