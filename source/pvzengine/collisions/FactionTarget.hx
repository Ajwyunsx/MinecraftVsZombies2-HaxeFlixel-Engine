// Ported from: (alias) Assets/Scripts/Engine/Level/Entities/EngineEntityExt.cs (enum FactionTarget)
package pvzengine.collisions;

// PORT-NOTE: C# 中 FactionTarget 定义在 EngineEntityExt.cs、命名空间 PVZEngine.Entities
//   （实际枚举在 pvzengine/entities/FactionTarget.hx）。上层有 12 个文件以
//   `import pvzengine.collisions.FactionTarget;` 引用（如 mvz2/gamecontent/contrabands 的检测器），
//   故在此提供同名 typedef 别名。
typedef FactionTarget = pvzengine.entities.FactionTarget;
