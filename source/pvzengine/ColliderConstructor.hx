// Ported from: Assets/Scripts/Engine/Level/Collisions/ColliderConstructor.cs
// PORT-NOTE: 别名模块。既有上层代码以 `import pvzengine.ColliderConstructor` 引用它
// （mvz2/collisions/UnityCollisionSystem.hx、mvz2/collisions/UnityCollisionEntity.hx），
// 而 C# 中该类型的命名空间是 PVZEngine.Collisions（→ pvzengine.collisions.ColliderConstructor）。
// Haxe 的 import 必须精确对应模块文件，故在此提供 typedef 别名。
package pvzengine;

typedef ColliderConstructor = pvzengine.collisions.ColliderConstructor;
