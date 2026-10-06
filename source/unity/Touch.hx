package unity;

import flixel.FlxG;

// Minimal UnityEngine.Touch shim.
class Touch {
    public var fingerId:Int = 0;
    public var position:Vector2 = new Vector2();
    public var rawPosition:Vector2 = new Vector2();
    public var deltaPosition:Vector2 = new Vector2();
    public var deltaTime:Float = 0;
    public var tapCount:Int = 1;
    public var phase:TouchPhase = TouchPhase.Began;
    public var pressure:Float = 1;
    public var maximumPossiblePressure:Float = 1;
    public var radius:Float = 0;
    public var type:Int = 0;
    public var altitudeAngle:Float = 0;
    public var azimuthAngle:Float = 0;

    public function new() {}
}

// Minimal UnityEngine.TouchPhase shim.
enum abstract TouchPhase(Int) {
    var Began = 0;
    var Moved = 1;
    var Stationary = 2;
    var Ended = 3;
    var Canceled = 4;
}
