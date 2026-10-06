// Ported from: (alias) Assets/Scripts/Engine/Level/Damage/ArmorDestroyInfo.cs
// PORT-NOTE: 上层既有调用点同时使用 `import pvzengine.damages.ArmorDestroyInfo;`（C# 命名空间 PVZEngine.Damages，
//   实际定义在 pvzengine/damages/ArmorDestroyInfo.hx）与 `import pvzengine.armors.ArmorDestroyInfo;`
//   （见 mvz2/gamecontent/armors/DestroyAfterHalfHP.hx）。为使 armors 路径也可解析，此处提供同名 typedef 别名。
package pvzengine.armors;

typedef ArmorDestroyInfo = pvzengine.damages.ArmorDestroyInfo;
