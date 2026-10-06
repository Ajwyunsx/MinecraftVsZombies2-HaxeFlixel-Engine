// Ported from: Assets/Scripts/Engine/Base/Properties/PropertyKey.cs
package pvzengine.properties;

// PORT-NOTE: C# 中 PropertyKey<T> 位于命名空间 `PVZEngine`，本文件只是别名模块：
// 既有移植代码（mvz2/globalgames/GlobalGame.hx、mvz2/map/MapElement.hx）以
// `import pvzengine.properties.PropertyKey;` 引用它。真实定义在 pvzengine/PropertyKey.hx。
typedef PropertyKey<T> = pvzengine.PropertyKey<T>;
