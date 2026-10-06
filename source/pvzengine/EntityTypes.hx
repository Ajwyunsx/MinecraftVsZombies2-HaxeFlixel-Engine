// Ported from: Assets/Scripts/Engine/Level/Entities/EntityTypes.cs
package pvzengine;

// PORT-NOTE: C# 中 EntityTypes 位于 namespace PVZEngine.Entities（规范位置为 pvzengine.entities.EntityTypes）。
// 既有移植代码同时存在 `import pvzengine.EntityTypes;` 与 `import pvzengine.entities.EntityTypes;` 两种写法，
// 故在根包保留同名的 typedef 别名以兼容两种 import（PORTING.md：以既有调用点为准）。
typedef EntityTypes = pvzengine.entities.EntityTypes;
