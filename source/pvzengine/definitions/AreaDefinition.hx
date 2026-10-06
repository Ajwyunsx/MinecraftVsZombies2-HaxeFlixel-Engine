// Ported from: Assets/Scripts/Engine/Level/Level/AreaDefinition.cs
// PORT-NOTE: C# 中 AreaDefinition 的命名空间为 PVZEngine.Level（实现见 pvzengine/level/AreaDefinition.hx），
//   但既有上层调用点有两种 import：`pvzengine.level.AreaDefinition`（1 处）与
//   `pvzengine.definitions.AreaDefinition`（8 处，mvz2/gamecontent/areas/*.hx）。
//   两种写法必须指向同一个类型（子类通过 extends 继承），故在此提供 typedef 别名（同 GridDefinition/BuffDefinition 的既有做法）。
package pvzengine.definitions;

typedef AreaDefinition = pvzengine.level.AreaDefinition;
