// Ported from: (alias) Assets/Scripts/Engine/Level/Buffs/ModelInsertion.cs
// PORT-NOTE: 上层有 5 个文件以 `import pvzengine.models.ModelInsertion;` 引用本类
//   （见 mvz2/entities/EntityController.hx、mvz2/models/Model.hx 等；C# 命名空间为 PVZEngine.Buffs，
//   定义在 pvzengine/buffs/ModelInsertion.hx）。为使两种 import 均可用，此处提供同名 typedef 别名。
package pvzengine.models;

typedef ModelInsertion = pvzengine.buffs.ModelInsertion;
