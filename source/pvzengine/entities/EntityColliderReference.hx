// Ported from: Assets/Scripts/Engine/Level/Collisions/EntityCollision.cs
// PORT-NOTE: 该类型在 C# 中与 EntityCollision / SerializableEntityCollision 同处一个文件
// （命名空间为 PVZEngine.Entities），但既有上层代码分别以 `import pvzengine.EntityColliderReference`
// 和 `import pvzengine.collisions.EntityColliderReference` 两种路径引用它，而 Haxe 的 import
// 必须精确对应模块文件，故将其单独拆成一个模块，并在上述两处提供 typedef 别名模块
// （pvzengine/EntityColliderReference.hx、pvzengine/collisions/EntityColliderReference.hx）。
package pvzengine.entities;

import haxe.Int64;
import pvzengine.collisions.IEntityCollider;
import pvzengine.level.LevelEngine;

class EntityColliderReference
{
    // PORT-NOTE: C# 有两个构造函数 (IEntityCollider collider) 与 (long entityId, string unitName)。
    // Haxe 不支持构造函数重载，1 参重载拆为静态工厂 FromCollider（与工程内其它 *Reference 类一致）。
    public static function FromCollider(collider:IEntityCollider):EntityColliderReference
    {
        return new EntityColliderReference(collider.Entity.ID, collider.Name);
    }
    public function new(entityId:Int64, unitName:String)
    {
        this.entityId = entityId;
        this.unitName = unitName;
    }

    public function GetCollider(engine:LevelEngine):Null<IEntityCollider>
    {
        var entity = engine.FindEntityByID(entityId);
        if (entity == null)
            return null;
        return entity.GetCollider(unitName);
    }
    public function Equals(obj:Dynamic):Bool
    {
        if (Std.isOfType(obj, EntityColliderReference))
        {
            var other:EntityColliderReference = cast obj;
            return entityId == other.entityId && unitName == other.unitName;
        }
        return false;
    }
    public function GetHashCode():Int
    {
        // PORT-NOTE: C# 为 `long.GetHashCode() * 31 + string.GetHashCode()`；Haxe 的 String 没有
        // GetHashCode，这里改为逐字符累加，保证同一引用得到相同哈希。
        var hash = entityId.low * 31 + entityId.high;
        if (unitName != null)
        {
            for (i in 0...unitName.length)
            {
                hash = hash * 31 + unitName.charCodeAt(i);
            }
        }
        return hash;
    }
    // PORT-NOTE: C# 定义了 operator == / !=；Haxe 不支持类实例的 == 重载
    // （Array.indexOf / remove 会用引用相等），调用处请改用 Equals。

    public var entityId:Int64;
    public var unitName:String;
}
