// Ported from: Assets/Scripts/Engine/Level/SeedPacks/RechargeDefinition.cs
// PORT-NOTE: C# 中 RechargeDefinition 的命名空间为 PVZEngine.SeedPacks（实现见 pvzengine/seedpacks/RechargeDefinition.hx），
//   但既有上层调用点有两种 import：`pvzengine.seedpacks.RechargeDefinition` 与
//   `pvzengine.definitions.RechargeDefinition`（4 处，mvz2/gamecontent/recharges/*.hx）。
//   两种写法必须指向同一个类型（子类通过 extends 继承），故在此提供 typedef 别名。
package pvzengine.definitions;

typedef RechargeDefinition = pvzengine.seedpacks.RechargeDefinition;
