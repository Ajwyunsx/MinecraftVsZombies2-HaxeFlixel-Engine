// Ported from: Assets/Scripts/Engine/Level/Collisions/Level/ICollisionSystem.cs
// PORT-NOTE: C# 中 OverlapParams 与 ICollisionSystem 同处一个文件（命名空间 PVZEngine.Collisions.Level），
// 但既有上层代码以 `import pvzengine.collisions.level.OverlapParams` / `pvzengine.collisions.OverlapParams`
// 引用它，而 Haxe 的 import 必须精确对应模块文件，故 OverlapParams 被拆到独立模块
// （pvzengine/collisions/level/OverlapParams.hx，以及别名 pvzengine/collisions/OverlapParams.hx）。
package pvzengine.collisions.level;

import pvzengine.collisions.ColliderConstructor;
import pvzengine.collisions.IEntityCollider;
import pvzengine.entities.Entity;
import pvzengine.entities.EntityCollision;
import pvzengine.level.LevelEngine;
import unity.Vector3;

interface ICollisionSystem
{
    public function Update():Void;
    public function InitEntity(entity:Entity):Void;
    public function UpdateEntityDetection(entity:Entity):Void;
    public function UpdateEntityPosition(entity:Entity):Void;
    public function UpdateEntitySize(entity:Entity):Void;
    public function DestroyEntity(entity:Entity):Void;
    public function CreateCustomCollider(entity:Entity, info:ColliderConstructor):Null<IEntityCollider>;
    public function RemoveCollider(entity:Entity, name:String):Bool;
    public function GetCollider(entity:Entity, name:String):Null<IEntityCollider>;
    public function GetCurrentCollisions(entity:Entity, collisions:Array<EntityCollision>):Void;


    public function ToSerializable():ISerializableCollisionSystem;
    public function LoadFromSerializable(level:LevelEngine, seri:ISerializableCollisionSystem):Void;


    public function OverlapBox(center:Vector3, size:Vector3, param:OverlapParams):Array<IEntityCollider>;
    public function OverlapBoxNonAlloc(center:Vector3, size:Vector3, param:OverlapParams, results:Array<IEntityCollider>):Void;
    public function OverlapSphere(center:Vector3, radius:Float, param:OverlapParams):Array<IEntityCollider>;
    public function OverlapSphereNonAlloc(center:Vector3, radius:Float, param:OverlapParams, results:Array<IEntityCollider>):Void;
    public function OverlapCapsule(point0:Vector3, point1:Vector3, radius:Float, param:OverlapParams):Array<IEntityCollider>;
    public function OverlapCapsuleNonAlloc(point0:Vector3, point1:Vector3, radius:Float, param:OverlapParams, results:Array<IEntityCollider>):Void;
}
