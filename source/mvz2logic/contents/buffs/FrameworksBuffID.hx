// Ported from: Assets/Scripts/Logic/Contents/Buffs/FrameworksBuffID.cs
// PORT-NOTE: C# 用嵌套静态类 FrameworksBuffID.Entity / FrameworksBuffID.Enemy 组织常量，
// Haxe 不支持嵌套类，改为同模块的子类型（引用形式仍为 FrameworksBuffID.Entity.xxx）。
// FrameworksBuffNames 被拆到同目录的 FrameworksBuffNames.hx（同名子类型不能在一个模块内重复）。
package mvz2logic.contents.buffs;

import mvz2logic.contents.buffs.FrameworksBuffNames;
import mvz2logic.Global;
import pvzengine.NamespaceID;

class FrameworksBuffID
{
	// PORT-NOTE: 同模块的 Entity/Enemy 子类型需要访问该工厂方法，C# 中为嵌套类可访问，Haxe 子类型不可访问 private，故改为 public。
	public static function Get(name:String):NamespaceID
	{
		return new NamespaceID(Global.BuiltinNamespace, name);
	}
}

class Entity
{
	// Core
	// PORT-NOTE: C# 的 static readonly 字段是首次使用时才初始化；hxcpp 会在 main() 之前执行全部静态初始化
	// （__boot_all()），那时 Global.Game / MainManager.Instance 仍为 null，直接求值会段错误。
	// 此处改为惰性 getter（结果缓存一次，等价于 C# 的 readonly static），还原 C# 语义。
	public static var damageColor(get, never):NamespaceID;
	private static var _damageColor:NamespaceID;
	static function get_damageColor():NamespaceID
	{
		if (_damageColor == null) _damageColor = FrameworksBuffID.Get(FrameworksBuffNames.Entity_damageColor);
		return _damageColor;
	}
}

class Enemy
{
	public static var beingRiden(get, never):NamespaceID;
	private static var _beingRiden:NamespaceID;
	static function get_beingRiden():NamespaceID
	{
		if (_beingRiden == null) _beingRiden = FrameworksBuffID.Get(FrameworksBuffNames.Enemy_beingRiden);
		return _beingRiden;
	}
	public static var ridingPassenger(get, never):NamespaceID;
	private static var _ridingPassenger:NamespaceID;
	static function get_ridingPassenger():NamespaceID
	{
		if (_ridingPassenger == null) _ridingPassenger = FrameworksBuffID.Get(FrameworksBuffNames.Enemy_ridingPassenger);
		return _ridingPassenger;
	}
}
