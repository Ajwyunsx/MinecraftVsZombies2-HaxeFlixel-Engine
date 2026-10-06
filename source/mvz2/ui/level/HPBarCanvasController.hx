// Ported from: Assets/Scripts/View/Level/HPBar/HPBarCanvasController.cs
package mvz2.ui.level;

import unity.Quaternion;
import unity.Transform;
import unity.UnityObject;
import unity.Vector3;
import mvz2.gamecontent.commands.Clear;
import unity.MonoBehaviour;

class HPBarCanvasController extends unity.MonoBehaviour
{
	function Awake():Void
	{
		barItemPool = new ObjectPool<HPBarList>(BarItemCreateFunc, BarItemGetFunc, BarItemReleaseFunc, BarItemDestroyFunc);
	}

	public function AddHPBarSource(source:IHPBarSource):Void
	{
		if (!activeHPBarItems.exists(source))
		{
			activeHPBarItems.set(source, null);
		}
	}
	public function RemoveHPBarSource(source:IHPBarSource):Void
	{
		if (activeHPBarItems.exists(source))
		{
			var hpBar = activeHPBarItems.get(source);
			if (UnityObject.exists(hpBar))
			{
				barItemPool.Release(hpBar);
			}
			activeHPBarItems.remove(source);
		}
	}
	public function UpdateHPBars():Void
	{
		updateBuffer.resize(0);
		for (source in activeHPBarItems.keys())
		{
			updateBuffer.push(source);
		}
		for (source in updateBuffer)
		{
			if (!source.IsActive())
			{
				if (activeHPBarItems.exists(source))
				{
					var bar = activeHPBarItems.get(source);
					if (UnityObject.exists(bar))
					{
						barItemPool.Release(bar);
						activeHPBarItems.set(source, null);
					}
				}
				continue;
			}
			var hpBar = activeHPBarItems.exists(source) ? activeHPBarItems.get(source) : null;
			if (!UnityObject.exists(hpBar))
			{
				hpBar = barItemPool.Get();
				activeHPBarItems.set(source, hpBar);
			}
			hpBar.transform.position = source.GetPosition();
			var localPos = hpBar.transform.localPosition;
			localPos.z = 0;
			hpBar.transform.localPosition = localPos;
			source.UpdateHPBarList(hpBar);
		}
	}

	// #region 池子
	private function BarItemCreateFunc():HPBarList
	{
		var go = UnityObject.Instantiate(barItemTemplate.gameObject, new Vector3(0, 0, 0), Quaternion.identity, barItemRoot);
		return go.GetComponent(HPBarList);
	}
	private function BarItemGetFunc(item:HPBarList):Void
	{
		item.gameObject.SetActive(true);
	}
	private function BarItemReleaseFunc(item:HPBarList):Void
	{
		item.gameObject.SetActive(false);
	}
	private function BarItemDestroyFunc(item:HPBarList):Void
	{
		UnityObject.destroy(item.gameObject);
	}
	// #endregion

	@:serializeField
	private var barItemRoot:Transform;
	@:serializeField
	private var barItemTemplate:HPBarList;
	private var barItemPool:ObjectPool<HPBarList>;
	private var activeHPBarItems:Map<IHPBarSource, HPBarList> = [];
	private var updateBuffer:Array<IHPBarSource> = [];
}

// Minimal UnityEngine.Pool.ObjectPool<T> shim。
class ObjectPool<T>
{
	private var createFunc:Void->T;
	private var getFunc:T->Void;
	private var releaseFunc:T->Void;
	private var destroyFunc:T->Void;
	private var pool:Array<T> = [];

	public function new(createFunc:Void->T, ?actionOnGet:T->Void = null, ?actionOnRelease:T->Void = null, ?actionOnDestroy:T->Void = null) {
		this.createFunc = createFunc;
		this.getFunc = actionOnGet;
		this.releaseFunc = actionOnRelease;
		this.destroyFunc = actionOnDestroy;
	}

	public function Get():T {
		var item = pool.length > 0 ? pool.pop() : createFunc();
		if (getFunc != null) getFunc(item);
		return item;
	}
	public function Release(item:T):Void {
		if (releaseFunc != null) releaseFunc(item);
		pool.push(item);
	}
	public function Clear():Void {
		for (item in pool) if (destroyFunc != null) destroyFunc(item);
		pool = [];
	}
	public var countAll(get, never):Int;
	function get_countAll():Int return pool.length;
}
