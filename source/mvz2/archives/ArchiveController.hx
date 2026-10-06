package mvz2.archives;

import mvz2.managers.MainManager;
import mvz2.scenes.MainScenePage;
import mvz2.saves.MVZ2SaveExt;
import mvz2.talk.TalkController;
import mvz2.ui.archive.ArchiveUI;
import mvz2logic.Global;
import mvz2logic.archive.IArchiveInterface;
import mvz2logic.audios.LogicMusicID;
import mvz2logic.callbacks.LogicCallbacks;
import mvz2logic.localization.LogicStrings;
import mvz2logic.resources.SpriteReference;
import mvz2logic.talk.ITalkSystem;
import pvzengine.NamespaceID;
import unity.Vector2;
import unity.Vector3;
import mvz2.localization.LanguageManager;
import Main;
import mvz2.audios.MusicManager;
import mvz2.managers.ResourceManager;
import mvz2.saves.SaveManager;
import mvz2.cameras.ShakeManager;
import mvz2.ui.archive.ArchiveUI.Page;
import mvz2logic.callbacks.LogicCallbacks.TalkActionParams;
import mvz2.ui.archive.ArchiveDetailsSection.ArchiveDetailsSectionViewData;
import mvz2.ui.archive.DetailsArchivePage.ArchiveDetailsViewData;
import mvz2.ui.archive.ArchiveTagItem.ArchiveTagViewData;
import unity.scenemanagement.SceneInstance.Scene;

// Ported from: Assets/Scripts/MVZ2/Archive/ArchiveController.cs
class ArchiveController extends MainScenePage implements IArchiveInterface {
    override public function Display():Void {
        super.Display();
        ui.DisplayPage(Page.Index);
        UpdateIndex();
        if (!Main.MusicManager.IsPlaying(LogicMusicID.choosing))
            Main.MusicManager.Play(LogicMusicID.choosing);
    }

    // #region 私有方法

    // #region 生命周期
    private function Awake():Void {
        ui.OnIndexReturnClick.add(OnIndexReturnClickCallback);
        ui.OnSearchEndEdit.add(OnSearchEndEditCallback);
        ui.OnTalkTagValueChanged.add(OnTalkTagValueChangedCallback);
        ui.OnTalkEntryClick.add(OnTalkEntryClickCallback);

        ui.OnDetailsReturnClick.add(OnDetailsReturnClickCallback);
        ui.OnDetailsPlayClick.add(OnDetailsPlayClickCallback);

        talkSystem = new ArchiveTalkSystem(this, simulationTalk);
        simulationTalk.OnTalkAction.add(OnTalkActionCallback);
    }
    private function Update():Void {
        var shake = Main.ShakeManager.GetShake2D();
        // PORT-NOTE: C# `(Vector3)Vector2` implicit conversion → explicit Vector3 construction.
        ui.SetShake(new Vector3(shake.x, shake.y, 0) * 100);
    }
    // #endregion

    // #region 事件回调
    private function OnIndexReturnClickCallback():Void {
        Return();
    }
    private function OnDetailsReturnClickCallback():Void {
        ui.DisplayPage(Page.Index);
    }
    private function OnSearchEndEditCallback(value:String):Void {
        searchPattern = value;
        UpdateFilteredTalks();
    }
    private function OnTalkTagValueChangedCallback(index:Int, value:Bool):Void {
        if (value) {
            selectedTagIndexes.push(index);
        } else {
            selectedTagIndexes.remove(index);
        }
        UpdateFilteredTalks();
    }
    private function OnTalkEntryClickCallback(index:Int):Void {
        var groupID = filteredTalks[index];
        viewingTalkID = groupID;
        UpdateDetails(groupID);
        ui.DisplayPage(Page.Details);
    }
    private function OnDetailsPlayClickCallback():Void {
        if (NamespaceID.IsValid(viewingTalkID))
            PlayTalk(viewingTalkID);
    }
    private function OnTalkActionCallback(cmd:String, parameters:Array<String>):Void {
        Global.Game.RunCallbackFiltered(LogicCallbacks.TALK_ACTION, new TalkActionParams(talkSystem, cmd, parameters), cmd);
    }
    // #endregion

