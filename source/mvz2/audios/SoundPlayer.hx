package mvz2.audios;

import mvz2.managers.MainManager;
import pvzengine.NamespaceID;
import pvzengine.base.NamespaceIDReference;
import unity.MonoBehaviour;
import unity.Vector3;

// Ported from: Assets/Scripts/MVZ2/Audios/SoundPlayer.cs
class SoundPlayer extends MonoBehaviour {
    public function Play2D():Void {
        Play2DByID(soundID.Get());
    }
    public function PlaySound2D(idString:String):Void {
        Play2DByID(NamespaceID.Parse(idString, MainManager.Instance.BuiltinNamespace));
    }
    // PORT-NOTE: C# 重载 Play2D(NamespaceID id)（与无参 Play2D() 同名）在 Haxe 中不允许，
    // 沿用工程内 `SpawnByID` 的命名约定改名为 Play2DByID。
    public function Play2DByID(id:NamespaceID):Void {
        MainManager.Instance.SoundManager.Play(id, Vector3.zero, pitch, 0);
    }

    @:serializeField
    private var soundID:NamespaceIDReference = null;
    @:serializeField
    private var pitch:Float = 1;
}
