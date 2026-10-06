package mvz2.cameras;

import mvz2.managers.MainManager;
import mvz2.options.OptionsManager as OptionsManagerClass;
import mvz2logic.Shake;
import unity.MonoBehaviour;
import unity.Time;
import unity.Vector2;
import unity.Vector3;
import Main;
import mvz2.options.OptionsManager;
import mvz2logic.Shake.ShakeFloat;

// Ported from: Assets/Scripts/MVZ2/Cameras/ShakeManager.cs
// PORT-NOTE: C# 的 `OptionsManager` 是静态类，GetShakeAmount 是其静态扩展方法；
// 移植层 OptionsManager 是实例类，故用 `Main.OptionsManager` 实例 + `using` 调用扩展方法。
using mvz2logic.options.LogicOptionExt;
// PORT-NOTE: the `OptionsManager` instance property shadows the static OptionsManager class
// in Haxe, so the class is imported under the alias `OptionsManagerClass`.
class ShakeManager extends MonoBehaviour {
    public function AddShake(shakeAmp:Float, endAmp:Float, shakeTime:Float):Void {
        shakes.push(new ShakeFloat(shakeAmp, endAmp, shakeTime));
        // PORT-NOTE: the `#if UNITY_ANDROID || UNITY_IOS` Handheld.Vibrate() block is skipped;
        // platform vibration has no equivalent in the Haxe port.
    }
    public function GetShake2D():Vector2 {
        var shake2D:Vector2 = Vector2.zero;
        for (shake in shakes) {
            shake2D += shake.GetShake2D();
        }
        var amount = Main.OptionsManager.GetShakeAmount();
        return shake2D * amount;
    }
    public function GetShake3D():Vector3 {
        var shake3D:Vector3 = Vector3.zero;
        for (shake in shakes) {
            shake3D += shake.GetShake3D();
        }
        var amount = Main.OptionsManager.GetShakeAmount();
        return shake3D * amount;
    }
    private function Update():Void {
        for (shake in shakes) {
            shake.Run(Time.deltaTime);
        }
        shakes = shakes.filter(s -> !s.Expired);
    }
    private var Main(get, never):MainManager;
    inline function get_Main():MainManager return MainManager.Instance;
    private var OptionsManager(get, never):OptionsManagerClass;
    inline function get_OptionsManager():OptionsManagerClass return Main.OptionsManager;
    private var shakes:Array<ShakeFloat> = [];
}
