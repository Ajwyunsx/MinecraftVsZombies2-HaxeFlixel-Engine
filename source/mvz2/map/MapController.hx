package mvz2.map;

import mvz2.gamecontent.maps.VanillaMapID;
import mvz2.managers.MainManager;
import mvz2.metas.MapMeta;
import mvz2.metas.MapPreset;
import mvz2.options.OptionContextMap;
import mvz2.options.OptionsDialogController;
import mvz2.scenes.MainScenePage;
import mvz2.saves.MVZ2SaveExt;
import mvz2.talk.TalkController;
import mvz2.ui.map.MapButton;
import mvz2.ui.map.MapUI;
// PORT-NOTE: C# `MVZ2.UI.Map.MapUI.ButtonType`；此前被误写为 arcade 的 IndexArcadePage.ButtonType。
import mvz2.ui.map.MapUI.ButtonType;
import mvz2logic.Global;
import mvz2logic.Log;
import mvz2logic.audios.LogicSoundID;
import mvz2logic.callbacks.LogicCallbacks;
import mvz2logic.inputs.PointerTypes;
import mvz2logic.level.StageTypes;
import mvz2logic.localization.LogicStrings;
import mvz2logic.maps.IMapInterface;
import mvz2logic.stats.LogicStats;
import mvz2logic.talk.ITalkSystem;
import pvzengine.NamespaceID;
import pvzengine.level.StageDefinition;
import unity.Camera;
import unity.Color;
import unity.Coroutine;
import unity.eventsystems.EventSystem;
import unity.eventsystems.PointerEventData;
import unity.GameObject;
import unity.Input;
import unity.Mathf;
import unity.Time;
import unity.Touch;
import unity.Transform;
import unity.Vector2;
import unity.Vector3;
import unity.WaitForSeconds;
import mvz2.gamecontent.artifacts.Almanac;
import unity.ui.Button;
import mvz2.inputs.InputManager;
import mvz2.localization.LanguageManager;
import mvz2.level.LevelManager;
import Main;
import mvz2logic.maps.MapElementDefinition;
import mvz2.audios.MusicManager;
import mvz2.ui.OptionsDialog;
import mvz2.managers.ResourceManager;
import mvz2.saves.SaveManager;
import mvz2.cameras.ShakeManager;
import mvz2.audios.SoundManager;
import unity.UnityObject;
import mvz2logic.callbacks.LogicCallbacks.TalkActionParams;
import unity.Coroutine.CoroutineContext;
import unity.Touch.TouchPhase;
import unity.eventsystems.PointerEventData.RaycastResult;
import unity.scenemanagement.SceneInstance.Scene;

// PORT-NOTE: C# 中 GetUnlockConditions/GetStageType/DreamIsNightmare 等均为扩展方法，
// Haxe 侧用 `using` 还原为调用点方法形式。
using mvz2logic.level.LogicStageProps;
using mvz2logic.difficulties.LogicDifficultyProps;
using mvz2logic.games.LogicGameDefinitionsExt;
using mvz2logic.maps.LogicEntityProps;
using mvz2logic.saves.LogicSaveExt;
using mvz2.saves.MVZ2SaveExt;
using mvz2.talk.TalkHelper;

