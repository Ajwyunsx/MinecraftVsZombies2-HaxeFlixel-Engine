// Ported from: Assets/Scripts/Engine/Level/Collisions/ISerializableCollisionCollider.cs
package pvzengine.collisions;

import pvzengine.NamespaceID;
import unity.Vector3;

interface ISerializableCollisionCollider
{
    // PORT-NOTE: C# 为只读属性（get only）；用 (default, never) 以同时兼容
    // `(default, null)` 字段、(get, never) 属性与普通字段三种既有实现写法。
    public var Name(get, never):String;
    public var Enabled(get, never):Bool;
    public var ArmorSlot(get, never):Null<NamespaceID>;
    // PORT-NOTE: C# 为 `SerializableEntityCollision?[]? Collisions`。既有实现
    // （mvz2/collisions/UnityEntityCollider.hx 的 SerializableUnityEntityCollider）以 `Array<Dynamic>` 实现该成员，
    // 而以具体元素类型（SerializableEntityCollision）实现的写法同样存在；Haxe 的 Array 对类类型不变，
    // 二者无法统一为同一个 Array<T>，故此处声明为 Dynamic。
    public var Collisions(get, never):Dynamic;
    public var UpdateMode(get, never):Int;
    public var CustomSize(get, never):Vector3;
    public var CustomOffset(get, never):Vector3;
    public var CustomPivot(get, never):Vector3;
}
