// Ported from: Assets/Scripts/Engine/Level/SeedPacks/ConveyorSeedPack.cs
package pvzengine.seedpacks;

import haxe.Int64;
import pvzengine.buffs.Buff;
import pvzengine.buffs.BuffReference;
// PORT-NOTE: BuffReferenceConveyorSeedPack 与 SerializableConveyorSeedPack 均为同模块下的子类型，
//   按「模块.子类型」路径导入（Haxe 不会自动按包内子类型解析）。
import pvzengine.buffs.BuffReference.BuffReferenceConveyorSeedPack;
import pvzengine.seedpacks.SerializableSeedPack.SerializableConveyorSeedPack;
import pvzengine.level.LevelEngine;
using pvzengine.ContentProviderHelper;

class ConveyorSeedPack extends SeedPack
{
	public function new(level:LevelEngine, definition:SeedDefinition, id:Int64)
	{
		super(level, definition, id);
	}
	public function GetIndex():Int
	{
		return Level.GetConveyorSeedPackIndex(this);
	}
	public override function Exists():Bool
	{
		return GetIndex() >= 0;
	}
	public override function GetBuffReference(buff:Buff):BuffReference
	{
		return new BuffReferenceConveyorSeedPack(ID, buff.ID);
	}
	// #region 序列化
	public function ToSerializable():SerializableConveyorSeedPack
	{
		var seri = new SerializableConveyorSeedPack();
		SaveToSerializable(seri);
		return seri;
	}
	public static function CreateFromSerializable(seri:SerializableConveyorSeedPack, level:LevelEngine):Null<ConveyorSeedPack>
	{
		var definition = level.Content.GetSeedDefinition(seri.seedID);
		if (definition == null)
			return null;
		var seedPack = new ConveyorSeedPack(level, definition, seri.id);
		seedPack.InitFromSerializable(seri);
		return seedPack;
	}
	// #endregion
	// PORT-NOTE: C# 的 `override string ToString()` 在 Haxe 中写作不带 override 的 toString()（SeedPack 未声明 toString）。
	public function toString():String
	{
		return 'ConveyorSeedPack_${Definition}';
	}
}
