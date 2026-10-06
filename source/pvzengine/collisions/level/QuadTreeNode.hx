// Ported from: Assets/Scripts/Engine/Level/Collisions/Level/QuadTreeNode.cs
package pvzengine.collisions.level;

import pvzengine.collisions.level.QuadTree.QuadTreeItem;
import tools.geometrical.Geometry;
import unity.Rect;

class QuadTreeNode<T:IQuadTreeNodeObject>
{
    /// <summary>
    /// 构造函数
    /// </summary>
    public function new(tree:QuadTree<T>)
    {
        Tree = tree;
    }
    public function Init(parent:QuadTreeNode<T>, size:Rect, depth:Int = 0):Void
    {
        Parent = parent;
        // PORT-NOTE: unity.Rect 是引用类型（C# 的 Rect 为值类型），`bounds = size; looseBounds = bounds;`
        // 在 Haxe 中会共享同一实例，故对两处都显式复制以保持按值语义。
        bounds = new Rect(size.x, size.y, size.width, size.height);
        looseBounds = new Rect(size.x, size.y, size.width, size.height);
        looseBounds.position -= looseBounds.size * 0.5;
        looseBounds.size *= 2;
        this.depth = depth;
    }
    public function GetRect():Rect
    {
        // PORT-NOTE: C# 返回的是 Rect 值副本；这里也返回副本，避免外部修改到树内部状态。
        return new Rect(bounds.x, bounds.y, bounds.width, bounds.height);
    }

    // #region 获取子节点
    public function GetChildCount():Int
    {
        return children.length;
    }
    public function GetChild(i:Int):QuadTreeNode<T>
    {
        return children[i];
    }
    // #endregion

    // #region 插入
    /// <summary>
    /// 插入一个新的Rect
    /// </summary>
    public function Insert(item:QuadTreeItem<T>):Void
    {
        items.push(item);
        item.node = this;
        GainObject();
    }
    private function IncreaseObjectCounter():Void
    {
        totalTargetCount++;
        if (Parent != null)
        {
            Parent.IncreaseObjectCounter();
        }
    }
    private function SplitIfPossible():Void
    {
        //判断是否创建子节点
        if (children.length <= 0 && (totalTargetCount > Tree.MaxObjects && depth < Tree.MaxDepth))
        {
            // 分裂，并将完全位于子节点中的物体分给子节点。
            CreateChildren();
            //填充对象到新创建的子节点中
            SpreadObjectsToChildren();
        }
    }
    private function GainObject():Void
    {
        IncreaseObjectCounter();
        SplitIfPossible();
    }
    // #endregion

    // #region 移除
    public function Remove(item:QuadTreeItem<T>):Bool
    {
        //父节点坍缩
        //遍历移除
        if (items.remove(item))
        {
            LoseObject();
            return true;
        }
        return false;
    }
    private function DecreaseObjectCounter():Void
    {
        totalTargetCount--;
        if (Parent != null)
        {
            Parent.DecreaseObjectCounter();
        }
    }
    private function CollapseIfPossible():Void
    {
        if (totalTargetCount <= Tree.CollapseObjects)
        {
            RecycleObjectsFromChildren();
            RemoveChildren();
        }
        if (Parent != null)
        {
            Parent.CollapseIfPossible();
        }
    }
    private function LoseObject():Void
    {
        totalTargetCount--;
        if (totalTargetCount <= Tree.CollapseObjects)
        {
            RecycleObjectsFromChildren();
            RemoveChildren();
        }
        if (Parent != null)
        {
            Parent.LoseObject();
        }
    }
    // #endregion

    // #region 移动
    public function MoveItemTo(item:QuadTreeItem<T>, targetNode:QuadTreeNode<T>):Void
    {
        if (this == targetNode)
            return;

        if (!items.remove(item))
            return;
        targetNode.items.push(item);
        item.node = targetNode;

        DecreaseObjectCounter();
        targetNode.IncreaseObjectCounter();
        CollapseIfPossible();
        targetNode.SplitIfPossible();
    }
    // #endregion

    // #region 评估目标节点
    public function EvaluateNode(rect:Rect):QuadTreeNode<T>
    {
        if (children.length <= 0)
        {
            return this;
        }
        var child = GetContainerChild(rect);
        if (child == null)
            return this;
        return child.EvaluateNode(rect);
    }
    public function GetContainerChild(rect:Rect):Null<QuadTreeNode<T>>
    {
        var thisCenter = bounds.center;
        var center = rect.center;
        var index = 0;
        if (center.x >= thisCenter.x)
        {
            index |= 1;
        }
        if (center.y >= thisCenter.y)
        {
            index |= 2;
        }
        var child = children[index];
        if (!ContainsFully(child.bounds, rect))
            return null;
        return child;
    }
    private function ContainsFully(outer:Rect, inner:Rect):Bool
    {
        return inner.xMin >= outer.xMin && inner.xMax <= outer.xMax &&
            inner.yMin >= outer.yMin && inner.yMax <= outer.yMax;
    }
    // #endregion

