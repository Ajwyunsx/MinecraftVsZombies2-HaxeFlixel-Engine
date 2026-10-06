package mvz2.arcade;

import mvz2.gamecontent.difficulties.VanillaDifficulties;
import mvz2.managers.MainManager;
import mvz2.saves.MVZ2SaveExt;
import mvz2.scenes.MainScenePage;
import mvz2.ui.arcade.ArcadeUI;
import mvz2.ui.arcade.IndexArcadePage;
import mvz2.ui.arcade.IndexArcadePage.ButtonType;
import mvz2logic.audios.LogicMusicID;
import mvz2logic.audios.LogicSoundID;
import mvz2logic.level.LevelExitTarget;
import mvz2logic.level.StageTypes;
import mvz2logic.localization.LogicStrings;
import mvz2logic.stats.LogicStats;
import pvzengine.NamespaceID;
import unity.Sprite;
import mvz2.localization.LanguageManager;
import mvz2.level.LevelManager;
import Main;
import mvz2.audios.MusicManager;
import mvz2.managers.ResourceManager;
import mvz2.saves.SaveManager;
import mvz2.audios.SoundManager;
import mvz2.ui.arcade.ArcadeUI.ArcadePage;
import mvz2.ui.arcade.ArcadeItem.ArcadeItemViewData;

// PORT-NOTE: C# 中 GetUnlockConditions/GetStageType/GetLevelNameOfStage/GetArcadeIcon/IsLevelCleared
// 均为扩展方法，Haxe 侧用 `using` 还原为调用点方法形式。
using mvz2logic.level.LogicStageProps;
using mvz2logic.difficulties.LogicDifficultyProps;
using mvz2logic.saves.LogicSaveExt;

// Ported from: Assets/Scripts/MVZ2/Arcade/ArcadeController.cs
class ArcadeController extends MainScenePage {
    override public function Display():Void {
        super.Display();
        ui.DisplayPage(ArcadePage.Index);
        ui.SetAllInteractable(true);
        UpdateItems();
        if (!Main.MusicManager.IsPlaying(LogicMusicID.choosing))
            Main.MusicManager.Play(LogicMusicID.choosing);
    }
    public function DisplayMinigames():Void {
        ui.DisplayPage(ArcadePage.Minigame);
    }
    public function DisplayPuzzles():Void {
        ui.DisplayPage(ArcadePage.Puzzle);
    }
    private function Awake():Void {
        ui.OnIndexReturnClick.add(OnIndexReturnClickCallback);
        ui.OnPageReturnClick.add(OnPageReturnClickCallback);

        ui.OnIndexButtonClick.add(OnIndexButtonClickCallback);
        ui.OnItemClick.add(OnItemClickCallback);
    }
    // #region 事件回调
    private function OnIndexReturnClickCallback():Void {
        Return();
    }
    private function OnPageReturnClickCallback(page:ArcadePage):Void {
        ui.DisplayPage(ArcadePage.Index);
    }
    private function OnIndexButtonClickCallback(button:ButtonType):Void {
        switch (button) {
            case ButtonType.Minigame:
                DisplayMinigames();
            case ButtonType.Puzzle:
                DisplayPuzzles();
        }
        Main.SoundManager.Play2D(LogicSoundID.tap);
    }
    // PORT-NOTE: C# `async void` → Void; the awaited scene transition is started without blocking.
    private function OnItemClickCallback(page:ArcadePage, index:Int):Void {
        var items = page == ArcadePage.Puzzle ? puzzleItems : minigameItems;
        Main.SoundManager.Play2D(LogicSoundID.tap);

        var arcadeID = items[index];
        var arcadeMeta = Main.ResourceManager.GetArcadeMeta(arcadeID);
        if (arcadeMeta == null)
            return;
        var areaID = arcadeMeta.AreaID;
        var stageID = arcadeMeta.StageID;
        if (!NamespaceID.IsValid(areaID) || !NamespaceID.IsValid(stageID))
            return;
        ui.SetAllInteractable(false);
        Main.SaveManager.SaveToFile(); // 关卡开始时保存游戏
        Main.LevelManager.GotoLevelSceneAsync().awaitResult();
        var exitTarget = page == ArcadePage.Puzzle ? LevelExitTarget.Puzzle : LevelExitTarget.Minigame;
        Main.LevelManager.InitLevel(areaID, stageID, 0, exitTarget);
        Hide();
    }
    // #endregion

