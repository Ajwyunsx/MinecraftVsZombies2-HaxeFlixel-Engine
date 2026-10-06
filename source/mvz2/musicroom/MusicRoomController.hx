package mvz2.musicroom;

import mvz2.managers.MainManager;
import mvz2.saves.MVZ2SaveExt;
import mvz2.scenes.MainScenePage;
import mvz2.ui.musicroom.MusicRoomUI;
import mvz2logic.localization.LogicStrings;
import pvzengine.NamespaceID;
import system.text.StringBuilder;
import unity.Mathf;
import mvz2.localization.LanguageManager;
import Main;
import mvz2.audios.MusicManager;
import mvz2.managers.ResourceManager;
import mvz2.saves.SaveManager;
import unity.Time;
import pvzengine.base.UpdateList;

// Ported from: Assets/Scripts/MVZ2/MusicRoom/MusicRoomController.cs
class MusicRoomController extends MainScenePage {
    override public function Display():Void {
        super.Display();
        UpdateMusicList();
        Main.MusicManager.Stop();
    }

    // #region 私有方法

    // #region 生命周期
    private function Awake():Void {
        ui.OnReturnClick.add(OnIndexReturnClickCallback);
        ui.OnMusicItemClick.add(OnMusicItemClickCallback);
        ui.OnPlayButtonClick.add(OnPlayButtonClickCallback);
        ui.OnPauseButtonClick.add(OnPauseButtonClickCallback);
        ui.OnMusicBarDrag.add(OnMusicBarDragCallback);
        ui.OnMusicBarPointerUp.add(OnMusicBarPointerUpCallback);
        ui.OnTrackButtonClick.add(OnTrackButtonClickCallback);
    }
    private function Update():Void {
        UpdateMusic();
    }
    // #endregion

    // #region 事件回调
    private function OnIndexReturnClickCallback():Void {
        Main.MusicManager.Stop();
        Main.MusicManager.SetTrackWeight(0);
        playingSubTrack = false;
        Return();
    }
    private function OnMusicItemClickCallback(index:Int):Void {
        DisplayMusic(index);
    }
    private function OnPlayButtonClickCallback():Void {
        if (Main.MusicManager.IsPaused && currentMusicId == Main.MusicManager.GetCurrentMusicID()) {
            Main.MusicManager.Resume();
        } else if (NamespaceID.IsValid(currentMusicId)) {
            Main.MusicManager.Play(currentMusicId);
            playingSubTrack = false;
        }
    }
    private function OnPauseButtonClickCallback():Void {
        Main.MusicManager.Pause();
    }
    private function OnTrackButtonClickCallback():Void {
        if (currentMusicId == Main.MusicManager.GetCurrentMusicID()) {
            playingSubTrack = !playingSubTrack;
            ui.SetTrackButtonStyle(playingSubTrack);
        } else {
            ui.SetTrackButtonStyle(false);
        }
    }
    private function OnMusicBarDragCallback(value:Float):Void {
        if (!NamespaceID.IsValid(currentMusicId))
            return;
        var music = Main.MusicManager.GetCurrentMusicID();
        if (currentMusicId != music) {
            Main.MusicManager.Play(currentMusicId);
            playingSubTrack = false;
        }
        Main.MusicManager.Pause();
        Main.MusicManager.SetNormalizedMusicTime(value);
    }
    private function OnMusicBarPointerUpCallback():Void {
        if (Main.MusicManager.IsPaused && currentMusicId == Main.MusicManager.GetCurrentMusicID()) {
            Main.MusicManager.Resume();
        } else if (NamespaceID.IsValid(currentMusicId)) {
            Main.MusicManager.Play(currentMusicId);
            playingSubTrack = false;
        }
        Main.MusicManager.SetNormalizedMusicTime(ui.GetMusicBarValue());
    }
    // #endregion

