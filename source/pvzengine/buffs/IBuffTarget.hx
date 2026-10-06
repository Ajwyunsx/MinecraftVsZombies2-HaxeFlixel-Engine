// Ported from: Assets/Scripts/Engine/Level/Buffs/IBuffTarget.cs
// PORT-NOTE: 上层有 13 个文件以 `import pvzengine.auras.IBuffTarget;` 引用本接口（其余 18 个使用
//   `pvzengine.buffs.IBuffTarget`）。本接口保留在 C# 命名空间对应的 pvzengine.buffs，
//   并在 pvzengine.auras 下提供同名 typedef 别名（见 pvzengine/auras/IBuffTarget.hx），两种 import 均可用。
package pvzengine.buffs;

import pvzengine.level.ILevelObject;

// PORT-NOTE: C# 中 BuffTargetExt 的扩展方法（AddBuff / HasBuff / RemoveBuffs / GetBuffs ...）在 `using PVZEngine`
//   下可对任意 IBuffTarget 以实例形式调用，既有上层调用点大量写作 `entity.AddBuff(def)`（约 180 处）。
//   Entity 自身未声明这些方法（Armor / LawnGrid / LevelEngine 各自标了 @:using），
//   这里按工程既有约定（同 IHasModel、ILevelSourceReference）在接口上统一标注，覆盖全部实现类。
@:using(pvzengine.buffs.BuffTargetExt)
interface IBuffTarget extends ILevelObject
{
	public var Buffs(get, never):IBuffList;
	public function GetBuffReference(buff:Buff):BuffReference;
}
