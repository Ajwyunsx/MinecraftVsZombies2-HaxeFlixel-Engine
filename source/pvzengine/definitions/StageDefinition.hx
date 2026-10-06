// Ported from: Assets/Scripts/Engine/Level/Level/StageDefinition.cs
// PORT-NOTE: C# 中 StageDefinition 的命名空间为 PVZEngine.Level（实现见 pvzengine/level/StageDefinition.hx），
//   但既有上层调用点有两种 import：`pvzengine.level.StageDefinition`（42 处）与
//   `pvzengine.definitions.StageDefinition`（16 处，mvz2/gamecontent/stages/*.hx）。
//   两种写法必须指向同一个类型（子类通过 extends 继承），故在此提供 typedef 别名（同 GridDefinition/BuffDefinition 的既有做法）。
package pvzengine.definitions;

typedef StageDefinition = pvzengine.level.StageDefinition;
