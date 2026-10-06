// Ported from: Assets/Scripts/Engine/Level/Armors/EngineArmorExt.cs
// PORT-NOTE: C# 的扩展方法 GetShellDefinition(this Armor) 移植为静态方法（首参数为 Armor）；
//   既有调用点 armor.GetShellDefinition() 由 Armor.hx 中的兼容转发方法满足。
//   GetModelKeyOfArmorSlot 在既有调用点中本就是静态调用（mvz2/models/MVZ2ModelExt.hx）。
package pvzengine.armors;

import pvzengine.NamespaceID;
import pvzengine.shells.ShellDefinition;
using pvzengine.ContentProviderHelper;

class EngineArmorExt
{
	public static function GetShellDefinition(armor:Armor):Null<ShellDefinition>
	{
		var shellID = armor.GetShellID();
		if (shellID == null)
			return null;
		return armor.Level.Content.GetShellDefinition(shellID);
	}
	public static function GetModelKeyOfArmorSlot(slot:NamespaceID):NamespaceID
	{
		return new NamespaceID(slot.SpaceName, 'armor.${slot.Path}');
	}
	// PORT-NOTE: 移植层补充（非 C# 原有 API）：C# 的 static Armor.Exists(Armor?) 在 Haxe 中与实例方法
	//   Exists() 同名冲突（见 Armor.hx 的说明），此处提供等价入口，便于整合阶段替换 Armor.Exists(...) 调用点。
	public static function Exists(armor:Null<Armor>):Bool
	{
		return Armor.ExistsArmor(armor);
	}
}
