// Ported from: Assets/Scripts/Vanilla/GameContent/GlobalCallbacks/TalkActionGlobalCallbacks.cs
package mvz2.gamecontent.globalcallbacks;

import mvz2.gamecontent.areas.VanillaAreaID;
import mvz2.gamecontent.contraptions.VanillaContraptionID;
import mvz2.gamecontent.maps.VanillaArchiveBackgrounds;
import mvz2.gamecontent.maps.VanillaMapID;
import mvz2.gamecontent.maps.VanillaMapPresetID;
import mvz2.gamecontent.stages.VanillaStageID;
import mvz2.vanilla.chaptertransitions.VanillaChapterTransitions;
import mvz2.vanilla.localization.VanillaStrings;
import mvz2.vanilla.unlocks.VanillaUnlockID;
import mvz2logic.Global;
import mvz2logic.archive.IArchiveInterface;
import mvz2logic.callbacks.LogicCallbacks;
import mvz2logic.grids.LogicGridExt;
import mvz2logic.level.LogicLevelExt;
import mvz2logic.localization.LogicStrings;
import mvz2logic.maps.IMapInterface;
import mvz2logic.modding.Mod;
import mvz2logic.talk.ITalkSystem;
import pvzengine.callbacks.CallbackResult;
import pvzengine.level.LevelEngine;
import unity.Coroutine;
import unity.Coroutine.CoroutineContext;
import unity.Vector3;
using mvz2logic.saves.LogicSaveExt;

@:modGlobalCallbacks
class TalkActionGlobalCallbacks extends VanillaGlobalCallbacks
{
    public override function Apply(mod:Mod):Void
    {
        mod.AddTrigger(LogicCallbacks.TALK_ACTION, TalkAction);
    }
    function TalkAction(param:TalkActionParams, result:CallbackResult):Void
    {
        var system = param.system;
        var cmd = param.action;
        var parameters = param.parameters;
        var preset:Null<TalkPreset> = null;
        var archiveSource = system.GetArchive();
        var mapSource = system.GetMap();
        var levelSource = system.GetLevel();
        if (Std.isOfType(archiveSource, IArchiveInterface))
        {
            preset = new ArchivePreset(cast archiveSource);
        }
        else if (Std.isOfType(mapSource, IMapInterface))
        {
            preset = new MapPreset(cast mapSource);
        }
        else if (Std.isOfType(levelSource, LevelEngine))
        {
            preset = new LevelPreset(cast levelSource);
        }
        else
        {
            preset = new DefaultPreset();
        }

        if (preset != null)
        {
            preset.TalkAction(system, cmd, parameters);
        }
    }
}

// PORT-NOTE: C# 嵌套私有类 → Haxe 模块子类型（访问路径 TalkActionGlobalCallbacks.XxxPreset 一致）。
class TalkPreset
{
    public function new()
    {
    }
    public function TalkAction(system:ITalkSystem, cmd:String, parameters:Array<String>):Void
    {
    }
}

