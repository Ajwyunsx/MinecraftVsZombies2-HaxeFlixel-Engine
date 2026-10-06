package mvz2.note;

import mvz2.managers.MainManager;
import mvz2.scenes.MainScenePage;
import mvz2.talk.TalkController;
import mvz2.ui.note.NoteUI;
import mvz2logic.Global;
import mvz2logic.audios.LogicSoundID;
import mvz2logic.callbacks.LogicCallbacks;
import mvz2logic.notes.INote;
import mvz2logic.notes.LogicNoteProps;
import mvz2logic.notes.NoteDefinition;
import mvz2logic.talk.ITalkSystem;
import pvzengine.NamespaceID;
import system.io.Path;
import mvz2.managers.ResourceManager;
import mvz2.audios.SoundManager;
import mvz2logic.callbacks.LogicCallbacks.TalkActionParams;

// PORT-NOTE: C# 中 GetNoteDefinition / GetNoteSprite / GetNoteBackground / GetFlipNoteSprite /
// CanFlip / GetStartTalk / SimpleStartTalkAsync 都是扩展方法，Haxe 侧用 `using` 还原为调用点方法形式。
using mvz2logic.games.LogicGameDefinitionsExt;
using mvz2logic.notes.LogicNoteProps;
using mvz2.talk.TalkHelper;

// Ported from: Assets/Scripts/MVZ2/Note/NoteController.cs
// PORT-NOTE: C# `async void SetNote` → Void; the awaited talk is started without blocking.
class NoteController extends MainScenePage implements INote {
    public function SetNote(id:NamespaceID):Void {
        var def:NoteDefinition = main.Game.GetNoteDefinition(id);
        if (def == null)
            return;
        definition = def;
        isFlipped = false;
        // PORT-NOTE: C# Main.GetFinalSprite(SpriteReference?) 因重载改名，见 MainManager。
        ui.SetNoteSprite(main.GetFinalSpriteFromRef(def.GetNoteSprite()));
        ui.SetBackground(main.GetFinalSpriteFromRef(def.GetNoteBackground()));
        ui.SetCanFlip(def.CanFlip());
        ui.SetFlipAtLeft(isFlipped);
        var startTalk = def.GetStartTalk();
        if (startTalk == null) startTalk = new NamespaceID(id.SpaceName, '${id.Path}_note');
        if (main.ResourceManager.CanStartTalk(startTalk, 0)) {
            // TODO-PORT: `await talkController.SimpleStartTalkAsync(...)` requires coroutine
            // restructuring at the call site.
            talkController.SimpleStartTalkAsync(startTalk, 0, 3, () -> SetInteractable(false));
        }
        SetInteractable(true);
    }
    public function SetButtonText(text:String):Void {
        ui.SetButtonText(text);
    }
    public function SetInteractable(interactable:Bool):Void {
        ui.SetButtonInteractable(interactable);
    }
    // #region 生命周期
    private function Awake():Void {
        ui.OnNoteFlipClick.add(OnNoteFlipClickCallback);
        ui.OnButtonClick.add(OnButtonClickCallback);
        talkController.OnTalkAction.add(OnTalkActionCallback);
        talkSystem = new NoteTalkSystem(talkController);
    }
    // #endregion

    // #region 事件回调
    private function OnNoteFlipClickCallback():Void {
        isFlipped = !isFlipped;
        main.SoundManager.Play2D(LogicSoundID.paper);
        var sprRef = isFlipped ? definition.GetFlipNoteSprite() : definition.GetNoteSprite();
        ui.SetNoteSprite(main.GetFinalSpriteFromRef(sprRef));
        ui.SetFlipAtLeft(isFlipped);
    }
    private function OnButtonClickCallback():Void {
        if (definition != null) definition.OnBack(this);
    }
    private function OnTalkActionCallback(cmd:String, parameters:Array<String>):Void {
        Global.Game.RunCallbackFiltered(LogicCallbacks.TALK_ACTION, new TalkActionParams(talkSystem, cmd, parameters), cmd);
    }
    // #endregion

    // #region 属性字段
    private var main(get, never):MainManager;
    inline function get_main():MainManager return MainManager.Instance;

    private var definition:NoteDefinition = null;
    private var talkSystem:ITalkSystem = null;
    private var isFlipped:Bool;
    @:serializeField
    private var talkController:TalkController = null;
    @:serializeField
    private var ui:NoteUI = null;
    // #endregion
}
