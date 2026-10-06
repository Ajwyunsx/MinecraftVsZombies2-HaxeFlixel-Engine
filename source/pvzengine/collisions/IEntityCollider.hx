// Ported from: Assets/Scripts/Engine/Level/Collisions/IEntityCollider.cs
package pvzengine.collisions;

import pvzengine.NamespaceID;
import pvzengine.entities.Entity;
import pvzengine.entities.EntityColliderReference;
import unity.Bounds;
import unity.Vector3;

interface IEntityCollider
{
    // PORT-NOTE: C# 为只读属性（get only）。这里用 (default, never) 而非 (get, never)：
    // 既有实现 mvz2/collisions/UnityEntityCollider.hx 以 `public var Name(default, null):String;`
    // 这类字段实现它们，Haxe 的 (default, never) 同时接受 (default, null) 字段、普通字段与 (get, never) 属性。
    public var Name(default, never):String;
    public var Entity(default, never):Entity;
    public var Enabled(default, never):Bool;
    public var ArmorSlot(default, never):Null<NamespaceID>;
    public function ToReference():EntityColliderReference;
    public function CheckBox(center:Vector3, size:Vector3):Bool;
    public function CheckSphere(center:Vector3, radius:Float):Bool;
    public function CheckCapsule(pos1:Vector3, pos2:Vector3, radius:Float):Bool;
    public function GetBoundingBox():Bounds;
    public function SetEnabled(enabled:Bool):Void;
}
