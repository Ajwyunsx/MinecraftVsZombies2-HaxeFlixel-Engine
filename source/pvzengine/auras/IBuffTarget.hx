// Ported from: (alias) Assets/Scripts/Engine/Level/Buffs/IBuffTarget.cs
// PORT-NOTE: 上层有 13 个文件以 `import pvzengine.auras.IBuffTarget;` 引用本接口
//   （其余文件使用 `pvzengine.buffs.IBuffTarget`，定义在 pvzengine/buffs/IBuffTarget.hx）。
//   为使两种 import 均可用，此处提供同名 typedef 别名（跨包同名 typedef，Haxe 允许）。
package pvzengine.auras;

typedef IBuffTarget = pvzengine.buffs.IBuffTarget;