    private function UpdateMusicList():Void {
        musicList = [];
        var musics = Main.ResourceManager.GetAllMusicID();
        var unlockedMusic = Lambda.filter(musics, function(t) {
            var meta = Main.ResourceManager.GetMusicMeta(t);
            var unlockConditions = meta != null ? meta.UnlockConditions : null;
            return MVZ2SaveExt.IsNullOrMeetsConditions(unlockConditions, Main.SaveManager);
        });
        for (m in unlockedMusic) musicList.push(m);

        ui.UpdateList(Lambda.array(Lambda.map(musicList, m -> Main.ResourceManager.GetMusicName(m))));

        if (musicList.length > 0) {
            DisplayMusic(0);
        }
    }
    private function UpdateMusic():Void {
        var playing = NamespaceID.IsValid(currentMusicId) && Main.MusicManager.IsPlaying(currentMusicId) && !Main.MusicManager.IsPaused;
        ui.SetPlaying(playing);
        var music = Main.MusicManager.GetCurrentMusicID();
        if (music != currentMusicId) {
            ui.SetMusicTime(0, "00:00");
        } else {
            var time = Main.MusicManager.Time;
            // PORT-NOTE: C# 为 `(int)time / 60`（整数除法），Haxe 的 `/` 是浮点除法，需再取整。
            var timeSeconds = Std.int(time);
            var timeString = formatTime(Std.int(timeSeconds / 60), timeSeconds % 60);
            ui.SetMusicTime(Main.MusicManager.GetNormalizedMusicTime(), timeString);
        }
        var weightSpeed = playingSubTrack ? 1 : -1;
        subTrackWeight = Mathf.Clamp01(subTrackWeight + weightSpeed * 0.03);
        Main.MusicManager.SetTrackWeight(subTrackWeight);
    }
    private function DisplayMusic(index:Int):Void {
        var musicID = musicList[index];
        var meta = Main.ResourceManager.GetMusicMeta(musicID);
        if (meta == null)
            return;
        currentMusicId = musicID;
        var name = Main.ResourceManager.GetMusicName(currentMusicId);
        var infoBuilder = new StringBuilder();
        var sourceKey = meta.Source;
        if (sourceKey != null && sourceKey.length > 0) {
            var source = GetTranslatedStringParticular(LogicStrings.CONTEXT_MUSIC_SOURCE, sourceKey, []);
            infoBuilder.AppendLine(GetTranslatedString(INFORMATION_SOURCE, [source]));
        }
        var originKey = meta.Origin;
        if (originKey != null && originKey.length > 0) {
            var origin = GetTranslatedStringParticular(LogicStrings.CONTEXT_MUSIC_ORIGIN, originKey, []);
            infoBuilder.AppendLine(GetTranslatedString(INFORMATION_ORIGIN, [origin]));
        }
        var authorKey = meta.Author;
        if (authorKey != null && authorKey.length > 0) {
            var author = GetTranslatedStringParticular(LogicStrings.CONTEXT_MUSIC_AUTHOR, authorKey, []);
            infoBuilder.AppendLine(GetTranslatedString(INFORMATION_AUTHOR, [author]));
        }

        var description = GetTranslatedStringParticular(LogicStrings.CONTEXT_MUSIC_DESCRIPTION, meta.Description, []);

        var mainTrack = Main.ResourceManager.GetMusicClip(meta.MainTrack);
        var totalTime:String;
        if (mainTrack != null) {
            var time = mainTrack.length;
            // PORT-NOTE: C# 为 `(int)time / 60`（整数除法），Haxe 的 `/` 是浮点除法，需再取整。
            totalTime = formatTime(Std.int(Std.int(time) / 60), Std.int(time) % 60);
        } else {
            totalTime = "??:??";
        }


        ui.UpdateInformation(name, infoBuilder.ToString(), description, totalTime);
        ui.SetSelectedItem(index);
        ui.SetTrackButtonVisible(NamespaceID.IsValid(meta.SubTrack));
        ui.SetTrackButtonStyle(currentMusicId == Main.MusicManager.GetCurrentMusicID() && playingSubTrack);
    }
    // PORT-NOTE: C# `string.Format("{0:00}:{1:00}", ...)`.
    private static function formatTime(minutes:Int, seconds:Int):String {
        return '${pad2(minutes)}:${pad2(seconds)}';
    }
    private static function pad2(value:Int):String {
        var s = Std.string(value);
        return s.length < 2 ? "0" + s : s;
    }
    private function GetTranslatedString(text:String, args:Array<Dynamic>):String {
        if (text == null || text.length == 0)
            return "";
        return Main.LanguageManager._(text, args);
    }
    private function GetTranslatedStringParticular(context:String, text:String, args:Array<Dynamic>):String {
        if (text == null || text.length == 0)
            return "";
        return Main.LanguageManager._p(context, text, args);
    }
    // #endregion

    @:translateMsg("音乐室中的信息模板，{0}为音乐来源")
    public static inline var INFORMATION_SOURCE:String = "来源：{0}";
    @:translateMsg("音乐室中的信息模板，{0}为音乐原曲")
    public static inline var INFORMATION_ORIGIN:String = "原曲：{0}";
    @:translateMsg("音乐室中的信息模板，{0}为音乐作者")
    public static inline var INFORMATION_AUTHOR:String = "作者：{0}";

    private var Main(get, never):MainManager;
    inline function get_Main():MainManager return MainManager.Instance;

    private var musicList:Array<NamespaceID> = [];
    private var currentMusicId:NamespaceID;
    private var playingSubTrack:Bool;
    private var subTrackWeight:Float;

    @:serializeField
    private var ui:MusicRoomUI = null;
}
