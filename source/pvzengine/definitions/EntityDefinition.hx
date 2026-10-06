// Ported from: (alias) Assets/Scripts/Engine/Level/Entities/EntityDefinition.cs
package pvzengine.definitions;

// PORT-NOTE: 上层有 5 个文件以 `import pvzengine.definitions.EntityDefinition;` 引用本类，
//   而 C# 命名空间为 PVZEngine.Entities（实际定义在 pvzengine/entities/EntityDefinition.hx）。
//   主流写法是 `import pvzengine.entities.EntityDefinition;`（26 处），两种 import 均通过别名支持。
typedef EntityDefinition = pvzengine.entities.EntityDefinition;
