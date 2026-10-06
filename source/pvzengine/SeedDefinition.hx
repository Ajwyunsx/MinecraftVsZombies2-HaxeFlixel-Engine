// Ported from: Assets/Scripts/Engine/Level/SeedPacks/SeedDefinition.cs
// PORT-NOTE: C# 中 SeedDefinition 的命名空间为 PVZEngine.SeedPacks（实现见 pvzengine/seedpacks/SeedDefinition.hx），
//   但既有上层调用点还有 `import pvzengine.SeedDefinition;`（mvz2logic/callbacks/LogicCallbacks.hx、
//   mvz2logic/callbacks/LogicLevelCallbacks.hx），故提供根包的 typedef 别名。
package pvzengine;

typedef SeedDefinition = pvzengine.seedpacks.SeedDefinition;
