// Ported from: Assets/Scripts/Engine/Tools/RNG/RandomGenerator.cs
package pvzengine;

// PORT-NOTE: C# 命名空间为 `Tools`，正典实现位于 `tools.RandomGenerator`。
// 但既有上层调用点（mvz2/gamecontent/bosses/Frankenstein.hx 等）写的是
// `import pvzengine.RandomGenerator;`，故此处按「以既有调用点为准」提供别名模块。
typedef RandomGenerator = tools.RandomGenerator;
