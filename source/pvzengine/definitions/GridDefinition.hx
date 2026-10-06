// Ported from: Assets/Scripts/Engine/Level/Grids/GridDefinition.cs
// PORT-NOTE: C# 中 GridDefinition 的命名空间为 PVZEngine.Grids（实现见 pvzengine/grids/GridDefinition.hx），
//   但既有上层调用点有两种 import：`pvzengine.grids.GridDefinition`（2 处）与
//   `pvzengine.definitions.GridDefinition`（7 处，mvz2/gamecontent/grids/*.hx）。
//   两种写法必须指向同一个类型（子类通过 extends 继承），故在此提供 typedef 别名。
package pvzengine.definitions;

typedef GridDefinition = pvzengine.grids.GridDefinition;
