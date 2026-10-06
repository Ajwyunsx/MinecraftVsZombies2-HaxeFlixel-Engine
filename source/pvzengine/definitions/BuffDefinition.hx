// Ported from: (alias) Assets/Scripts/Engine/Level/Buffs/BuffDefinition.cs
// PORT-NOTE: 上层 194 个 Buff 定义类以 `import pvzengine.definitions.BuffDefinition;` 引用本类，
//   而 C# 命名空间为 PVZEngine.Buffs（实际定义在 pvzengine/buffs/BuffDefinition.hx）。
//   为使两种 import 均可用，此处提供同名 typedef 别名（跨包同名 typedef，Haxe 允许）。
package pvzengine.definitions;

typedef BuffDefinition = pvzengine.buffs.BuffDefinition;
