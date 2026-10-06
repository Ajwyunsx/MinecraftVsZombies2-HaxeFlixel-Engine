package mvz2.audios;

import mvz2.ui.FloatFader;
import pvzengine.NamespaceID;
import unity.AudioSource;
import unity.MonoBehaviour;

// Ported from: Assets/Scripts/MVZ2/Audios/SoundSource.cs
class SoundSource extends MonoBehaviour {
    public function StartFade(target:Float, time:Float):Void {
        volumeFader.StartFade(target, time);
    }
    public function StopFade():Void {
        volumeFader.StopFade();
    }
    private function Awake():Void {
        volumeFader.OnValueChanged.add(function(v:Float) audioSource.volume = v);
    }
    public var SoundID:NamespaceID = null;
    public var AudioSource(get, never):AudioSource;
    inline function get_AudioSource():AudioSource return audioSource;
    public var Intensity:Float;
    public var Volume(get, set):Float;
    function get_Volume():Float return volumeFader.Value;
    function set_Volume(value:Float):Float {
        volumeFader.Value = value;
        return value;
    }
    public var Pitch(get, set):Float;
    function get_Pitch():Float return audioSource.pitch;
    function set_Pitch(value:Float):Float {
        audioSource.pitch = value;
        return value;
    }
    @:serializeField
    private var audioSource:AudioSource = null;
    @:serializeField
    private var volumeFader:FloatFader = null;
}
