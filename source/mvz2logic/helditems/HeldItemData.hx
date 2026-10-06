// Ported from: Assets/Scripts/Logic/HeldItems/HeldItemData.cs (class HeldItemData)
package mvz2logic.helditems;

import pvzengine.NamespaceID;
import pvzengine.PropertyDictionary;
import pvzengine.PropertyKey;

class HeldItemData implements IHeldItemData
{
	public function new(type:NamespaceID)
	{
		_type = type;
	}
	public function SetProperty<T>(key:PropertyKey<T>, value:T):Void
	{
		properties.SetProperty(key, value);
	}
	public function GetProperty<T>(key:PropertyKey<T>):Null<T>
	{
		return properties.GetProperty(key);
	}
	public function Build(builder:IHeldItemBuilder):Void
	{
		_type = builder.Type;
		_priority = builder.Priority;

		properties.Clear();
		for (key in builder.GetPropertyKeys())
		{
			properties.SetPropertyObject(key, builder.GetPropertyObject(key));
		}
	}
	// C#: public NamespaceID Type { get; private set; }
	// PORT-NOTE: 接口 IHeldItemData 声明 (get, never)，故类内改用私有字段 + getter。
	public var Type(get, never):NamespaceID;
	private function get_Type():NamespaceID return _type;
	private var _type:NamespaceID = null;
	// C#: public int Priority { get; private set; }
	public var Priority(get, never):Int;
	private function get_Priority():Int return _priority;
	private var _priority:Int = 0;
	private var properties:PropertyDictionary = new PropertyDictionary();
}
