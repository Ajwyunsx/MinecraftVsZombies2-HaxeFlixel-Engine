// Ported from: Assets/Scripts/Logic/Shake.cs
package mvz2logic;

import unity.Mathf;
import unity.Quaternion;
import unity.Random;
import unity.Vector2;
import unity.Vector3;

// abstract
class Shake {
    public function new(startAmplitude:Float, endAmplitude:Float) {
        this.startAmplitude = startAmplitude;
        this.endAmplitude = endAmplitude;
    }

    public function GetAmplitude():Float {
        return Mathf.Lerp(startAmplitude, endAmplitude, GetTimePercentage());
    }

    function GetTimePercentage():Float {
        throw "abstract"; // abstract
    }

    public function GetShake2D():Vector2 {
        var radius = Random.Range(0, GetAmplitude());
        var angle = Random.Range(0, 360);
        var rad = Mathf.Deg2Rad * angle;
        return new Vector2(Mathf.Cos(rad), Mathf.Sin(rad)) * radius;
    }

    public function GetShake3D():Vector3 {
        var radius = Random.Range(0, GetAmplitude());
        var angleX = Random.Range(0, 360);
        var angleY = Random.Range(0, 360);
        var angleZ = Random.Range(0, 360);
        var quaternion = Quaternion.Euler(angleX, angleY, angleZ);
        return Quaternion.rotate(quaternion, Vector3.right) * radius;
    }

    public var startAmplitude:Float;
    public var endAmplitude:Float;
}

// [Serializable]
class ShakeInt extends Shake {
    public function new(startAmplitude:Float, endAmplitude:Float, timeout:Int) {
        super(startAmplitude, endAmplitude);
        this.timeout = timeout;
        maxTimeout = timeout;
    }

    public function Run():Void {
        timeout--;
    }

    override function GetTimePercentage():Float {
        return 1 - timeout / maxTimeout;
    }

    public var Expired(get, never):Bool;
    function get_Expired():Bool return timeout <= 0;

    public var timeout:Int;
    public var maxTimeout:Int;
}

// [Serializable]
class ShakeFloat extends Shake {
    public function new(startAmplitude:Float, endAmplitude:Float, timeout:Float) {
        super(startAmplitude, endAmplitude);
        this.timeout = timeout;
        maxTimeout = timeout;
    }

    public function Run(speed:Float):Void {
        timeout -= speed;
    }

    override function GetTimePercentage():Float {
        return 1 - timeout / maxTimeout;
    }

    public var Expired(get, never):Bool;
    function get_Expired():Bool return timeout <= 0;

    public var timeout:Float;
    public var maxTimeout:Float;
}
