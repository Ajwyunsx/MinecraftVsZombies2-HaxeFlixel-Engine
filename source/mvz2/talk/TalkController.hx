// Ported from: Assets/Scripts/MVZ2/Talks/Components/TalkController.cs
package mvz2.talk;

import mvz2.talk.TalkCharacterController.CharacterSide;
import mvz2logic.talk.ITalkSystem;  // UNKNOWNIMPORT

import flixel.util.FlxSignal.FlxTypedSignal;
import mvz2.io.XMLHelper;
import mvz2.managers.MainManager;
import mvz2.talkdata.TalkCharacter;
import mvz2.talkdata.TalkScript;
import mvz2.talkdata.TalkSection;
import mvz2.talkdata.TalkSentence;
import mvz2.ui.ColorFader;
import mvz2.ui.talk.SpeechBubble.SpeechBubbleDirection;  // IMPORTFIX
import mvz2.ui.talk.TalkUI;
import mvz2logic.ParseHelper;
import mvz2logic.audios.LogicSoundID;
import mvz2logic.localization.LogicStrings;
import mvz2logic.resources.SpriteReference;
import mvz2logic.talk.ITalkController;
import pvzengine.Log;
import pvzengine.NamespaceID;
import system.threading.tasks.Task;
import unity.Color;
import unity.ColorUtility;
import unity.Debug;
import unity.GameObject;
import unity.Transform;
import unity.Vector3;
using mvz2logic.ParseHelper;  // EXTUSING
using pvzengine.PropertyKeyHelper;  // EXTUSING

// PORT-NOTE: C# 的 async/await 在本移植中同步化；保留返回 Task 的方法签名以匹配
// ITalkSystem/CoroutineManager 的移植约定，调用 await 处改为 `.awaitResult()`。
class TalkController extends unity.MonoBehaviour implements ITalkController {
    public function new() {
        super();
    }

    // #region 公有方法
    /// <summary>
    /// 开始进行对话。
    /// </summary>
    public function StartTalk(groupId:NamespaceID, sectionIndex:Int, delay:Float = 0, ?onEnd:Void->Void):Void {
        StartTalkAsync(groupId, sectionIndex, delay);
        if (onEnd != null) onEnd();
    }
    /// <summary>
    /// 开始进行对话。
    /// </summary>
    public function StartTalkAsync(groupId:NamespaceID, startingSection:Int, delay:Float = 0):Task {
        var group = Main.ResourceManager.GetTalkGroup(groupId);
        if (group == null) {
            Log.LogWarning('Could not find talk group with id ${groupId}.');
            return Task.CompletedTask;
        }
        if (IsTalking)
            return Task.CompletedTask;
        tcs = new unity.TaskCompletionSource();

        SetupForStarting(groupId, startingSection);

        // 执行开始指令。
        var section = group.sections[startingSection];
        if (section.startScripts != null) {
            ExecuteScriptsAsync(section.startScripts);
        }

        // 延迟。
        if (delay > 0) {
            Main.CoroutineManager.DelaySeconds(delay).awaitResult();
        }

        // 延迟完毕。
        // 创建角色。
        InitSectionCharacters(section);

        // 延迟半秒。
        Main.CoroutineManager.DelaySeconds(0.5).awaitResult();

        // 设置阻挡和跳过按钮。
        canClick = true;
        ui.SetBlockerActive(false);
        ui.SetSkipButtonActive(true);
        // 开始语句。
        StartSentence();

        if (tcs != null) {
            tcs.Task.awaitResult();
        }
        return Task.CompletedTask;
    }
    public function AutoSkipTalks(groupId:NamespaceID, sectionIndex:Int, ?onSkipped:Void->Void):Void {
        AutoSkipTalksAsync(groupId, sectionIndex);
        if (onSkipped != null) onSkipped();
    }
    public function AutoSkipTalksAsync(groupId:NamespaceID, startSection:Int):Task {
        var group = Main.ResourceManager.GetTalkGroup(groupId);
        if (group == null)
            return Task.CompletedTask;
        if (group.archive != null) {
            var dialogName = Main.LanguageManager._p(LogicStrings.CONTEXT_ARCHIVE, group.archive.name);
            var popup = Main.LanguageManager._(DIALOG_SKIPPED, [dialogName]);
            Main.Scene.ShowPopup(popup);
        }
        var section = group.sections[startSection];
        // 执行开始指令。
        var skipScripts:Array<TalkScript>;
        if (section.autoSkipScripts != null) {
            skipScripts = section.autoSkipScripts;
        } else if (section.skipScripts != null && !section.notUseSkipScriptsForAutoSkip) {
            skipScripts = section.skipScripts;
        } else {
            skipScripts = GetDefaultSectionSkipScripts();
        }
        ExecuteScriptsAsync(skipScripts);
        return Task.CompletedTask;
    }
    public function WillSkipTalk(groupId:NamespaceID, sectionIndex:Int):Bool {
        return Main.ResourceManager.WillSkipTalk(groupId, sectionIndex);
    }
    // #endregion

