// Ported from: (no C# source) — Assets/Scripts/Engine/Level/Buffs/BuffTargetExt.cs 的移植层别名模块
// PORT-NOTE: 上层移植代码中有 70 个文件写着 `import pvzengine.buffs.BuffExt;`（但没有任何 `BuffExt.` 调用点，
//   C# 原工程也不存在 BuffExt 类）。为使这些 import 能解析（Haxe 要求 import 的类型必须存在，即使未被使用），
//   在此提供同名模块，并把 BuffTargetExt 的静态方法原样转发，使其也可作为 `using pvzengine.buffs.BuffExt;` 使用。
package pvzengine.buffs;

import haxe.Int64;

class BuffExt
{
	private function new() {}

	public static function NewBuff(target:IBuffTarget, key:Dynamic):Buff
	{
		return BuffTargetExt.NewBuff(target, key);
	}
	public static function AddBuff(target:IBuffTarget, key:Dynamic):Buff
	{
		return BuffTargetExt.AddBuff(target, key);
	}
	public static function RemoveBuff(target:IBuffTarget, buff:Buff):Bool
	{
		return BuffTargetExt.RemoveBuff(target, buff);
	}
	public static function RemoveBuffs(target:IBuffTarget, key:Dynamic):Int
	{
		return BuffTargetExt.RemoveBuffs(target, key);
	}
	public static function HasBuff(target:IBuffTarget, key:Dynamic):Bool
	{
		return BuffTargetExt.HasBuff(target, key);
	}
	public static function GetFirstBuff(target:IBuffTarget, key:Dynamic):Null<Buff>
	{
		return BuffTargetExt.GetFirstBuff(target, key);
	}
	public static function GetBuffs(target:IBuffTarget, key:Dynamic):Array<Buff>
	{
		return BuffTargetExt.GetBuffs(target, key);
	}
	public static function GetBuffsNonAlloc(target:IBuffTarget, key:Dynamic, results:Array<Buff>):Void
	{
		BuffTargetExt.GetBuffsNonAlloc(target, key, results);
	}
	public static function GetBuffCount(target:IBuffTarget, key:Dynamic):Int
	{
		return BuffTargetExt.GetBuffCount(target, key);
	}
	public static function GetBuff(target:IBuffTarget, id:Int64):Null<Buff>
	{
		return BuffTargetExt.GetBuff(target, id);
	}
	public static function GetAllBuffs(target:IBuffTarget, results:Array<Buff>):Void
	{
		BuffTargetExt.GetAllBuffs(target, results);
	}
	public static function GetModelInsertions(target:IBuffTarget):Array<ModelInsertion>
	{
		return BuffTargetExt.GetModelInsertions(target);
	}
}
