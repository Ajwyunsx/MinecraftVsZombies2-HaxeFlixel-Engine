// Ported from: Assets/Scripts/Engine/Level/Collisions/BuiltinCollisionCollider.cs
package pvzengine.collisions;

import flixel.util.FlxSignal.FlxTypedSignal;
import pvzengine.NamespaceID;
import pvzengine.collisions.level.QuadTreeNode.IQuadTreeNodeObject;
import pvzengine.entities.Entity;
import pvzengine.entities.EntityCollision;
import pvzengine.entities.EntityColliderReference;
import pvzengine.entities.EntityCollisionHelper;
import pvzengine.entities.SerializableEntityCollider;
import pvzengine.level.LevelEngine;
import tools.Ref;
import tools.geometrical.Geometry;
import unity.Bounds;
import unity.Mathf;
import unity.Rect;
import unity.Vector3;

class BuiltinCollisionCollider implements IEntityCollider implements IQuadTreeNodeObject
{
    // PORT-NOTE: C# 有两个构造函数：public (Entity, string, Hitbox) 与 private (Entity, string)。
    // Haxe 不支持构造函数重载，私有重载合并进主构造函数（hitbox 缺省为 null 时走原私有构造函数的分支，
    // 由 FromSerializable 之后自行给 hitbox 赋值）。
    public function new(entity:Entity, name:String, ?hitbox:Hitbox)
    {
        if (hitbox == null)
        {
            Entity = entity;
            Name = name;
            this.hitbox = null;
            return;
        }
        if (name == null || name.length == 0)
            throw 'The name of an BuiltinCollisionCollider cannot be null or empty.';
        Entity = entity;
        Name = name;
        this.hitbox = hitbox;
        ReevaluateBounds();
    }
    public function SetEnabled(enabled:Bool):Void
    {
        Enabled = enabled;
        UpdateEnabled();
    }
    public function SetIgnored(ignored:Bool):Void
    {
        Ignored = ignored;
        UpdateEnabled();
    }
    private function UpdateEnabled():Void
    {
        var newValue = Enabled && !Ignored;

        if (newValue != lastEnabledState)
        {
            lastEnabledState = newValue;
            if (newValue)
            {
                OnEnabled.dispatch(this);
            }
            else
            {
                OnDisabled.dispatch(this);
            }
        }
    }
    public function ReevaluateBounds():Void
    {
        hitbox.ReevaluateBounds();
        // C#: bottomRect = hitbox.GetLocalBounds().GetBottomRect();
        // PORT-NOTE: `Bounds.GetBottomRect()` 是 Tools.Geometrical.Geometry 的扩展方法，
        // 按 PORTING.md 的扩展方法约定改为静态调用（与 mvz2/vanilla/detection/Detection.hx 中
        // Geometry.DoRangesIntersect 的写法一致）。
        bottomRect = Geometry.GetBottomRect(hitbox.GetLocalBounds());
    }
    public function GetCollisionTime(prevPosition:Vector3, target:BuiltinCollisionCollider, precision:Float, collisionTime:Ref<Float>):Bool
    {
        return GetCollisionTimeWithBounds(prevPosition, target.hitbox.GetBounds(), precision, collisionTime);
    }
    // PORT-NOTE: Haxe 不支持方法重载；C# 的 `GetCollisionTime(Vector3, Bounds, float, out float)` 重载
    // 重命名为 GetCollisionTimeWithBounds。
    // PORT-NOTE: C# 的 `out float collisionTime` → tools.Ref<Float>（与工程内其它 out 参数写法一致）。
    public function GetCollisionTimeWithBounds(prevPosition:Vector3, target:Bounds, precision:Float, collisionTime:Ref<Float>):Bool
    {
        var oldPosition = prevPosition + hitbox.GetLocalCenter();
        oldPosition = floorToPrecision(oldPosition, precision);

        var newPosition = hitbox.GetBoundsCenter();
        newPosition = floorToPrecision(newPosition, precision);

        // PORT-NOTE: unity.Bounds 是引用类型（C# 的 Bounds 为值类型），`var targetBounds = target;`
        // 会共享实例，故显式构造副本以保持 C# 的按值语义。
        var targetBounds = new Bounds(target.center, target.size);
        targetBounds.center = floorToPrecision(targetBounds.center, precision);
        return Geometry.CalculateAABBCollisionTime(oldPosition, newPosition, hitbox.GetBoundsSize(), targetBounds, collisionTime);
    }
    // PORT-NOTE: C# `(Vector3)Vector3Int.FloorToInt(v * precision) / precision`；
    // unity shim 未提供 Vector3Int.FloorToInt 与 Vector3Int → Vector3 的转换，改为逐分量取整。
    private static inline function floorToPrecision(v:Vector3, precision:Float):Vector3
    {
        return new Vector3(
            Mathf.FloorToInt(v.x * precision),
            Mathf.FloorToInt(v.y * precision),
            Mathf.FloorToInt(v.z * precision)) / precision;
    }