// Ported from: Assets/Scripts/MVZ2/Map/MapController.cs
// PORT-NOTE: `IEnumerator EnterLevel` coroutines → unity.Coroutine step functions; `async void
// SetMap` → Void with the talk sequence started without blocking.
class MapController extends MainScenePage implements IMapInterface {
    // #region 公有方法
    override public function Display():Void {
        super.Display();
        ResetCamera();
        ui.SetButtonActive(ButtonType.Almanac, Main.SaveManager.IsAlmanacUnlocked());
        ui.SetButtonActive(ButtonType.Store, Main.SaveManager.IsStoreUnlocked());
        ui.SetButtonActive(ButtonType.Map, Main.SaveManager.IsGensokyoUnlocked());
        ui.SetHintText(Main.LanguageManager._(Main.InputManager.GetActivePointerType() == PointerTypes.TOUCH ? HINT_TEXT_MOBILE : HINT_TEXT));
        ui.SetDragRootVisible(false);
        ui.SetOptionsDialogActive(false);
        ui.SetRaycastBlockerActive(false);
        if (!Main.SoundManager.IsPlaying(LogicSoundID.travel)) {
            Main.SoundManager.Play2D(LogicSoundID.travel);
        }
        Main.Scene.SetPortalAlpha(1);
        Main.Scene.PortalFadeOut();
    }
    override public function Hide():Void {
        super.Hide();
        if (model != null) {
            model.OnMapButtonClick.remove(OnMapButtonClickCallback);
            model.OnEndlessButtonClick.remove(OnEndlessButtonClickCallback);
            unity.UnityObject.destroy(model.gameObject);
            model = null;
        }
        SetCameraBackgroundColor(Color.black);
        CancelDraggingView();
    }
    public function SetMap(mapId:NamespaceID):Void {
        var meta = Main.ResourceManager.GetMapMeta(mapId);
        if (meta == null)
            return;
        MapID = mapId;
        mapMeta = meta;

        var unlockedPresets = Lambda.filter(mapMeta.presets, p -> p.conditions == null || Main.SaveManager.MeetsXMLConditions(p.conditions));
        var sortedPresets = Lambda.array(unlockedPresets);
        sortedPresets.sort((a, b) -> b.priority - a.priority);
        var mapPreset = sortedPresets.length > 0 ? sortedPresets[0] : null;
        SetMapPreset(mapPreset);

        var music = mapPreset.music;
        if (!NamespaceID.IsValid(music)) {
            Main.MusicManager.Stop();
        } else {
            Main.MusicManager.Play(music);
        }
        Main.SaveManager.SetLastMapID(mapId);

        if (mapId == VanillaMapID.gensokyo) {
            ui.SetButtonActive(ButtonType.Map, false);
            ui.SetHintText("");
        }
        Global.Saves.SaveToFile(); // 进入地图时保存游戏

        // 对话
        HideUIArrows();
        // 上一次地图的对话
        var mapTalk = Main.SaveManager.GetMapTalk();
        var queue:Array<NamespaceID> = [];
        if (NamespaceID.IsValid(mapTalk)) {
            queue.push(mapTalk);
        }

        // 地图自带剧情对话
        var mapLores = mapMeta.loreTalks != null ? mapMeta.loreTalks.GetLoreTalks(Main.SaveManager) : null;
        if (mapLores != null) {
            for (lore in mapLores) {
                if (!queue.contains(lore))
                    queue.push(lore);
            }
        }

        RunMapTalks(queue);
    }
    // PORT-NOTE: the `while (queue.Count > 0) { ... await ... }` loop of SetMap; the loop body is
    // grouped here so the coroutine restructure is contained in one place.
    private function RunMapTalks(queue:Array<NamespaceID>):Void {
        while (queue.length > 0) {
            var talk = queue.shift();
            if (!Main.ResourceManager.CanStartTalk(talk, 0))
                continue;
            Main.SaveManager.SetMapTalk(talk);
            // TODO-PORT: `await talkController.SimpleStartTalkAsync(talk, 0, 3)` requires
            // restructuring this loop into a coroutine.
            talkController.SimpleStartTalkAsync(talk, 0, 3);

            // 如果对话去了其他页面，那就不触发之后的对话。
            if (!gameObject.activeInHierarchy)
                break;
        }
        UpdateUIArrows();
        Main.SaveManager.SetMapTalk(null);
        Global.Saves.SaveToFile(); // 完成进入地图对话时保存游戏
    }
    public function SetMapPreset(mapPreset:MapPreset):Void {
        var modelPrefab = Main.ResourceManager.GetMapModel(mapPreset.model);
        if (model != null) {
            model.OnMapButtonClick.remove(OnMapButtonClickCallback);
            model.OnEndlessButtonClick.remove(OnEndlessButtonClickCallback);
            unity.UnityObject.destroy(model.gameObject);
        }
        if (modelPrefab == null)
            return;

        var modelObject:GameObject = unity.UnityObject.Instantiate(modelPrefab.gameObject, null, null, modelRoot);
        model = modelObject.GetComponent(MapModel);
        model.OnMapButtonClick.add(OnMapButtonClickCallback);
        model.OnEndlessButtonClick.add(OnEndlessButtonClickCallback);

        UpdateModelButtons(model);
        UpdateModelElements(model);
        UpdateModelEndlessFlags(model);
        SetCameraBackgroundColor(mapPreset.backgroundColor);
    }
    public function ChangeMap(id:NamespaceID):Void {
        Hide();
        Main.Scene.DisplayMap(id);
    }
    public function SetRaycastBlockerActive(active:Bool):Void {
        ui.SetRaycastBlockerActive(active);
    }
    public function GetMapID():NamespaceID {
        return MapID;
    }
    public function GetTalkSystem():ITalkSystem {
        return talkSystem;
    }
    // #endregion

