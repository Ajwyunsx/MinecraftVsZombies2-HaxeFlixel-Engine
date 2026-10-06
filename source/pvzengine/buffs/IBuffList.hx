// Ported from: Assets/Scripts/Engine/Level/Buffs/IBuffList.cs
// PORT-NOTE: C# 的泛型/重载方法（GetBuffs<T>()、GetBuffs(BuffDefinition)、GetBuffs(NamespaceID) 等）在
//   Haxe 中统一为一个方法名 + Dynamic 形参（实参可为 Class<T> / BuffDefinition / NamespaceID / Buff），
//   具体分派见 BuffList.hx。其它签名与 C# 保持一致。
package pvzengine.buffs;

import haxe.Int64;
import pvzengine.modifiers.IModifierProvider;

interface IBuffList extends IModifierProvider
{
	public function AllocBuffID():Int64;

	public function AddBuff(buff:Buff, target:IBuffTarget):Bool;

	public function RemoveBuff(buff:Buff):Bool;

	public function RemoveBuffs(key:Dynamic):Int;

	public function HasBuff(key:Dynamic):Bool;

	public function GetFirstBuff(key:Dynamic):Null<Buff>;

	public function GetBuffs(key:Dynamic):Array<Buff>;

	public function GetBuffCount(key:Dynamic):Int;
	public function GetBuffsNonAlloc(key:Dynamic, results:Array<Buff>):Void;

	public function GetBuff(id:Int64):Null<Buff>;

	public function GetAllBuffs(results:Array<Buff>):Void;

	public function GetModelInsertions():Array<ModelInsertion>;
}
