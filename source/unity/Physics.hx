package unity;

import unity.Collider;

// Minimal UnityEngine.Physics shim.
// PORT-NOTE: there is no physics engine behind the Haxe port, so broadphase queries are
// emulated by pairwise AABB tests over the registered colliders (see unity.Collider), and
// Physics.Simulate dispatches OnTriggerStay to the components of interacting objects.
class Physics {
    public static var defaultContactOffset:Float = 0.01;
    public static var gravity:Vector3 = new Vector3(0, -9.81, 0);
    public static var queriesHitTriggers:Bool = true;

    private static var colliders:Array<Collider> = [];

    public static function register(c:Collider):Void {
        if (c != null && !colliders.contains(c)) colliders.push(c);
    }
    public static function unregister(c:Collider):Void {
        colliders.remove(c);
    }
    public static function getAllColliders():Array<Collider> {
        return colliders;
    }

    private static function isActive(c:Collider):Bool {
        if (c == null || !c.enabled) return false;
        if (c.gameObject == null) return false;
        return c.gameObject.activeInHierarchy;
    }
    private static function layerMatch(layer:Int, mask:Int):Bool {
        if (mask == Physics.AllLayers) return true;
        return (mask & (1 << layer)) != 0;
    }
    public static inline var AllLayers:Int = ~0;
    public static inline var DefaultRaycastLayers:Int = ~(1 << 2);
    public static inline var IgnoreRaycastLayer:Int = 1 << 2;

    private static function dispatchTriggerStay(source:Collider, other:Collider):Void {
        if (source == null || source.gameObject == null) return;
        for (comp in source.gameObject.GetAllComponents()) {
            if (Reflect.hasField(comp, "OnTriggerStay")) {
                Reflect.callMethod(comp, Reflect.field(comp, "OnTriggerStay"), [other]);
            }
        }
    }

    public static function Simulate(step:Float):Void {
        for (a in colliders) {
            if (!isActive(a)) continue;
            if (!a.isTrigger) continue;
            for (b in colliders) {
                if (a == b || !isActive(b)) continue;
                if (!a.bounds.Intersects(b.bounds)) continue;
                dispatchTriggerStay(a, b);
            }
        }
    }

    public static function OverlapBoxNonAlloc(center:Vector3, halfExtents:Vector3, results:Array<Collider>, orientation:Quaternion, layerMask:Int, queryTriggerInteraction:QueryTriggerInteraction):Int {
        var box = new Bounds(center, halfExtents * 2);
        var count = 0;
        for (c in colliders) {
            if (!isActive(c)) continue;
            if (queryTriggerInteraction == QueryTriggerInteraction.Ignore && c.isTrigger) continue;
            if (!layerMatch(c.gameObject.layer, layerMask)) continue;
            if (!box.Intersects(c.bounds)) continue;
            if (count < results.length) results[count] = c;
            count++;
        }
        return count;
    }
    public static function OverlapBoxNonAllocSimple(center:Vector3, halfExtents:Vector3, results:Array<Collider>, layerMask:Int):Int {
        return OverlapBoxNonAlloc(center, halfExtents, results, Quaternion.identity, layerMask, QueryTriggerInteraction.UseGlobal);
    }

    public static function OverlapSphereNonAlloc(center:Vector3, radius:Float, results:Array<Collider>, layerMask:Int, queryTriggerInteraction:QueryTriggerInteraction):Int {
        var r2 = radius * radius;
        var count = 0;
        for (c in colliders) {
            if (!isActive(c)) continue;
            if (queryTriggerInteraction == QueryTriggerInteraction.Ignore && c.isTrigger) continue;
            if (!layerMatch(c.gameObject.layer, layerMask)) continue;
            if (Vector3.Distance(c.bounds.ClosestPoint(center), center) > radius) continue;
            if (count < results.length) results[count] = c;
            count++;
        }
        return count;
    }

    public static function OverlapCapsuleNonAlloc(point0:Vector3, point1:Vector3, radius:Float, results:Array<Collider>, layerMask:Int, queryTriggerInteraction:QueryTriggerInteraction):Int {
        // PORT-NOTE: capsule overlap approximated with a bounding sphere around the capsule.
        var center = (point0 + point1) * 0.5;
        var halfLen = Vector3.Distance(point0, point1) * 0.5;
        return OverlapSphereNonAlloc(center, radius + halfLen, results, layerMask, queryTriggerInteraction);
    }

    public static function Raycast(origin:Vector3, direction:Vector3, outHit:Dynamic, maxDistance:Float, layerMask:Int):Bool {
        return false;
    }
    public static function RaycastAll(origin:Vector3, direction:Vector3, maxDistance:Float, layerMask:Int):Array<Dynamic> {
        return [];
    }
    public static function CheckBox(center:Vector3, halfExtents:Vector3, orientation:Quaternion, layermask:Int, queryTriggerInteraction:QueryTriggerInteraction):Bool {
        var results:Array<Collider> = [];
        results.resize(1);
        return OverlapBoxNonAlloc(center, halfExtents, results, orientation, layermask, queryTriggerInteraction) > 0;
    }
    public static function CheckSphere(position:Vector3, radius:Float, layerMask:Int, queryTriggerInteraction:QueryTriggerInteraction):Bool {
        var results:Array<Collider> = [];
        results.resize(1);
        return OverlapSphereNonAlloc(position, radius, results, layerMask, queryTriggerInteraction) > 0;
    }
    public static function IgnoreCollision(collider1:Collider, collider2:Collider, ?ignore:Bool = true):Void {}
    public static function SyncTransforms():Void {}
}
