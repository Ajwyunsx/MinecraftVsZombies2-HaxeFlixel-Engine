// Ported from: Assets/Scripts/View/Widgets/ElementList.cs
package mvz2.ui;

import unity.Component;
import unity.GameObject;
import unity.Transform;
import unity.UnityObject;
import unity.MonoBehaviour;

class ElementList extends unity.MonoBehaviour
{
	public function updateList(count:Int, ?onUpdate:Int->GameObject->Void = null, ?onCreateOrEnable:GameObject->Void = null,
		?onDestroyOrDisable:GameObject->Void = null, ?rebuild:Bool = false):Void
	{
		var maxNum = Std.int(Math.max(itemList.length, count));

		for (i in 0...maxNum)
		{
			if (i < count) // 应当出现在列表中
			{
				var item:GameObject;
				if (i >= itemList.length) // 目前没有这个项
				{
					//创建列表项
					item = CreateItem();
					Add(item);
					if (onCreateOrEnable != null) onCreateOrEnable(item);
				}
				else // 目前有这个项
				{
					item = itemList[i];
					if (!item.activeSelf && pooled)
					{
						//激活
						item.SetActive(true);
						if (onCreateOrEnable != null) onCreateOrEnable(item);
					}
				}
				//更新
				if (onUpdate != null) onUpdate(i, item);
			}
			else // 不应出现在列表中
			{
				var item:GameObject;
				if (!pooled) // 可以销毁
				{
					if (count < itemList.length) // 目前有这个项
					{
						// 销毁列表项
						item = itemList[count];
						DestroyItem(item);
						if (onDestroyOrDisable != null) onDestroyOrDisable(item);
					}
				}
				else // 不可以销毁
				{
					if (i < itemList.length) // 目前有这个项
					{
						item = itemList[i];
						if (item.activeSelf)
						{
							// 禁用
							item.SetActive(false);
							if (onDestroyOrDisable != null) onDestroyOrDisable(item);
						}
					}
				}
			}
		}
	}
	public function Add(item:GameObject):Void
	{
		Insert(Count, item);
	}
	public function Insert(index:Int, item:GameObject):Void
	{
		item.transform.SetParent(_listRoot, true);
		itemList.insert(index, item);
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
		return itemList.remove(item);
	}
	public function RemoveAt(index:Int):Void
	{
		itemList.splice(index, 1);
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
		return itemList.indexOf(go);
	}
	// PORT-NOTE: C# 的 indexOf(Component) 重载在 Haxe 中不能与 indexOf(GameObject) 并存，故改名。
	public function indexOfComponent(comp:Component):Int
	{
		return indexOf(comp.gameObject);
	}
	public function getElement(index:Int):Null<GameObject>
	{
		if (index < 0 || index >= itemList.length)
			return null;
		return itemList[index];
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
		return itemList;
	}
	public function getElementsAs<T:Component>(type:Class<T>):Array<T>
	{
		var result:Array<T> = [];
		for (item in itemList)
		{
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
		for (i in 0...itemList.length)
		{
			var item = itemList[i];
			item.transform.SetAsLastSibling();
		}
	}
	public var Count(get, never):Int;
	function get_Count():Int return itemList.length;
	public var ListRoot(get, never):Transform;
	function get_ListRoot():Transform return _listRoot;
	@:serializeField
	private var _listRoot:Transform;
	@:serializeField
	private var _template:GameObject;
	@:serializeField
	private var pooled:Bool;
	@:serializeField
	private var itemList:Array<GameObject> = [];
}