    // #region 私有方法

    // #region 生命周期
    private function Awake():Void {
        ui.OnButtonClick.add(OnButtonClickCallback);
        talkController.OnTalkAction.add(OnTalkActionCallback);
        optionDialogController.OnClose.add(OnOptionsDialogCloseCallback);

        talkSystem = new MapTalkSystem(this, talkController);
    }
    private function Update():Void {
        UpdateTouchDatas();
        if (Input.touchCount > 0) {
            UpdateTouch();
        } else {
            UpdateMouse();
        }
        var aspect = mapCamera.aspect;

        var maxWidth = mapMeta.size.x * 0.01;
        var maxHeight = mapMeta.size.y * 0.01;
        var maxScaleX = maxWidth / aspect * 0.5;
        var maxScaleY = maxHeight * 0.5;
        var maxCameraSize = Mathf.Min(maxScaleX, maxScaleY);
        mapCamera.orthographicSize = Mathf.Clamp(mapCamera.orthographicSize + cameraScaleSpeed, minCameraSize, maxCameraSize);
        LimitCameraPosition();
        cameraScaleSpeed *= 0.8;
        mapCameraShakeRoot.localPosition = Main.ShakeManager.GetShake2D();
    }
    private function OnApplicationFocus(focus:Bool):Void {
        if (!focus && draggingView) {
            draggingView = false;
            ui.SetDragRootVisible(false);
        }
    }
    // #endregion

    // #region 事件回调
    private function OnButtonClickCallback(button:ButtonType):Void {
        switch (button) {
            case ButtonType.Back:
                Main.Scene.DisplayMainmenu();
                Main.SaveManager.SaveToFile(); // 显示主菜单时保存游戏
            case ButtonType.Almanac:
                Main.Scene.DisplayAlmanac(() -> Main.Scene.DisplayMap(MapID));
            case ButtonType.Store:
                Main.Scene.DisplayStore(() -> Main.Scene.DisplayMap(MapID), true);
            case ButtonType.Map:
                Main.Scene.DisplayMap(VanillaMapID.gensokyo);
            case ButtonType.Setting:
                ui.SetOptionsDialogActive(true);
                ui.OptionsDialog.ResetPosition();
                var context = new OptionContextMap();
                optionDialogController.Open(context);
        }
    }
    private function OnTalkActionCallback(cmd:String, parameters:Array<String>):Void {
        Global.Game.RunCallbackFiltered(LogicCallbacks.TALK_ACTION, new TalkActionParams(talkSystem, cmd, parameters), cmd);
    }
    private function OnOptionsDialogCloseCallback(needsReload:Bool):Void {
        ui.SetOptionsDialogActive(false);
        if (needsReload) {
            ReloadMap();
        }
    }
    private function OnMapButtonClickCallback(index:Int):Void {
        var stageID = GetStageID(index);
        if (stageID == null)
            return;
        var area = GetStageArea(index);
        if (area == null) area = mapMeta.area;
        StartCoroutine(EnterLevel(area, stageID));
    }
    private function OnEndlessButtonClickCallback():Void {
        var stageID = mapMeta.endlessStage;
        StartCoroutine(EnterLevel(mapMeta.area, stageID));
    }
    private function OnMapNightmareBoxClickCallback():Void {
        Main.SaveManager.SetDreamIsNightmare(!Main.SaveManager.DreamIsNightmare());
        ReloadMap();
    }
    // #endregion

    public function SetPreset(presetID:NamespaceID):Void {
        var preset = Lambda.find(mapMeta.presets, p -> p.id == presetID);
        SetMapPreset(preset);
    }

