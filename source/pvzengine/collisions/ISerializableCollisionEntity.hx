// Ported from: Assets/Scripts/Engine/Level/Collisions/ISerializableCollisionEntity.cs
package pvzengine.collisions;

import haxe.Int64;

interface ISerializableCollisionEntity
{
    // PORT-NOTE: C# 为只读属性；用 (default, never) 兼容既有实现的 (default, null) 字段与 (get, never) 属性写法。
    public var ID(get, never):Int64;
    public var Colliders(get, never):Null<Array<ISerializableCollisionCollider>>;
}