class LevelPreset extends TalkPreset
{
    var level:LevelEngine;
    public function new(level:LevelEngine)
    {
        super();
        this.level = level;
    }
    public override function TalkAction(system:ITalkSystem, cmd:String, parameters:Array<String>):Void
    {
        switch (cmd)
        {
            case "create_tutorial_form":
                ShowTutorialDialog(system);
            case "try_buy_seventh_slot":
                TryBuySeventhSlot(system);
            case "create_seventh_slot_form":
                ShowSeventhSlotDialog(system);
            case "start_tutorial":
                level.ChangeStage(VanillaStageID.tutorial);
            case "prepare_starshard_tutorial":
                {
                    var grid = level.GetGrid(4, 2);
                    if (grid == null)
                        return;
                    if (!LogicGridExt.CanSpawnEntity(grid, VanillaContraptionID.dispenser))
                        return;
                    var x = level.GetEntityColumnX(4);
                    var z = level.GetEntityLaneZ(2);
                    var y = level.GetGroundY(x, z);
                    var position = new Vector3(x, y, z);
                    level.Spawn(VanillaContraptionID.dispenser, position, null);
                }
            case "start_starshard_tutorial":
                level.ChangeStage(VanillaStageID.starshardTutorial);
            case "start_trigger_tutorial":
                level.ChangeStage(VanillaStageID.triggerTutorial);
            default:
        }
    }
    function ShowTutorialDialog(system:ITalkSystem):Void
    {
        var game = Global.Game;
        var title = Global.Localization.GetText(VanillaStrings.UI_TUTORIAL);
        var desc = Global.Localization.GetText(VanillaStrings.UI_CONFIRM_TUTORIAL);
        var options = [
            Global.Localization.GetText(LogicStrings.YES),
            Global.Localization.GetText(LogicStrings.NO)
        ];
        system.ShowDialog(title, desc, options, (index) ->
        {
            switch (index)
            {
                case 0:
                    system.StartSection(1);
                case 1:
                    system.StartSection(2);
                default:
            }
        });
    }
    function TryBuySeventhSlot(system:ITalkSystem):Void
    {
        var saves = Global.Saves;
        if (saves.GetMoney() >= 750)
        {
            LogicLevelExt.ShowMoney(level);
            LogicLevelExt.SetMoneyFade(level, false);
            system.StartSection(1);
        }
        else
        {
            LogicLevelExt.ShowMoney(level);
            system.StartSection(2);
        }
    }
    function ShowSeventhSlotDialog(system:ITalkSystem):Void
    {
        var game = Global.Game;
        var title = Global.Localization.GetText(VanillaStrings.UI_PURCHASE);
        var desc = Global.Localization.GetText(VanillaStrings.UI_CONFIRM_BUY_7TH_SLOT);
        var options = [
            Global.Localization.GetText(LogicStrings.YES),
            Global.Localization.GetText(LogicStrings.NO)
        ];


        system.ShowDialog(title, desc, options, (index) ->
        {
            var saves = Global.Saves;
            switch (index)
            {
                case 0:
                    saves.AddMoney(-750);
                    saves.Unlock(VanillaUnlockID.blueprintSlot1);
                    saves.SaveToFile(); // 完成蓝图槽位交易后保存游戏。
                    LogicLevelExt.UpdatePersistentLevelUnlocks(level);
                    system.StartSection(3);
                    LogicLevelExt.SetMoneyFade(level, true);
                case 1:
                    system.StartSection(4);
                    LogicLevelExt.SetMoneyFade(level, true);
                default:
            }
        });
    }
}

class MapPreset extends DefaultPreset
{
    var map:IMapInterface;
    public function new(map:IMapInterface)
    {
        super();
        this.map = map;
    }
    public override function TalkAction(system:ITalkSystem, cmd:String, parameters:Array<String>):Void
    {
        super.TalkAction(system, cmd, parameters);
        var saves = Global.Saves;
        switch (cmd)
        {
            case "show_nightmare":
                map.SetPreset(VanillaMapPresetID.nightmare);
                saves.Unlock(VanillaUnlockID.dreamIsNightmare);
                saves.SaveToFile(); // 转换到噩梦世界时保存游戏
            default:
        }
    }
}

class DefaultPreset extends TalkPreset
{
    public function new()
    {
        super();
    }
    public override function TalkAction(system:ITalkSystem, cmd:String, parameters:Array<String>):Void
    {
        super.TalkAction(system, cmd, parameters);
        var saves = Global.Saves;
        switch (cmd)
        {
            case "goto_dream":
                saves.Unlock(VanillaUnlockID.enteredDream);
                saves.SetLastMapID(VanillaMapID.dream);
                saves.SaveToFile(); // 进入梦境过渡时保存游戏
                Global.Game.StartCoroutine(VanillaChapterTransitions.TransitionTalkToLevel(VanillaChapterTransitions.dream, VanillaAreaID.dream, VanillaStageID.dream1));
            case "goto_castle":
                saves.SetLastMapID(VanillaMapID.castle);
                saves.SaveToFile(); // 进入辉针城过渡时保存游戏
                Global.Game.StartCoroutine(VanillaChapterTransitions.TransitionTalkToLevel(VanillaChapterTransitions.castle, VanillaAreaID.castle, VanillaStageID.castle1));
            case "goto_mausoleum":
                saves.SetLastMapID(VanillaMapID.mausoleum);
                saves.SaveToFile(); // 进入大祀庙过渡时保存游戏
                Global.Game.StartCoroutine(VanillaChapterTransitions.TransitionTalkToLevel(VanillaChapterTransitions.mausoleum, VanillaAreaID.mausoleum, VanillaStageID.mausoleum1));
            case "goto_ship":
                saves.SetLastMapID(VanillaMapID.ship);
                saves.SaveToFile(); // 进入圣辇船过渡时保存游戏
                Global.Game.StartCoroutine(VanillaChapterTransitions.TransitionTalkToLevel(VanillaChapterTransitions.ship, VanillaAreaID.ship, VanillaStageID.ship1));
            case "goto_palace":
                saves.SetLastMapID(VanillaMapID.palace);
                saves.SaveToFile(); // 进入地灵殿过渡时保存游戏
                Global.Game.StartCoroutine(VanillaChapterTransitions.TransitionTalkToLevel(VanillaChapterTransitions.palace, VanillaAreaID.palace, VanillaStageID.palace1));
            case "chapter_3_finish":
                Global.Game.StartCoroutine(VanillaChapterTransitions.TransitionToMap(VanillaChapterTransitions.castle, VanillaMapID.gensokyo, true));
            case "chapter_4_finish":
                Global.Game.StartCoroutine(VanillaChapterTransitions.TransitionToMap(VanillaChapterTransitions.mausoleum, VanillaMapID.gensokyo, true));
            case "chapter_5_finish":
                Global.Game.StartCoroutine(VanillaChapterTransitions.TransitionToMap(VanillaChapterTransitions.ship, VanillaMapID.gensokyo, true));
            case "chapter_6_finish":
                // PORT-NOTE: C# 局部 IEnumerator 函数 → unity.Coroutine 步骤函数。
                Global.Game.StartCoroutine(Coroutine.create(function(co:CoroutineContext)
                {
                    co.wait(0); // yield return VanillaChapterTransitions.TransitionToMap(...);
                    var result = VanillaChapterTransitions.TransitionToMap(VanillaChapterTransitions.palace, VanillaMapID.gensokyo, true);
                    var title = Global.Localization.GetText(VanillaStrings.UI_GAME_CLEARED);
                    var desc = Global.Localization.GetText(VanillaStrings.UI_COMING_SOON);
                    var options = [Global.Localization.GetText(LogicStrings.CONFIRM)];
                    Global.GUI.ShowDialog(title, desc, options);
                }));
            default:
        }
    }
}