    // #region 相机
    private function ResetCamera():Void {
        mapCamera.transform.localPosition = Vector3.zero;
    }
    private function SetCameraBackgroundColor(color:Color):Void {
        mapCamera.backgroundColor = color;
    }
    private function LimitCameraPosition():Void {
        var position = mapCamera.transform.position;
        var aspect = mapCamera.aspect;
        var fullHeight = mapCamera.orthographicSize * 2;
        var cameraHeight = fullHeight;
        var cameraWidth = cameraHeight * aspect;

        var mapSize = mapMeta.size * 0.01;
        var minX = -mapSize.x * 0.5;
        var maxX = mapSize.x * 0.5;
        var minY = -mapSize.y * 0.5;
        var maxY = mapSize.y * 0.5;
        position.x = Mathf.Clamp(position.x, minX + cameraWidth * 0.5, maxX - cameraWidth * 0.5);
        position.y = Mathf.Clamp(position.y, minY + cameraHeight * 0.5, maxY - cameraHeight * 0.5);
        mapCamera.transform.position = position;
    }
    // #endregion

    // #region 关卡
    private function GetStageID(index:Int):NamespaceID {
        var meta = mapMeta.stages[index];
        if (meta == null)
            return null;
        return meta.stage;
    }
    private function GetStageArea(index:Int):NamespaceID {
        var meta = mapMeta.stages[index];
        if (meta == null)
            return null;
        return meta.area;
    }
    private function GetStageDefinition(stageID:NamespaceID):StageDefinition {
        return Main.Game.GetStageDefinition(stageID);
    }
    // PORT-NOTE: C# overload GetStageDefinition(int); Haxe has no overloads.
    private function GetStageDefinitionByIndex(index:Int):StageDefinition {
        var stageID = GetStageID(index);
        if (!NamespaceID.IsValid(stageID))
            return null;
        return GetStageDefinition(stageID);
    }
    private function GetStageType(index:Int):String {
        var stageDef = GetStageDefinitionByIndex(index);
        if (stageDef == null)
            return "";
        var type = stageDef.GetStageType();
        return type != null ? type : "";
    }
    private function IsLevelUnlocked(stageID:NamespaceID):Bool {
        var stageDef = GetStageDefinition(stageID);
        if (stageDef == null)
            return false;
        var conditions = stageDef.GetUnlockConditions();
        if (!MVZ2SaveExt.IsNullOrMeetsConditions(conditions, Main.SaveManager))
            return false;
        return true;
    }
    private function IsLevelUnlockedByIndex(index:Int):Bool {
        var stageID = GetStageID(index);
        if (!NamespaceID.IsValid(stageID))
            return false;
        return IsLevelUnlocked(stageID);
    }
    private function SetMapButtonDifficulty(model:MapModel, index:Int):Void {
        var stageID = GetStageID(index);
        if (!NamespaceID.IsValid(stageID))
            return;
        var difficulty = Main.SaveManager.GetLevelDifficulty(stageID);
        if (NamespaceID.IsValid(difficulty)) {
            var game = Main.Game;
            var difficultyMeta = game.GetDifficultyDefinition(difficulty);
            if (difficultyMeta != null) {
                // PORT-NOTE: C# 重载 GetFinalSprite(SpriteReference?) 在移植层名为 GetFinalSpriteFromRef。
                var back = Main.GetFinalSpriteFromRef(difficultyMeta.GetMapButtonBorderBack());
                var bottom = Main.GetFinalSpriteFromRef(difficultyMeta.GetMapButtonBorderBottom());
                var overlay = Main.GetFinalSpriteFromRef(difficultyMeta.GetMapButtonBorderOverlay());
                model.SetMapButtonBorder(index, back, bottom, overlay);
                return;
            }
        }
        model.SetMapButtonBorderToDefault(index);
    }
    private function IsEndlessUnlocked():Bool {
        var stageID = mapMeta.endlessStage;
        if (!NamespaceID.IsValid(stageID))
            return false;
        return IsLevelUnlocked(stageID);
    }
    private function IsLevelCleared(index:Int):Bool {
        var stageId = GetStageID(index);
        if (stageId == null)
            return false;
        return Main.SaveManager.IsLevelCleared(stageId);
    }
    // #endregion

