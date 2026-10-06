// Ported from: Assets/Scripts/Engine/Level/Collisions/Level/QuadTreeCollider.cs
package pvzengine.collisions.level;

import pvzengine.collisions.BuiltinCollisionCollider;
import unity.Rect;

class QuadTreeCollider extends QuadTree<BuiltinCollisionCollider>
{
    public function new(size:Rect, maxObjects:Int = 1, collapseObjects:Int = 1, maxDepth:Int = 5)
    {
        super(size, maxObjects, collapseObjects, maxDepth);
    }
}
