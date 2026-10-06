// Ported from: Assets/Scripts/Logic/HeldItems/HeldItemData.cs (class HeldItemBuilder)
package mvz2logic.helditems;

import pvzengine.IPropertyKey;
import pvzengine.NamespaceID;
import pvzengine.PropertyDictionary;
import pvzengine.PropertyKey;

class HeldItemBuilder implements IHeldItemBuilder
{
	public function new(type:NamespaceID, priority:Int = 0)
	{
		_type = type;
		_priority = priority;
	}

	public function SetProperty<T>(key:PropertyKey<T>, value:T):Void
	{
		properties.SetProperty(key, value);
	}
	public function GetProperty<T>(key:PropertyKey<T>):Null<T>
	{
		return properties.GetProperty(key);
	}
	public function GetPropertyObject(key:IPropertyKey):Dynamic
	{
		return properties.GetPropertyObject(key);
	}
	public function GetPropertyKeys():Array<IPropertyKey>
	{
		return properties.GetPropertyNames();
	}
	// C#: public NamespaceID Type { get; }
	// PORT-NOTE: 接口 IHeldItemBuilder 声明 (get, never)，故类内改用私有字段 + getter。
	public var Type(get, never):NamespaceID;
	private function get_Type():NamespaceID return _type;
	private var _type:NamespaceID = null;
	// C#: public int Priority { get; }
	public var Priority(get, never):Int;
	private function get_Priority():Int return _priority;
	private var _priority:Int = 0;
	private var properties:PropertyDictionary = new PropertyDictionary();
}