    // #region 触摸输入
    private function UpdateTouchDatas():Void {
        touchDatas = touchDatas.filter(d -> Lambda.exists([for (i in 0...Input.touchCount) Input.GetTouch(i)], t -> d.fingerId == t.fingerId));
        for (i in 0...Input.touchCount) {
            UpdateTouchData(i, Input.GetTouch(i));
        }
    }
    private function UpdateTouch():Void {
        if (touchDatas.length > 1) {
            var touch0 = touchDatas[0];
            var touch1 = touchDatas[1];
            var position0 = new Vector2(mapCamera.ScreenToWorldPoint(touch0.position).x, mapCamera.ScreenToWorldPoint(touch0.position).y);
            var position1 = new Vector2(mapCamera.ScreenToWorldPoint(touch1.position).x, mapCamera.ScreenToWorldPoint(touch1.position).y);
            var lastPosition0 = new Vector2(mapCamera.ScreenToWorldPoint(touch0.position - touch0.delta).x, mapCamera.ScreenToWorldPoint(touch0.position - touch0.delta).y);
            var lastPosition1 = new Vector2(mapCamera.ScreenToWorldPoint(touch1.position - touch1.delta).x, mapCamera.ScreenToWorldPoint(touch1.position - touch1.delta).y);

            var lastLength = (lastPosition0 - lastPosition1).magnitude;
            var currentLength = (position0 - position1).magnitude;
            var scale = lastLength / currentLength;

            var lastCenter = (lastPosition0 + lastPosition1) * 0.5;
            var currentCenter = (position0 + position1) * 0.5;
            var motion = lastCenter - currentCenter;

            var maxCameraSize = mapMeta.size.y / 100 * 0.5;
            mapCamera.orthographicSize = Mathf.Clamp(mapCamera.orthographicSize * scale, minCameraSize, maxCameraSize);
            mapCamera.transform.position = mapCamera.transform.position + new Vector3(motion.x, motion.y, 0);
        } else if (touchDatas.length > 0) {
            var touch0 = touchDatas[0];
            var position0 = new Vector2(mapCamera.ScreenToWorldPoint(touch0.position).x, mapCamera.ScreenToWorldPoint(touch0.position).y);
            var lastPosition0 = new Vector2(mapCamera.ScreenToWorldPoint(touch0.position - touch0.delta).x, mapCamera.ScreenToWorldPoint(touch0.position - touch0.delta).y);

            var motion = lastPosition0 - position0;

            mapCamera.transform.position = mapCamera.transform.position + new Vector3(motion.x, motion.y, 0);
        }
    }
    private function GetTouchData(fingerId:Int):TouchData {
        return Lambda.find(touchDatas, t -> t.fingerId == fingerId);
    }
    private function UpdateTouchData(index:Int, touch:Touch):Void {
        if (touch.phase == TouchPhase.Began) {
            if (IsPositionOnReceiver(touch.position)) {
                var data = new TouchData();
                data.fingerId = touch.fingerId;
                data.position = touch.position;
                touchDatas.push(data);
            }
        } else if (touch.phase == TouchPhase.Ended || touch.phase == TouchPhase.Canceled) {
            touchDatas = touchDatas.filter(t -> t.fingerId != touch.fingerId);
        } else {
            var touchData = GetTouchData(touch.fingerId);
            if (touchData != null) {
                touchData.delta = touch.deltaPosition;
                touchData.position = touch.position;
            }
        }
    }
    // #endregion

