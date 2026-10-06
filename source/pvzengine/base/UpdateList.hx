// Ported from: Assets/Scripts/Engine/Base/DataStructures/UpdateList.cs
package pvzengine.base;

// PORT-NOTE: C# 的 `IEnumerable<TKey>` 在 Haxe 中由迭代器方法（iterator()）表达，供 `for (x in list)` 使用。
// PORT-NOTE: 同 ListUpdater，TKey 需要 `{}` 约束（Map 的键类型必须可解析）。
class UpdateList<TKey:{}>
{
    public function new(?elements:Array<TKey>)
    {
        if (elements != null)
        {
            this.elements = this.elements.concat(elements);
        }
    }
    // C#: public virtual void Update(IEnumerable<TKey> validSources)
    public function Update(validSources:Array<TKey>):Void
    {
        UpdateElements(validSources);
    }
    public function UpdateElements(validSources:Array<TKey>):Void
    {
        updater.Update(validSources, elements, AddElement, RemoveElement);
    }
    private function AddElement(element:TKey):Void
    {
        elements.push(element);
    }
    private function RemoveElement(element:TKey):Void
    {
        elements.remove(element);
    }
    public function iterator():Iterator<TKey>
    {
        return elements.iterator();
    }
    public function GetElements():Array<TKey>
    {
        return elements;
    }
    private var updater:ListUpdater<TKey> = new ListUpdater<TKey>();
    private var elements:Array<TKey> = [];
}
