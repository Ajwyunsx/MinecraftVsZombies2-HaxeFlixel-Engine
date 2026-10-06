// Ported from: Assets/Scripts/Engine/Level/Collisions/EntityCollision.cs
// PORT-NOTE: 别名模块。既有上层代码以 `import pvzengine.EntityColliderReference` 引用它
// （mvz2/collisions/UnityEntityCollider.hx），而 C# 中该类型的命名空间为 PVZEngine.Entities
// （→ pvzengine.entities.EntityColliderReference）。
// Haxe 的 import 必须精确对应模块文件，故在此提供 typedef 别名。
package pvzengine;

typedef EntityColliderReference = pvzengine.entities.EntityColliderReference;
