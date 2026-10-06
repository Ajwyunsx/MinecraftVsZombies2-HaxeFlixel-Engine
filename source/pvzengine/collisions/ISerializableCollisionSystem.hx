// Ported from: Assets/Scripts/Engine/Level/Collisions/Level/ISerializableCollisionSystem.cs
// PORT-NOTE: 别名模块。既有上层代码以 `import pvzengine.collisions.ISerializableCollisionSystem` 引用它
// （mvz2/collisions/UnityCollisionSystem.hx），而 C# 中该接口的命名空间为 PVZEngine.Collisions.Level
// （→ pvzengine.collisions.level.ISerializableCollisionSystem）。
// Haxe 的 import 必须精确对应模块文件，故在此提供 typedef 别名。
package pvzengine.collisions;

typedef ISerializableCollisionSystem = pvzengine.collisions.level.ISerializableCollisionSystem;