    // #region 私有方法

    // #region 生命周期
    private function Awake():Void {
        // PORT-NOTE: C# 中 characterTemplate 是 GameObject，移植层直接调 SetActive。
        characterTemplate.SetActive(false);
        ui.OnSkipClick.add(OnSkipClickedCallback);
        ui.OnClick.add(OnClickCallback);
    }
    private function Update():Void {
        ui.SetShake(cast(Main.ShakeManager.GetShake2D(), Vector3) * 100);
    }
    private function OnDisable():Void {
        StopAllCoroutines();
        ClearCharacters();
    }
    // #endregion

    // #region 事件回调
    private function OnClickCallback():Void {
        if (!canClick)
            return;
        var sentence = GetTalkSentence();
        if (sentence == null) {
            NextSentence();
            return;
        }
        var scripts = sentence.clickScripts != null ? sentence.clickScripts : GetDefaultSentenceClickScripts();
        ExecuteScriptsAsync(scripts);
    }
    private function OnSkipClickedCallback():Void {
        var section = GetTalkSection();
        if (section == null) {
            EndTalk();
            return;
        }
        var skipScripts = section.skipScripts != null ? section.skipScripts : GetDefaultSectionSkipScripts();
        ExecuteScriptsAsync(skipScripts);
    }
    // #endregion

    // #region 参数
    private function ParseArgumentInt(str:String):Int {
        return ParseHelper.ParseInt(str);
    }
    private function ParseArgumentFloat(str:String):Float {
        return ParseHelper.ParseFloat(str);
    }
    private function ParseArgumentColor(str:String):Color {
        // PORT-NOTE: C# 通过 out 返回颜色；ColorUtility 的移植版以 {value:Color} 承接 out 参数。
        var ref:{value:Color} = {value: new Color(1, 1, 1, 0)};
        if (ColorUtility.TryParseHtmlString(str, ref)) {
            return ref.value;
        }
        return new Color(1, 1, 1, 0);
    }
    private function ParseArgumentNamespaceID(str:String):NamespaceID {
        return NamespaceID.Parse(str, Main.BuiltinNamespace);
    }
    private function ParseArgumentSpriteReference(str:String):SpriteReference {
        return SpriteReference.Parse(str, Main.BuiltinNamespace);
    }
    private function ParseCharacterSide(side:String):CharacterSide {
        switch (side) {
            case "left":
                return CharacterSide.Left;
            case "right":
                return CharacterSide.Right;
            case "self":
                return CharacterSide.Self;
            default:
                return CharacterSide.None;
        }
    }
    private function FadeArgumentsColor(fader:ColorFader, args:Array<String>):Void {
        if (args.length >= 3) {
            fader.Value = ParseArgumentColor(args[0]);
            fader.StartFade(ParseArgumentColor(args[1]), ParseArgumentFloat(args[2]));
        } else if (args.length == 2) {
            fader.StartFade(ParseArgumentColor(args[0]), ParseArgumentFloat(args[1]));
        } else if (args.length == 1) {
            fader.StartFade(ParseArgumentColor(args[0]), 1);
        }
    }
    // #endregion

