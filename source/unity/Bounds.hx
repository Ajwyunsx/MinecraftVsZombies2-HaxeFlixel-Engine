package unity;

// Minimal UnityEngine.Bounds shim.
class Bounds {
    public var center:Vector3 = new Vector3(0, 0, 0); // PORT-NOTE: C# Vector3 为 struct，默认 (0,0,0)；显式初始化避免 abstract-over-class 的 null 解引用
    public var size:Vector3 = new Vector3(0, 0, 0); // PORT-NOTE: C# Vector3 为 struct，默认 (0,0,0)；显式初始化避免 abstract-over-class 的 null 解引用

    public var extents(get, set):Vector3;
    public var min(get, set):Vector3;
    public var max(get, set):Vector3;

    public function new(?center:Vector3, ?size:Vector3) {
        this.center = center != null ? center : new Vector3();
        this.size = size != null ? size : new Vector3();
    }

    inline function get_extents():Vector3 return size * 0.5;
    inline function set_extents(v:Vector3):Vector3 {
        size = v * 2;
        return v;
    }
    inline function get_min():Vector3 return center - extents;
    inline function set_min(v:Vector3):Vector3 {
        var maxV = max;
        size = maxV - v;
        center = (v + maxV) * 0.5;
        return v;
    }
    inline function get_max():Vector3 return center + extents;
    inline function set_max(v:Vector3):Vector3 {
        var minV = min;
        size = v - minV;
        center = (v + minV) * 0.5;
        return v;
    }

    public function Contains(point:Vector3):Bool {
        var mn = min;
        var mx = max;
        return point.x >= mn.x && point.x <= mx.x
            && point.y >= mn.y && point.y <= mx.y
            && point.z >= mn.z && point.z <= mx.z;
    }
    public function Intersects(other:Bounds):Bool {
        var aMin = min, aMax = max;
        var bMin = other.min, bMax = other.max;
        return aMin.x <= bMax.x && aMax.x >= bMin.x
            && aMin.y <= bMax.y && aMax.y >= bMin.y
            && aMin.z <= bMax.z && aMax.z >= bMin.z;
    }
    // PORT-NOTE: Tools.Geometrical extension `Bounds.IntersectsOptimized` (external assembly)
    // is reimplemented here as a plain AABB intersection test.
    public function IntersectsOptimized(other:Bounds):Bool return Intersects(other);

    public function ClosestPoint(point:Vector3):Vector3 {
        var mn = min, mx = max;
        return new Vector3(
            Mathf.Clamp(point.x, mn.x, mx.x),
            Mathf.Clamp(point.y, mn.y, mx.y),
            Mathf.Clamp(point.z, mn.z, mx.z));
    }
    public function Expand(amount:Float):Void {
        size = size + new Vector3(amount, amount, amount) * 2;
    }
    public function SetMinMax(mn:Vector3, mx:Vector3):Void {
        size = mx - mn;
        center = (mn + mx) * 0.5;
    }
    public function toString():String return 'Bounds(center: $center, size: $size)';
}
