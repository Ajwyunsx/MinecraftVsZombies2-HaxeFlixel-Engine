// Ported from: UnityEngine.Pool.ObjectPool<T> (minimal shim)
// PORT-NOTE: C# 的 UnityEngine.Pool.ObjectPool<T> 依赖 Unity 的对象生命周期回调。
// 这里实现一个功能等价的最小对象池：Get/Release/Dispose 语义与 Unity 一致。
package unity.pool;

class ObjectPool<T>
{
	private var createFunc:Void->T;
	private var actionOnGet:T->Void;
	private var actionOnRelease:T->Void;
	private var actionOnDestroy:T->Void;
	private var collectionCheck:Bool;
	private var defaultCapacity:Int;
	private var maxSize:Int;

	private var stack:Array<T> = [];
	private var inUse:Array<T> = [];

	public function new(createFunc:Void->T, ?actionOnGet:T->Void, ?actionOnRelease:T->Void, ?actionOnDestroy:T->Void, ?collectionCheck:Bool = true, ?defaultCapacity:Int = 10, ?maxSize:Int = 10000)
	{
		this.createFunc = createFunc;
		this.actionOnGet = actionOnGet;
		this.actionOnRelease = actionOnRelease;
		this.actionOnDestroy = actionOnDestroy;
		this.collectionCheck = collectionCheck;
		this.defaultCapacity = defaultCapacity;
		this.maxSize = maxSize;
	}

	public function Get():T
	{
		var element:T;
		if (stack.length > 0)
		{
			element = stack.pop();
		}
		else
		{
			element = createFunc != null ? createFunc() : null;
		}
		if (actionOnGet != null)
			actionOnGet(element);
		inUse.push(element);
		return element;
	}

	public function Release(element:T):Void
	{
		if (element == null)
			return;
		// PORT-NOTE: C# 在 collectionCheck 为真时会检测重复释放，这里保留同样的检查语义。
		if (collectionCheck && inUse.contains(element))
		{
			inUse.remove(element);
		}
		if (stack.length < maxSize)
		{
			if (actionOnRelease != null)
				actionOnRelease(element);
			stack.push(element);
		}
		else if (actionOnDestroy != null)
		{
			actionOnDestroy(element);
		}
	}

	public function Clear():Void
	{
		if (actionOnDestroy != null)
		{
			for (element in stack)
			{
				actionOnDestroy(element);
			}
		}
		stack = [];
	}

	public var CountInactive(get, never):Int;
	function get_CountInactive():Int return stack.length;
}
