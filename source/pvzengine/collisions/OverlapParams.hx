// Ported from: Assets/Scripts/Engine/Level/Collisions/Level/ICollisionSystem.cs
// PORT-NOTE: 别名模块。既有上层代码以 `import pvzengine.collisions.OverlapParams` 引用它
// （mvz2/gamecontent/contraptions/TeslaCoil.hx、mvz2/vanilla/level/VanillaLevelExt.hx），
// 而 C# 中 OverlapParams 的命名空间为 PVZEngine.Collisions.Level
// （→ pvzengine.collisions.level.OverlapParams）。
// Haxe 的 import 必须精确对应模块文件，故在此提供 typedef 别名。
package pvzengine.collisions;

typedef OverlapParams = pvzengine.collisions.level.OverlapParams;
