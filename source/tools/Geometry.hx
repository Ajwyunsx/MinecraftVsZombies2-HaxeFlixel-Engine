// Ported from: Assets/Scripts/Engine/Tools/Geometry/Geometry.cs
package tools;

// PORT-NOTE: C# 命名空间为 `Tools.Geometrical`，正典实现位于 `tools.geometrical.Geometry`。
// 但既有上层调用点（如 mvz2/models/NightmareaperModel.hx）写的是 `import tools.Geometry;`，
// 故此处按「以既有调用点为准」提供同签名的别名模块。
typedef Geometry = tools.geometrical.Geometry;