    // #region 脚本
    private function ExecuteScriptSync(script:TalkScript):Void {
        var args = script.arguments;
        switch (script.functionName) {
            // #region 流程控制
            case "next":
                NextSentence();

            case "sentence":
                SetSentence(ParseArgumentInt(args[0]));

            case "end":
                EndTalk();
            // #endregion

            // #region 人物相关
            case "character":
                {
                    switch (args[0]) {
                        case "create":
                            {
                                var characterId = ParseArgumentNamespaceID(args[1]);
                                var side = ParseCharacterSide(args[2]);
                                var variant = DEFAULT_VARIANT_ID;
                                if (args.length > 3) {
                                    variant = ParseArgumentNamespaceID(args[3]);
                                }
                                CreateCharacter(characterId, variant, side);
                            }
                        case "variant":
                            {
                                var targetCharacter = ParseArgumentNamespaceID(args[1]);
                                var characterIndex = GetCharacterIndex(targetCharacter);
                                if (characterIndex < 0)
                                    return;
                                var variant = ParseArgumentNamespaceID(args[2]);

                                SetCharacterVariant(characterIndex, targetCharacter, variant);
                            }
                        case "leave":
                            {
                                var characterId = ParseArgumentNamespaceID(args[1]);
                                CharacterLeave(characterId);
                            }
                        case "leaveall":
                            {
                                AllCharactersLeave();
                            }
                        case "faint":
                            {
                                var characterId = ParseArgumentNamespaceID(args[1]);
                                var duration = 1.0;
                                if (args.length > 2) {
                                    duration = ParseArgumentFloat(args[2]);
                                }
                                var characterIndex = GetCharacterIndex(characterId);
                                if (characterIndex < 0)
                                    return;

                                CharacterFaint(characterIndex, duration);
                            }
                        case "clear":
                            {
                                ClearCharacters();
                            }
                        case "init":
                            {
                                var section = GetTalkSection();
                                if (section == null)
                                    return;
                                InitSectionCharacters(section);
                            }
                        case "layer":
                            {
                                var characterId = ParseArgumentNamespaceID(args[1]);
                                var layer = args[2];
                                var characterIndex = GetCharacterIndex(characterId);
                                if (characterIndex < 0)
                                    return;
                                var controller = GetCharacter(characterIndex);
                                if (controller == null)
                                    return;
                                switch (layer) {
                                    case "first":
                                        controller.SetToTheFirstLayer();
                                    case "last":
                                        controller.SetToTheLastLayer();
                                    default:
                                }
                            }
                        default:
                    }
                }
            // #endregion

            // #region 贴图
            case "foreground":
                {
                    switch (args[0]) {
                        case "change":
                            ui.SetForegroundSprite(Main.GetFinalSpriteFromRef(ParseArgumentSpriteReference(args[1])));
                        case "alpha":
                            ui.SetForegroundAlpha(ParseArgumentFloat(args[1]));
                        case "fade":
                            if (args.length >= 4) {
                                ui.SetForegroundAlpha(ParseArgumentFloat(args[1]));
                                ui.StartForegroundFade(ParseArgumentFloat(args[2]), ParseArgumentFloat(args[3]));
                            } else if (args.length == 3) {
                                ui.StartForegroundFade(ParseArgumentFloat(args[1]), ParseArgumentFloat(args[2]));
                            } else if (args.length == 2) {
                                ui.StartForegroundFade(ParseArgumentFloat(args[1]), 1);
                            }
                        default:
                    }
                }
            case "background":
                {
                    switch (args[0]) {
                        case "change":
                            ui.SetBackgroundSprite(Main.GetFinalSpriteFromRef(ParseArgumentSpriteReference(args[1])));
                        case "alpha":
                            ui.SetBackgroundAlpha(ParseArgumentFloat(args[1]));
                        case "fade":
                            if (args.length >= 4) {
                                ui.SetBackgroundAlpha(ParseArgumentFloat(args[1]));
                                ui.StartBackgroundFade(ParseArgumentFloat(args[2]), ParseArgumentFloat(args[3]));
                            } else if (args.length == 3) {
                                ui.StartBackgroundFade(ParseArgumentFloat(args[1]), ParseArgumentFloat(args[2]));
                            } else if (args.length == 2) {
                                ui.StartBackgroundFade(ParseArgumentFloat(args[1]), 1);
                            }
                        default:
                    }
                }
            case "portal":
                {
                    switch (args[0]) {
                        case "set":
                            Main.Scene.SetPortalAlpha(ParseArgumentFloat(args[1]));
                        case "fade":
                            {
                                if (args.length >= 4) {
                                    Main.Scene.SetPortalAlpha(ParseArgumentFloat(args[1]));
                                    Main.Scene.StartPortalFade(ParseArgumentFloat(args[2]), ParseArgumentFloat(args[3]));
                                } else if (args.length == 3) {
                                    Main.Scene.StartPortalFade(ParseArgumentFloat(args[1]), ParseArgumentFloat(args[2]));
                                } else if (args.length == 2) {
                                    Main.Scene.StartPortalFade(ParseArgumentFloat(args[1]), 1);
                                }
                            }
                        default:
                    }
                }
            case "forecolor":
                {
                    switch (args[0]) {
                        case "set":
                            ui.SetForecolor(ParseArgumentColor(args[1]));
                        case "fade":
                            {
                                if (args.length >= 4) {
                                    ui.SetForecolor(ParseArgumentColor(args[1]));
                                    ui.StartForecolorFade(ParseArgumentColor(args[2]), ParseArgumentFloat(args[3]));
                                } else if (args.length == 3) {
                                    ui.StartForecolorFade(ParseArgumentColor(args[1]), ParseArgumentFloat(args[2]));
                                } else if (args.length == 2) {
                                    ui.StartForecolorFade(ParseArgumentColor(args[1]), 1);
                                }
                            }
                        default:
                    }
                }
            case "backcolor":
                {
                    switch (args[0]) {
                        case "set":
                            ui.SetBackcolor(ParseArgumentColor(args[1]));
                        case "fade":
                            {
                                if (args.length >= 4) {
                                    ui.SetBackcolor(ParseArgumentColor(args[1]));
                                    ui.StartBackcolorFade(ParseArgumentColor(args[2]), ParseArgumentFloat(args[3]));
                                } else if (args.length == 3) {
                                    ui.StartBackcolorFade(ParseArgumentColor(args[1]), ParseArgumentFloat(args[2]));
                                } else if (args.length == 2) {
                                    ui.StartBackcolorFade(ParseArgumentColor(args[1]), 1);
                                }
                            }
                        default:
                    }
                }

            case "shake":
                {
                    var shakeAmp = 0.1;
                    var shakeTime = 0.5;
                    var endAmp = 0.0;
                    if (args.length > 0) {
                        shakeAmp = ParseArgumentFloat(args[0]);
                    }
                    if (args.length > 1) {
                        shakeTime = ParseArgumentFloat(args[1]);
                    }
                    if (args.length > 2) {
                        endAmp = ParseArgumentFloat(args[2]);
                    }
                    Main.ShakeManager.AddShake(shakeAmp, endAmp, shakeTime);
                }
            // #endregion

            // #region 音频
            case "music":
                switch (args[0]) {
                    case "fade":
                        {
                            if (args.length >= 4) {
                                Main.MusicManager.SetVolume(ParseArgumentFloat(args[1]));
                                Main.MusicManager.StartFade(ParseArgumentFloat(args[2]), ParseArgumentFloat(args[3]));
                            } else if (args.length == 3) {
                                Main.MusicManager.StartFade(ParseArgumentFloat(args[1]), ParseArgumentFloat(args[2]));
                            } else if (args.length == 2) {
                                Main.MusicManager.StartFade(ParseArgumentFloat(args[1]), 1);
                            }
                        }
                    case "volume":
                        var volume = ParseArgumentFloat(args[1]);
                        Main.MusicManager.SetVolume(volume);
                        Main.MusicManager.StopFade();
                    case "play":
                        var musicId = ParseArgumentNamespaceID(args[1]);
                        Main.MusicManager.Play(musicId);
                    case "stop":
                        Main.MusicManager.Stop();
                    default:
                }
            case "playsound":
                {
                    Main.SoundManager.Play2D(ParseArgumentNamespaceID(args[0]));
                }
            case "loopsound":
                switch (args[0]) {
                    case "play":
                        {
                            var soundId = ParseArgumentNamespaceID(args[1]);
                            Main.SoundManager.PlayLoopSound(soundId);
                        }
                    case "stop":
                        {
                            var soundId = ParseArgumentNamespaceID(args[1]);
                            Main.SoundManager.StopLoopSound(soundId);
                        }
                    case "volume":
                        {
                            var soundId = ParseArgumentNamespaceID(args[1]);
                            var volume = ParseArgumentFloat(args[2]);
                            Main.SoundManager.SetLoopSoundIntensity(soundId, volume);
                            Main.SoundManager.StopFadeLoopSound(soundId);
                        }
                    case "fade":
                        {
                            var soundId = ParseArgumentNamespaceID(args[1]);
                            if (args.length >= 5) {
                                Main.SoundManager.SetLoopSoundIntensity(soundId, ParseArgumentFloat(args[2]));
                                Main.SoundManager.StartFadeLoopSound(soundId, ParseArgumentFloat(args[3]), ParseArgumentFloat(args[4]));
                            } else if (args.length == 4) {
                                Main.SoundManager.StartFadeLoopSound(soundId, ParseArgumentFloat(args[2]), ParseArgumentFloat(args[3]));
                            } else if (args.length == 3) {
                                Main.SoundManager.StartFadeLoopSound(soundId, ParseArgumentFloat(args[2]), 1);
                            }
                        }
                    default:
                }
            // #endregion

            // #region 展示物品
            case "item":
                {
                    switch (args[0]) {
                        case "show":
                            var sprite = Main.GetFinalSpriteFromRef(ParseArgumentSpriteReference(args[1]));
                            ui.ShowTalkItem(sprite);
                            showingTalkItem = true;
                            Main.SoundManager.Play2D(LogicSoundID.dialogItemShow);
                        case "hide":
                            if (showingTalkItem) {
                                showingTalkItem = false;
                                ui.HideTalkItem();
                                Main.SoundManager.Play2D(LogicSoundID.dialogItemHide);
                            }
                        default:
                    }
                }
            // #endregion

            // #region 其他
            case "unlock":
                {
                    if (!canUnlock)
                        return;
                    if (args.length <= 0)
                        return;
                    Main.SaveManager.Unlock(ParseArgumentNamespaceID(args[0]));
                    Main.SaveManager.SaveToFile(); // 在对话中解锁时保存游戏
                }

            case "relock":
                {
                    if (!canUnlock)
                        return;
                    if (args.length <= 0)
                        return;
                    Main.SaveManager.Relock(ParseArgumentNamespaceID(args[0]));
                    Main.SaveManager.SaveToFile(); // 在对话中取消解锁时保存游戏
                }

            case "action":
                ExecuteAction(args);

            case "bubble":
                ui.SetSpeechBubbleShowing(args[0] != "hide");
            // #endregion
            default:
        }
    }
    /// <summary>
    /// 执行脚本。
    /// </summary>
    /// <param name="script">对话脚本。</param>
    private function ExecuteScriptAsync(script:TalkScript):Task {
        var args = script.arguments;
        switch (script.functionName) {
            case "section":
                StartSection(ParseArgumentInt(args[0]));
            case "delay":
                canClick = false;
                Main.CoroutineManager.DelaySeconds(ParseArgumentFloat(args[0])).awaitResult();
                canClick = true;
            default:
                ExecuteScriptSync(script);
        }
        return Task.CompletedTask;
    }
    private function ExecuteScriptsAsync(scripts:Array<TalkScript>):Task {
        if (scripts == null)
            return Task.CompletedTask;
        RunningScriptCount++;
        ui.SetBlockerActive(RunningScriptCount > 0);
        for (scr in scripts) {
            ExecuteScriptAsync(scr);
        }
        RunningScriptCount--;
        ui.SetBlockerActive(RunningScriptCount > 0);
        return Task.CompletedTask;
    }
    private function ExecuteAction(args:Array<String>):Void {
        if (OnTalkAction == null)
            return;
        if (args.length <= 0)
            return;
        var func = args[0];
        var actionArgs = args.slice(1);
        try {
            OnTalkAction.dispatch(func, actionArgs);
        } catch (e:Dynamic) {
            Debug.Log('动作"${func}"的参数数组大小(${actionArgs.length})不足：' + e);
        }
    }
    // #endregion

