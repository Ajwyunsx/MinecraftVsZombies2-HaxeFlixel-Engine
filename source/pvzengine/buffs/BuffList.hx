// Ported from: Assets/Scripts/Engine/Level/Buffs/BuffList.cs
// PORT-NOTE: C# 大量使用泛型重载（GetBuffs<T>() / GetBuffs(BuffDefinition) / GetBuffs(NamespaceID) 等），
//   Haxe 不支持重载也不支持在调用点书写显式类型参数，因此按既有调用点（BuffTargetExt 的 using 调用）
//   统一为「一个方法名 + Dynamic 形参」，参数可为 Class<T>（BuffDefinition 子类）、BuffDefinition 实例、
//   NamespaceID 或 Buff 实例，运行期分派。返回值与 C# 对应重载保持一致。
// PORT-NOTE: C# event Action<T>? → FlxTypedSignal<T->Void>，+= / -= 改为 add / remove，Invoke 改为 dispatch。
// PORT-NOTE: NamespaceID 是 abstract（abstract 不能作为运行期值），故「key 是否为 NamespaceID」的判断
//   改为 `Std.isOfType(key, String)`（NamespaceID 底层就是 String，语义等价，见 NamespaceID.hx 的说明）。
package pvzengine.buffs;

import flixel.util.FlxSignal.FlxTypedSignal;
import haxe.Int64;
import pvzengine.IPropertyKey;
import pvzengine.NamespaceID;
import pvzengine.level.LevelEngine;
import pvzengine.modifiers.IModifierProvider;
import pvzengine.modifiers.ModifierLibrary;
import pvzengine.modifiers.ModifierSourceItem;
import pvzengine.modifiers.PropertyModifier;

class BuffList implements IBuffList
{
	public function new()
	{
		modifierLibrary = new ModifierLibrary();
		modifierLibrary.OnModifiedPropertyNeedsUpdate.add(OnModifiedPropertyNeedsUpdateCallback);
	}

	// #region 增益操作
	public function AllocBuffID():Int64
	{
		return currentBuffID++;
	}
	public function AddBuff(buff:Buff, target:IBuffTarget):Bool
	{
		if (AddBuffImplement(buff))
		{
			buff.AddToTarget(target);
			return true;
		}
		return false;
	}

	// #region 移除
	public function RemoveBuff(buff:Buff):Bool
	{
		return RemoveBuffImplement(buff);
	}
	// #endregion

	// #region 移除多个
	// C#: RemoveBuffs(BuffDefinition) / RemoveBuffs(IEnumerable<Buff>) / RemoveBuffs(NamespaceID) / RemoveBuffs<T>()
	public function RemoveBuffs(key:Dynamic):Int
	{
		if (key == null)
			return 0;

		if (Std.isOfType(key, Array))
		{
			// C#: RemoveBuffs(IEnumerable<Buff> buffs)
			var count = 0;
			var buffsToRemove:Array<Buff> = cast key;
			for (buff in buffsToRemove)
			{
				count += RemoveBuffImplement(buff) ? 1 : 0;
			}
			return count;
		}
		else if (Std.isOfType(key, String))
		{
			// C#: RemoveBuffs(NamespaceID id)
			var id:NamespaceID = cast key;
			if (!NamespaceID.IsValid(id))
				return 0;
			var count = 0;
			var i = buffs.length - 1;
			while (i >= 0)
			{
				var buff = buffs[i];
				i--;
				if (buff.Definition.GetID() != id)
					continue;
				count += RemoveBuffImplement(buff) ? 1 : 0;
			}
			return count;
		}
		else if (Std.isOfType(key, BuffDefinition))
		{
			// C#: RemoveBuffs(BuffDefinition buffDef)
			var buffDef:BuffDefinition = cast key;
			var count = 0;
			var i = buffs.length - 1;
			while (i >= 0)
			{
				var buff = buffs[i];
				i--;
				if (buff.Definition != buffDef)
					continue;
				count += RemoveBuffImplement(buff) ? 1 : 0;
			}
			return count;
		}
		else
		{
			// C#: RemoveBuffs<T>() where T : BuffDefinition
			var count = 0;
			var i = buffs.length - 1;
			while (i >= 0)
			{
				var buff = buffs[i];
				i--;
				if (!BuffTargetExt.IsDefinitionOfType(buff.Definition, key))
					continue;
				count += RemoveBuffImplement(buff) ? 1 : 0;
			}
			return count;
		}
	}
	// #endregion

	// #region 包含
	// C#: HasBuff<T>() / HasBuff(NamespaceID) / HasBuff(BuffDefinition) / HasBuff(Buff)
	public function HasBuff(key:Dynamic):Bool
	{
		if (key == null)
			return false;

		if (Std.isOfType(key, String))
		{
			var id:NamespaceID = cast key;
			for (buff in buffs)
			{
				if (buff.Definition.GetID() == id)
					return true;
			}
			return false;
		}
		else if (Std.isOfType(key, BuffDefinition))
		{
			var buffDef:BuffDefinition = cast key;
			for (buff in buffs)
			{
				if (buff.Definition == buffDef)
					return true;
			}
			return false;
		}
		else if (Std.isOfType(key, Buff))
		{
			return buffs.indexOf(cast key) >= 0;
		}
		else
		{
			for (buff in buffs)
			{
				if (BuffTargetExt.IsDefinitionOfType(buff.Definition, key))
					return true;
			}
			return false;
		}
	}
	// #endregion

