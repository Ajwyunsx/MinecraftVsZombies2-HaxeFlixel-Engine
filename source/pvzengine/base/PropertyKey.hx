// Ported from: Assets/Scripts/Engine/Base/Properties/PropertyKey.cs
package pvzengine.base;

// PORT-NOTE: C# 中 PropertyKey<T> 位于命名空间 `PVZEngine`（而非 PVZEngine.Base），
// 本文件只是别名模块：既有移植代码（mvz2/gamecontent/bosses/Nightmareaper.hx）以
// `import pvzengine.base.PropertyKey;` 引用它。真实定义在 pvzengine/PropertyKey.hx。
typedef PropertyKey<T> = pvzengine.PropertyKey<T>;
