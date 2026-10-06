// Ported from: Assets/Scripts/View/Widgets/ElementArray.cs
package mvz2.ui;

import unity.Component;
import unity.GameObject;
import unity.Transform;
import unity.UnityObject;
import unity.MonoBehaviour;

class ElementArray extends unity.MonoBehaviour
{
	public function SetCount(count:Int):Void
	{
		var i = count;
		while (i < itemArray.length)
		{
			DestroyAt(i);
			i++;
		}
		while (itemArray.length > count) itemArray.pop();
		while (itemArray.length < count) itemArray.push(null);
	}
	public function Insert(index:Int, item:GameObject):Void
	{
		item.transform.SetParent(_listRoot, true);
		itemArray[index] = item;
		SortItems();
	}
	public function CreateItem():GameObject
	{
		var item = UnityObject.Instantiate(_template, null, null, _listRoot);
		//激活
		item.SetActive(true);
		return item;
	}
	public function Remove(item:GameObject):Bool
	{
		var index = indexOf(item);
		if (index < 0)
			return false;
		RemoveAt(index);
		return true;
	}
	public function RemoveAt(index:Int):Void
	{
		if (index < 0 || index >= Count)
			return;
		itemArray[index] = null;
	}
	public function DestroyAt(index:Int):Bool
	{
		if (index < 0 || index >= Count)
			return false;
		var item = itemArray[index];
		if (!UnityObject.exists(item))
			return false;
		return DestroyItem(item);
	}
	public function DestroyItem(item:GameObject):Bool
	{
		if (Remove(item))
		{
			item.transform.SetParent(null);
			UnityObject.destroy(item);
			return true;
		}
		return false;
	}
	public function indexOf(go:GameObject):Int
	{
		return itemArray.indexOf(go);
	}
	// PORT-NOTE: C# 的 indexOf(Component) 重载在 Haxe 中不能与 indexOf(GameObject) 并存，故改名。
	public function indexOfComponent(comp:Component):Int
	{
		return indexOf(comp.gameObject);
	}
	public function getElement(index:Int):Null<GameObject>
	{
		if (index < 0 || index >= Count)
			return null;
		return itemArray[index];
	}
	// PORT-NOTE: C# 的泛型重载 getElement<T>(index) 不能与非泛型版本并存，Haxe 需要显式传入组件类型。
	public function getElementAs<T:Component>(index:Int, type:Class<T>):Null<T>
	{
		var element = getElement(index);
		return element != null ? element.GetComponent(type) : null;
	}
	public function getTemplate():GameObject
	{
		return _template;
	}
	public function getTemplateAs<T:Component>(type:Class<T>):Null<T>
	{
		var template = getTemplate();
		return template != null ? template.GetComponent(type) : null;
	}
	public function getElements():Array<GameObject>
	{
		return itemArray;
	}
	public function getElementsAs<T:Component>(type:Class<T>):Array<T>
	{
		var result:Array<T> = [];
		for (item in itemArray)
		{
			if (item == null)
				continue;
			result.push(item.GetComponent(type));
		}
		return result;
	}
	function Awake():Void
	{
		if (_template.transform.parent == _listRoot)
		{
			_template.SetActive(false);
		}
	}
	function SortItems():Void
	{
		for (i in 0...Count)
		{
			var item = itemArray[i];
			if (!UnityObject.exists(item))
				continue;
			item.transform.SetAsLastSibling();
		}
	}
	public var Count(get, never):Int;
	function get_Count():Int return itemArray.length;
	public var ListRoot(get, never):Transform;
	function get_ListRoot():Transform return _listRoot;
	@:serializeField
	private var _listRoot:Transform;
	@:serializeField
	private var _template:GameObject;
	@:serializeField
	private var itemArray:Array<GameObject>;
}
