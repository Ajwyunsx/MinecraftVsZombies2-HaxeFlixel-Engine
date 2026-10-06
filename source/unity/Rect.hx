package unity;

// Minimal UnityEngine.Rect shim.
class Rect {
    public var x:Float;
    public var y:Float;
    public var width:Float;
    public var height:Float;

    public var xMin(get, set):Float;
    public var yMin(get, set):Float;
    public var xMax(get, set):Float;
    public var yMax(get, set):Float;
    public var center(get, set):Vector2;
    public var position(get, set):Vector2;
    public var size(get, set):Vector2;

    public function new(x:Float = 0, y:Float = 0, width:Float = 0, height:Float = 0) {
        this.x = x;
        this.y = y;
        this.width = width;
        this.height = height;
    }

    inline function get_xMin():Float return x;
    inline function set_xMin(v:Float):Float { width += x - v; x = v; return v; }
    inline function get_yMin():Float return y;
    inline function set_yMin(v:Float):Float { height += y - v; y = v; return v; }
    inline function get_xMax():Float return x + width;
    inline function set_xMax(v:Float):Float { width = v - x; return v; }
    inline function get_yMax():Float return y + height;
    inline function set_yMax(v:Float):Float { height = v - y; return v; }
    inline function get_center():Vector2 return new Vector2(x + width / 2, y + height / 2);
    inline function set_center(v:Vector2):Vector2 { x = v.x - width / 2; y = v.y - height / 2; return v; }
    inline function get_position():Vector2 return new Vector2(x, y);
    inline function set_position(v:Vector2):Vector2 { x = v.x; y = v.y; return v; }
    inline function get_size():Vector2 return new Vector2(width, height);
    inline function set_size(v:Vector2):Vector2 { width = v.x; height = v.y; return v; }

    public var min(get, never):Vector2;
    inline function get_min():Vector2 return new Vector2(xMin, yMin);
    public var max(get, never):Vector2;
    inline function get_max():Vector2 return new Vector2(xMax, yMax);

    public function Contains(point:Vector2):Bool {
        return point.x >= xMin && point.x < xMax && point.y >= yMin && point.y < yMax;
    }
    public function Overlaps(other:Rect):Bool {
        return other.xMax > xMin && other.xMin < xMax && other.yMax > yMin && other.yMin < yMax;
    }
    public function toString():String return '(x:$x, y:$y, width:$width, height:$height)';
}
