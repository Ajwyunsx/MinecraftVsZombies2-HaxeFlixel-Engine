// Ported from: Tools vector extension methods used by MVZ2 (external Tools assembly)
// PORT-NOTE: the original Tools assembly defines RotateClockwise as an extension method on Vector2;
// here it is a plain static helper called explicitly at the ported call sites.
package tools;

import unity.Vector2;

class VectorExt
{
    public static function RotateClockwise(vector:Vector2, degrees:Float):Vector2
    {
        var rad = degrees * Math.PI / 180;
        var cos = Math.cos(rad);
        var sin = Math.sin(rad);
        return new Vector2(vector.x * cos + vector.y * sin, -vector.x * sin + vector.y * cos);
    }
}