    public function SetBackground(backgroundRef:SpriteReference):Void {
        // PORT-NOTE: C# 重载 GetFinalSprite(SpriteReference?) 在移植层名为 GetFinalSpriteFromRef。
        var background = Main.GetFinalSpriteFromRef(backgroundRef);
        ui.SetSimulationBackground(background);
    }
    private function ShowReplayDialog():Void {
        var title = Main.LanguageManager._p(LogicStrings.CONTEXT_ARCHIVE, LogicStrings.ARCHIVE_TALK_END);
        var desc = Main.LanguageManager._p(LogicStrings.CONTEXT_ARCHIVE, LogicStrings.ARCHIVE_REPLAY);
        Main.Scene.ShowDialogSelect(title, desc, function(value:Bool) {
            if (value && NamespaceID.IsValid(viewingTalkID)) {
                PlayTalk(viewingTalkID);
            } else {
                ReturnFromSimulation();
            }
        });
    }
    private function UpdateIndex():Void {
        searchPattern = "";
        ui.SetIndexSearch(searchPattern);

        talksList = [];
        var talks = Main.ResourceManager.GetAllTalkGroupsID();
        // PORT-NOTE: C# LINQ (Select/Where/OrderBy/ThenBy) → Lambda helpers.
        var talkGroups = Lambda.filter(Lambda.map(talks, id -> {id: id, group: Main.ResourceManager.GetTalkGroup(id)}), tuple -> tuple.group != null && tuple.group.archive != null);

        // Where(unlockConditions.IsNullOrMeetsConditions).OrderBy(documentOrder).ThenBy(groupOrder)
        var filteredTalks = Lambda.array(Lambda.filter(talkGroups, tuple -> MVZ2SaveExt.IsNullOrMeetsConditions(tuple.group.archive.unlockConditions, Main.SaveManager)));
        filteredTalks.sort(function(a, b) {
            var r = a.group.documentOrder - b.group.documentOrder;
            if (r != 0) return r;
            return a.group.groupOrder - b.group.groupOrder;
        });
        for (g in filteredTalks) talksList.push(g.id);

        tagsList = [];
        var tags:Array<NamespaceID> = [];
        for (g in filteredTalks) {
            for (t in g.group.tags) {
                if (!tags.contains(t)) tags.push(t);
            }
        }
        tags.sort(function(a, b) {
            var pa = Main.ResourceManager.GetArchiveTagMeta(a) != null ? Main.ResourceManager.GetArchiveTagMeta(a).Priority : 0;
            var pb = Main.ResourceManager.GetArchiveTagMeta(b) != null ? Main.ResourceManager.GetArchiveTagMeta(b).Priority : 0;
            return pa - pb;
        });
        for (t in tags) tagsList.push(t);

        selectedTagIndexes = [];
        var tagViewDatas = Lambda.array(Lambda.mapi(tagsList, (index, tag) -> new ArchiveTagViewData({
            name: Main.ResourceManager.GetArchiveTagName(tag),
            value: selectedTagIndexes.contains(index)
        })));
        ui.SetIndexTags(tagViewDatas);

        UpdateFilteredTalks();
    }
    private function UpdateDetails(groupID:NamespaceID):Void {
        var group = Main.ResourceManager.GetTalkGroup(groupID);
        if (group == null || group.archive == null)
            return;
        var name = GetTranslatedString(LogicStrings.CONTEXT_ARCHIVE, group.archive.name);
        var backgroundRef = group.archive.background;
        var background = Main.GetFinalSpriteFromRef(backgroundRef);
        var musicID = group.archive.music;
        var music = Main.ResourceManager.GetMusicName(musicID);
        var tags = Lambda.array(Lambda.map(group.tags, t -> Main.ResourceManager.GetArchiveTagName(t))).join(", ");
        var sections = group.sections;
        var sectionsViewData:Array<ArchiveDetailsSectionViewData> = [];
        sectionsViewData.resize(sections.length);
        for (i in 0...sectionsViewData.length) {
            var section = sections[i];
            var description = GetTranslatedString(LogicStrings.CONTEXT_ARCHIVE, section.archiveText);
            var talks = Lambda.array(Lambda.map(section.sentences, function(s) {
                var description = GetTranslatedString(LogicStrings.CONTEXT_ARCHIVE, s.description);
                var characterName = s.GetSpeakerName(Main);
                var text = GetTranslatedString(LogicStrings.GetTalkTextContext(groupID), s.text);
                if (description == null || description.length == 0) {
                    return GetTranslatedString(LogicStrings.CONTEXT_ARCHIVE, SENTENCE_TEMPLATE, [characterName, text]);
                } else {
                    return GetTranslatedString(LogicStrings.CONTEXT_ARCHIVE, SENTENCE_TEMPLATE_DESCRIPTION, [description, characterName, text]);
                }
            }));
            var talksString = talks.join("\n");
            sectionsViewData[i] = new ArchiveDetailsSectionViewData({
                description: description,
                talks: talksString
            });
        }
        var viewData = new ArchiveDetailsViewData({
            name: name,
            background: background,
            segments: Std.string(sections.length),
            music: music,
            tags: tags,
            sections: sectionsViewData
        });
        ui.UpdateDetails(viewData);
    }
    private function UpdateFilteredTalks():Void {
        filteredTalks = [];
        var talkGroups = Lambda.filter(talksList, function(t) {
            var group = Main.ResourceManager.GetTalkGroup(t);
            if (group == null || group.archive == null)
                return false;
            var name = GetTranslatedString(LogicStrings.CONTEXT_ARCHIVE, group.archive.name);
            var selectedTags = Lambda.array(Lambda.map(selectedTagIndexes, i -> tagsList[i]));
            var anyTag = false;
            for (tg in group.tags) {
                if (selectedTags.contains(tg)) {
                    anyTag = true;
                    break;
                }
            }
            return (searchPattern == null || searchPattern.length == 0 || name.indexOf(searchPattern) >= 0)
                && (selectedTags.length <= 0 || anyTag);
        });
        for (g in talkGroups) filteredTalks.push(g);
        ui.SetIndexTalks(Lambda.array(Lambda.map(filteredTalks, function(t) {
            var group = Main.ResourceManager.GetTalkGroup(t);
            if (group == null || group.archive == null)
                return Std.string(t);
            return GetTranslatedString(LogicStrings.CONTEXT_ARCHIVE, group.archive.name);
        })));
    }
    private function PlayTalk(groupID:NamespaceID):Void {
        var group = Main.ResourceManager.GetTalkGroup(groupID);
        if (group == null || group.archive == null)
            return;
        var backgroundRef = group.archive.background;
        var background = Main.GetFinalSpriteFromRef(backgroundRef);
        var musicID = group.archive.music;
        ui.SetSimulationBackground(background);
        ui.DisplayPage(Page.Simulation);
        simulationTalk.StartTalk(groupID, 0, ShowReplayDialog);
        Main.MusicManager.StopFade();
        Main.MusicManager.SetVolume(1);
        if (NamespaceID.IsValid(musicID)) {
            Main.MusicManager.Play(musicID);
        } else {
            Main.MusicManager.Stop();
        }
    }
    private function ReturnFromSimulation():Void {
        if (!Main.MusicManager.IsPlaying(LogicMusicID.choosing))
            Main.MusicManager.Play(LogicMusicID.choosing);
        Main.MusicManager.StopFade();
        Main.MusicManager.SetVolume(1);
        ui.DisplayPage(Page.Details);
    }
    private function GetTranslatedString(context:String, text:String, args:Array<Dynamic> = null):String {
        if (text == null || text.length == 0)
            return "";
        return Main.LanguageManager._p(context, text, args != null ? args : []);
    }
    // #endregion

