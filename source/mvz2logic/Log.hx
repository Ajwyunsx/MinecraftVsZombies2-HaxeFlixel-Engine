// Ported from: Assets/Scripts/Engine/Tools/Unity/Log.cs
package mvz2logic;

// PORT-NOTE: C# 的 `Log` 位于全局命名空间（Tools 程序集），MVZ2Logic 中并无同名类型。
// 既有上层调用点（mvz2/modding/ModLoader.hx、mvz2/io/XMLHelper.hx 等）写的是
// `import mvz2logic.Log;`，故此处按「以既有调用点为准」提供别名模块。
typedef Log = pvzengine.Log;