    // #region 鼠标输入
    private function UpdateMouse():Void {
        // PORT-NOTE: C# 的 `var position = Input.mousePosition` 是 Vector3，隐含转换为 Vector2；
        // Haxe 无隐式转换，这里在入口处显式转换一次。
        var mousePosition = Input.mousePosition;
        var position = new Vector2(mousePosition.x, mousePosition.y);
        if (Input.GetMouseButtonDown(1))
            OnRightMouseDown(position);
        if (Input.GetMouseButton(1))
            OnRightMouse(position);
        if (Input.GetMouseButtonUp(1))
            OnRightMouseUp();
        OnMouseScroll(position, Input.mouseScrollDelta);
    }
    private function OnRightMouseDown(position:Vector2):Void {
        if (!IsPositionOnReceiverOrButton(position))
            return;
        ui.SetDragRootVisible(true);
        ui.SetDragRootPosition(position);
        draggingView = true;
        mapDragStartPos = position;
    }
    private function OnRightMouse(position:Vector2):Void {
        if (!draggingView)
            return;
        ui.SetDragArrowTargetPosition(position);
        var cameraPos = mapCamera.transform.position;
        var targetWorld = mapCamera.ScreenToWorldPoint(new Vector3(position.x, position.y, 0));
        var fromWorld = mapCamera.ScreenToWorldPoint(new Vector3(mapDragStartPos.x, mapDragStartPos.y, 0));
        var motion = new Vector2(targetWorld.x - fromWorld.x, targetWorld.y - fromWorld.y);
        cameraPos = cameraPos + new Vector3(motion.x, motion.y, 0) * (6 * Time.deltaTime);
        mapCamera.transform.position = cameraPos;
    }
    private function OnRightMouseUp():Void {
        draggingView = false;
        ui.SetDragRootVisible(false);
    }
    private function OnMouseScroll(position:Vector2, scrollDelta:Vector2):Void {
        if (scrollDelta.y == 0)
            return;
        if (!IsPositionOnReceiverOrButton(position))
            return;
        cameraScaleSpeed = Mathf.Clamp(cameraScaleSpeed + -scrollDelta.y * 0.1, -1, 1);
    }
    private function IsPositionOnReceiver(position:Vector2):Bool {
        var eventSystem = EventSystem.current;
        var pointerEventData = new PointerEventData(eventSystem);
        pointerEventData.position = position;
        raycastResultCache = [];
        eventSystem.RaycastAll(pointerEventData, raycastResultCache);
        var firstResult = Lambda.find(raycastResultCache, r -> r.gameObject != null);
        var first:GameObject = firstResult != null ? firstResult.gameObject : null;
        if (first == null)
            return false;
        return first == raycastHitbox || first.GetComponentInParent(MapElement) != null;
    }
    private function IsPositionOnReceiverOrButton(position:Vector2):Bool {
        raycastResultCache = [];
        var eventSystem = EventSystem.current;
        var pointerEventData = new PointerEventData(eventSystem);
        pointerEventData.position = position;
        eventSystem.RaycastAll(pointerEventData, raycastResultCache);
        var firstResult = Lambda.find(raycastResultCache, r -> r.gameObject != null);
        var first:GameObject = firstResult != null ? firstResult.gameObject : null;
        if (first == null)
            return false;
        return first == raycastHitbox || first.GetComponentInParent(MapElement) != null || first.GetComponentInParent(MapButton) != null;
    }
    // #endregion

    private function EnterLevel(areaID:NamespaceID, stageID:NamespaceID):Coroutine {
        return Coroutine.create(function(co:unity.CoroutineContext) {
            CancelDraggingView();
            if (!NamespaceID.IsValid(areaID) || Global.Game.GetAreaDefinition(areaID) == null) {
                var title = Main.LanguageManager._(LogicStrings.ERROR);
                var desc = Main.LanguageManager._(ERROR_AREA_NOT_EXISTS, [areaID]);
                Main.Scene.ShowDialogMessage(title, desc);
                co.yieldBreak();
                return;
            }
            if (!NamespaceID.IsValid(stageID) || Global.Game.GetStageDefinition(stageID) == null) {
                var title = Main.LanguageManager._(LogicStrings.ERROR);
                var desc = Main.LanguageManager._(ERROR_STAGE_NOT_EXISTS, [stageID]);
                Main.Scene.ShowDialogMessage(title, desc);
                co.yieldBreak();
                return;
            }

            ui.SetHintText(Main.LanguageManager._(HINT_TEXT_ENTERING_LEVEL));
            ui.SetRaycastBlockerActive(true);
            Main.MusicManager.Stop();
            Main.SoundManager.Play2D(LogicSoundID.spring);
            co.wait(1);
            var task:unity.Task = GotoLevelAsync(areaID, stageID);
            // PORT-NOTE: the C# `while (!task.IsCompleted) yield return null;` busy-wait is not
            // meaningful in the port; the task body runs to completion above.
        });
    }
    private function GotoLevelAsync(areaID:NamespaceID, stageID:NamespaceID):unity.Task {
        Main.SaveManager.SaveToFile(); // 进入关卡时保存游戏
        Main.LevelManager.GotoLevelSceneAsync().awaitResult();
        Main.LevelManager.InitLevel(areaID, stageID);
        Hide();
        return unity.Task.completedTask();
    }