    // #region 流程控制
    private function GetTalkSection():TalkSection {
        if (!NamespaceID.IsValid(groupID))
            return null;
        return Main.ResourceManager.GetTalkSection(groupID, sectionIndex);
    }
    private function GetTalkSentence():TalkSentence {
        if (!NamespaceID.IsValid(groupID))
            return null;
        return Main.ResourceManager.GetTalkSentence(groupID, sectionIndex, sentenceIndex);
    }
    /// <summary>
    /// 开始区间。
    /// </summary>
    public function StartSection(index:Int):Task {
        sectionIndex = index;
        sentenceIndex = 0;
        var section = GetTalkSection();
        if (section != null && section.startScripts != null) {
            ExecuteScriptsAsync(section.startScripts);
        }
        StartSentence();
        return Task.CompletedTask;
    }

    /// <summary>
    /// 跳转到下一个句子。
    /// </summary>
    private function NextSentence():Void {
        sentenceIndex += 1;
        StartSentence();
    }

    /// <summary>
    /// 跳转到指定句子。
    /// </summary>
    /// <param name="index">指定句子的索引。</param>
    private function SetSentence(index:Int):Void {
        sentenceIndex = index;
        StartSentence();
    }

    /// <summary>
    /// 开始句子。
    /// </summary>
    private function StartSentence():Void {
        var sentence = GetTalkSentence();
        if (sentence == null)
            return;


        var speakerID = sentence.speaker;
        // 对话状态。
        for (i in 0...characterList.length) {
            var characterData = characterList[i];
            var isSpeaker = speakerID == characterData.id;

            var controller = characterData.controller;
            controller.SetSpeaking(isSpeaker);
            if (isSpeaker) {
                controller.SetToTheFirstLayer();
            }
        }

        // 切换变种贴图。
        var speakerIndex = GetCharacterIndex(speakerID);
        if (speakerIndex >= 0 && NamespaceID.IsValid(sentence.variant)) {
            SetCharacterVariant(speakerIndex, speakerID, sentence.variant);
        }

        var textKey = sentence.text;
        var bubbleText:String;
        if (NamespaceID.IsValid(groupID)) {
            var context = LogicStrings.GetTalkTextContext(groupID);
            bubbleText = Main.LanguageManager._p(context, textKey);
        } else {
            bubbleText = Main.LanguageManager._(textKey);
        }


        var speakerName = sentence.GetSpeakerName(Main);

        // 气泡位置。
        var bubbleDirection = SpeechBubbleDirection.Up;
        var showSpeakerName = false;
        if (speakerIndex >= 0) {
            var characterData = characterList[speakerIndex];
            bubbleDirection = GetSpeechBubbleDirectionBySide(characterData.side);
        } else {
            bubbleDirection = SpeechBubbleDirection.Up;
            showSpeakerName = true;
        }

        if (ui.GetForegroundAlpha() > 0.1 && bubbleDirection != SpeechBubbleDirection.Up) {
            bubbleDirection = SpeechBubbleDirection.Down;
            showSpeakerName = true;
        }
        if (showSpeakerName) {
            bubbleText = Main.LanguageManager._p(LogicStrings.CONTEXT_TALK, FORGROUND_TALK_TEMPLATE, [speakerName, bubbleText]);
        }
        ui.SetSpeechBubbleText(bubbleText);
        ui.SetSpeechBubbleDirection(bubbleDirection);
        ui.SetSpeechBubbleShowing(true);
        ui.ForceReshowSpeechBubble();

        // 播放音效。
        if (sentence.sounds != null) {
            for (sound in sentence.sounds) {
                Main.SoundManager.Play2D(sound);
            }
        }

        // 执行脚本组。
        var scripts = sentence.startScripts != null ? sentence.startScripts : GetDefaultSentenceStartScripts();
        ExecuteScriptsAsync(scripts);
    }

