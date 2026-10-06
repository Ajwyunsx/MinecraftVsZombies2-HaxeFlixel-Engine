// Ported from: Assets/Scripts/Engine/Level/SeedPacks/SeedPack.cs
// PORT-NOTE: C# 中 SeedPack 的命名空间为 PVZEngine.SeedPacks（实现见 pvzengine/seedpacks/SeedPack.hx），
//   但既有上层调用点还有 `import pvzengine.SeedPack;`（mvz2/gamecontent/stages/IZombieBehaviour.hx、
//   mvz2logic/callbacks/LogicLevelCallbacks.hx），故提供根包的 typedef 别名。
package pvzengine;

typedef SeedPack = pvzengine.seedpacks.SeedPack;
