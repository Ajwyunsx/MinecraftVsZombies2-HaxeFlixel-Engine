// Ported from: Assets/Scripts/Engine/Base/DataStructures/ArrayBuffer.cs
package pvzengine.base;

// PORT-NOTE: C# 的索引器 `public T this[int index]` 在 Haxe 中无法表达
//（@:arrayAccess 只对 abstract / extern class 生效），改为同名语义的读取方法。
// 既有移植代码（mvz2/gamecontent/bosses/TheGiant.hx、LightningOrbEvokedBuff.hx）写的是 `buffer.Get(i)`。
class ArrayBuffer<T>
{
    public function new(length:Int)
    {
        array = new Array<T>();
        for (i in 0...length)
        {
            array.push(null);
        }
    }
    public function Clear():Void
    {
        currentIndex = 0;
    }
    public function CopyFrom(source:Array<T>):Void
    {
        for (src in source)
        {
            Add(src);
        }
    }
    public function Add(item:T):Void
    {
        if (currentIndex >= array.length)
        {
            Expand();
        }
        array[currentIndex] = item;
        currentIndex++;
    }
    private function Expand():Void
    {
        // C#: 长度为 0 时 `array.Length * 2` 仍为 0，会导致越界；这里与 C# 保持一致的扩容倍数。
        var newLength = array.length * 2;
        while (newLength <= currentIndex)
        {
            newLength = newLength * 2;
        }
        var newArray = new Array<T>();
        for (i in 0...newLength)
        {
            newArray.push(i < array.length ? array[i] : null);
        }
        array = newArray;
    }
    public var Count(get, never):Int;
    inline function get_Count():Int return currentIndex;
    public function Get(index:Int):T
    {
        return array[index];
    }
    private var currentIndex:Int = 0;
    private var array:Array<T>;
}