    @:translateMsg("对话档案中语句的模板，{0}为人物，{1}为语句内容")
    public static inline var SENTENCE_TEMPLATE:String = "<b>[{0}]</b> {1}";
    @:translateMsg("对话档案中语句的模板，{0}为前缀描述，{1}为人物，{2}为语句内容")
    public static inline var SENTENCE_TEMPLATE_DESCRIPTION:String = "<color=blue>{0}</color>\n<b>[{1}]</b> {2}";

    private var Main(get, never):MainManager;
    inline function get_Main():MainManager return MainManager.Instance;

    private var searchPattern:String;
    private var selectedTagIndexes:Array<Int> = [];
    private var tagsList:Array<NamespaceID> = [];
    private var talksList:Array<NamespaceID> = [];
    private var filteredTalks:Array<NamespaceID> = [];

    private var viewingTalkID:NamespaceID;

    private var talkSystem:ITalkSystem = null;

    @:serializeField
    private var ui:ArchiveUI = null;
    @:serializeField
    private var simulationTalk:TalkController = null;
}

// PORT-NOTE: C# tuple + anonymous-type LINQ chains above are expressed with anonymous
// structures ({id:, group:}). Type here mirrors the query element shape.
typedef TalkGroupPair = {
    var id:NamespaceID;
    var group:Dynamic;
}
