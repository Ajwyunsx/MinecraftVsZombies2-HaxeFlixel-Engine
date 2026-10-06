// Ported from: Assets/Scripts/Engine/Level/Collisions/EntityCollision.cs
// PORT-NOTE: 该 C# 文件的命名空间为 PVZEngine.Entities（虽然文件位于 Level/Collisions 目录），
// 依据 PORTING.md「命名空间 → 包路径」的规则，Haxe 包为 pvzengine.entities。
// 同文件中的 EntityColliderReference 因既有 import 路径需要被拆成独立模块
// （pvzengine/entities/EntityColliderReference.hx），其余类型仍留在本模块内。
package pvzengine.entities;

import pvzengine.collisions.IEntityCollider;
import pvzengine.level.LevelEngine;
import unity.Vector3;

class EntityCollision
{
    public function new(collider:IEntityCollider, otherCollider:IEntityCollider)
    {
        Collider = collider;
        OtherCollider = otherCollider;
    }
    public function ToSerializable():SerializableEntityCollision
    {
        return new SerializableEntityCollision({
            collider: EntityColliderReference.FromCollider(Collider),
            otherCollider: EntityColliderReference.FromCollider(OtherCollider),
            seperation: Seperation
        });
    }
    public static function FromSerializable(serializable:SerializableEntityCollision, level:LevelEngine):Null<EntityCollision>
    {
        if (serializable == null)
            return null;
        var collider1 = serializable.collider != null ? serializable.collider.GetCollider(level) : null;
        if (collider1 == null)
            return null;
        var collider2 = serializable.otherCollider != null ? serializable.otherCollider.GetCollider(level) : null;
        if (collider2 == null)
            return null;
        var result = new EntityCollision(collider1, collider2);
        result.Seperation = serializable.seperation;
        return result;
    }
    public var Collider:IEntityCollider;
    public var OtherCollider:IEntityCollider;
    public var Seperation:Vector3 = new Vector3(0, 0, 0); // PORT-NOTE: C# Vector3 为 struct，默认 (0,0,0)；显式初始化避免 abstract-over-class 的 null 解引用
    public var Entity(get, never):Entity;
    inline function get_Entity():Entity return Collider.Entity;
    public var Other(get, never):Entity;
    inline function get_Other():Entity return OtherCollider.Entity;
    public var Enter:Bool;
    public var Checked:Bool;
}