    private function EndTalk():Void {
        ResetForEnding();

        if (tcs != null) {
            var source = tcs;
            tcs = null;
            source.SetResult(null);
        }
    }
    // #endregion


    // #region 角色
    private function GetCharacterIndex(id:NamespaceID):Int {
        return Lambda.findIndex(characterList, d -> d.id == id);
    }
    private function GetCharacter(index:Int):TalkCharacterController {
        if (index < 0 || index >= characterList.length)
            return null;
        return characterList[index].controller;
    }


    private function InitSectionCharacters(section:TalkSection):Void {
        var characters = section.characters;
        for (chr in characters) {
            CreateCharacter(chr.id, chr.variant, ParseCharacterSide(chr.side));
        }
    }
    public function CreateCharacter(characterId:NamespaceID, variant:NamespaceID, side:CharacterSide):Void {
        // PORT-NOTE: 原 C# 为 Instantiate(characterTemplate, characterRoot)；unity 的 Instantiate
        // shim 只支持位置/旋转，故实例化后显式设置父节点。
        var go:GameObject = unity.UnityObject.Instantiate(characterTemplate);
        go.transform.SetParent(characterRoot, false);
        var chr = go.GetComponent(TalkCharacterController);
        chr.gameObject.SetActive(true);

        var faceRight = false;
        var characterMeta = Main.ResourceManager.GetCharacterMeta(characterId);
        if (characterMeta != null) {
            faceRight = characterMeta.faceRight;
        }

        chr.SetVariant(characterId, variant);
        chr.SetSide(side, faceRight);
        characterList.push(new CharacterData(characterId, side, chr));
    }


