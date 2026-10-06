// Ported from: Assets/Scripts/Engine/Level/Entities/EntityID.cs
package pvzengine;

// PORT-NOTE: C# 中 EntityID 位于 namespace PVZEngine.Entities（规范位置为 pvzengine.entities.EntityID）。
// 既有移植代码同时存在 `import pvzengine.EntityID;` 与 `import pvzengine.entities.EntityID;` 两种写法，
// 故在根包保留同名 typedef 别名以兼容两种 import。
typedef EntityID = pvzengine.entities.EntityID;
