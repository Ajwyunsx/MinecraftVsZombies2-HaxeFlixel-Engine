// Ported from: (alias) Assets/Scripts/Engine/Level/Entities/EntityBehaviourDefinition.cs
package pvzengine.definitions;

// PORT-NOTE: 上层有 129 个文件以 `import pvzengine.definitions.EntityBehaviourDefinition;` 引用本类
//   （如 mvz2/gamecontent/carts/CartBehaviour.hx、mvz2/gamecontent/projectiles/ProjectileBehaviour.hx），
//   而 C# 命名空间为 PVZEngine.Entities（实际定义在 pvzengine/entities/EntityBehaviourDefinition.hx）。
//   为使两种 import 均可用，此处提供同名 typedef 别名（与 pvzengine/definitions/ArmorBehaviourDefinition.hx 的做法一致）。
typedef EntityBehaviourDefinition = pvzengine.entities.EntityBehaviourDefinition;