	// #region 获取单个
	public function GetBuff(id:Int64):Null<Buff>
	{
		for (buff in buffs)
		{
			if (buff.ID == id)
				return buff;
		}
		return null;
	}
	// C#: GetFirstBuff<T>() / GetFirstBuff(BuffDefinition) / GetFirstBuff(NamespaceID)
	public function GetFirstBuff(key:Dynamic):Null<Buff>
	{
		if (key == null)
			return null;

		if (Std.isOfType(key, String))
		{
			var id:NamespaceID = cast key;
			for (buff in buffs)
			{
				if (buff.Definition.GetID() == id)
					return buff;
			}
			return null;
		}
		else if (Std.isOfType(key, BuffDefinition))
		{
			var definition:BuffDefinition = cast key;
			for (buff in buffs)
			{
				if (buff.Definition == definition)
					return buff;
			}
			return null;
		}
		else
		{
			for (buff in buffs)
			{
				if (BuffTargetExt.IsDefinitionOfType(buff.Definition, key))
					return buff;
			}
			return null;
		}
	}
	// #endregion

	// #region 获取多个
	// C#: GetBuffs<T>() / GetBuffs(BuffDefinition) / GetBuffs(NamespaceID)
	public function GetBuffs(key:Dynamic):Array<Buff>
	{
		var list:Array<Buff> = [];
		GetBuffsNonAlloc(key, list);
		return list;
	}
	// C#: GetBuffsNonAlloc<T>(List<Buff>) / (BuffDefinition, List<Buff>) / (NamespaceID, List<Buff>)
	public function GetBuffsNonAlloc(key:Dynamic, results:Array<Buff>):Void
	{
		if (key == null)
			return;

		if (Std.isOfType(key, String))
		{
			var id:NamespaceID = cast key;
			for (buff in buffs)
			{
				if (buff.Definition.GetID() == id)
					results.push(buff);
			}
		}
		else if (Std.isOfType(key, BuffDefinition))
		{
			var definition:BuffDefinition = cast key;
			for (buff in buffs)
			{
				if (buff.Definition == definition)
					results.push(buff);
			}
		}
		else
		{
			for (buff in buffs)
			{
				if (BuffTargetExt.IsDefinitionOfType(buff.Definition, key))
					results.push(buff);
			}
		}
	}
	// #endregion

	// #region 获取数量
	// C#: GetBuffCount<T>() / GetBuffCount(BuffDefinition) / GetBuffCount(NamespaceID)
	public function GetBuffCount(key:Dynamic):Int
	{
		if (key == null)
			return 0;

		var count = 0;
		if (Std.isOfType(key, String))
		{
			var id:NamespaceID = cast key;
			for (buff in buffs)
			{
				if (buff.Definition.GetID() == id)
					count++;
			}
		}
		else if (Std.isOfType(key, BuffDefinition))
		{
			var definition:BuffDefinition = cast key;
			for (buff in buffs)
			{
				if (buff.Definition == definition)
					count++;
			}
		}
		else
		{
			for (buff in buffs)
			{
				if (BuffTargetExt.IsDefinitionOfType(buff.Definition, key))
					count++;
			}
		}
		return count;
	}
	// #endregion

	// #region 获取全部
	public function GetAllBuffs(results:Array<Buff>):Void
	{
		for (buff in buffs)
		{
			results.push(buff);
		}
	}
	// #endregion

	public function Update():Void
	{
		updateBuffer.resize(0);
		GetAllBuffs(updateBuffer);
		for (buff in updateBuffer)
		{
			buff.Update();
		}
	}
	private function AddBuffImplement(buff:Buff):Bool
	{
		if (buff == null)
			return false;

		var lastInsertions = GetModelInsertions();

		buffs.push(buff);
		AddModifierCaches(buff);
		OnBuffAdded.dispatch(buff);
		buff.OnPropertyChanged.add(OnBuffPropertyChangedCallback);

		var insertions = buff.GetModelInsertions();
		for (insertion in insertions)
		{
			var key = insertion.key;
			var lastInsertion = Lambda.find(lastInsertions, i -> i.key == key);
			if (lastInsertion != null)
				continue;
			OnModelInsertionAdded.dispatch(insertion);
		}
		return true;
	}
	private function RemoveBuffImplement(buff:Buff):Bool
	{
		if (buff == null)
			return false;
		if (buffs.remove(buff))
		{
			buff.RemoveFromTarget();
			RemoveModifierCaches(buff);
			OnBuffRemoved.dispatch(buff);
			buff.OnPropertyChanged.remove(OnBuffPropertyChangedCallback);

			var insertions = buff.GetModelInsertions();
			var currentInsertions = GetModelInsertions();
			for (insertion in insertions)
			{
				var key = insertion.key;
				var currentInsertion = Lambda.find(currentInsertions, i -> i.key == key);
				if (currentInsertion != null)
					continue;
				OnModelInsertionRemoved.dispatch(insertion);
			}
			return true;
		}
		return false;
	}
	// #endregion

