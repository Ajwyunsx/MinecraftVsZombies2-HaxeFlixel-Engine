// Ported from: (alias) Assets/Scripts/Engine/Level/Damage/ArmorDamageResult.cs
// PORT-NOTE: 上层既有调用点同时使用 `pvzengine.damages.ArmorDamageResult`（C# 命名空间 PVZEngine.Damages）
//   与 `pvzengine.armors.ArmorDamageResult`（C# 中该类型被 Armor 命名空间的文件引用，见 ArmorDestroyInfo/Source）。
//   为使 armors 路径也可解析，此处提供同名 typedef 别名（实际定义在 pvzengine/damages/ArmorDamageResult.hx）。
package pvzengine.armors;

typedef ArmorDamageResult = pvzengine.damages.ArmorDamageResult;
