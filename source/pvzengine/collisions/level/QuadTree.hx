// Ported from: Assets/Scripts/Engine/Level/Collisions/Level/QuadTree.cs
package pvzengine.collisions.level;

import pvzengine.collisions.level.QuadTreeNode.IQuadTreeNodeObject;
import unity.Rect;
import unity.pool.ObjectPool;

class QuadTree<T:IQuadTreeNodeObject>
{
    public function new(size:Rect, maxObjects:Int = 1, collapseObjects:Int = 1, maxDepth:Int = 5)
    {
        // PORT-NOTE: C# 的对象池 参数为具名参数（maxSize / actionOnRelease），Haxe 无具名参数，改为按位置传参。
        itemPool = new ObjectPool<QuadTreeItem<T>>(CreateQuadTreeItemFunc, null, null, null, true, 10, 128);
        nodePool = new ObjectPool<QuadTreeNode<T>>(CreateQuadTreeNodeFunc, null, a -> a.Reset(), null, true, 10, 128);

        root = CreateNode(this, null, size, 0);
        MaxObjects = maxObjects;
        CollapseObjects = collapseObjects;
        MaxDepth = maxDepth;
    }
    public function Insert(target:T):Void
    {
        var rect = target.GetCollisionRect();
        var nodeToInsert = root.EvaluateNode(rect);

        var item = itemPool.Get();
        item.target = target;
        items.push(item);

        nodeToInsert.Insert(item);
    }
    public function Remove(target:T):Void
    {
        var item = GetItem(target);
        if (item == null)
            return;
        item.node.Remove(item);
        RemoveItem(item);
    }
    public function FindTargetsInRect(rect:Rect, results:Array<T>, rewind:Float = 0, predicate:T->Bool = null):Void
    {
        root.FindTargetsInRect(rect, results, rewind, predicate);
    }
    public function GetAllTargets(results:Array<T>):Void
    {
        for (item in items)
        {
            results.push(item.target);
        }
    }
    public function GetRootNode():QuadTreeNode<T>
    {
        return root;
    }
    public function Update():Void
    {
        var i = items.length - 1;
        while (i >= 0)
        {
            UpdateTarget(items[i]);
            i--;
        }
    }
    public function CreateNode(tree:QuadTree<T>, parent:QuadTreeNode<T>, size:Rect, depth:Int = 0):QuadTreeNode<T>
    {
        var node = nodePool.Get();
        node.Init(parent, size, depth);
        return node;
    }
    public function ReleaseNode(node:QuadTreeNode<T>):Void
    {
        nodePool.Release(node);
    }
    private function UpdateTarget(item:QuadTreeItem<T>):Void
    {
        var rect = item.target.GetCollisionRect();
        var node = root.EvaluateNode(rect);
        item.node.MoveItemTo(item, node);
    }
    private function RemoveItem(item:QuadTreeItem<T>):Void
    {
        items.remove(item);
        itemPool.Release(item);
    }
    private function GetItem(target:T):Null<QuadTreeItem<T>>
    {
        for (item in items)
        {
            // C#: item.target.Equals(target)（IEquatable<IQuadTreeNodeObject>）
            if (item.target.Equals(target))
            {
                return item;
            }
        }
        return null;
    }
    private function CreateQuadTreeItemFunc():QuadTreeItem<T>
    {
        return new QuadTreeItem<T>();
    }
    private function CreateQuadTreeNodeFunc():QuadTreeNode<T>
    {
        return new QuadTreeNode<T>(this);
    }
    public var MaxObjects(default, null):Int;
    public var CollapseObjects(default, null):Int;
    public var MaxDepth(default, null):Int;
    private var root:QuadTreeNode<T>;
    private var items:Array<QuadTreeItem<T>> = [];
    private var itemPool:ObjectPool<QuadTreeItem<T>>;
    private var nodePool:ObjectPool<QuadTreeNode<T>>;
}

class QuadTreeItem<T:IQuadTreeNodeObject>
{
    public function new()
    {
    }
    public function toString():String
    {
        // PORT-NOTE: C# 为 `target.ToString()`（object 的方法）。Haxe 中类型参数只能访问其约束
        // （IQuadTreeNodeObject）声明的成员，故改用 Std.string（等价地调用 toString）。
        return Std.string(target);
    }

    public var target:T;
    public var node:QuadTreeNode<T>;
}
