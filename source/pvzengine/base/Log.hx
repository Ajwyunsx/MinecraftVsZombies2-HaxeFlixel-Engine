// Ported from: Assets/Scripts/Engine/Tools/Unity/Log.cs
package pvzengine.base;

// PORT-NOTE: C# 的 `Log` 位于全局命名空间（Tools 程序集）。既有上层调用点
// （mvz2/saves/UserDataPackMetadata.hx）写的是 `import pvzengine.base.Log;`，
// 故此处按「以既有调用点为准」提供别名模块。
typedef Log = pvzengine.Log;