	// #region 修改器
	// C#: IEnumerable<IPropertyKey> GetModifiedProperties()
	public function GetModifiedProperties():Array<IPropertyKey>
	{
		return [for (key in modifierLibrary.GetModifyPropertyKeys()) key];
	}
	public function GetModifiersForProperty(name:IPropertyKey, results:Array<ModifierSourceItem>):Void
	{
		modifierLibrary.GetModifierItemsForProperty(name, results);
	}
	private function AddModifierCaches(buff:Buff):Void
	{
		modifierLibrary.AddModifierCaches([for (m in buff.GetModifiers()) new ModifierSourceItem(buff, m)]);
	}
	private function RemoveModifierCaches(buff:Buff):Void
	{
		modifierLibrary.RemoveModifierCaches([for (m in buff.GetModifiers()) new ModifierSourceItem(buff, m)]);
	}
	private function ReevaluateModifierCaches():Void
	{
		modifierLibrary.ClearModifierCaches();
		for (buff in buffs)
		{
			AddModifierCaches(buff);
		}
	}
	// #endregion

	// #region 插入模型
	public function GetModelInsertions():Array<ModelInsertion>
	{
		var result:Array<ModelInsertion> = [];
		for (buff in buffs)
		{
			for (insertion in buff.GetModelInsertions())
			{
				result.push(insertion);
			}
		}
		return result;
	}
	// #endregion

	// #region 序列化
	public function ToSerializable():SerializableBuffList
	{
		var seri = new SerializableBuffList();
		seri.buffs = [for (b in buffs) b.ToSerializable()];
		seri.currentBuffID = currentBuffID;
		return seri;
	}
	public function InitFromSerializable(serializable:Null<SerializableBuffList>, level:LevelEngine, target:IBuffTarget):Void
	{
		if (serializable == null)
			return;

		buffs.resize(0);
		if (serializable.buffs != null)
		{
			for (seriBuff in serializable.buffs)
			{
				var buff = Buff.CreateFromSerializable(seriBuff, level, target);
				if (buff == null)
					continue;
				buff.OnPropertyChanged.add(OnBuffPropertyChangedCallback);
				buffs.push(buff);
			}
		}
		currentBuffID = serializable.currentBuffID;
		ReevaluateModifierCaches();
	}
	public function LoadFromSerializable(serializable:SerializableBuffList):Void
	{
		for (buff in buffs)
		{
			if (buff == null)
				continue;
			var seriBuff = Lambda.find(serializable.buffs, b -> b.id == buff.ID);
			if (seriBuff == null)
				continue;
			buff.LoadFromSerializable(seriBuff);
		}
	}
	// #endregion

	// #region 事件回调
	private function OnBuffPropertyChangedCallback(buff:Buff, key:IPropertyKey):Void
	{
		modifierLibrary.CallPropertyChanged(buff, key);
	}
	private function OnModifiedPropertyNeedsUpdateCallback(name:IPropertyKey):Void
	{
		OnModifiedPropertyNeedsUpdate.dispatch(name);
	}
	// #endregion

	// #region 接口实现
	// C#: void IModifierProvider.GetModifiersForProperty(...) 显式实现 → Haxe 由上面的公开方法满足。
	public function iterator():Iterator<Buff>
	{
		// PORT-NOTE: C# IEnumerable<Buff> → Haxe 迭代器方法，支持 for (buff in buffList)。
		return buffs.iterator();
	}
	// #endregion

	// #region 事件
	public var OnBuffAdded:FlxTypedSignal<Buff->Void> = new FlxTypedSignal();
	public var OnBuffRemoved:FlxTypedSignal<Buff->Void> = new FlxTypedSignal();
	public var OnModelInsertionAdded:FlxTypedSignal<ModelInsertion->Void> = new FlxTypedSignal();
	public var OnModelInsertionRemoved:FlxTypedSignal<ModelInsertion->Void> = new FlxTypedSignal();
	public var OnModifiedPropertyNeedsUpdate:FlxTypedSignal<IPropertyKey->Void> = new FlxTypedSignal();
	// #endregion

	// #region 属性
	private var currentBuffID:Int64 = Int64.ofInt(1);
	private var updateBuffer:Array<Buff> = [];
	private var buffs:Array<Buff> = [];
	private var modifierLibrary:ModifierLibrary;
	// #endregion
}

// PORT-NOTE: C# 的 PropertyCalculateResult 结构体无其它引用（仅在 BuffList.cs 内声明），按
//   PORTING.md「其余类放同文件底部」保留为模块子类型：pvzengine.buffs.BuffList.PropertyCalculateResult。
class PropertyCalculateResult
{
	public var name:String;
	public var value:Dynamic;
	public function new() {}
}