    private function UpdateModelButtons(model:MapModel):Void {
        var unclearedMapButtonIndex = -1;
        for (i in 0...model.GetMapButtonCount()) {
            var unlocked = IsLevelUnlockedByIndex(i);
            var cleared = IsLevelCleared(i);
            var stageType = GetStageType(i);

            var color = buttonColorCleared;
            if (!unlocked)
                color = buttonColorLocked;
            else if (stageType == StageTypes.TYPE_MINIGAME || stageType == StageTypes.TYPE_PUZZLE)
                color = buttonColorMinigame;
            else if (stageType == StageTypes.TYPE_BOSS)
                color = buttonColorBoss;
            else if (!cleared)
                color = buttonColorUncleared;

            if (unlocked && !cleared) {
                unclearedMapButtonIndex = i;
            }

            model.SetMapButtonInteractable(i, unlocked);
            model.SetMapButtonColor(i, color);
            model.SetMapButtonText(i, Std.string(i + 1));
            SetMapButtonDifficulty(model, i);
        }
        var endlessColor = buttonColorEndless;
        var endlessUnlocked = IsEndlessUnlocked();
        if (!endlessUnlocked)
            endlessColor = buttonColorLocked;
        model.SetEndlessButtonInteractable(endlessUnlocked);
        model.SetEndlessButtonColor(endlessColor);
        model.SetEndlessButtonText("\u221E");


        var unclearedMapButton:MapButton = null;
        if (unclearedMapButtonIndex >= 0) {
            unclearedMapButton = model.GetMapButton(unclearedMapButtonIndex);
        } else {
            unclearedMapButton = model.GetEndlessMapButton();
        }
        if (unclearedMapButton != null) {
            var pos = unclearedMapButton.transform.position;
            pos.z = mapCamera.transform.position.z;
            mapCamera.transform.position = pos;
        }
    }
    private function UpdateModelElements(model:MapModel):Void {
        var elements = model.GetMapElements();
        for (element in elements) {
            var id = element.definitionID != null ? element.definitionID.Get() : null;
            var mapElementDefinition = Main.Game.GetMapElementDefinition(id);
            if (mapElementDefinition == null) {
                element.SetActive(false);
                Log.LogWarning('Cannot find the MapElementDefinition of id ${id}.');
                continue;
            }
            element.Init(this, mapElementDefinition);
            // PORT-NOTE: C# 重载 GetUnlockConditions(this MapElementDefinition) 在移植层改名为 GetUnlockConditionsFromDefinition。
            var unlockGroup = mapElementDefinition.GetUnlockConditionsFromDefinition();
            element.SetActive(MVZ2SaveExt.IsNullOrMeetsConditions(unlockGroup, Main.SaveManager));
        }
    }
    private function UpdateModelEndlessFlags(model:MapModel):Void {
        var currentFlags = GetEndlessFlags();
        var maxFlags = GetMaxEndlessFlags();
        var text = Main.LanguageManager._(ENDLESS_FLAGS_TEMPLATE, [currentFlags, maxFlags]);
        model.SetEndlessFlagsTextActive(IsEndlessUnlocked());
        model.SetEndlessFlagsText(text);
    }
    private function UpdateUIArrows():Void {
        var storeTalks = Main.ResourceManager.GetCurrentStoreLoreTalks();
        ui.SetStoreArrowVisible(storeTalks.length > 0);

        var meta = Main.ResourceManager.GetMapMeta(VanillaMapID.gensokyo);
        var mapTalks = meta != null && meta.loreTalks != null ? meta.loreTalks.GetLoreTalks(Main.SaveManager) : null;
        ui.SetMapArrowVisible(mapTalks != null && mapTalks.length > 0);
    }
    private function HideUIArrows():Void {
        ui.SetStoreArrowVisible(false);
        ui.SetMapArrowVisible(false);
    }
    private function GetEndlessFlags():Int {
        var stageID = mapMeta.endlessStage;
        if (!NamespaceID.IsValid(stageID))
            return 0;
        return Main.SaveManager.GetCurrentEndlessFlag(stageID);
    }
    private function GetMaxEndlessFlags():Int {
        var stageID = mapMeta.endlessStage;
        if (!NamespaceID.IsValid(stageID))
            return 0;
        // PORT-NOTE: C# 的 `(int)GetStat(...)`；移植层 GetStat 返回 haxe.Int64，需显式转换。
        return haxe.Int64.toInt(Main.SaveManager.GetStat(LogicStats.CATEGORY_MAX_ENDLESS_FLAGS, stageID));
    }
    private function ReloadMap():Void {
        Main.Scene.HidePages();
        Main.Scene.DisplayMap(MapID);
    }
    private function CancelDraggingView():Void {
        draggingView = false;
        ui.SetDragRootVisible(false);
    }

