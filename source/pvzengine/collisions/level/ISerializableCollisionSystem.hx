// Ported from: Assets/Scripts/Engine/Level/Collisions/Level/ISerializableCollisionSystem.cs
package pvzengine.collisions.level;

import pvzengine.collisions.ISerializableCollisionEntity;

interface ISerializableCollisionSystem
{
    // PORT-NOTE: C# 为只读属性；用 (default, never) 兼容既有实现的 (get, never) 属性写法。
    public var Entities(get, never):Null<Array<ISerializableCollisionEntity>>;
    public var EntityTrash(get, never):Null<Array<ISerializableCollisionEntity>>;
}