    // #region 检测
    public function CheckBox(center:Vector3, size:Vector3):Bool
    {
        return hitbox.IsInBox(center, size);
    }
    public function CheckSphere(center:Vector3, radius:Float):Bool
    {
        return hitbox.IsInSphere(center, radius);
    }
    public function CheckCapsule(pos1:Vector3, pos2:Vector3, radius:Float):Bool
    {
        return hitbox.IsInCapsule(pos1, pos2, radius);
    }
    // #endregion

    // #region 碰撞箱
    public function DoCollision(other:BuiltinCollisionCollider, offset:Vector3):Void
    {
        var hitbox1 = hitbox;
        var hitbox2 = other.hitbox;
        // PORT-NOTE: C# 的 `out Vector3 seperation` → tools.Ref<Vector3>。
        var seperation = Ref.to(Vector3.zero);
        if (hitbox1.DoCollision(hitbox2, offset, seperation))
        {
            var collision = Lambda.find(collisionList, c -> c.OtherCollider == other);
            var enter = false;
            if (collision == null)
            {
                enter = true;
                collision = new EntityCollision(this, other);
            }
            collision.Seperation = seperation.value;
            if (CallPreCollision(collision))
            {
                if (enter)
                {
                    collisionList.push(collision);
                    CallPostCollision(collision, EntityCollisionHelper.STATE_ENTER);
                }
                else
                {
                    CallPostCollision(collision, EntityCollisionHelper.STATE_STAY);
                }
                collision.Checked = true;
            }
            return;
        }
    }
    public function GetBoundingBox():Bounds
    {
        return hitbox.GetBounds();
    }
    public function GetCenter():Vector3
    {
        return hitbox.GetBoundsCenter();
    }
    public function GetPosition():Vector3
    {
        return hitbox.GetPosition();
    }
    public function GetCollisionRect(rewind:Float = 0):Rect
    {
        // PORT-NOTE: unity.Rect 是引用类型（C# 的 Rect 为值类型），这里显式复制以保持按值语义。
        var rect = new Rect(bottomRect.x, bottomRect.y, bottomRect.width, bottomRect.height);
        var entityPos = Entity.Position;
        var entityMotion = entityPos - Entity.PreviousPosition;
        var offset = entityPos - entityMotion * rewind;
        rect.x += offset.x;
        rect.y += offset.z;
        return rect;
    }
    public function GetHitbox():Hitbox
    {
        return hitbox;
    }
    // #endregion

    // #region 碰撞
    public function GetCollisions(collisions:Array<EntityCollision>):Void
    {
        for (collision in collisionList)
        {
            collisions.push(collision);
        }
    }
    public function ExitCollision():Void
    {
        exitBuffer = [];
        for (collision in collisionList)
        {
            exitBuffer.push(collision);
        }
        for (collision in exitBuffer)
        {
            if (!collision.Checked)
            {
                CallPostCollision(collision, EntityCollisionHelper.STATE_EXIT);
                collisionList.remove(collision);
            }
            collision.Checked = false;
        }
    }
    private function CallPreCollision(collision:EntityCollision):Bool
    {
        return Entity.PreCollision(collision);
    }
    private function CallPostCollision(collision:EntityCollision, state:Int):Void
    {
        Entity.PostCollision(collision, state);
    }
    // #endregion

