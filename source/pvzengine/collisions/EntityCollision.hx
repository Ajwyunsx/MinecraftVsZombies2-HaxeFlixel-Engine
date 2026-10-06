// Ported from: Assets/Scripts/Engine/Level/Collisions/EntityCollision.cs
// PORT-NOTE: 别名模块。既有上层代码以 `import pvzengine.collisions.EntityCollision` 引用它
// （mvz2/collisions/UnityCollisionEntity.hx、UnityCollisionSystem.hx、UnityEntityCollider.hx），
// 而 C# 中 EntityCollision 的命名空间为 PVZEngine.Entities
// （→ pvzengine.entities.EntityCollision，见 pvzengine/entities/EntityCollision.hx）。
// Haxe 的 import 必须精确对应模块文件，故在此提供 typedef 别名。
package pvzengine.collisions;

typedef EntityCollision = pvzengine.entities.EntityCollision;
