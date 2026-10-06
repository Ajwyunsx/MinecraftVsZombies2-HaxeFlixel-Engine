// Ported from: Assets/Scripts/Engine/Level/Buffs/BuffTargetExt.cs
// PORT-NOTE: C# 中这些方法为 IBuffTarget 的扩展方法，既有调用点通过 `using pvzengine.buffs.BuffTargetExt;`
//   以实例形式调用（entity.AddBuff(X) / level.GetBuffs(X) / armor.RemoveBuffs(X) 等）。
// PORT-NOTE: C# 的泛型重载（AddBuff<T>()、HasBuff<T>()、GetBuffs<T>() 等）在 Haxe 调用点无法书写类型参数，
//   因此与既有调用点一致，改为传入类对象（Class<T>）；同一方法名还需兼容 NamespaceID / BuffDefinition / Buff 实参，
//   故形参统一为 Dynamic，在运行期分派。
// PORT-NOTE: C# AddBuff(this IBuffTarget, Buff) 返回 bool，其余重载返回 Buff。既有调用点均把返回值当 Buff 使用
//   （var buff = entity.AddBuff(...)），故此处统一返回 Buff。
package pvzengine.buffs;

import haxe.Int64;
import pvzengine.NamespaceID;
import pvzengine.level.LevelEngine;

class BuffTargetExt
{
	public static function NewBuff(target:IBuffTarget, key:Dynamic):Buff
	{
		var level = target.GetLevel();
		var definition:BuffDefinition;
		if (Std.isOfType(key, BuffDefinition))
		{
			definition = cast key;
		}
		else if (Std.isOfType(key, String))
		{
			// PORT-NOTE: NamespaceID 是 abstract，不能作为运行期值参与 Std.isOfType，
			//   故用 Std.isOfType(key, String) 判断「key 是 NamespaceID」（底层即 String，语义等价）。
			definition = ContentProviderHelper.GetBuffDefinition(level.Content, cast key);
		}
		else
		{
			// key 为 Class<T>（C# 的 AddBuff<T>() 形式，既有调用点 game.GetBuffDefinition(DebugGodmodeBuff)），
			// 对应 ContentProviderHelper 的泛型版 GetBuffDefinitionByType。
			// PORT-NOTE: C# 的 `level.Content.GetBuffDefinition(key)` 扩展方法形式在 Haxe 中不可用（IGameContent 无该方法），
			//   改为显式静态调用。
			var cls:Class<BuffDefinition> = cast key;
			definition = ContentProviderHelper.GetBuffDefinitionByType(level.Content, cls);
		}
		// PORT-NOTE: C# 经 LevelEngine.CreateBuff(BuffDefinition, long) 创建，而该重载实现仅为 new Buff(this, def, id)，
		//   此处直接构造，避免依赖 LevelEngine 的重载命名。
		return new Buff(level, definition, target.Buffs.AllocBuffID());
	}

	public static function AddBuff(target:IBuffTarget, key:Dynamic):Buff
	{
		if (Std.isOfType(key, Buff))
		{
			var buff:Buff = cast key;
			target.Buffs.AddBuff(buff, target);
			return buff;
		}
		var newBuff = NewBuff(target, key);
		target.Buffs.AddBuff(newBuff, target);
		return newBuff;
	}

	public static function RemoveBuff(target:IBuffTarget, buff:Buff):Bool
	{
		return target.Buffs.RemoveBuff(buff);
	}
	public static function RemoveBuffs(target:IBuffTarget, key:Dynamic):Int
	{
		// key 可为 Array<Buff> / Class<T> / BuffDefinition / NamespaceID，由 BuffList.RemoveBuffs 分派。
		return target.Buffs.RemoveBuffs(key);
	}

	public static function HasBuff(target:IBuffTarget, key:Dynamic):Bool
	{
		return target.Buffs.HasBuff(key);
	}
	public static function GetFirstBuff(target:IBuffTarget, key:Dynamic):Null<Buff>
	{
		return target.Buffs.GetFirstBuff(key);
	}
	public static function GetBuffs(target:IBuffTarget, key:Dynamic):Array<Buff>
	{
		return target.Buffs.GetBuffs(key);
	}
	// PORT-NOTE: C# 另有 GetBuffs<T>(List<Buff> results) 重载（Haxe 不支持重载），移植层命名为 GetBuffsNonAlloc；
	//   既有调用点未使用该形式（一律使用返回数组的 GetBuffs）。
	public static function GetBuffsNonAlloc(target:IBuffTarget, key:Dynamic, results:Array<Buff>):Void
	{
		target.Buffs.GetBuffsNonAlloc(key, results);
	}
	public static function GetBuffCount(target:IBuffTarget, key:Dynamic):Int
	{
		return target.Buffs.GetBuffCount(key);
	}
	public static function GetBuff(target:IBuffTarget, id:Int64):Null<Buff>
	{
		return target.Buffs.GetBuff(id);
	}
	public static function GetAllBuffs(target:IBuffTarget, results:Array<Buff>):Void
	{
		target.Buffs.GetAllBuffs(results);
	}
	public static function GetModelInsertions(target:IBuffTarget):Array<ModelInsertion>
	{
		return target.Buffs.GetModelInsertions();
	}

	// PORT-NOTE: 移植层辅助方法（非 C# 原有 API）：判断 BuffDefinition 是否为某个类对象（Class<T>）或其子类的实例。
	//   C# 中由 `buff.Definition is T` / Where(b => b.Definition is T) 表达。BuffList 的 Dynamic 分派同样使用本方法。
	public static function IsDefinitionOfType(definition:Dynamic, key:Dynamic):Bool
	{
		if (definition == null || key == null)
			return false;
		var keyName = Type.getClassName(cast key);
		if (keyName == null)
			return false;
		var cls = Type.getClass(definition);
		while (cls != null)
		{
			if (Type.getClassName(cls) == keyName)
				return true;
			cls = Type.getSuperClass(cls);
		}
		return false;
	}
}
