// Ported from: Assets/Scripts/Engine/Level/SeedPacks/ClassicSeedPack.cs
package pvzengine.seedpacks;

import haxe.Int64;
import pvzengine.buffs.Buff;
import pvzengine.buffs.BuffReference;
// PORT-NOTE: BuffReferenceClassicSeedPack 与 SerializableClassicSeedPack 均为同模块下的子类型，
//   按「模块.子类型」路径导入（Haxe 不会自动按包内子类型解析）。
import pvzengine.buffs.BuffReference.BuffReferenceClassicSeedPack;
import pvzengine.seedpacks.SerializableSeedPack.SerializableClassicSeedPack;
import pvzengine.level.LevelEngine;
import unity.Mathf;
using pvzengine.ContentProviderHelper;

class ClassicSeedPack extends SeedPack
{
	public function new(level:LevelEngine, definition:SeedDefinition, id:Int64)
	{
		super(level, definition, id);
	}
	public function GetIndex():Int
	{
		// PORT-NOTE: C# 的 GetSeedPackIndex(ClassicSeedPack) 与 GetSeedPackIndex(NamespaceID) 为重载，
		// 移植层把前者命名为 LevelEngine.GetSeedPackIndexBySeedPack（见 pvzengine/level/LevelEngine.hx）。
		return Level.GetSeedPackIndexBySeedPack(this);
	}
	public override function Exists():Bool
	{
		return GetIndex() >= 0;
	}
	public override function GetBuffReference(buff:Buff):BuffReference
	{
		return new BuffReferenceClassicSeedPack(ID, buff.ID);
	}
	// PORT-NOTE: C# 的 protected override 在 Haxe 中改用 override private（Haxe 无 protected）。
	override private function OnUpdate(rechargeSpeed:Float):Void
	{
		super.OnUpdate(rechargeSpeed);
		if (!this.IsCharged())
		{
			var recharge = this.GetRecharge();
			recharge += rechargeSpeed * this.GetRechargeSpeed();
			recharge = Mathf.Min(this.GetMaxRecharge(), recharge);
			this.SetRecharge(recharge);
		}
	}
	// #region 序列化
	public function ToSerializable():SerializableClassicSeedPack
	{
		var seri = new SerializableClassicSeedPack();
		SaveToSerializable(seri);
		return seri;
	}
	public static function CreateFromSerializable(seri:SerializableClassicSeedPack, level:LevelEngine):Null<ClassicSeedPack>
	{
		var definition = level.Content.GetSeedDefinition(seri.seedID);
		if (definition == null)
			return null;
		var seedPack = new ClassicSeedPack(level, definition, seri.id);
		seedPack.InitFromSerializable(seri);
		return seedPack;
	}
	// #endregion
	// PORT-NOTE: C# 的 `override string ToString()` 在 Haxe 中写作不带 override 的 toString()（SeedPack 未声明 toString）。
	public function toString():String
	{
		return 'ClassicSeedPack_${Definition}';
	}
}