    // #region 序列化
    public function ToReference():EntityColliderReference
    {
        return new EntityColliderReference(Entity.ID, Name);
    }
    public function ToSerializable():SerializableEntityCollider
    {
        // PORT-NOTE: C# 用对象初始化器 `new SerializableEntityCollider() { ... }`，这里改为逐字段赋值
        // （SerializableEntityCollider 由 Engine/Level/Entities 工作包提供）。
        var seri = new SerializableEntityCollider();
        seri.name = Name;
        seri.collisionList = [for (c in collisionList) c.ToSerializable()];
        seri.enabled = Enabled;
        seri.armorSlot = ArmorSlot;
        if (Std.isOfType(hitbox, CustomHitbox))
        {
            var custom:CustomHitbox = cast hitbox;
            seri.updateMode = cast ColliderUpdateMode.Custom;
            seri.customSize = custom.GetSize();
            seri.customOffset = custom.GetOffset();
            seri.customPivot = custom.GetPivot();
        }
        else
        {
            seri.updateMode = cast ColliderUpdateMode.Main;
        }
        return seri;
    }
    public static function FromSerializable(seri:ISerializableCollisionCollider, entity:Entity):BuiltinCollisionCollider
    {
        if (seri.Name == null || seri.Name.length == 0)
        {
            // PORT-NOTE: C# 为 `throw MissingSerializeDataException.Property<BuiltinCollisionCollider>(nameof(Name))`；
            // Haxe 不支持在调用处显式指定函数的类型参数（`Property<T>(...)` 会被解析为比较表达式），
            // 且既有上层代码（mvz2/collisions/UnityEntityCollider.hx）对同一异常也是直接抛字符串，故保持一致。
            throw 'Missing serialization property BuiltinCollisionCollider.Name.';
        }
        var collider = new BuiltinCollisionCollider(entity, seri.Name);
        collider.SetEnabled(seri.Enabled);
        collider.ArmorSlot = seri.ArmorSlot;

        var updateMode:ColliderUpdateMode = cast seri.UpdateMode;
        if (updateMode == ColliderUpdateMode.Custom)
        {
            var customHitbox = new CustomHitbox(entity);
            customHitbox.SetSize(seri.CustomSize);
            customHitbox.SetOffset(seri.CustomOffset);
            customHitbox.SetPivot(seri.CustomPivot);
            collider.hitbox = customHitbox;
        }
        else if (updateMode == ColliderUpdateMode.Main)
        {
            collider.hitbox = new EntityHitbox(entity);
        }
        collider.ReevaluateBounds();
        return collider;
    }
    public function LoadCollisions(level:LevelEngine, seri:ISerializableCollisionCollider):Void
    {
        if (seri == null || seri.Collisions == null)
            return;
        collisionList = [];
        // PORT-NOTE: ISerializableCollisionCollider.Collisions 声明为 Dynamic（见该接口的 PORT-NOTE）。
        var seriCollisions:Array<Dynamic> = seri.Collisions;
        for (seriCollision in seriCollisions)
        {
            if (seriCollision == null)
                continue;
            var collision = EntityCollision.FromSerializable(seriCollision, level);
            if (collision == null)
                continue;
            collisionList.push(collision);
        }
    }
    // #endregion

    // C#: bool IEquatable<IQuadTreeNodeObject>.Equals(IQuadTreeNodeObject other)
    public function Equals(other:IQuadTreeNodeObject):Bool
    {
        if (!Std.isOfType(other, BuiltinCollisionCollider))
            return false;
        var collider:BuiltinCollisionCollider = cast other;
        return this == collider;
    }

    public function toString():String
    {
        return '${Entity}[${Name}]';
    }

    public var OnEnabled:FlxTypedSignal<BuiltinCollisionCollider->Void> = new FlxTypedSignal();
    public var OnDisabled:FlxTypedSignal<BuiltinCollisionCollider->Void> = new FlxTypedSignal();
    public var Enabled(default, null):Bool = true;
    public var Ignored(default, null):Bool = false;
    public var Name:String;
    public var Entity:Entity;
    public var ArmorSlot:Null<NamespaceID>;
    private var lastEnabledState:Bool = true;
    private var bottomRect:Rect = new Rect(0, 0, 0, 0); // PORT-NOTE: C# Rect 为 struct，默认 (0,0,0,0)；显式初始化避免 abstract-over-class 的 null 解引用
    private var hitbox:Hitbox;
    private var collisionList:Array<EntityCollision> = [];
    private var exitBuffer:Array<EntityCollision> = [];
}
