// Ported from: Assets/Scripts/Engine/Level/Models/IModeledBuffTarget.cs
// PORT-NOTE: 该 C# 文件位于 Models/ 目录，但 namespace 为 PVZEngine.Buffs，
//   按「包名以 namespace 为准」的规则放在 pvzengine/buffs/ 下。
package pvzengine.buffs;

import pvzengine.NamespaceID;
import pvzengine.models.IHasModel;
import pvzengine.models.IModelInterface;

// PORT-NOTE: C# 的接口默认实现（`IModelInterface? GetInsertedModel(NamespaceID key) => this.GetChildModel(key);`）
//   在 Haxe 中无法表达，改为只声明签名，由各实现类提供（与 pvzengine.armors.Armor、
//   pvzengine.grids.LawnGrid、pvzengine.seedpacks.SeedPack 的既有移植写法一致）。
interface IModeledBuffTarget extends IHasModel extends IBuffTarget
{
	public function GetInsertedModel(key:NamespaceID):Null<IModelInterface>;
}