    public function RemoveCharacter(characterID:NamespaceID):Bool {
        var index = GetCharacterIndex(characterID);
        if (index < 0)
            return false;
        RemoveCharacterAt(index);
        return true;
    }
    public function RemoveCharacterAt(index:Int):Void {
        characterList.splice(index, 1);
    }


    public function DestroyCharacter(characterID:NamespaceID):Bool {
        var index = GetCharacterIndex(characterID);
        if (index < 0)
            return false;
        DestroyCharacterAt(index);
        return true;
    }
    public function DestroyCharacterAt(index:Int):Void {
        var chr = GetCharacter(index);
        if (chr != null)
            unity.UnityObject.Destroy(chr.gameObject);
        RemoveCharacterAt(index);
    }


    public function ClearCharacters():Void {
        for (data in characterList) {
            unity.UnityObject.Destroy(data.controller.gameObject);
        }
        characterList = [];
    }

    public function SetCharacterVariant(index:Int, characterId:NamespaceID, variantId:NamespaceID):Void {
        var speaker = GetCharacter(index);
        if (speaker != null) {
            speaker.SetVariant(characterId, variantId);
        }
    }

    public function CharacterDisappear(index:Int, disappearSpeed:Float):Void {
        var character = GetCharacter(index);
        if (character != null) {
            character.SetDisappear(true);
            character.SetDisappearSpeed(disappearSpeed);
            RemoveCharacterAt(index);
        }
    }
    private function CharacterLeave(id:NamespaceID):Void {
        var index = GetCharacterIndex(id);
        if (index < 0)
            return;
        CharacterLeaveAt(index);
    }
    public function CharacterLeaveAt(index:Int):Void {
        var chr = GetCharacter(index);
        if (chr != null) {
            chr.SetLeaving(true);
            RemoveCharacterAt(index);
        }
    }
    private function AllCharactersLeave():Void {
        var i = characterList.length - 1;
        while (i >= 0) {
            CharacterLeaveAt(i);
            i--;
        }
    }
    private function CharacterFaint(index:Int, duration:Float):Void {
        CharacterDisappear(index, 1 / duration);
    }

