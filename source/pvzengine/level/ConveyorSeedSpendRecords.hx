// Ported from: Assets/Scripts/Engine/Level/Level/ConveyorSeedSpendRecords.cs
package pvzengine.level;

import pvzengine.NamespaceID;
// PORT-NOTE: SerializableConveyorSeedSendRecordEntry 与 SerializableConveyorSeedSpendRecords 同处模块
// pvzengine.level.SerializableConveyorSeedSpendRecords，跨模块引用须按 `模块.子类型` 形式 import。
import pvzengine.level.SerializableConveyorSeedSpendRecords.SerializableConveyorSeedSendRecordEntry;

class ConveyorSeedSpendRecords
{
	public function new() {}
	public function SetSpendValue(id:NamespaceID, value:Int):Void
	{
		var entry = Lambda.find(entries, e -> e.id == id);
		if (entry == null)
		{
			entry = new ConveyorSeedSendRecordEntry(id);
			entry.spend = value;
			entries.push(entry);
		}
		else
		{
			entry.spend = value;
		}
	}
	public function AddSpendValue(id:NamespaceID, value:Int):Void
	{
		SetSpendValue(id, GetSpendValue(id) + value);
	}
	public function GetSpendValue(id:NamespaceID):Int
	{
		var entry = Lambda.find(entries, e -> e.id == id);
		return entry != null ? entry.spend : 0;
	}
	public function SetSeedCountInDiscardPile(id:NamespaceID, value:Int):Void
	{
		var entry = Lambda.find(entries, e -> e.id == id);
		if (entry == null)
		{
			entry = new ConveyorSeedSendRecordEntry(id);
			entry.discardCount = value;
			entries.push(entry);
		}
		else
		{
			entry.discardCount = value;
		}
	}
	public function AddToDiscardPile(id:NamespaceID, value:Int):Void
	{
		SetSeedCountInDiscardPile(id, GetSeedCountInDiscardPile(id) + value);
	}
	public function GetSeedCountInDiscardPile(id:NamespaceID):Int
	{
		var entry = Lambda.find(entries, e -> e.id == id);
		return entry != null ? entry.discardCount : 0;
	}
	public function ToSerializable():SerializableConveyorSeedSpendRecords
	{
		var seri = new SerializableConveyorSeedSpendRecords();
		seri.entries = [for (e in entries) e.ToSerializable()];
		return seri;
	}
	public static function ToDeserialized(seri:Null<SerializableConveyorSeedSpendRecords>):ConveyorSeedSpendRecords
	{
		var entries:Array<ConveyorSeedSendRecordEntry> = [];
		if (seri != null && seri.entries != null)
		{
			for (seriEntry in seri.entries)
			{
				if (seriEntry == null)
					continue;
				var entry = ConveyorSeedSendRecordEntry.ToDeserialized(seriEntry);
				if (entry == null)
					continue;
				entries.push(entry);
			}
		}
		var records = new ConveyorSeedSpendRecords();
		records.entries = entries;
		return records;
	}
	// PORT-NOTE: C# 为 private 字段，但 ToDeserialized 是静态方法、Haxe 静态方法无法访问实例私有字段，
	// 故改为 private var 并由 static 方法在本模块内直接赋值（Haxe 允许模块内访问私有字段）。
	private var entries:Array<ConveyorSeedSendRecordEntry> = [];
}

class ConveyorSeedSendRecordEntry
{
	public function new(id:NamespaceID)
	{
		this.id = id;
	}
	public function ToSerializable():SerializableConveyorSeedSendRecordEntry
	{
		var seri = new SerializableConveyorSeedSendRecordEntry();
		seri.id = id;
		seri.spend = spend;
		seri.discardCount = discardCount;
		return seri;
	}
	public static function ToDeserialized(seri:Null<SerializableConveyorSeedSendRecordEntry>):Null<ConveyorSeedSendRecordEntry>
	{
		if (seri == null || !NamespaceID.IsValid(seri.id))
			return null;
		var entry = new ConveyorSeedSendRecordEntry(seri.id);
		entry.spend = seri.spend;
		entry.discardCount = seri.discardCount;
		return entry;
	}
	public var id:NamespaceID;
	public var spend:Int;
	public var discardCount:Int;
}