    // #region 查找目标
    public function FindTargetsInRect(rect:Rect, results:Array<T>, rewind:Float = 0, predicate:T->Bool = null):Void
    {
        // C#: rect.OverlapOptimized(looseBounds)（Tools.Geometrical.Geometry 的扩展方法）→ 静态调用。
        if (!Geometry.OverlapOptimized(rect, looseBounds))
            return;

        //查找匹配对象
        for (item in items)
        {
            var target = item.target;
            if (!Geometry.OverlapOptimized(rect, target.GetCollisionRect(rewind)))
                continue;
            if (predicate != null && !predicate(target))
                continue;
            results.push(target);
        }

        //遍历子节点
        for (child in children)
        {
            child.FindTargetsInRect(rect, results, rewind, predicate);
        }
    }
    // #endregion

    // #region 创建子节点
    /// <summary>
    /// 分割四叉树，为这个结点计算出四个子结点
    /// </summary>
    private function CreateChildren():Void
    {
        //这部分是计算子结点的x,y,w,h
        var halfWidth = bounds.width / 2;
        var halfHeight = bounds.height / 2;
        var x = bounds.x;
        var y = bounds.y;
        children.push(Tree.CreateNode(Tree, this, new Rect(x, y, halfWidth, halfHeight), depth + 1));
        children.push(Tree.CreateNode(Tree, this, new Rect(x + halfWidth, y, halfWidth, halfHeight), depth + 1));
        children.push(Tree.CreateNode(Tree, this, new Rect(x, y + halfHeight, halfWidth, halfHeight), depth + 1));
        children.push(Tree.CreateNode(Tree, this, new Rect(x + halfWidth, y + halfHeight, halfWidth, halfHeight), depth + 1));
    }
    private function SpreadObjectsToChildren():Void
    {
        var thisSize = bounds.size;
        var childSize = thisSize * 0.5;
        // PORT-NOTE: C# 为倒序 for 循环并在循环中 RemoveAt；Haxe 的 `for (i in 0...n)` 无法安全地在遍历中删除元素，
        // 故改为等价的倒序 while 循环。
        var i = items.length - 1;
        while (i >= 0)
        {
            var movingItem = items[i];
            var target = movingItem.target;
            var movingRect = target.GetCollisionRect();
            var child = GetContainerChild(movingRect);
            if (child != null)
            {
                child.items.push(movingItem);
                child.totalTargetCount++;
                movingItem.node = child;
                items.splice(i, 1);
            }
            i--;
        }
    }
    // #endregion

    // #region 回收子节点
    private function RemoveChildren():Void
    {
        for (child in children)
        {
            child.RemoveChildren();
            Tree.ReleaseNode(child);
        }
        children = [];
    }
    private function RecycleObjectsFromChildren():Void
    {
        //遍历子节点
        for (child in children)
        {
            var i = child.items.length - 1;
            while (i >= 0)
            {
                var recycling = child.items[i];
                items.push(recycling);
                recycling.node = this;
                i--;
            }
        }
    }
    // #endregion

    public function Reset():Void
    {
        Parent = null;
        bounds = null;
        looseBounds = null;
        items = [];
        totalTargetCount = 0;
        RemoveChildren();
        depth = 0;
    }
    public function toString():String
    {
        return '[${depth}]${bounds}';
    }

    public var Tree(default, null):QuadTree<T>;
    public var Parent(default, null):QuadTreeNode<T>;
    //rect范围
    private var bounds:Rect = new Rect(0, 0, 0, 0); // PORT-NOTE: C# Rect 为 struct，默认 (0,0,0,0)；显式初始化避免 abstract-over-class 的 null 解引用
    private var looseBounds:Rect = new Rect(0, 0, 0, 0); // PORT-NOTE: C# Rect 为 struct，默认 (0,0,0,0)；显式初始化避免 abstract-over-class 的 null 解引用
    //当前层级内的对象
    private var items:Array<QuadTreeItem<T>> = [];
    private var totalTargetCount:Int;
    //子节点
    private var children:Array<QuadTreeNode<T>> = [];
    //当前层级
    private var depth:Int;
}

// C#: public interface IQuadTreeNodeObject : IEquatable<IQuadTreeNodeObject>
// PORT-NOTE: Haxe 没有 IEquatable，直接在接口里声明 Equals。
interface IQuadTreeNodeObject
{
    public function GetCollisionRect(rewind:Float = 0):Rect;
    public function Equals(other:IQuadTreeNodeObject):Bool;
}