class ArchivePreset extends TalkPreset
{
    var archive:IArchiveInterface;
    public function new(archive:IArchiveInterface)
    {
        super();
        this.archive = archive;
    }
    public override function TalkAction(system:ITalkSystem, cmd:String, parameters:Array<String>):Void
    {
        switch (cmd)
        {
            case "create_tutorial_form":
                ShowTutorialDialog(system);
            case "try_buy_seventh_slot":
                TryBuySeventhSlot(system);
            case "create_seventh_slot_form":
                ShowSeventhSlotDialog(system);
            case "show_nightmare":
                archive.SetBackground(VanillaArchiveBackgrounds.nightmare);
            default:
        }
    }
    function ShowTutorialDialog(system:ITalkSystem):Void
    {
        var game = Global.Game;
        var title = Global.Localization.GetTextParticular(LogicStrings.ARCHIVE_BRANCH, LogicStrings.CONTEXT_ARCHIVE);
        var desc = Global.Localization.GetText(VanillaStrings.UI_CONFIRM_TUTORIAL);
        var options = [
            Global.Localization.GetText(LogicStrings.YES),
            Global.Localization.GetText(LogicStrings.NO)
        ];
        system.ShowDialog(title, desc, options, (index) ->
        {
            switch (index)
            {
                case 0:
                    system.StartSection(1);
                case 1:
                    system.StartSection(2);
                default:
            }
        });
    }
    function TryBuySeventhSlot(system:ITalkSystem):Void
    {
        var game = Global.Game;
        var title = Global.Localization.GetTextParticular(LogicStrings.ARCHIVE_BRANCH, LogicStrings.CONTEXT_ARCHIVE);
        var desc = Global.Localization.GetTextParticular(VanillaStrings.ARCHIVE_WHETHER_HAS_ENOUGH_MONEY, LogicStrings.CONTEXT_ARCHIVE);
        var options = [
            Global.Localization.GetText(LogicStrings.YES),
            Global.Localization.GetText(LogicStrings.NO)
        ];

        system.ShowDialog(title, desc, options, (index) ->
        {
            switch (index)
            {
                case 0:
                    system.StartSection(1);
                case 1:
                    system.StartSection(2);
                default:
            }
        });
    }
    function ShowSeventhSlotDialog(system:ITalkSystem):Void
    {
        var game = Global.Game;
        var title = Global.Localization.GetTextParticular(LogicStrings.ARCHIVE_BRANCH, LogicStrings.CONTEXT_ARCHIVE);
        var desc = Global.Localization.GetText(VanillaStrings.UI_CONFIRM_BUY_7TH_SLOT);
        var options = [
            Global.Localization.GetText(LogicStrings.YES),
            Global.Localization.GetText(LogicStrings.NO)
        ];


        system.ShowDialog(title, desc, options, (index) ->
        {
            switch (index)
            {
                case 0:
                    system.StartSection(3);
                case 1:
                    system.StartSection(4);
                default:
            }
        });
    }
}
