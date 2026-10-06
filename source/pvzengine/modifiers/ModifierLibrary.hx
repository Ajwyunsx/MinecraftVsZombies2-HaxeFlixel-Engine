// Ported from: Assets/Scripts/Engine/Level/Modifiers/ModifierLibrary.cs
package pvzengine.modifiers;

import flixel.util.FlxSignal.FlxTypedSignal;
import pvzengine.IPropertyKey;

class ModifierLibrary
{
	public function new()
	{
	}
	// #region 属性
	public function GetModifyPropertyKeys():Array<IPropertyKey>
	{
		return [for (key in propertyKeys) key];
	}
	public function GetModifierItemsForProperty(name:IPropertyKey, results:Array<ModifierSourceItem>):Void
	{
		var list = modifierCachesForProperty.get(GetKeyValue(name));
		if (list == null)
			return;
		noStackModifierBuffer.resize(0);
		for (element in list)
		{
			var modifier = element.modifier;
			if (modifier.NoStack)
			{
				if (noStackModifierBuffer.contains(modifier))
				{
					continue;
				}
				else
				{
					noStackModifierBuffer.push(modifier);
				}
			}
			results.push(element);
		}
	}
	// #endregion

	// #region 修改器缓存
	public function AddModifierCaches(modifiers:Array<ModifierSourceItem>):Void
	{
		for (item in modifiers)
		{
			var modifier = item.modifier;
			var modifyName = modifier.PropertyName;
			var usingName = modifier.UsingContainerPropertyName;
			var modifyKey = GetKeyValue(modifyName);
			if (!modifierCachesForProperty.exists(modifyKey))
			{
				modifierCachesForProperty.set(modifyKey, []);
				propertyKeys.set(modifyKey, modifyName);
			}
			modifierCachesForProperty.get(modifyKey).push(item);

			var usingKey = GetKeyValue(usingName);
			if (!modifierCachesUsingProperty.exists(usingKey))
			{
				modifierCachesUsingProperty.set(usingKey, []);
			}
			modifierCachesUsingProperty.get(usingKey).push(item);

			CallModifiedPropertyChanged(modifyName);
		}
	}
	public function RemoveModifierCaches(modifiers:Array<ModifierSourceItem>):Void
	{
		for (item in modifiers)
		{
			var modifier = item.modifier;
			var modifyName = modifier.PropertyName;
			var modifyKey = GetKeyValue(modifyName);
			if (modifierCachesForProperty.exists(modifyKey))
			{
				modifierCachesForProperty.get(modifyKey).remove(item);
			}

			var usingName = modifier.UsingContainerPropertyName;
			// PORT-NOTE: 与 C# 原实现保持一致（此处原代码用 modifyName 查询 using 缓存，而非 usingName）。
			if (modifierCachesUsingProperty.exists(modifyKey))
			{
				modifierCachesUsingProperty.get(modifyKey).remove(item);
			}

			CallModifiedPropertyChanged(modifyName);
		}
	}
	public function ClearModifierCaches():Void
	{
		for (modifyKey in modifierCachesForProperty.keys())
		{
			var list = modifierCachesForProperty.get(modifyKey);
			if (list != null)
			{
				list.resize(0);
			}
			CallModifiedPropertyChanged(propertyKeys.get(modifyKey));
		}
		for (usingKey in modifierCachesUsingProperty.keys())
		{
			var list = modifierCachesUsingProperty.get(usingKey);
			if (list != null)
			{
				list.resize(0);
			}
		}
		modifierCachesForProperty.clear();
		modifierCachesUsingProperty.clear();
		propertyKeys.clear();
	}
	// #endregion

	public function CallPropertyChanged(source:IModifierSource, key:IPropertyKey):Void
	{
		var list = modifierCachesUsingProperty.get(GetKeyValue(key));
		if (list == null)
			return;
		for (item in list)
		{
			if (item.container != source)
				continue;
			var modifier = item.modifier;
			if (GetKeyValue(key) == GetKeyValue(modifier.UsingContainerPropertyName))
			{
				CallModifiedPropertyChanged(modifier.PropertyName);
			}
		}
	}
	public function CallModifiedPropertyChanged(key:IPropertyKey):Void
	{
		if (OnModifiedPropertyNeedsUpdate != null)
		{
			OnModifiedPropertyNeedsUpdate.dispatch(key);
		}
	}
	// PORT-NOTE: C# `event Action<IPropertyKey>? OnModifiedPropertyNeedsUpdate` 移植为 FlxTypedSignal。
	public var OnModifiedPropertyNeedsUpdate:FlxTypedSignal<IPropertyKey->Void> = new FlxTypedSignal();

	// #region 缓存字段
	// PORT-NOTE: C# 用 `Dictionary<IPropertyKey, ...>(new PropertyKeyComparer())`（按 IPropertyKey.Key 数值比较）。
	// Haxe 直接以 Key 的整数值作为 Map 键，语义等价。
	private var modifierCachesForProperty:Map<Int, Array<ModifierSourceItem>> = new Map();
	private var modifierCachesUsingProperty:Map<Int, Array<ModifierSourceItem>> = new Map();
	private var propertyKeys:Map<Int, IPropertyKey> = new Map();
	private static var noStackModifierBuffer:Array<PropertyModifier> = [];
	// #endregion

	static function GetKeyValue(key:IPropertyKey):Int
	{
		return key == null ? 0 : key.Key;
	}
}
