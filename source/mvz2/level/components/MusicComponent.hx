package mvz2.level.components;

import mvz2.level.LevelController;
import mvz2logic.Global;
import mvz2logic.level.components.ComponentInterfaces.IMusicComponent;
import pvzengine.NamespaceID;
import pvzengine.level.LevelEngine;
import mvz2.audios.MusicManager;
import mvz2logic.LogicMain;
import Main;

// Ported from: Assets/Scripts/MVZ2/Audios/MusicComponent.cs
class MusicComponent extends MVZ2Component implements IMusicComponent {
    public function new(level:LevelEngine, controller:LevelController) {
        super(level, componentID, controller);
    }
    override public function Update():Void {
        super.Update();
        Controller.SetMusicLowQuality(Level.IsMusicLowQuality());
    }
    public function Play(id:NamespaceID):Void {
        Main.MusicManager.Play(id);
    }
    public function Stop():Void {
        Main.MusicManager.Stop();
    }
    public function IsPlayingMusic(id:NamespaceID):Bool {
        return Main.MusicManager.IsPlaying(id);
    }
    public function SetPlayingMusic(id:NamespaceID):Void {
        Main.MusicManager.SetPlayingMusic(id);
    }
    public function GetMusicVolume():Float {
        return Controller.MusicVolume;
    }
    public function SetMusicVolume(volume:Float):Void {
        Controller.MusicVolume = volume;
    }
    public function GetSubtrackWeight():Float {
        return Controller.MusicTrackWeight;
    }
    public function SetSubtrackWeight(weight:Float):Void {
        Controller.MusicTrackWeight = weight;
    }
    // PORT-NOTE: C# 写作 `MVZ2Logic.Global.BuiltinNamespace`，Haxe 里对应 mvz2logic.Global 的静态属性
    // （LogicMain 上没有 Global 成员）。
    // PORT-NOTE: C# 的 static readonly 字段是首次使用时才初始化；hxcpp 会在 main() 之前执行全部静态初始化
    // （__boot_all()），那时 Global.Game / MainManager.Instance 仍为 null，直接求值会段错误。
    // 此处改为惰性 getter（结果缓存一次，等价于 C# 的 readonly static），还原 C# 语义。
    public static var componentID(get, never):NamespaceID;
    private static var _componentID:NamespaceID;
    static function get_componentID():NamespaceID
    {
    	if (_componentID == null) _componentID = new NamespaceID(Global.BuiltinNamespace, "music");
    	return _componentID;
    }
}
