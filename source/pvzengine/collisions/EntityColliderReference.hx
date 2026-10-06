// Ported from: Assets/Scripts/Engine/Level/Collisions/EntityCollision.cs
// PORT-NOTE: 别名模块。既有上层代码以 `import pvzengine.collisions.EntityColliderReference` 引用它
// （mvz2/vanilla/projectiles/VanillaProjectileProps.hx），而 C# 中 EntityColliderReference 的命名空间为
// PVZEngine.Entities（→ pvzengine.entities.EntityColliderReference）。
// Haxe 的 import 必须精确对应模块文件，故在此提供 typedef 别名。
package pvzengine.collisions;

typedef EntityColliderReference = pvzengine.entities.EntityColliderReference;
