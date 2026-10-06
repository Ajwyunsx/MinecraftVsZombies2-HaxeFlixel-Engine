// Ported from: (alias) Assets/Scripts/Engine/Level/Entities/EntitySourceReference.cs
package pvzengine.damages;

// PORT-NOTE: 上层有 3 个文件以 `import pvzengine.damages.EntitySourceReference;` 引用本类，
//   而 C# 命名空间为 PVZEngine.Entities（实际定义在 pvzengine/entities/EntitySourceReference.hx，
//   另有 19 个文件以 `import pvzengine.entities.EntitySourceReference;` 引用）。别名使两种写法都可用。
typedef EntitySourceReference = pvzengine.entities.EntitySourceReference;