    // #endregion

    private function GetSpeechBubbleDirectionBySide(side:CharacterSide):SpeechBubbleDirection {
        switch (side) {
            case CharacterSide.Left:
                return SpeechBubbleDirection.Left;
            case CharacterSide.Right:
                return SpeechBubbleDirection.Right;
            case CharacterSide.Self:
                return SpeechBubbleDirection.Down;
            default:
                return SpeechBubbleDirection.Up;
        }
    }

    private function SetupForStarting(groupId:NamespaceID, startingSection:Int):Void {
        IsTalking = true;
        groupID = groupId;
        sectionIndex = startingSection;
        sentenceIndex = 0;

        ResetUIForStarting();
    }
    private function ResetUIForStarting():Void {
        ui.SetSpeechBubbleShowing(false);
        ui.SetRaycastReceiverActive(true);

        ui.SetForecolor(Color.clear);
        ui.SetBackcolor(Color.clear);
        ui.SetForegroundAlpha(0);
        ui.SetBackgroundAlpha(0);
        ui.SetForegroundSprite(null);
        ui.SetBackgroundSprite(null);

        ui.SetBlockerActive(true);
        ui.SetSkipButtonActive(false);

        ClearCharacters();
    }
    private function ResetForEnding():Void {
        groupID = null;
        sectionIndex = -1;
        sentenceIndex = -1;
        IsTalking = false;
        canClick = false;

        ResetUIForEnding();
    }
    private function ResetUIForEnding():Void {
        ui.SetSpeechBubbleShowing(false);
        ui.SetRaycastReceiverActive(false);

        if (ui.gameObject.activeInHierarchy) {
            ui.StartBackcolorFade(Color.clear, 1);
            ui.StartForecolorFade(Color.clear, 1);
            ui.StartBackgroundFade(0, 1);
            ui.StartForegroundFade(0, 1);
        } else {
            ui.SetBackcolor(Color.clear);
            ui.SetForecolor(Color.clear);
            ui.SetBackgroundAlpha(0);
            ui.SetForegroundAlpha(0);
        }

        ui.SetBlockerActive(false);
        ui.SetSkipButtonActive(false);

        AllCharactersLeave();
    }

