// Ported from: Assets/Scripts/Engine/Base/DataStructures/ListUpdater.cs
package pvzengine.base;

// PORT-NOTE: C# 的 `HashSet<T>` 在 Haxe 中用 `Map<T, Bool>` 表示（见 PORTING.md）。
// PORT-NOTE: Haxe 的 Map 需要能确定键类型的实现，未约束的类型参数无法解析；
// C# 的 HashSet<T> 默认按相等比较（类为引用相等），因此这里约束 T 为对象类型 → 底层使用 ObjectMap（引用相等）。
// PORT-NOTE: C# 的 `Action<T>? updateAction = null` 可选委托 → Haxe 的可空函数类型。
class ListUpdater<T:{}>
{
    public function new() {}
    public function Update(targets:Array<T>, current:Array<T>, addAction:T->Void, removeAction:T->Void, ?updateAction:T->Void):Void
    {
        // 清空并填充当前集合的 HashSet
        currentBuffer.clear();
        removeBuffer.clear();
        for (item in current)
        {
            currentBuffer.set(item, true);
            removeBuffer.set(item, true);
        }

        // 处理目标集合
        for (element in targets)
        {
            // 从待移除集合中移除当前元素（O(1) 操作）
            removeBuffer.remove(element);

            // 如果元素不在当前集合中，则添加
            if (!currentBuffer.exists(element)) // O(1) 查找
            {
                if (addAction != null)
                    addAction(element);
            }

            // 执行更新操作
            if (updateAction != null)
                updateAction(element);
        }

        // 移除剩余元素
        for (element in removeBuffer.keys())
        {
            if (removeAction != null)
                removeAction(element);
        }
    }
    private var currentBuffer:Map<T, Bool> = new Map<T, Bool>();
    private var removeBuffer:Map<T, Bool> = new Map<T, Bool>();
}