    private function GetOrderedArcade(arcades:Array<NamespaceID>, appendList:Array<NamespaceID>):Void {
        var idList = GetIDListByArcadeOrder(arcades, ArcadeTypes.MINIGAME);
        for (id in idList) appendList.push(id);
    }
    private function GetOrderedPuzzles(arcades:Array<NamespaceID>, appendList:Array<NamespaceID>):Void {
        var idList = GetIDListByArcadeOrder(arcades, ArcadeTypes.PUZZLE);
        for (id in idList) appendList.push(id);
    }
    private function GetIDListByArcadeOrder(idList:Array<NamespaceID>, type:String):Array<NamespaceID> {
        if (idList == null || idList.length == 0)
            return [];
        var arcades = Lambda.filter(Lambda.map(idList, id -> {
            id: id,
            meta: Main.ResourceManager.GetArcadeMeta(id)
        }), tuple -> tuple.meta != null && tuple.meta.Type == type);
        if (arcades.length <= 0)
            return [];
        var arcadeIndexes = Lambda.map(arcades, tuple -> {
            id: tuple.id,
            index: tuple.meta != null ? tuple.meta.Index : -1
        });
        var maxAlmanacIndex = 0;
        for (tuple in arcadeIndexes) {
            if (tuple.index > maxAlmanacIndex) maxAlmanacIndex = tuple.index;
        }
        var ordered:Array<NamespaceID> = [];
        ordered.resize(maxAlmanacIndex + 1);
        for (i in 0...ordered.length) {
            var tuple = Lambda.find(arcadeIndexes, t -> t.index == i);
            ordered[i] = tuple != null ? tuple.id : null;
        }
        return ordered;
    }
    private function GetArcadeItemViewData(id:NamespaceID):ArcadeItemViewData {
        var meta = Main.ResourceManager.GetArcadeMeta(id);
        if (meta == null)
            return ArcadeItemViewData.Empty;
        var stageID = meta.StageID;
        if (stageID == null)
            return ArcadeItemViewData.Empty;
        var stageDef = Main.Game.GetStageDefinition(stageID);
        if (stageDef == null)
            return ArcadeItemViewData.Empty;

        var conditions = stageDef.GetUnlockConditions();
        var unlocked = MVZ2SaveExt.IsNullOrMeetsConditions(conditions, Main.SaveManager);
        var name:String;
        if (unlocked) {
            // PORT-NOTE: C# 重载 GetLevelName(this StageDefinition) 在移植层改名为 GetLevelNameOfStage。
            name = GetTranslatedStringParticular(LogicStrings.CONTEXT_LEVEL_NAME, stageDef.GetLevelNameOfStage(), []);
        } else {
            name = GetTranslatedString(LEVEL_NAME_NOT_UNLOCKED, []);
        }
        var hint = "";
        if (unlocked && stageDef.GetStageType() == StageTypes.TYPE_PUZZLE_ENDLESS) {
            var flags = Main.SaveManager.GetStat(LogicStats.CATEGORY_MAX_ENDLESS_FLAGS, stageID);
            hint = GetTranslatedString(ENDLESS_MAX_STREAKS, [flags]);
        }
        // PORT-NOTE: C# 重载 GetFinalSprite(SpriteReference?) 在移植层名为 GetFinalSpriteFromRef。
        var icon = Main.GetFinalSpriteFromRef(meta.Icon);

        var clearSprite:Sprite = null;
        if (Main.SaveManager.IsLevelCleared(stageID)) {
            var game = Main.Game;
            var difficulty = Main.SaveManager.GetLevelDifficulty(stageID);
            var def = game.GetDifficultyDefinition(difficulty);
            if (def == null) {
                def = game.GetDifficultyDefinition(VanillaDifficulties.normal);
            }
            if (def != null) {
                var clearSpriteID = def.GetArcadeIcon();
                clearSprite = Main.GetFinalSpriteFromRef(clearSpriteID);
            }
        }
        return new ArcadeItemViewData({
            name: name,
            hint: hint,
            sprite: icon,
            clearSprite: clearSprite,
            unlocked: unlocked,
        });
    }
    private function UpdateItems():Void {
        minigameItems = [];
        puzzleItems = [];
        var arcades = Lambda.filter(Main.ResourceManager.GetAllArcadeItems(), function(id) {
            var meta = Main.ResourceManager.GetArcadeMeta(id);
            if (meta == null)
                return false;
            var stage = Main.Game.GetStageDefinition(meta.StageID);
            if (stage == null)
                return false;
            return MVZ2SaveExt.IsNullOrMeetsConditions(meta.HiddenUntil, Main.SaveManager);
        });
        GetOrderedArcade(arcades, minigameItems);
        GetOrderedPuzzles(arcades, puzzleItems);

        var minigameViewDatas = Lambda.array(Lambda.map(minigameItems, c -> GetArcadeItemViewData(c)));
        ui.SetMinigameItems(minigameViewDatas);

        var puzzleViewDatas = Lambda.array(Lambda.map(puzzleItems, c -> GetArcadeItemViewData(c)));
        ui.SetPuzzleItems(puzzleViewDatas);
    }
    private function GetTranslatedString(text:String, args:Array<Dynamic>):String {
        return Main.LanguageManager._(text, args);
    }
    private function GetTranslatedStringParticular(context:String, text:String, args:Array<Dynamic>):String {
        return Main.LanguageManager._p(context, text, args);
    }

    @:translateMsg("未解锁的小游戏关卡名")
    public static inline var LEVEL_NAME_NOT_UNLOCKED:String = "未解锁";
    @:translateMsg("无尽模式的小游戏的连胜显示，{0}为最高连胜")
    public static inline var ENDLESS_MAX_STREAKS:String = "最高连胜：\n{0}";

    private var Main(get, never):MainManager;
    inline function get_Main():MainManager return MainManager.Instance;

    private var minigameItems:Array<NamespaceID> = [];
    private var puzzleItems:Array<NamespaceID> = [];

    @:serializeField
    private var ui:ArcadeUI = null;
}