    // #endregion

    @:translateMsg("地图的提示文本")
    public static inline var HINT_TEXT:String = "按住右键拖动以移动视图\n滚轮以缩放视图";
    @:translateMsg("地图的提示文本")
    public static inline var HINT_TEXT_MOBILE:String = "单指拖动以移动视图\n双指触摸以缩放视图";
    @:translateMsg("地图的提示文本")
    public static inline var HINT_TEXT_ENTERING_LEVEL:String = "正在进入关卡……";
    @:translateMsg("地图的无尽模式提示文本，{0}为当前轮数，{1}为历史最高")
    public static inline var ENDLESS_FLAGS_TEMPLATE:String = "轮数\n{0}/{1}";
    @:translateMsg("进入关卡的错误信息，{0}为地点ID")
    public static inline var ERROR_AREA_NOT_EXISTS:String = "目标地点{0}不存在。";
    @:translateMsg("进入关卡的错误信息，{0}为关卡ID")
    public static inline var ERROR_STAGE_NOT_EXISTS:String = "目标关卡{0}不存在。";

    private var Main(get, never):MainManager;
    inline function get_Main():MainManager return MainManager.Instance;

    private var model:MapModel;
    private var mapMeta:MapMeta = null;
    private var draggingView:Bool;
    private var mapDragStartPos:Vector2 = new Vector2(0, 0); // PORT-NOTE: C# Vector2 为 struct，默认 (0,0)；显式初始化避免 abstract-over-class 的 null 解引用
    private var cameraScaleSpeed:Float;
    private var raycastResultCache:Array<RaycastResult> = [];
    private var touchDatas:Array<TouchData> = [];
    private var talkSystem:ITalkSystem = null;
    public var MapID(default, null):NamespaceID = null;
    @:serializeField
    private var ui:MapUI = null;
    @:serializeField
    private var talkController:TalkController = null;
    @:serializeField
    private var raycastHitbox:GameObject = null;
    @:serializeField
    private var modelRoot:Transform = null;
    @:serializeField
    private var mapCameraShakeRoot:Transform = null;
    @:serializeField
    private var mapCamera:Camera = null;
    @:serializeField
    private var minCameraSize:Float = 2;
    @:serializeField
    private var optionDialogController:OptionsDialogController = null;

    @:inspectorHeader("Button Colors")
    @:serializeField
    private var buttonColorMinigame:Color = Color.yellow;
    @:serializeField
    private var buttonColorLocked:Color = Color.gray;
    @:serializeField
    private var buttonColorBoss:Color = Color.red;
    @:serializeField
    private var buttonColorEndless:Color = Color.magenta;
    @:serializeField
    private var buttonColorUncleared:Color = new Color(0, 1, 0, 1);
    @:serializeField
    private var buttonColorCleared:Color = new Color(0, 0.5, 1, 1);
}

// PORT-NOTE: C# private nested class → module-level class.
private class TouchData {
    public var fingerId:Int;
    public var position:Vector2 = new Vector2(0, 0); // PORT-NOTE: C# Vector2 为 struct，默认 (0,0)；显式初始化避免 abstract-over-class 的 null 解引用
    public var delta:Vector2 = new Vector2(0, 0); // PORT-NOTE: C# Vector2 为 struct，默认 (0,0)；显式初始化避免 abstract-over-class 的 null 解引用

    public function new() {}
}