    private static function GetDefaultSectionStartScripts():Array<TalkScript> return emptyScripts;
    private static function GetDefaultSectionSkipScripts():Array<TalkScript> return defaultSectionSkipScripts;
    private static function GetDefaultSentenceStartScripts():Array<TalkScript> return emptyScripts;
    private static function GetDefaultSentenceClickScripts():Array<TalkScript> return defaultSentenceClickScripts;
    // #endregion

    // #region 事件
    public var OnTalkAction:FlxTypedSignal<String->Array<String>->Void> = new FlxTypedSignal<String->Array<String>->Void>();
    // #endregion 动作

    // #region 属性字段
    // [TranslateMsg("前景图生效时的对话模板，{0}为讨论者，{1}为文本")]
    public static inline var FORGROUND_TALK_TEMPLATE:String = "<color=blue>[{0}]</color>\n{1}";
    // [TranslateMsg("跳过对话时的提示，{0}为对话名称")]
    public static inline var DIALOG_SKIPPED:String = "已跳过对话\"{0}\"";
    public var RunningScriptCount(default, null):Int;
    public var IsTalking(default, null):Bool;
    public static var DEFAULT_VARIANT_ID:NamespaceID = new NamespaceID("mvz2", "normal");
    private static var emptyScripts:Array<TalkScript> = [];
    private static var defaultSectionSkipScripts:Array<TalkScript> = [
        new TalkScript("end")
    ];
    private static var defaultSentenceClickScripts:Array<TalkScript> = [
        new TalkScript("next")
    ];
    private var Main(get, never):MainManager;
    function get_Main():MainManager return MainManager.Instance;

    private var showingTalkItem:Bool = false;
    private var canClick:Bool = false;
    private var sectionIndex:Int = 0;
    private var sentenceIndex:Int = 0;
    private var groupID:NamespaceID;
    private var tcs:unity.TaskCompletionSource;
    private var characterList:Array<CharacterData> = [];
    private var ui:TalkUI = null;
    private var canUnlock:Bool = true;
    private var characterTemplate:GameObject = null;
    private var characterRoot:Transform = null;
    // #endregion 属性
}

class CharacterData {
    public var id:NamespaceID;
    public var side:CharacterSide;
    public var controller:TalkCharacterController;

    public function new(id:NamespaceID, side:CharacterSide, controller:TalkCharacterController) {
        this.id = id;
        this.side = side;
        this.controller = controller;
    }
}
