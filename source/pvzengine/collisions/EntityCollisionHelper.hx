// Ported from: (alias) Assets/Scripts/Engine/Level/Entities/EntityCollisionHelper.cs
package pvzengine.collisions;

// PORT-NOTE: 上层有 27 个文件以 `import pvzengine.collisions.EntityCollisionHelper;` 引用本类
//   （如 mvz2/collisions/UnityCollisionSystem.hx、mvz2/collisions/UnityCollisionHelper.hx），
//   而 C# 命名空间为 PVZEngine.Entities（实际定义在 pvzengine/entities/EntityCollisionHelper.hx，
//   另有 45 个文件以 `import pvzengine.entities.EntityCollisionHelper;` 引用）。别名使两种写法都可用。
typedef EntityCollisionHelper = pvzengine.entities.EntityCollisionHelper;
