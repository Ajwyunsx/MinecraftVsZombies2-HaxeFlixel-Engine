// Ported from: Assets/Scripts/MVZ2/Level/LevelController/*.cs
//             合并了 LevelController 的全部 partial（分部）文件为单一 LevelController.hx。
package mvz2.level;

import haxe.Int64;
import mvz2.audios.*;
import mvz2.cameras.*;
import mvz2.gamecontent.effects.VanillaEffectID;
import mvz2.globalgames.GlobalGame;
import mvz2.level.components.*;
import mvz2.localization.LanguageManager;
import mvz2.managers.*;
import mvz2.models.*;
import mvz2.options.OptionsManager;
import mvz2.rendering.RenderDowngrade;
import mvz2.saves.SaveManager;
import mvz2.scenes.MainSceneController;
import mvz2.supporters.SponsorPlans;
import mvz2.ui.*;
import mvz2.ui.level.*;
import mvz2logic.Global;
import mvz2logic.callbacks.*;
// PORT-NOTE: C# 命名空间为 MVZ2Logic.Entities，但移植后 EntityTypes 实际声明在
// pvzengine/entities/EntityTypes.hx（package pvzengine.entities）。
import pvzengine.entities.EntityTypes;
import mvz2logic.level.*;
import mvz2logic.options.*;
import pvzengine.*;
import pvzengine.callbacks.CallbackResult;
// PORT-NOTE: ICollisionSystem 的规范模块是 pvzengine.collisions.level.ICollisionSystem，
// 但既有调用点（mvz2/collisions/UnityCollisionSystem.hx）统一用别名模块 pvzengine.collisions.ICollisionSystem。
import pvzengine.collisions.ICollisionSystem;
import pvzengine.entities.*;
import pvzengine.level.*;
import pvzengine.seedpacks.*;
import system.threading.tasks.Task;
import tools.*;
import unity.pool.ObjectPool;
import unity.*;
import unity.Debug;
// PORT-NOTE: 以下类型是同包其他模块的次类型，Haxe 需显式从所属模块导入。
import mvz2.level.LevelControllerPart.ILevelControllerPart;
import mvz2.level.LevelControllerPart.SerializableLevelControllerPart;
import mvz2.level.LevelManager.LevelDataIdentifier;
import mvz2.level.LevelManager.LevelDataIdentifierCompareResult;
import mvz2.level.LevelManager.LevelDataIdentifierPair;
import mvz2.collisions.UnityCollisionSystem;
import mvz2.cursors.CursorManager;
import mvz2.debugs.DebugManager;
import mvz2.entities.EntityController;
import mvz2.entities.EntityController.SerializableEntityController;
import mvz2.gamecontent.commands.Energy;
import mvz2.gamecontent.commands.Spawn;
import mvz2.gamecontent.commands.Unlock;
import mvz2.gamecontent.contraptions.CommandBlock;
import mvz2.gamecontent.contraptions.Furnace;
import mvz2.gamecontent.contraptions.VanillaContraptionID;
import mvz2.gamecontent.effects.FloatingText;
import mvz2.gamecontent.enemies.VanillaSpawnID;
import mvz2.gamecontent.helditems.VanillaHeldTypes;
import mvz2.gamecontent.models.VanillaModelID;
import mvz2.gamecontent.pickups.BlueprintPickup;
import mvz2.gamecontent.sprites.VanillaSprites;
import mvz2.grids.GridController.GridControllerData;
import mvz2.grids.GridController.GridInitData;
import mvz2.grids.GridLayoutController;
import mvz2.grids.GridModelInterface;
import mvz2.helditems.HeldItemCursorSource;
import mvz2.helditems.HeldItemModelInterface;
import mvz2.inputs.InputManager;
import mvz2.metas.StageMetaTalk;
import mvz2.modding.ModManager;
import mvz2.options.HotKeys;
import mvz2.options.OptionContextLevel;
import mvz2.options.OptionsDialogController;
import mvz2.supporters.SponsorManager;
import mvz2.talk.TalkController;
import mvz2.view.level.LevelPointerInteractionHandler.IPointerReleaseHandler;
import mvz2logic.Layers;
import mvz2logic.audios.LogicMusicID;
import mvz2logic.audios.LogicSoundID;
import mvz2logic.blueprints.BlueprintChooseItem;
// PORT-NOTE: 原先自动补齐的 mvz2logic.contents.buffs.FrameworksBuffID(.Enemy) 两个 import 未被使用，
// 且会把 Entity 解析到错误类型，故删除。
import mvz2logic.cursor.CursorSource;
import mvz2logic.helditems.HeldHighlight;
import mvz2logic.helditems.HeldHighlightMode;
import mvz2logic.helditems.HeldItemDefinition;
import mvz2logic.helditems.HeldItemTargetBlueprint;
import mvz2logic.helditems.HeldItemTargetGrid;
import mvz2logic.helditems.HeldItemTargetLawn;
import mvz2logic.helditems.HeldTargetFlag;
import mvz2logic.helditems.IHeldItemData;
import mvz2logic.helditems.LogicHeldTypes;
import mvz2logic.inputs.InputHelper;
import mvz2logic.inputs.MouseButtons;
import mvz2logic.inputs.PointerData;
import mvz2logic.inputs.PointerInteraction;
import mvz2logic.inputs.PointerInteractionData;
import mvz2logic.inputs.PointerPositionParams;
import mvz2logic.inputs.PointerTypes;
import mvz2logic.localization.LogicStrings;
import mvz2logic.models.SortingLayers.ShaderProperties;
import mvz2logic.resources.SpriteReference;
import mvz2logic.talk.ITalkSystem;
import mvz2logic.unlocks.LogicUnlockID;
import pvzengine.base.Definition;
import pvzengine.callbacks.LevelCallbackParams;
import pvzengine.callbacks.LevelCallbacks;
import pvzengine.callbacks.LevelCallbacks.PostWaveParams;
import pvzengine.collisions.BuiltinCollisionCollider;
import pvzengine.collisions.Hitbox;
import pvzengine.collisions.level.BuiltinCollisionSystem;
import pvzengine.collisions.level.QuadTreeNode;
import pvzengine.collisions.level.QuadTreeParams;
import pvzengine.grids.LawnGrid;
import pvzengine.models.IModelInterface;
import unity.eventsystems.EventSystem;
import unity.eventsystems.PointerEventData;
import unity.eventsystems.PointerEventData.InputButton;
import unity.eventsystems.PointerEventData.RaycastResult;
import mvz2.grids.GridController;
import mvz2.options.Options;
import mvz2.view.level.LevelPointerInteractionHandler;
import mvz2logic.models.SortingLayers;
import unity.scenemanagement.SceneInstance.Scene;
import Main;
import mvz2.level.components.MVZ2Component.IMVZ2LevelComponent;
import mvz2.ui.Tooltip.TooltipContent;
import mvz2.ui.level.LevelUI.ILevelUI;
import mvz2.ui.level.LevelUIPreset.VisibleState;
import mvz2.ui.level.PickaxeSlot.PickaxeNumberText;
import mvz2.ui.level.ProgressBar.ProgressBarTemplateViewData;
import mvz2logic.callbacks.LogicCallbacks.TalkActionParams;
import mvz2logic.callbacks.LogicLevelCallbacks.PostBlueprintSelectionParams;
import mvz2logic.callbacks.LogicLevelCallbacks.PostUseEntityBlueprintParams;
import unity.Coroutine.CoroutineContext;
import unity.scenemanagement.SceneInstance;
// PORT-NOTE: C# 中下列扩展方法（this 参数形式）在 Haxe 里必须显式 using 才能以 `obj.Method()` 调用，
// 与 Assets/Scripts 中的 `*Ext.cs` / `*Props.cs` / `*Helper.cs` 一一对应。
using mvz2.talk.TalkHelper;                        // SimpleStartTalkAsync(this TalkController, ...)
using mvz2logic.entities.LogicBossProps;           // DontCountBossHP(this Entity)
using mvz2logic.entities.LogicEnemyProps;          // IsPreviewEnemy / GetCrySound
using mvz2logic.entities.LogicEntityExt;           // IsHostileEntity / UpdateAnimationParameters / GetRideablePassenger
using mvz2logic.entities.LogicEntityProps;         // CanUpdateBeforeGameStart / CanUpdateInPause / CanUpdateAfterGameOver
using mvz2logic.games.LogicGameExt;                // GetBlueprintErrorMessage / GetDifficultyName / GetInnateBlueprints
using mvz2logic.helditems.LogicHeldItemExt;        // GetDefinition / GetHoldingEntity / GetSeedPack
using mvz2logic.inputs.InputHelper;                // IsMouseButNotLeft(this PointerEventData)
using mvz2logic.level.LogicAreaProps;              // GetModelIDFromArea(this AreaDefinition)
using mvz2logic.level.LogicStageProps;             // GetModelPreset / GetStartCameraPosition / GetStartTransition
using mvz2logic.options.LogicOptionExt;            // IsHPBarEnabled / ShowHotkeyIndicators / GetHPBarAmountMode 等
using mvz2logic.blueprints.LogicSeedProps;         // IsTriggerActiveOfPack / CanInstantTrigger(SeedDefinition)
using mvz2logic.blueprints.LogicSeedExt;           // CanInstantTrigger(SeedPack) / CanPick
using mvz2logic.saves.LogicSaveExt;                // IsLevelCleared / IsAlmanacUnlocked / SetMapTalk / GetStarshardSlots
using mvz2logic.contents.enemies.LogicEnemyExt;    // GetRideablePassenger(this Entity)
using tools.EnumerableExt;                         // Random(this Array<T>, rng)

class LevelController extends MonoBehaviour implements ILevelController
{
	private function Awake():Void
	{
		parts = [
			blueprintController,
			blueprintChooseController,
		];
		Awake_Collision();
		Awake_Model();
		Awake_Grids();
		Awake_Entities();
		Awake_Talk();
		Awake_Camera();
		Awake_UI(); // Awake_UI 要放在其他使用UIPreset的前面，防止获取到错误的Preset。
		Awake_HeldItem();
		Awake_ProgressBar();
		Awake_Tooltip();
		Awake_Dialogs();
		Awake_Tools();
		Awake_Artifacts();
		Awake_Blueprints();
		for (controller in parts)
		{
			controller.Init(this);
		}

		OptionsManager.OnOptionChangedBool.add(OnOptionChangedBoolCallback);
		OptionsManager.OnKeybindingChanged.add(OnKeybindingChangedCallback);
		OptionsManager.OnKeybindingsReset.add(OnKeybindingsResetCallback);
	}
	private function ReadFromSerializable_Parts(seri:SerializableLevelController):Void
	{
		for (part in parts)
		{
			// PORT-NOTE: C# 的 `seri.parts.FirstOrDefault(p => p != null && p.id == part.ID)`。
			var seriPart:SerializableLevelControllerPart = null;
			if (seri.parts != null)
			{
				for (p in seri.parts)
				{
					if (p != null && p.id == part.ID)
					{
						seriPart = p;
						break;
					}
				}
			}
			if (seriPart == null)
			{
				Debug.LogWarning('Could not find serialized LevelControllerPart data with id ${part.ID}.');
				continue;
			}
			part.LoadFromSerializable(seriPart);
		}
	}
	public function Dispose():Void
	{
		Music.SetVolume(1);
		Music.SetTrackWeight(0);
		if (level != null)
		{
			for (component in level.GetComponents())
			{
				if (Std.isOfType(component, IMVZ2LevelComponent))
				{
					var comp:IMVZ2LevelComponent = cast component;
					comp.PostDispose();
				}
			}
			level.StopAllLoopSounds();
			level.Dispose();
		}
		LevelManager.SetLevelController(null);

		OptionsManager.OnOptionChangedBool.remove(OnOptionChangedBoolCallback);
		OptionsManager.OnKeybindingChanged.remove(OnKeybindingChangedCallback);
		OptionsManager.OnKeybindingsReset.remove(OnKeybindingsResetCallback);
	}
	public function UpdateDifficulty():Void
	{
		if (level.CurrentFlag <= 0)
		{
			level.SetDifficulty(Options.GetDifficulty());
		}
		UpdateDifficultyName();
	}
	public function GetCurrentFlag():Int
	{
		return level.CurrentFlag;
	}
	public function GetEngine():LevelEngine
	{
		return level;
	}
	public function SetActive(active:Bool):Void
	{
		gameObject.SetActive(active);
	}
	public function IsHPBarsUnlocked():Bool
	{
		return isHPBarUnlocked;
	}
	public function ShouldShowHPBars():Bool
	{
		return Main.OptionsManager.IsHPBarEnabled() && IsHPBarsUnlocked();
	}

	private function OnOptionChangedBoolCallback(id:NamespaceID, value:Bool):Void
	{
		if (id == LogicOptionItemID.showHotkeys)
		{
			UpdateHotkeyTexts();
		}
	}
	private function OnKeybindingChangedCallback(id:NamespaceID, code:KeyCode):Void
	{
		UpdateHotkeyTexts();
	}
	private function OnKeybindingsResetCallback():Void
	{
		UpdateHotkeyTexts();
	}

	// #region 属性字段
	public var Game(get, never):GlobalGame;
	function get_Game():GlobalGame return Main.Game;
	private var Main(get, never):MainManager;
	function get_Main():MainManager return MainManager.Instance;
	private var Saves(get, never):SaveManager;
	function get_Saves():SaveManager return Main.SaveManager;
	private var Music(get, never):MusicManager;
	function get_Music():MusicManager return Main.MusicManager;
	private var LevelManager(get, never):mvz2.level.LevelManager;
	function get_LevelManager():mvz2.level.LevelManager return Main.LevelManager;
	private var Localization(get, never):LanguageManager;
	function get_Localization():LanguageManager return Main.LanguageManager;
	private var Resources(get, never):ResourceManager;
	function get_Resources():ResourceManager return Main.ResourceManager;
	private var Sounds(get, never):SoundManager;
	function get_Sounds():SoundManager return Main.SoundManager;
	private var Scene(get, never):MainSceneController;
	function get_Scene():MainSceneController return Main.Scene;
	private var Options(get, never):OptionsManager;
	function get_Options():OptionsManager return Main.OptionsManager;
	private var Shakes(get, never):ShakeManager;
	function get_Shakes():ShakeManager return Main.ShakeManager;
	private var level:LevelEngine = null;
	private var rng:RandomGenerator = null;

	private var parts:Array<ILevelControllerPart> = null;
	private var isHPBarUnlocked:Bool;
	// #endregion

	// ==== 以下为各 LevelController_*.cs 分部成员 ====

	public function GetUI():ILevelUI
	{
		return ui;
	}
	// ===== LevelController_Model.cs =====
	private function Awake_Model():Void
	{
		areaModelInterface = new AreaModelInterface(this);
	}
	private function InitLevelEngine_Model(level:LevelEngine, areaID:NamespaceID, stageID:NamespaceID):Void
	{
		CreateLevelModel(areaID, stageID);
	}
	private function WriteToSerializable_Model(seri:SerializableLevelController):Void
	{
		if (model != null)
			seri.model = model.ToSerializable();
	}
	private function ReadFromSerializable_Model(seri:SerializableLevelController):Void
	{
		if (model != null && seri.model != null)
			model.LoadFromSerializable(seri.model);
	}

	// #region 初始化模型
	private function CreateLevelModel(areaId:NamespaceID, stageID:NamespaceID):Void
	{
		var areaDef = Game.GetAreaDefinition(areaId);
		if (areaDef == null)
			return;
		var modelID = areaDef.GetModelIDFromArea();
		if (modelID == null)
			return;
		var modelPrefab = Resources.GetAreaModel(modelID);
		if (modelPrefab == null)
			return;
		// PORT-NOTE: C# `Instantiate(prefab.gameObject, modelRoot).GetComponent<AreaModel>()`。
		// Haxe 侧 unity.UnityObject.Instantiate 对 Component 模板会新建 GameObject 并 AddComponent，
		// 返回新实例，等价于原写法（parent 参数对应 C# 的 parent 参数）。
		model = UnityObject.Instantiate(modelPrefab, null, null, modelRoot);
		if (model != null)
		{
			model.Init(modelID, GetCamera());
			var stageDef = Game.GetStageDefinition(stageID);
			var modelPreset = stageDef != null ? stageDef.GetModelPreset() : null;
			if (modelPreset != null)
			{
				SetModelPreset(modelPreset);
			}
		}
	}
	// #endregion

	// #region 修改模型
	public function SetModelPreset(name:String):Void
	{
		if (model == null)
			return;
		model.SetPreset(name);
	}
	// #endregion

	// #region 获取模型
	public function GetAreaModel():AreaModel
	{
		return model;
	}
	public function GetAreaModelInterface():IModelInterface
	{
		return areaModelInterface;
	}
	// #endregion

	// #region 动画
	public function TriggerModelAnimator(name:String):Void
	{
		if (model == null)
			return;
		model.TriggerAnimator(name);
	}
	public function SetModelAnimatorBool(name:String, value:Bool):Void
	{
		if (model == null)
			return;
		model.SetAnimatorBool(name, value);
	}
	public function SetModelAnimatorInt(name:String, value:Int):Void
	{
		if (model == null)
			return;
		model.SetAnimatorInt(name, value);
	}
	public function SetModelAnimatorFloat(name:String, value:Float):Void
	{
		if (model == null)
			return;
		model.SetAnimatorFloat(name, value);
	}
	// #endregion

	// #region 属性字段
	private var model:AreaModel;
	private var areaModelInterface:IModelInterface = null;

	@:header("Model")
	@:serializeField
	private var modelRoot:Transform = null;
	// #endregion

	// ===== LevelController_Audio.cs =====
	public function SetMusicLowQuality(lowQuality:Bool):Void
	{
		normalAudioListener.SetActive(!lowQuality);
		lowQualityAudioListener.SetActive(lowQuality);
	}
	private function StartGame_Audio():Void
	{
		var musicID = level.GetMusicID();
		if (musicID == null)
			return;
		Music.Play(musicID);
		MusicTime = 0;
		MusicTrackWeight = 0;
	}
	private function WriteToSerializable_Audio(seri:SerializableLevelController):Void
	{
		seri.musicID = CurrentMusic;
		seri.musicTime = MusicTime;
		seri.musicVolume = MusicVolume;
		seri.musicTrackWeight = MusicTrackWeight;
	}
	private function ReadFromSerializable_Audio(seri:SerializableLevelController):Void
	{
		CurrentMusic = seri.musicID;
		MusicTime = seri.musicTime;
		MusicVolume = seri.musicVolume;
	}
	public var CurrentMusic(get, set):NamespaceID;
	function get_CurrentMusic():NamespaceID return Music.GetCurrentMusicID();
	function set_CurrentMusic(value:NamespaceID):NamespaceID
	{
		if (NamespaceID.IsValid(value))
		{
			Music.Play(value);
		}
		else
		{
			Music.Stop();
		}
		return value;
	}
	public var MusicTime(get, set):Float;
	function get_MusicTime():Float return Music.Time;
	function set_MusicTime(value:Float):Float return Music.Time = value;
	public var MusicVolume(get, set):Float;
	function get_MusicVolume():Float return Music.GetVolume();
	function set_MusicVolume(value:Float):Float { Music.SetVolume(value); return value; }
	public var MusicTrackWeight(get, set):Float;
	function get_MusicTrackWeight():Float return Music.GetTrackWeight();
	function set_MusicTrackWeight(value:Float):Float { Music.SetTrackWeight(value); return value; }
	@:header("Audio")
	@:serializeField
	private var normalAudioListener:GameObject = null;
	@:serializeField
	private var lowQualityAudioListener:GameObject = null;

	// ===== LevelController_Camera.cs =====
	private function Awake_Camera():Void
	{
		levelCamera.SetPosition(cameraHousePosition, cameraHouseAnchor);
	}
	public function GetCamera():Camera
	{
		return levelCamera.Camera;
	}
	public function SetCameraDisabled(disabled:Bool):Void
	{
		cameraRoot.SetActive(!disabled);
	}
	private function UpdateCamera():Void
	{
		var camera = levelCamera.Camera;
		var cameraHeight = camera.orthographicSize * 2;
		var cameraWidth = cameraHeight * camera.aspect;
		var cameraSize = new Vector2(cameraWidth, cameraHeight);
		var anchorOffset = levelCamera.CameraAnchor - Vector2.one * 0.5;
		var cameraCenter = levelCamera.CameraPosition - toVector3(anchorOffset * cameraSize);
		var cameraMin = cameraCenter - toVector3(cameraSize * 0.5);
		var width = (cameraLimitX - cameraMin.x) / cameraLimitX;
		var preset = ui.GetUIPreset();
		preset.SetCameraLimitWidth(width);
	}
	private static function toVector3(v:Vector2):Vector3
	{
		return new Vector3(v.x, v.y, 0);
	}
	private function UpdateCameraByLevel(level:LevelEngine):Void
	{
		var targetRotation:Float = level.GetCameraRotation();
		if (!IsGameStarted() || IsGameOver())
		{
			targetRotation = 0;
		}
		var rotation = levelCamera.GetRotation();
		levelCamera.SetSpace(Main.UseMobileLayout() ? cameraLeftSpaceMobile : cameraLeftSpaceStandalone);
		levelCamera.SetRotation(rotation * 0.8 + targetRotation * 0.2);
		downgradeScript.enabled = level.AreGraphicsDowngrade();
	}
	// #region 移动相机
	private function SetCameraPosition(position:LevelCameraPosition):Void
	{
		var pos = cameraHousePosition;
		var anchor = cameraHouseAnchor;
		switch (position)
		{
			case LevelCameraPosition.Lawn:
				pos = cameraLawnPosition;
				anchor = cameraLawnAnchor;
			case LevelCameraPosition.Choose:
				pos = cameraChoosePosition;
				anchor = cameraChooseAnchor;
			default:
		}
		levelCamera.SetPosition(pos, anchor);
	}
	private function MoveCameraLawn(target:Vector3, targetAnchor:Vector2, maxTime:Float):Coroutine
	{
		return Coroutine.create(function(co:CoroutineContext)
		{
			var time:Float = 0;
			var start = levelCamera.CameraPosition;
			var startAnchor = levelCamera.CameraAnchor;
			while (time < maxTime)
			{
				time = Mathf.Clamp(time + Time.deltaTime, 0, maxTime);
				var lerp = cameraMoveCurve.Evaluate(time / maxTime);
				var pos = Vector3.Lerp(start, target, lerp);
				var anchor = Vector2.Lerp(startAnchor, targetAnchor, lerp);
				levelCamera.SetPosition(pos, anchor);
				co.waitFrames(1);
			}
		});
	}
	private function MoveCameraToHouse():Coroutine
	{
		return MoveCameraLawn(cameraHousePosition, cameraHouseAnchor, 1);
	}
	public function MoveCameraToLawn():Coroutine
	{
		return MoveCameraLawn(cameraLawnPosition, cameraLawnAnchor, 1);
	}
	public function MoveCameraToChoose():Coroutine
	{
		return MoveCameraLawn(cameraChoosePosition, cameraChooseAnchor, 1);
	}
	// #endregion

	// #region 属性字段
	@:header("Camera")
	@:serializeField
	private var cameraRoot:GameObject = null;
	@:serializeField
	private var levelCamera:LevelCamera = null;
	@:serializeField
	private var downgradeScript:RenderDowngrade = null;
	@:serializeField
	private var cameraMoveCurve:AnimationCurve = null;
	@:serializeField
	private var cameraLimitX:Float = 2.2;
	@:serializeField
	private var cameraLeftSpaceMobile:Float = 2.2;
	@:serializeField
	private var cameraLeftSpaceStandalone:Float = 0;
	@:serializeField
	private var cameraHousePosition:Vector3 = new Vector3(0, 3, -10);
	@:serializeField
	private var cameraHouseAnchor:Vector2 = new Vector2(0, 0.5);
	@:serializeField
	private var cameraLawnPosition:Vector3 = new Vector3(10.2, 3, -10);
	@:serializeField
	private var cameraLawnAnchor:Vector2 = new Vector2(1, 0.5);
	@:serializeField
	private var cameraChoosePosition:Vector3 = new Vector3(14, 3, -10);
	@:serializeField
	private var cameraChooseAnchor:Vector2 = new Vector2(1, 0.5);
	// #endregion

	// ===== LevelController_Transform.cs =====
	// #region 方位
	public function LawnToTrans(pos:Vector3):Vector3
	{
		// PORT-NOTE: C# `pos * LawnToTransScale`，Haxe 的 unity.Vector3 用运算符重载（无 multiplyScalar 方法）。
		pos = pos * LawnToTransScale;
		var vector = new Vector3(pos.x, pos.z + pos.y, pos.z);
		vector = vector + transform.position;
		return vector;
	}
	public function TransToLawn(pos:Vector3):Vector3
	{
		pos = pos - transform.position;
		var vector = new Vector3(pos.x, pos.y - pos.z, pos.z);
		vector = vector * TransToLawnScale;
		return vector;
	}
	public function LawnToTransDistance(distance:Vector3):Vector3
	{
		distance = distance * LawnToTransScale;
		return new Vector3(distance.x, distance.z + distance.y, distance.z);
	}
	public function TransToLawnDistance(distance:Vector3):Vector3
	{
		var vector = new Vector3(distance.x, distance.y - distance.z, distance.z);
		vector = vector * TransToLawnScale;
		return vector;
	}
	public function ScreenToLawnPositionByZ(screenPosition:Vector2, z:Float):Vector3
	{
		var worldPosition = levelCamera.Camera.ScreenToWorldPoint(screenPosition);
		worldPosition.z = transform.position.z;

		var lawnPosition = TransToLawn(worldPosition);
		lawnPosition.z = z;
		lawnPosition.y -= z;

		return lawnPosition;
	}
	public function ScreenToLawnPositionByY(screenPosition:Vector2, y:Float):Vector3
	{
		var worldPosition = levelCamera.Camera.ScreenToWorldPoint(screenPosition);
		worldPosition.z = transform.position.z;

		var lawnPosition = TransToLawn(worldPosition);
		lawnPosition.z = lawnPosition.y - y;
		lawnPosition.y = y;

		return lawnPosition;
	}
	public function ScreenToLawnPositionByRelativeY(screenPosition:Vector2, relativeY:Float, precision:Float = 0.2):Vector3
	{
		var worldPosition = levelCamera.Camera.ScreenToWorldPoint(screenPosition);
		worldPosition.z = transform.position.z;

		var lawnPosition = TransToLawn(worldPosition);
		var targetY = lawnPosition.y;
		var x = lawnPosition.x;
		var currentZ:Float = 0;
		var maxZ = targetY;
		for (i in 0...16)
		{
			var yOffset = level.GetGroundY(x, currentZ) + relativeY;
			var nextMaxZ = maxZ - yOffset;
			currentZ = (currentZ + nextMaxZ) * 0.5;
			if (Mathf.Abs(targetY - (currentZ + yOffset)) <= precision)
			{
				break;
			}
		}
		lawnPosition.z = currentZ;
		lawnPosition.y = targetY - currentZ;

		return lawnPosition;
	}
	// #endregion

	public var LawnToTransScale(get, never):Float;
	function get_LawnToTransScale():Float return LevelManager.LawnToTransScale;
	public var TransToLawnScale(get, never):Float;
	function get_TransToLawnScale():Float return LevelManager.TransToLawnScale;

	// ===== LevelController_Lighting.cs =====
	private function UpdateLighting():Void
	{
		var background = Color.white;
		var backgroundTint = Color.white;
		var global = Color.white;
		if (level != null)
		{
			background = level.GetBackgroundLight();
			backgroundTint = level.GetBackgroundTint();
			global = Color.Lerp(Color.white, level.GetGlobalLight(), darknessFactor);
		}
		Main.GraphicsManager.SetLighting(background, backgroundTint, global);
	}

	// #region 属性字段
	private var darknessFactor:Float = 1;
	// #endregion

	// ===== LevelController_Twinkle.cs =====
	private function WriteToSerializable_Twinkle(seri:SerializableLevelController):Void
	{
		seri.twinkleTime = twinkleTime;
	}
	private function ReadFromSerializable_Twinkle(seri:SerializableLevelController):Void
	{
		twinkleTime = seri.twinkleTime;
	}
	public function GetTwinkleAlpha():Float
	{
		var clamped = (Mathf.Cos(twinkleTime * Mathf.PI * 2) + 1) * 0.5;
		return clamped * 0.75;
	}
	public function GetTwinkleColor():Color
	{
		var c = 1 - GetTwinkleAlpha();
		return new Color(c, c, c, 1);
	}
	private function UpdateTwinkle(deltaTime:Float):Void
	{
		var speed = 2;
		twinkleTime += deltaTime * speed;
		twinkleTime %= 1;
	}

	// #region 属性字段
	private var twinkleTime:Float;
	// #endregion

	// ===== LevelController_Cry.cs =====
	private function UpdateEnemyCry():Void
	{
		var crySoundEnemies:Array<Entity> = null;
		if (level.IsTimeInterval(7))
		{
			crySoundEnemies = GetCrySoundEnemies();
			var enemyCount = crySoundEnemies.length;
			var t = Mathf.Clamp01((enemyCount - MinEnemyCryCount) / (MaxEnemyCryCount - MinEnemyCryCount));
			maxCryTime = Std.int(Mathf.Lerp(MaxCryInterval, MinCryInterval, t));
		}
		cryTimer.Run();
		if (cryTimer.MaxFrame - cryTimer.Frame >= maxCryTime)
		{
			cryTimer.Reset();

			if (crySoundEnemies == null)
				crySoundEnemies = GetCrySoundEnemies();
			var enemyCount = crySoundEnemies.length;
			if (enemyCount <= 0)
				return;
			var crySoundEnemy = crySoundEnemies.Random(rng);
			var crySound = crySoundEnemy.GetCrySound();
			if (crySound != null)
			{
				crySoundEnemy.PlayCrySound(crySound);
			}
		}
	}
	private function GetCrySoundEnemies():Array<Entity>
	{
		var enemies = level.GetEntities(EntityTypes.ENEMY);
		if (enemies.length <= 0)
			return [];
		return [for (e in enemies) if (e.GetCrySound() != null) e];
	}
	private function WriteToSerializable_Cry(seri:SerializableLevelController):Void
	{
		seri.maxCryTime = maxCryTime;
		seri.cryTimer = cryTimer;
	}
	private function ReadFromSerializable_Cry(seri:SerializableLevelController):Void
	{
		maxCryTime = seri.maxCryTime;
		if (seri.cryTimer != null)
			cryTimer = seri.cryTimer;
	}

	// #region 属性字段
	public static inline var MinEnemyCryCount:Int = 1;
	public static inline var MaxEnemyCryCount:Int = 20;
	public static inline var MinCryInterval:Int = 60;
	public static inline var MaxCryInterval:Int = 300;
	private var cryTimer:FrameTimer = new FrameTimer(MaxCryInterval);
	private var maxCryTime:Int = MaxCryInterval;
	// #endregion

	// ===== LevelController_Pause.cs =====
	public function IsGamePaused():Bool
	{
		return isPaused;
	}
	private function IsPauseDisabled():Bool
	{
		if (level == null)
			return true;
		return level.IsPauseDisabled();
	}
	public function PauseGame(pauseLevel:Int = 0):Void
	{
		if (isPaused)
		{
			if (pauseLevel > this.pauseLevel)
			{
				this.pauseLevel = pauseLevel;
			}
			return;
		}
		this.pauseLevel = pauseLevel;
		isPaused = true;
		Music.Pause();

		level.Triggers.RunCallback(LogicLevelCallbacks.POST_PAUSE, new LevelCallbackParams(level));
	}
	public function ResumeGameDelayed(pauseLevel:Int = 0):Void
	{
		// PORT-NOTE: Haxe 的局部函数需先声明后使用。
		function resumeDelayedCoroutine():Coroutine
		{
			return Coroutine.create(function(co:CoroutineContext)
			{
				co.waitFrames(1);

				ResumeGame(pauseLevel);
			});
		}
		StartCoroutine(resumeDelayedCoroutine());
	}
	// TODO-PORT: C# 重载 ResumeGame(int level = 0)，此处参数改名以避免与字段 level 冲突。
	public function ResumeGame(pauseLevel:Int = 0):Bool
	{
		if (!isPaused || pauseLevel < this.pauseLevel)
			return false;
		if (Main.Scene.HasDialog())
			return false;
		this.pauseLevel = 0;
		isPaused = false;
		Music.Resume();

		if (optionsDialogController.IsOpen())
		{
			optionsDialogController.Close();
		}
		ui.SetPauseDialogActive(false);
		ui.SetOptionsDialogActive(false);
		ui.SetLevelLoadedDialogVisible(false);
		levelLoaded = false;
		this.level.Triggers.RunCallback(LogicLevelCallbacks.POST_RESUME, new LevelCallbackParams(this.level));
		return true;
	}
	private function OnApplicationFocus(focus:Bool):Void
	{
		UpdateFocusLost(focus);
	}
	private function UpdateFocusLost(focus:Bool):Void
	{
		if (IsInputDisabled())
			return;
		if (!IsGameRunning())
			return;
		if (focus)
			return;
		if (!Options.GetPauseOnFocusLost())
			return;
		if (IsPauseDisabled())
			return;
		PauseGame();
		ShowPausedDialog();
	}

	// #region 属性字段
	private var isPaused:Bool = false;
	private var pauseLevel:Int = 0;
	// #endregion

	// ===== LevelController_Sponsors.cs =====
	private function AddLevelCallbacks_Sponsors(level:LevelEngine):Void
	{
		level.AddTrigger(LogicLevelCallbacks.POST_USE_ENTITY_BLUEPRINT, EnginePostUseEntityBlueprintCallback);
	}
	private function EnginePostUseEntityBlueprintCallback(param:PostUseEntityBlueprintParams, callbackResult:CallbackResult):Void
	{
		if (!Main.OptionsManager.ShowSponsorNames())
			return;
		var output = param.placeOutput;
		var entity = output.entity;
		if (entity == null)
			return;
		if (output.placeDefinition == null)
			return;
		var entityID = output.placeDefinition.GetID();
		if (entityID == VanillaContraptionID.furnace)
		{
			ShowFurnaceSponsorName(entity);
		}
		else if (entityID == VanillaContraptionID.moonlightSensor)
		{
			ShowMoonlightSensorSponsorName(entity);
		}
		else if (entityID == VanillaContraptionID.gunpowderBarrel)
		{
			ShowGunpowderBarrelSensorSponsorName(entity);
		}
	}
	private function ShowFurnaceSponsorName(furnace:Entity):Void
	{
		// PORT-NOTE: C# `SponsorPlans.Furnace.TYPE` 是嵌套静态类；Haxe 无内部类型，
		// SponsorPlans.hx 把常量平铺为 FURNACE_TYPE / FURNACE_FURNACE 等。
		var names = Main.SponsorManager.GetSponsorPlanNames(SponsorPlans.FURNACE_TYPE, SponsorPlans.FURNACE_FURNACE);
		if (names.length <= 0)
			return;
		var name = names.Random(rng);
		var param = new SpawnParams();
		param.SetProperty(FloatingText.PROP_TEXT, name);
		furnace.Spawn(VanillaEffectID.floatingText, furnace.GetCenter(), param);
	}
	private function ShowMoonlightSensorSponsorName(sensor:Entity):Void
	{
		var names = Main.SponsorManager.GetSponsorPlanNames(SponsorPlans.SENSOR_TYPE, SponsorPlans.SENSOR_MOONLIGHT_SENSOR);
		if (names.length <= 0)
			return;
		var name = names.Random(rng);
		var param = new SpawnParams();
		param.SetProperty(FloatingText.PROP_TEXT, name);
		sensor.Spawn(VanillaEffectID.floatingText, sensor.GetCenter(), param);
	}
	private function ShowGunpowderBarrelSensorSponsorName(barrel:Entity):Void
	{
		var names = Main.SponsorManager.GetSponsorPlanNames(SponsorPlans.FURNACE_TYPE, SponsorPlans.FURNACE_GUNPOWDER_BARREL);
		if (names.length <= 0)
			return;
		var name = names.Random(rng);
		var param = new SpawnParams();
		param.SetProperty(FloatingText.PROP_TEXT, name);
		barrel.Spawn(VanillaEffectID.floatingText, barrel.GetCenter(), param);
	}

	// ===== LevelController_Artifacts.cs =====
	private function Awake_Artifacts():Void
	{
		var uiPreset = GetUIPreset();
		uiPreset.OnArtifactPointerEnter.add(UI_OnArtifactPointerEnterCallback);
		uiPreset.OnArtifactPointerExit.add(UI_OnArtifactPointerExitCallback);
	}

	// #region 制品
	private function UI_OnArtifactPointerEnterCallback(index:Int):Void
	{
		var uiPreset = GetUIPreset();
		var artifact = level.GetArtifactAt(index);
		if (artifact == null || artifact.Definition == null)
			return;
		var artifactUI = uiPreset.GetArtifactAt(index);
		if (artifactUI == null)
			return;
		var artifactID = artifact.Definition.GetID();
		ShowTooltip(new ArtifactTooltipSource(this, artifactID, artifactUI));
	}
	private function UI_OnArtifactPointerExitCallback(index:Int):Void
	{
		HideTooltip();
	}
	// #endregion

	// ===== LevelController_Collision.cs =====
	private function Awake_Collision():Void
	{
		var quadTreeParams = new QuadTreeParams();
		quadTreeParams.maxDepth = 6;
		quadTreeParams.maxObjects = 3;
		quadTreeParams.collapseObjects = 1;
		quadTreeParams.size = new Rect(0, -500, 1600, 1600);
		builtinCollisionSystem = new BuiltinCollisionSystem(quadTreeParams);
	}
	private function OnDrawGizmos():Void
	{
		if (level == null)
			return;
		var buffer:Array<BuiltinCollisionCollider> = [];
		for (i in 0...8)
		{
			var flag = EntityCollisionHelper.GetTypeMask(i + 1);
			var quadTree = builtinCollisionSystem.GetCollisionQuadTree(flag);
			if (quadTree == null)
				continue;
			var node = quadTree.GetRootNode();
			Gizmos.color = Color.HSVToRGB(i / 8.0, 1, 1);
			DrawQuadTreeNode(node);
			buffer = [];
			quadTree.GetAllTargets(buffer);
			for (collider in buffer)
			{
				DrawHitbox(collider.GetHitbox());
			}
		}
	}
	private function DrawQuadTreeNode(node:QuadTreeNode<BuiltinCollisionCollider>):Void
	{
		var rect = node.GetRect();
		// PORT-NOTE: C# `rect.min * 0.01f` 等向量运算；Haxe 的 unity.Vector2 用运算符重载。
		var min = rect.min * 0.01;
		var max = rect.max * 0.01;
		var size2D = max - min;
		var center2D = min + size2D * 0.5;
		var size = new Vector3(size2D.x, 0, size2D.y);
		var center = new Vector3(center2D.x, 0, center2D.y);
		Gizmos.DrawWireCube(center, size);

		var childCount = node.GetChildCount();
		for (i in 0...childCount)
		{
			var child = node.GetChild(i);
			DrawQuadTreeNode(child);
		}
	}
	private function DrawHitbox(hitbox:Hitbox):Void
	{
		var bounds = hitbox.GetBounds();
		var size = bounds.size * LawnToTransScale;
		var center = bounds.center;
		if (alignHitboxGizmosZ)
		{
			center.y += hitbox.GetPosition().z;
		}
		center = center * LawnToTransScale;
		Gizmos.DrawWireCube(center, size);
	}

	private function GetCollisionSystem():ICollisionSystem
	{
		return builtinCollisionSystem;
		//return unityCollisionSystem;
	}
	@:header("Collision")
	@:serializeField
	private var unityCollisionSystem:UnityCollisionSystem;
	private var builtinCollisionSystem:BuiltinCollisionSystem = null;
	@:serializeField
	private var alignHitboxGizmosZ:Bool = true;

	// ===== LevelController_HPBar.cs =====
	public function AddHPBarSource(source:IHPBarSource):Void
	{
		hpBarController.AddHPBarSource(source);
	}
	public function RemoveHPBarSource(source:IHPBarSource):Void
	{
		hpBarController.RemoveHPBarSource(source);
	}
	private function UpdateHPBars(deltaTime:Float):Void
	{
		hpBarController.UpdateHPBars();
	}

	// #region 属性字段
	@:header("HPBar")
	@:serializeField
	private var hpBarController:HPBarCanvasController = null;
	// #endregion

	// ===== LevelController_Serialization.cs =====
	// #region 公有方法
	public function SaveGameHeader():SerializableLevelControllerHeader
	{
		var header = new SerializableLevelControllerHeader();
		header.identifiers = LevelManager.GetLevelStateIdentifierList();
		return header;
	}
	public function SaveGame():SerializableLevelController
	{
		var seri = new SerializableLevelController();
		seri.rng = rng.ToSerializable();
		seri.level = level.ToSerializable();
		seri.entities = [for (e in entities) e.ToSerializable()];
		seri.parts = [for (p in parts) p.ToSerializable()];
		WriteToSerializable_Audio(seri);
		WriteToSerializable_Cry(seri);
		WriteToSerializable_Model(seri);
		WriteToSerializable_ProgressBar(seri);
		WriteToSerializable_Twinkle(seri);
		WriteToSerializable_Tools(seri);
		WriteToSerializable_UI(seri);
		WriteToSerializable_Grids(seri);
		return seri;
	}
	public function ValidateGameStateHeader(header:SerializableLevelControllerHeader):Bool
	{
		var compareResult = LevelManager.GetLevelStateIdentifierList().Compare(header.identifiers);
		if (!compareResult.valid)
		{
			ShowLevelMismatchLoadingDialog(compareResult);
			return false;
		}
		return true;
	}
	public function LoadGame(seri:SerializableLevelController, game:GlobalGame, areaID:NamespaceID, stageID:NamespaceID):Bool
	{
		try
		{
			if (seri.level == null)
			{
				var msg = Main.LanguageManager._(ERROR_LOAD_LEVEL_CORRUPTED);
				throw msg;
			}
			rng = seri.rng != null ? RandomGenerator.FromSerializable(seri.rng) : new RandomGenerator(Std.random(0x7FFFFFFF));
			level = LevelEngine.CreateFromSerializable(seri.level, game, game, GetCollisionSystem());
			InitLevelEngine(level, game, areaID, stageID);

			level.InitComponentsFromSerializable(seri.level);
			level.LoadComponentsFromSerializable(seri.level);

			ReadFromSerializable_ProgressBar(seri);
			ReadFromSerializable_Twinkle(seri);
			ReadFromSerializable_Tools(seri);
			ReadFromSerializable_UI(seri);
			ReadFromSerializable_Cry(seri);
			ReadFromSerializable_Audio(seri);
			ReadFromSerializable_Grids(seri);
			ReadFromSerializable_Parts(seri);
			ReadFromSerializable_Entities(seri);
			ReadFromSerializable_Model(seri);
		}
		catch (e:Dynamic)
		{
			ShowLevelErrorLoadingDialog(e);
			Debug.LogException(e);
			return false;
		}

		// 设置UI可见状态
		SetUIVisibleState(VisibleState.InLevel);
		// 相机位置
		SetCameraPosition(LevelCameraPosition.Lawn);
		UpdateCamera();
		UpdateCameraByLevel(level);

		// 手持物品
		level.ResetHeldItem();
		RefreshUIAtLevelInit();
		RefreshUIAtLevelStart();
		ShowMoney();
		// 光照
		UpdateLighting();

		// 游戏开始状态
		SetGameStarted(true);


		for (component in level.GetComponents())
		{
			if (Std.isOfType(component, IMVZ2LevelComponent))
			{
				var comp:IMVZ2LevelComponent = cast component;
				comp.PostLevelLoad();
			}
		}
		for (part in parts)
		{
			part.PostLevelLoad();
		}

		PauseGame();
		ShowLevelLoadedDialog();
		levelLoaded = true;

		level.AreaDefinition.PostLoad(level);

		return true;
	}
	// #endregion


	// ===== LevelController_Blueprints.cs =====
	private function Awake_Blueprints():Void
	{
		ui.BlueprintChoose.SetViewLawnReturnBlockerActive(false);
		ui.Blueprints.SetConveyorMode(false);

		var uiPreset = GetUIPreset();
		uiPreset.OnBlueprintPointerInteraction.add(UI_OnBlueprintPointerInteractionCallback);
	}
	private function StartGame_Blueprints():Void
	{
		ui.SetBlueprintsSortingToChoosing(false);
	}
	public function ChooseBlueprintsInteractable():Bool
	{
		return BlueprintChoosePart.IsInteractable();
	}
	public var BlueprintController(get, never):LevelBlueprintController;
	function get_BlueprintController():LevelBlueprintController return blueprintController;
	public var BlueprintChoosePart(get, never):LevelBlueprintChooseController;
	function get_BlueprintChoosePart():LevelBlueprintChooseController return blueprintChooseController;
	@:serializeField
	var blueprintController:LevelBlueprintController = null;
	@:serializeField
	var blueprintChooseController:LevelBlueprintChooseController = null;

	// ===== LevelController_ExtraInterface.cs =====
	// #region 图鉴
	public function IsOpeningAlmanac():Bool return isOpeningAlmanac;
	public function OpenAlmanac():Void
	{
		isOpeningAlmanac = true;
		SetCameraDisabled(true);
		Main.Scene.DisplayAlmanac(function()
		{
			isOpeningAlmanac = false;
			SetCameraDisabled(false);
			if (!Music.IsPlaying(LogicMusicID.choosing))
				Music.Play(LogicMusicID.choosing);
		});
	}
	private function OpenEnemyAlmanac(enemyID:NamespaceID):Void
	{
		OpenAlmanac();
		Main.Scene.DisplayEnemyAlmanac(enemyID);
	}
	// #endregion

	// #region 商店
	public function IsOpeningStore():Bool return isOpeningStore;
	public function OpenStore():Void
	{
		isOpeningStore = true;
		SetCameraDisabled(true);
		Main.Scene.DisplayStore(function()
		{
			isOpeningStore = false;
			SetCameraDisabled(false);
			level.UpdatePersistentLevelUnlocks();
			BlueprintChoosePart.Refresh(Saves.GetUnlockedContraptions());
			if (!Music.IsPlaying(LogicMusicID.choosing))
				Music.Play(LogicMusicID.choosing);
		}, false);
	}
	// #endregion
	public function IsOpeningExtraScene():Bool return IsOpeningAlmanac() || IsOpeningStore();

	// #region 属性字段
	private var isOpeningAlmanac:Bool;
	private var isOpeningStore:Bool;
	// #endregion

	// ===== LevelController_ProgressBar.cs =====
	private function Awake_ProgressBar():Void
	{
		var uiPreset = GetUIPreset();
		uiPreset.SetProgressBarVisible(false);
	}
	private function StartGame_ProgressBar():Void
	{
		levelProgress = 0;
		bannerProgresses = [];
		bannerProgresses.resize(level.GetTotalFlags());
	}
	private function WriteToSerializable_ProgressBar(seri:SerializableLevelController):Void
	{
		seri.bannerProgresses = bannerProgresses.copy();
		seri.levelProgress = levelProgress;
		seri.bossHealth = bossHealth;
		seri.bossMaxHealth = bossMaxHealth;
		seri.progressBarMode = progressBarMode;
		seri.bossProgressBarStyle = bossProgressBarStyle;
	}
	private function ReadFromSerializable_ProgressBar(seri:SerializableLevelController):Void
	{
		bannerProgresses = seri.bannerProgresses.copy();
		levelProgress = seri.levelProgress;
		bossHealth = seri.bossHealth;
		bossMaxHealth = seri.bossMaxHealth;
		progressBarMode = seri.progressBarMode;
		bossProgressBarStyle = seri.bossProgressBarStyle;
	}


	public function SetProgressToBoss(barStyleID:NamespaceID):Void
	{
		var ui = GetUIPreset();
		progressBarMode = true;
		bossProgressBarStyle = barStyleID;
		ui.SetProgressBarMode(progressBarMode);
		var meta = Main.ResourceManager.GetProgressBarMeta(barStyleID);
		if (meta == null)
			return;
		var background = Main.GetFinalSpriteFromRef(meta.BackgroundSprite);
		var foreground = Main.GetFinalSpriteFromRef(meta.ForegroundSprite);
		var bar = Main.GetFinalSpriteFromRef(meta.BarSprite);
		var icon = Main.GetFinalSpriteFromRef(meta.IconSprite);
		var viewData = new ProgressBarTemplateViewData();
		viewData.backgroundSprite = background;
		viewData.foregroundSprite = foreground;
		viewData.barSprite = bar;
		viewData.fromLeft = meta.FromLeft;
		viewData.barMode = meta.BarMode;
		viewData.iconSprite = icon;
		viewData.padding = meta.Padding;
		viewData.size = meta.Size;
		viewData.textOffset = meta.TextOffset;
		ui.SetBossProgressTemplate(viewData);
	}
	public function SetProgressToStage():Void
	{
		var ui = GetUIPreset();
		progressBarMode = false;
		ui.SetProgressBarMode(progressBarMode);
	}
	private function AdvanceLevelProgress():Void
	{
		var deltaTime = Time.deltaTime;
		if (progressBarMode)
		{
			// BOSS血条
			var bosses = level.FindEntities(function(e:Entity) return e.Type == EntityTypes.BOSS && e.IsHostileEntity() && !e.DontCountBossHP());
			var bossCount = bosses.length;
			if (bossCount <= 0)
			{
				bossHealth = 0;
				bossMaxHealth = 0;
			}
			else
			{
				var healthSum = 0.0;
				var maxHealthSum = 0.0;
				for (b in bosses)
				{
					healthSum += b.Health;
					maxHealthSum += b.GetMaxHealth();
				}
				bossHealth = healthSum;
				bossMaxHealth = maxHealthSum;
			}
		}
		else
		{
			// 关卡进度
			var totalFlags = level.GetTotalFlags();
			if (bannerProgresses == null || bannerProgresses.length != totalFlags)
			{
				var newProgresses:Array<Float> = [];
				newProgresses.resize(totalFlags);
				if (bannerProgresses != null)
				{
					for (i in 0...bannerProgresses.length)
					{
						if (i < newProgresses.length)
							newProgresses[i] = bannerProgresses[i];
					}
				}
				bannerProgresses = newProgresses;
			}
			for (i in 0...bannerProgresses.length)
			{
				var value = (level.CurrentWave >= (totalFlags - i) * level.GetWavesPerFlag()) ? deltaTime : -deltaTime;
				bannerProgresses[i] = Mathf.Clamp01(bannerProgresses[i] + value);
			}
			var totalWaveCount = level.GetTotalWaveCount();
			var targetProgress = totalWaveCount <= 0 ? 0.0 : level.CurrentWave / totalWaveCount;
			var progressDirection = targetProgress > levelProgress ? 1 : (targetProgress < levelProgress ? -1 : 0);
			if (progressDirection != 0)
			{
				levelProgress += Time.deltaTime * 0.1 * progressDirection;
				var newDirection = targetProgress > levelProgress ? 1 : (targetProgress < levelProgress ? -1 : 0);
				if (progressDirection != newDirection)
				{
					levelProgress = targetProgress;
				}
			}
		}
	}
	private function UpdateLevelProgressUI():Void
	{
		var ui = GetUIPreset();
		ui.SetProgressBarVisible(level.LevelProgressVisible);
		ui.SetLevelProgress(levelProgress);
		if (bannerProgresses != null)
			ui.SetBannerProgresses(bannerProgresses);

		var bossProgress:Float = 0;
		var bossProgressText = "";
		if (bossMaxHealth != 0)
		{
			bossProgress = bossHealth / bossMaxHealth;
		}
		if (IsHPBarsUnlocked())
		{
			bossProgressText = EntityController.GetHPBarText(bossHealth, bossMaxHealth, Main.OptionsManager.GetHPBarAmountMode());
		}
		ui.SetBossProgress(bossProgress);
		ui.SetBossProgressText(bossProgressText);
	}
	private function RefreshProgressBar():Void
	{
		if (progressBarMode && NamespaceID.IsValid(bossProgressBarStyle))
		{
			SetProgressToBoss(bossProgressBarStyle);
		}
		else
		{
			SetProgressToStage();
		}
	}


	// #region 属性字段
	private var levelProgress:Float;
	private var bannerProgresses:Array<Float>;
	private var bossHealth:Float;
	private var bossMaxHealth:Float;
	private var progressBarMode:Bool;
	private var bossProgressBarStyle:NamespaceID;
	// #endregion

	// ===== LevelController_Tooltip.cs =====
	private function Awake_Tooltip():Void
	{
		pickaxeTooltipSource = new PickaxeTooltipSource(this);
		triggerTooltipSource = new TriggerTooltipSource(this);

		HideTooltip();
	}
	public function ShowTooltip(source:ITooltipSource):Void
	{
		Main.Scene.ShowTooltip(source);
	}
	public function HideTooltip():Void
	{
		Main.Scene.HideTooltip();
	}

	// #region 属性字段
	private var tooltipSource:ITooltipSource;
	private var pickaxeTooltipSource:ITooltipSource;
	private var triggerTooltipSource:ITooltipSource;
	// #endregion

	// ===== LevelController_Talk.cs =====
	private function Awake_Talk():Void
	{
		talkController.OnTalkAction.add(UI_OnTalkActionCallback);
	}
	private function InitLevelEngine_Talk(level:LevelEngine):Void
	{
		talkSystem = new LevelTalkSystem(level, talkController);
	}

	public function StartTalk(groupId:NamespaceID, section:Int, delay:Float = 0, onEnd:Void->Void = null):Void talkController.StartTalk(groupId, section, delay, onEnd);
	public function WillSkipTalk(groupId:NamespaceID, section:Int):Bool return talkController.WillSkipTalk(groupId, section);
	public function AutoSkipTalks(groupId:NamespaceID, section:Int, onSkip:Void->Void = null):Void talkController.AutoSkipTalks(groupId, section, onSkip);

	// #region 设置对话
	private function GetTalkIDOfType(type:String):NamespaceID
	{
		var talks = level.GetTalksOfType(type);
		if (talks == null)
			return null;

		for (startTalk in talks)
		{
			if (level.IsRerun && !startTalk.ShouldRepeat(Main.SaveManager))
				continue;
			if (!startTalk.CanStartTalk(Main.SaveManager) || !Main.ResourceManager.CanStartTalk(startTalk.Value, startTalk.StartSection))
				continue;
			return startTalk.Value;
		}
		return null;
	}
	private function StartLevelIntroDialog():Task
	{
		var talkID = GetTalkIDOfType(StageMetaTalk.TYPE_START);
		if (!Main.ResourceManager.CanStartTalk(talkID, 0))
			return Task.CompletedTask;

		// PORT-NOTE: C# 中为 `await talkController.SimpleStartTalkAsync(...)`。
		talkController.SimpleStartTalkAsync(talkID, 0, 2, function()
		{
			if (!level.NoStartTalkMusic())
			{
				Music.Play(LogicMusicID.mainmenu);
			}
		});
		return Task.CompletedTask;
	}
	private function StartLevelOutroDialog():Task
	{
		var talkID = GetTalkIDOfType(StageMetaTalk.TYPE_END);
		if (!Main.ResourceManager.CanStartTalk(talkID, 0))
			return Task.CompletedTask;

		var played = false;
		talkController.SimpleStartTalkAsync(talkID, 0, 5, function() played = true);
		lastOutroPlayed = played;
		return Task.CompletedTask;
	}
	// TODO-PORT: C# 的 async Task<bool> 结果无法通过 Task 返回，改用字段 lastOutroPlayed 传递。
	private var lastOutroPlayed:Bool;
	public function getLastOutroPlayed():Bool return lastOutroPlayed;
	private function SetMapDialog():Void
	{
		var talkID = GetTalkIDOfType(StageMetaTalk.TYPE_MAP);
		if (!NamespaceID.IsValid(talkID))
			return;
		Saves.SetMapTalk(talkID);
	}
	// #endregion

	// #region 事件回调
	private function UI_OnTalkActionCallback(cmd:String, parameters:Array<String>):Void
	{
		Global.Game.RunCallbackFiltered(LogicCallbacks.TALK_ACTION, new TalkActionParams(talkSystem, cmd, parameters), cmd);
	}
	// #endregion

	// #region 属性字段
	@:serializeField
	private var talkController:TalkController = null;
	private var talkSystem:ITalkSystem = null;
	// #endregion

	// ===== LevelController_Grids.cs =====
	private function InitGridControllers():Void
	{
		var maxColumn = level.GetMaxColumnCount();
		var gridWidth = level.GetGridWidth();
		var gridHeight = level.GetGridHeight();
		var initDatas:Array<Array<GridInitData>> = [];
		initDatas.resize(level.GetMaxLaneCount());
		var modelBuilder = new ModelBuilder(VanillaModelID.gridPlaceHolder, levelCamera.Camera);
		for (lane in 0...initDatas.length)
		{
			initDatas[lane] = [];
			initDatas[lane].resize(maxColumn);
			for (column in 0...maxColumn)
			{
				var lawnGrid = level.GetGrid(column, lane);
				if (lawnGrid == null)
					continue;
				var data = new GridInitData();
				data.levelController = this;
				data.grid = lawnGrid;
				data.modelBuilder = modelBuilder;
				initDatas[lane][column] = data;
			}
		}
		gridLayout.InitGridViews(initDatas);
	}
	private function CreateGridControllers():Void
	{
		InitGridControllers();
		// 设置Grid的模型接口。
		var gridWidth = level.GetGridWidth();
		var gridHeight = level.GetGridHeight();
		var areaMeta = Main.ResourceManager.GetAreaMeta(level.AreaID);
		var grids = gridLayout.GetGrids();
		if (grids == null)
			return;
		for (gridUI in grids)
		{
			var modelInterface = new GridModelInterface(gridUI);
			var column = gridUI.Column;
			var lane = gridUI.Lane;
			var grid = level.GetGrid(column, lane);
			if (grid == null)
				continue;
			grid.SetModelInterface(modelInterface);


			var x = level.GetColumnX(column) + gridWidth * 0.5;
			var z = level.GetLaneZ(lane) + gridHeight * 0.5;
			var gridIndex = level.GetGridIndex(column, lane);
			var gridMeta = (areaMeta != null && areaMeta.Grids != null) ? areaMeta.Grids[gridIndex] : null;
			var yOffset:Float = gridMeta != null ? gridMeta.YOffset : 0;
			var y:Float = 0 + yOffset;
			var pos = new Vector3(x, y, z);
			pos = pos * LawnToTransScale;
			var gridPos = new Vector3(pos.x, pos.z + pos.y, pos.z);


			var sprite:Sprite;
			var overlaySpriteRef = grid.GetOverlaySprite();
			if (SpriteReference.IsValid(overlaySpriteRef))
			{
				// PORT-NOTE: C# 的重载 Main.GetFinalSprite(SpriteReference) 在 Haxe 中改名为 GetFinalSpriteFromRef。
				sprite = Main.GetFinalSpriteFromRef(overlaySpriteRef);
			}
			else
			{
				// PORT-NOTE: 此处的重载接收的是 unity.Sprite（C# Main.GetFinalSprite(Sprite)），
				// Haxe 对应 GetFinalSpriteFromSprite。
				sprite = Main.GetFinalSpriteFromSprite(defaultGridSprite);
			}

			var slope = grid.GetSlope() * LawnToTransScale;

			var viewData = new GridControllerData();
			viewData.position = gridPos;
			viewData.sprite = sprite;
			viewData.slope = slope;

			gridUI.UpdateGridController(viewData);
			gridUI.UpdateFrame(0);
		}
	}
	private function Awake_Grids():Void
	{
		ClearGridHighlight();
		gridLayout.OnPointerInteraction.add(UI_OnGridPointerInteractionCallback);
	}

	// #region 事件回调
	private function UI_OnGridPointerInteractionCallback(lane:Int, column:Int, data:PointerEventData, interaction:PointerInteraction):Void
	{
		var gridUI = gridLayout.GetGrid(lane, column);
		if (gridUI != null && IsGameRunning())
		{
			var grid = level.GetGrid(column, lane);
			if (grid != null)
			{
				var worldPosition = data.pointerCurrentRaycast.worldPosition;
				var screenPosition = data.pointerCurrentRaycast.screenPosition;
				var pointerPosition = gridUI.TransformWorld2ColliderPosition(worldPosition);
				var pointerParams = InputHelper.GetPointerInteractionParamsFromEventData(data, interaction);
				var target = new HeldItemTargetGrid(grid, pointerPosition, screenPosition);
				level.DoHeldItemPointerEvent(target, pointerParams);
			}
		}


		if (interaction == PointerInteraction.Enter)
		{
			OnGridPointerEnterCallback(lane, column, data);
		}
		else if (interaction == PointerInteraction.Exit)
		{
			OnGridPointerExitCallback(lane, column, data);
		}
	}
	private function OnGridPointerEnterCallback(lane:Int, column:Int, data:PointerEventData):Void
	{
		SetPointingGrid(level.GetGridIndex(column, lane), data.pointerId);
	}
	private function OnGridPointerExitCallback(lane:Int, column:Int, data:PointerEventData):Void
	{
		ClearPointingGrid();
	}
	// #endregion

	// #region 序列化
	private function WriteToSerializable_Grids(seri:SerializableLevelController):Void
	{
		seri.grids = [for (g in gridLayout.GetGrids()) g.ToSerializable()];
	}
	private function ReadFromSerializable_Grids(seri:SerializableLevelController):Void
	{
		CreateGridControllers();
		if (seri.grids == null)
			return;
		var grids = gridLayout.GetGrids();
		if (grids == null)
			return;
		var count = Std.int(Mathf.Min(grids.length, seri.grids.length));
		for (i in 0...count)
		{
			var seriGrid = seri.grids[i];
			if (seriGrid == null)
				continue;
			grids[i].LoadFromSerializable(seriGrid);
		}
	}
	// #endregion

	private function SetPointingGrid(index:Int, pointerId:Int):Void
	{
		pointingGrid = index;
		pointingGridPointerId = pointerId;
		UpdateHeldHighlight();
	}
	private function ClearPointingGrid():Void
	{
		pointingGrid = -1;
		pointingGridPointerId = -1;
		UpdateHeldHighlight();
	}
	private function ClearGridHighlight():Void
	{
		var grids = gridLayout.GetGrids();
		if (grids == null)
			return;
		for (grid in grids)
		{
			grid.SetColor(Color.clear);
			grid.SetDisplaySection(0, 1);
		}
	}
	private function UpdateGridsFrame(deltaTime:Float, gameSpeed:Float):Void
	{
		var grids = gridLayout.GetGrids();
		if (grids == null)
			return;
		for (grid in grids)
		{
			grid.UpdateFrame(deltaTime);
		}
	}
	private function HighlightAxisGrids(lane:Int, column:Int):Void
	{
		for (l in 0...level.GetMaxLaneCount())
		{
			if (l != lane)
			{
				var g = gridLayout.GetGrid(l, column);
				if (g != null)
				{
					g.SetColor(gridColorTransparent);
					g.SetDisplaySection(0, 1);
				}
			}
		}
		for (c in 0...level.GetMaxColumnCount())
		{
			if (c != column)
			{
				var g = gridLayout.GetGrid(lane, c);
				if (g != null)
				{
					g.SetColor(gridColorTransparent);
					g.SetDisplaySection(0, 1);
				}
			}
		}
	}

	// #region 属性字段
	private var pointingGridPointerId:Int = -1;
	private var pointingGrid:Int = -1;

	@:header("Grids")
	@:serializeField
	private var gridColorTransparent:Color = new Color(1, 1, 1, 0.5);
	@:serializeField
	private var gridLayout:GridLayoutController = null;
	@:serializeField
	private var defaultGridSprite:Sprite = null;
	// #endregion

	// ===== LevelController_Serialization.cs 的私有字段 =====
	private var levelLoaded:Bool = false;

	// ===== LevelController_Entities.cs =====
	private function Awake_Entities():Void
	{
		entityControllerPool = new ObjectPool<EntityController>(CreateEntityControllerFunc, GetEntityControllerFunc, ReleaseEntityControllerFunc, DestroyEntityControllerFunc);
	}
	private function AddLevelCallbacks_Entities(level:LevelEngine):Void
	{
		level.OnEntitySpawn.add(OnEngineEntitySpawnCallback);
		level.OnEntityRemove.add(OnEngineEntityRemoveCallback);
	}
	private function ReadFromSerializable_Entities(seri:SerializableLevelController):Void
	{
		for (entity in level.GetEntities())
		{
			var controller = CreateControllerForEntity(entity);

			var seriEntity:SerializableEntityController = null;
			if (seri.entities != null)
			{
				for (e in seri.entities)
				{
					if (e != null && e.id == entity.ID)
					{
						seriEntity = e;
						break;
					}
				}
			}
			if (seriEntity == null)
				throw 'Could not find entity data with id ${entity.ID} in the level state data.';
			controller.LoadFromSerializable(seriEntity);
			controller.UpdateAnimators(0);
			controller.UpdateFrame(0);
		}
	}

	// #region 事件回调
	private function OnEngineEntitySpawnCallback(entity:Entity):Void
	{
		CreateControllerForEntity(entity);
	}
	private function OnEngineEntityRemoveCallback(entity:Entity):Void
	{
		RemoveControllerFromEntity(entity);
	}
	private function UI_OnEntityPointerInteractionCallback(entityCtrl:EntityController, eventData:PointerEventData, interaction:PointerInteraction):Void
	{
		if (IsGameRunning())
		{
			// 触发手持物品指针事件。
			var target = entityCtrl.GetHeldItemTarget(eventData);
			var pointerParams = InputHelper.GetPointerInteractionParamsFromEventData(eventData, interaction);
			level.DoHeldItemPointerEvent(target, pointerParams);
		}

		if (interaction == PointerInteraction.Enter) // 指针进入
		{
			OnEntityPointerEnter(entityCtrl);
		}
		else if (interaction == PointerInteraction.Exit) // 指针退出
		{
			OnEntityPointerExit(entityCtrl);
		}
		else if (interaction == PointerInteraction.Down) // 指针按下
		{
			OnEntityPointerDown(entityCtrl, eventData);
		}
	}
	private function OnEntityPointerEnter(entityCtrl:EntityController):Void
	{
		SetHoveredEntity(entityCtrl);
		// 显示查看图鉴提示
		if (!IsGameStarted() && entityCtrl.Entity.IsPreviewEnemy() && ChooseBlueprintsInteractable())
		{
			ShowTooltip(new EntityTooltipSource(this, entityCtrl));
		}
	}
	private function OnEntityPointerExit(entityCtrl:EntityController):Void
	{
		SetHoveredEntity(null);
		// 隐藏查看图鉴提示
		if (entityCtrl.Entity.IsPreviewEnemy())
		{
			HideTooltip();
		}
	}
	private function OnEntityPointerDown(entityCtrl:EntityController, eventData:PointerEventData):Void
	{
		if (IsGameStarted())
			return;
		var pointer = InputHelper.GetPointerDataFromEventData(eventData);
		var entity = entityCtrl.Entity;
		if (pointer.type == PointerTypes.MOUSE && pointer.button != MouseButtons.LEFT)
			return;
		if (!entity.IsPreviewEnemy() || !Main.SaveManager.IsAlmanacUnlocked() || !ChooseBlueprintsInteractable())
			return;
		var entityID = entityCtrl.Entity.GetDefinitionID();
		if (!Main.ResourceManager.IsEnemyInAlmanac(entityID) || !Main.SaveManager.IsEnemyUnlocked(entityID))
			return;
		HideTooltip();
		OpenEnemyAlmanac(entity.GetDefinitionID());
		Main.SoundManager.Play2D(LogicSoundID.tap);
	}
	// #endregion

	// #region 控制器
	private function CreateControllerForEntity(entity:Entity):EntityController
	{
		var entityController = GetEntityControllerFromPool();
		entityController.Init(this, entity);
		entityController.OnPointerInteraction.add(UI_OnEntityPointerInteractionCallback);
		entities.push(entityController);
		return entityController;
	}
	private function RemoveControllerFromEntity(entity:Entity):Bool
	{
		var entityController = GetEntityController(entity);
		if (entityController != null)
		{
			entityController.OnPointerInteraction.remove(UI_OnEntityPointerInteractionCallback);
			entityController.RemoveEntity();
			ReleaseEntityControllerFromPool(entityController);
			return entities.remove(entityController);
		}
		return false;
	}
	public function GetEntityController(entity:Entity):EntityController
	{
		for (e in entities)
		{
			if (e.Entity == entity)
				return e;
		}
		return null;
	}
	private function CreateEntityControllerFunc():EntityController
	{
		// PORT-NOTE: C# `Instantiate(entityTemplate.gameObject, entitiesRoot)`；Haxe 侧由
		// unity.UnityObject.Instantiate 对 Component 模板新建 GameObject + AddComponent 并挂到 parent。
		return UnityObject.Instantiate(entityTemplate, null, null, entitiesRoot);
	}
	private function GetEntityControllerFunc(controller:EntityController):Void
	{
		controller.gameObject.SetActive(true);
	}
	private function ReleaseEntityControllerFunc(controller:EntityController):Void
	{
		controller.gameObject.SetActive(false);
	}
	private function DestroyEntityControllerFunc(controller:EntityController):Void
	{
		UnityObject.destroy(controller.gameObject);
	}
	private function GetEntityControllerFromPool():EntityController
	{
		return entityControllerPool.Get();
	}
	private function ReleaseEntityControllerFromPool(entity:EntityController):Void
	{
		entityControllerPool.Release(entity);
	}
	// #endregion

	// #region 高亮
	private function SetHoveredEntity(entity:EntityController):Void
	{
		hoveredEntity = entity;
		UpdateHeldHighlight();
	}
	private function SetHighlightedEntity(entity:EntityController):Void
	{
		if (highlightedEntity != null)
		{
			highlightedEntity.SetHighlight(false);
		}
		highlightedEntity = entity;
		if (highlightedEntity != null)
		{
			highlightedEntity.SetHighlight(true);
		}
	}
	// #endregion

	// #region 动画
	private function UpdateEntityAnimators(toUpdate:Array<AnimatorUpdateData>, deltaTime:Float, gameSpeed:Float, maxBatchPercentage:Float):Void
	{
		var count = toUpdate.length;
		if (count <= 0)
			return;
		var maxCount = Mathf.CeilToInt(maxBatchPercentage * count);
		var updateCount = Std.int(Mathf.Min(count, maxCount));
		var updateSpeed = count / updateCount;

		var startIndex = currentEntityAnimatorIndex;
		for (i in 0...updateCount)
		{
			var index = (i + startIndex) % count;
			var data = toUpdate[index];
			var animator = data.animator;
			var speed = data.speed;
			animator.enabled = false;
			animator.Update(deltaTime * gameSpeed * updateSpeed * speed);
		}
		currentEntityAnimatorIndex = (updateCount + startIndex) % count;
	}
	// #endregion

	// #region 属性字段
	public static inline var SelfFaction:Int = 0;
	public static inline var EnemyFaction:Int = 1;

	@:translateMsg("实体提示", LogicStrings.CONTEXT_ENTITY_TOOLTIP)
	public static inline var VIEW_IN_ALMANAC:String = "在图鉴中查看";

	private var entityControllerPool:ObjectPool<EntityController> = null;
	private var entities:Array<EntityController> = [];
	private var hoveredEntity:EntityController;
	private var highlightedEntity:EntityController;
	private var entityAnimatorBuffer:Array<AnimatorUpdateData> = [];
	private var currentEntityAnimatorIndex:Int = 0;

	@:header("Entities")
	@:serializeField
	private var entityTemplate:EntityController = null;
	@:serializeField
	private var entitiesRoot:Transform = null;
	// #endregion

	// ===== LevelController_Gameflow.cs =====
	// #region 初始化
	public function InitLevel(game:GlobalGame, areaID:NamespaceID, stageID:NamespaceID, seed:Int = 0):Void
	{
		SetActive(true);
		rng = new RandomGenerator(Std.random(0x7FFFFFFF));

		var collisionSystem = GetCollisionSystem();
		level = new LevelEngine(game, game, collisionSystem);
		InitLevelEngine(level, game, areaID, stageID);

		var option = new LevelOption();
		option.CardSlotCount = 10;
		option.StarshardSlotCount = 10;
		option.LeftFaction = SelfFaction;
		option.RightFaction = EnemyFaction;
		option.MaxEnergy = 9990;
		option.TPS = 30;
		level.Init(areaID, stageID, option, seed);

		level.SetArtifactRNG(level.CreateRNG());
		CreateGridControllers();

		level.Setup();

		RefreshUIAtLevelInit();
		UpdateToolUIUnlockedActive();
		// 光照
		UpdateLighting();
	}
	// TODO-PORT: C# 重载 InitLevelEngine(LevelEngine, GlobalGame, NamespaceID, NamespaceID)。
	private function InitLevelEngine(level:LevelEngine, game:GlobalGame, areaID:NamespaceID, stageID:NamespaceID):Void
	{
		ApplyComponents(level);
		AddLevelCallbacks(level);

		InitLevelEngine_UI(level);
		InitLevelEngine_Model(level, areaID, stageID);
		InitLevelEngine_Talk(level);

		level.IsRerun = Saves.IsLevelCleared(stageID);
		isHPBarUnlocked = Main.LevelManager.GetHPBarUnlocked();
	}
	private function ApplyComponents(level:LevelEngine):Void
	{
		level.AddComponent(new AdviceComponent(level, this));
		level.AddComponent(new HeldItemComponent(level, this));
		level.AddComponent(new AreaComponent(level, this));
		level.AddComponent(new UIComponent(level, this));
		level.AddComponent(new LogicComponent(level, this));
		level.AddComponent(new SoundComponent(level, this));
		level.AddComponent(new TalkComponent(level, this));
		level.AddComponent(new MusicComponent(level, this));
		level.AddComponent(new MoneyComponent(level, this));
		level.AddComponent(new LightComponent(level, this));
		level.AddComponent(new ArtifactComponent(level, this));
		level.AddComponent(new BlueprintComponent(level, this));
	}
	private function AddLevelCallbacks(level:LevelEngine):Void
	{
		AddLevelCallbacks_Entities(level);
		AddLevelCallbacks_GameFlow(level);
		AddLevelCallbacks_Sponsors(level);
		level.OnPropertyChanged.add(OnLevelPropertyChangedCallback);

		for (controller in parts)
		{
			controller.AddEngineCallbacks(level);
		}
	}
	private function AddLevelCallbacks_GameFlow(level:LevelEngine):Void
	{
		level.OnGameOver.add(OnEngineGameOverCallback);
		level.OnClear.add(OnEngineClearCallback);
		level.AddTrigger(LevelCallbacks.POST_WAVE_FINISHED, PostWaveFinishedCallback);
		level.AddTrigger(LogicLevelCallbacks.POST_HUGE_WAVE_APPROACH, PostHugeWaveApproachCallback);
		level.AddTrigger(LogicLevelCallbacks.POST_FINAL_WAVE, PostFinalWaveCallback);
	}
	public function SetStartStage(area:NamespaceID, stage:NamespaceID):Void
	{
		startAreaID = area;
		startStageID = stage;
	}
	public function GetStartAreaID():NamespaceID
	{
		return startAreaID;
	}
	public function GetStartStageID():NamespaceID
	{
		return startStageID;
	}
	// #endregion

	// #region 开始
	public function StartLevelIntro(delay:Float):Void
	{
		StartLevelIntroAsync(delay);
	}
	private function StartLevelIntroAsync(delay:Float):Task
	{
		// PORT-NOTE: C# 的 `await Main.CoroutineManager.DelaySeconds(delay)` 在 Haxe 中同步执行。
		if (delay > 0)
		{
			Main.CoroutineManager.DelaySeconds(delay);
		}
		SetCameraPosition(level.StageDefinition.GetStartCameraPosition());
		StartLevelIntroDialog();
		level.BeginLevel();
		return Task.CompletedTask;
	}
	public function StartLevelIntroTransition():Void
	{
		var transition = level.StageDefinition.GetStartTransition();
		if (transition == null)
			transition = LevelTransitions.DEFAULT;
		if (transition == LevelTransitions.INSTANT)
		{
			GameStartInstantTransition();
		}
		else if (transition == LevelTransitions.TO_LAWN)
		{
			StartCoroutine(GameStartToLawnInstantTransition());
		}
		else
		{
			StartCoroutine(GameStartTransition());
		}
	}
	public function StartGame():Void
	{
		if (isGameStarted)
			return;
		level.ResetHeldItem();
		level.RemovePreviewEnemies();
		var starshardSlots = Saves.GetStarshardSlots();
		level.SetStarshardSlotCount(starshardSlots);

		// 设置蓝图。
		BlueprintChoosePart.ApplyChoose();
		// 设置难度
		UpdateDifficulty();

		StartGame_Audio();
		StartGame_ProgressBar();
		StartGame_Tools();
		StartGame_Blueprints();
		StartGame_UI();

		for (part in parts)
		{
			part.PostLevelStart();
		}

		level.Start();
		SetGameStarted(true);
		// TODO-PORT: unity.Application.isFocused 在 unity shim 中缺失。此处是 StartGame() 调用点，
		// 游戏窗口刚获得焦点，故按 C# 语义传 true；待 shim 补齐 Application.isFocused 后改回。
		UpdateFocusLost(true);
	}
	private function SetGameStarted(value:Bool):Void
	{
		isGameStarted = value;
	}
	public function IsGameStarted():Bool
	{
		return isGameStarted;
	}
	// #endregion

	// #region 重新开始
	public function RestartLevel():Task
	{
		RemoveLevelState();
		return ReloadLevel();
	}
	public function ReloadLevel():Task
	{
		Saves.SaveToFile(); // 关卡重载时保存游戏
		Dispose();
		LevelManager.GotoLevelSceneAsync();
		LevelManager.InitLevel(startAreaID, startStageID, 0, exitTarget);
		return Task.CompletedTask;
	}
	public function RemoveLevelState():Void
	{
		LevelManager.RemoveLevelState(startStageID);
	}
	// #endregion

	// #region 游戏结束
	public function GameOverByEntity(killer:Entity):Void
	{
		if (killer != null)
		{
			killerID = killer.GetDefinitionID();
			killerEntity = GetEntityController(killer);
		}
		SetGameOver();
		StartCoroutine(GameOverByEnemyTransition());
	}
	// TODO-PORT: C# 重载 GameOver(Entity?) 与 GameOver(string?) 在 Haxe 中无法共存，重命名以区分。
	public function GameOver(deathMessage:String):Void
	{
		this.deathMessage = deathMessage;
		SetGameOver();
		StartCoroutine(GameOverNoEnemyTransition());
	}
	public function GameOverInstantly(deathMessage:String):Void
	{
		this.deathMessage = deathMessage;
		SetGameOver();
		Music.Stop();
		ShowGameOverDialog();
	}
	private function SetGameOver():Void
	{
		isGameOver = true;
		level.PlaySound(LogicSoundID.loseMusic);
		level.HideAdvice();

		var areaModel = GetAreaModel();
		if (areaModel != null)
		{
			areaModel.SetProperty("GameOver", true);
		}

		ClearPointingGrid();
		SetUIVisibleState(VisibleState.Nothing);

		RemoveLevelState();
	}
	// TODO-PORT: C# 已有属性 isGameOver 与同名方法 IsGameOver()，需要区分命名冲突。
	public function IsGameOver():Bool
	{
		return isGameOver;
	}
	// #endregion

	// #region 中止关卡
	public function StopLevel():Void
	{
		level.ResetHeldItem();
		level.ClearEnergyDelayedEntities();
		level.ClearDelayedMoney();

		ClearPointingGrid();
		SetUIVisibleState(VisibleState.Nothing);

		SetGameStarted(false);
		Saves.SaveToFile(); // 关卡停止时保存游戏

		level.Triggers.RunCallback(LogicLevelCallbacks.POST_LEVEL_STOP, new LevelCallbackParams(level));
	}
	// #endregion

	// #region 退出关卡
	public function SetExitTarget(target:LevelExitTarget):Void
	{
		exitTarget = target;
	}
	public function ExitLevelToNote(id:NamespaceID):Task
	{
		Sounds.Play2D(LogicSoundID.paper);

		var buttonText = Localization._(LogicStrings.CONTINUE);
		Scene.DisplayNote(id, buttonText);

		ExitScene();
		return Task.CompletedTask;
	}
	public function ExitLevel():Task
	{
		// PORT-NOTE: C# 中该方法是 `async Task`，switch 后 `await ExitScene()`。
		switch (exitTarget)
		{
			case LevelExitTarget.Minigame:
				Scene.DisplayArcade(function() Scene.DisplayMainmenu());
				Scene.DisplayArcadeMinigames();
			case LevelExitTarget.Puzzle:
				Scene.DisplayArcade(function() Scene.DisplayMainmenu());
				Scene.DisplayArcadePuzzles();
			default:
				Scene.GotoMapOrMainmenu();
		}
		ExitScene();
		return Task.CompletedTask;
	}
	private function ExitScene():Task
	{
		SetActive(false);
		Saves.SaveToFile(); // 退出关卡时保存游戏
		Dispose();
		LevelManager.ExitLevelSceneAsync();
		Main.GraphicsManager.ResetLighting();
		return Task.CompletedTask;
	}
	// #endregion

	// #region 事件回调
	private function OnEngineGameOverCallback(type:Int, killer:Entity, message:String):Void
	{
		switch (type)
		{
			case GameOverTypes.ENEMY:
				GameOverByEntity(killer);
			case GameOverTypes.NO_ENEMY:
				GameOver(message);
			case GameOverTypes.INSTANT:
				GameOverInstantly(message);
			default:
		}
	}
	private function OnLevelPropertyChangedCallback(name:IPropertyKey, beforeValue:Dynamic, afterValue:Dynamic, triggersEvaluation:Bool):Void
	{
		if (LogicAreaProps.STARSHARD_ICON == name)
		{
			SetStarshardIcon();
		}
	}
	private function OnEngineClearCallback():Void
	{
		RemoveLevelState();
		Saves.Unlock(LogicUnlockID.GetLevelClearUnlock(level.StageID));
		Saves.AddLevelDifficultyRecord(level.StageID, level.Difficulty);

		SetMapDialog();
		Saves.SaveToFile(); // 关卡通关后时保存游戏

		StartLevelOutroDialog();
		var played = getLastOutroPlayed();
		var transitionDelay:Float = played ? 0 : 3;
		StartExitLevelTransition(transitionDelay);
	}
	private function OnUIExitLevelToNoteCalledCallback():Void
	{
		if (exitTargetNoteID == null)
		{
			ExitLevel();
		}
		else
		{
			ExitLevelToNote(exitTargetNoteID);
		}
	}
	private function PostWaveFinishedCallback(param:PostWaveParams, result:CallbackResult):Void
	{
		UpdateLevelName();
	}
	private function PostHugeWaveApproachCallback(param:LevelCallbackParams, result:CallbackResult):Void
	{
		var ui = GetUIPreset();
		ui.ShowHugeWaveText();
	}
	private function PostFinalWaveCallback(param:LevelCallbackParams, result:CallbackResult):Void
	{
		var ui = GetUIPreset();
		ui.ShowFinalWaveText();
	}
	// #endregion

	// #region 属性字段
	private var isGameStarted:Bool;
	private var isGameOver:Bool;
	private var killerID:NamespaceID;
	private var killerEntity:EntityController;
	private var deathMessage:String;
	private var exitTargetNoteID:NamespaceID;
	private var exitTarget:LevelExitTarget;
	private var startAreaID:NamespaceID = null;
	private var startStageID:NamespaceID = null;
	// #endregion

	// PORT-NOTE: 以下是供同模块的 Tooltip 源类访问私有属性的访问器。
	// （C# 中嵌套类可直接访问外部类私有成员，Haxe 模块级类不行）。
	// ===== LevelController_UI.cs =====
	private function Awake_UI():Void
	{
		ui.OnExitLevelToNoteCalled.add(OnUIExitLevelToNoteCalledCallback);
		ui.OnStartGameCalled.add(StartGame);
		ui.SetMobile(Main.UseMobileLayout());

		var uiPreset = GetUIPreset();
		uiPreset.OnRaycastReceiverPointerInteraction.add(UI_OnRaycastReceiverPointerInteractionCallback);
		uiPreset.OnMenuButtonClick.add(UI_OnMenuButtonClickCallback);
		uiPreset.OnSpeedUpButtonClick.add(UI_OnSpeedUpButtonClickCallback);

		uiPreset.HideMoney();
		SetUIVisibleState(VisibleState.Nothing);
	}
	private function InitLevelEngine_UI(level:LevelEngine):Void
	{
		levelRaycaster.Init(level);
	}
	private function StartGame_UI():Void
	{
		// 设置UI可见状态
		SetUIVisibleState(VisibleState.InLevel);
		RefreshUIAtLevelStart();

		var uiPreset = GetUIPreset();
		uiPreset.SetReceiveRaycasts(true);
		uiPreset.UpdateFrame(0);
	}
	private function WriteToSerializable_UI(seri:SerializableLevelController):Void
	{
		seri.uiPreset = GetUIPreset().ToSerializable();
	}
	private function ReadFromSerializable_UI(seri:SerializableLevelController):Void
	{
		// uiPreset的animator.Update会导致第一次加载该场景时，蓝图UI的子模型显示状态不正确，所以放在前面
		var uiPreset = GetUIPreset();
		if (seri.uiPreset != null)
			uiPreset.LoadFromSerializable(seri.uiPreset);
		uiPreset.UpdateFrame(0);
	}
	// PORT-NOTE: C# 的 GetUI() 定义在 LevelController_UI.cs 中（骨架里已移除重复定义）。
	public function GetUIPreset():LevelUIPreset
	{
		return ui.GetUIPreset();
	}
	private function RefreshUIAtLevelInit():Void
	{
		var uiPreset = GetUIPreset();
		uiPreset.UpdateFrame(0);
		SetStarshardIcon();
		UpdateHotkeyTexts();
	}
	private function RefreshUIAtLevelStart():Void
	{
		// 关卡名
		UpdateLevelName();
		// 能量、关卡进度条、手持物品、蓝图状态、星之碎片
		UpdateInLevelUI(0);
		// 金钱
		UpdateMoney();
		// 难度名称
		UpdateDifficultyName();
		// 关卡进度条
		RefreshProgressBar();
	}

	// #region 金钱
	public function ShowMoney():Void
	{
		var levelUI = GetUIPreset();
		levelUI.ResetMoneyFadeTime();
	}
	public function SetMoneyFade(fade:Bool):Void
	{
		var levelUI = GetUIPreset();
		levelUI.SetMoneyFade(fade);
	}
	private function UpdateMoney():Void
	{
		var ui = GetUIPreset();
		ui.SetMoney(formatNumber(level.GetMoney() - level.GetDelayedMoney()));
	}
	// PORT-NOTE: C# 的 `ToString("N0")` 在 Haxe 中用千分位格式化等价实现。
	private static function formatNumber(value:Int):String
	{
		var str = Std.string(value);
		var neg = str.charAt(0) == "-";
		if (neg)
			str = str.substr(1);
		var out = "";
		var count = 0;
		var i = str.length - 1;
		while (i >= 0)
		{
			out = str.charAt(i) + out;
			count++;
			if (count % 3 == 0 && i > 0)
				out = "," + out;
			i--;
		}
		return (neg ? "-" : "") + out;
	}
	// #endregion

	// #region 关卡名
	public function UpdateLevelName():Void
	{
		var levelUI = GetUIPreset();
		levelUI.SetLevelName(LevelManager.GetStageNameFromLevel(level));
	}
	// #endregion

	// #region 难度
	private function UpdateDifficultyName():Void
	{
		var difficultyName = Game.GetDifficultyName(level.Difficulty);
		var levelUI = GetUIPreset();
		levelUI.SetDifficulty(difficultyName);
	}
	// #endregion

	// #region 提示红字
	private function PlayReadySetBuild():Void
	{
		var ui = GetUIPreset();
		ui.ShowReadySetBuild();
		level.PlaySound(LogicSoundID.readySetBuild);
	}
	// #endregion

	// #region 能量
	public function FlickerEnergy():Void
	{
		var levelUI = GetUIPreset();
		levelUI.FlickerEnergy();
	}
	private function UpdateEnergy():Void
	{
		var ui = GetUIPreset();
		ui.SetEnergy(Std.string(Mathf.FloorToInt(Mathf.Max(0, level.Energy - level.GetDelayedEnergy()))));
	}
	// #endregion

	// #region UI可见度
	private function SetUIVisibleState(state:VisibleState):Void
	{
		var levelUI = GetUIPreset();
		levelUI.SetUIVisibleState(state);
	}
	// #endregion

	// #region 热键
	public function UpdateHotkeyTexts():Void
	{
		var preset = ui.GetUIPreset();
		preset.SetPickaxeHotkeyText(GetHotkeyName(HotKeys.pickaxe));
		preset.SetStarshardHotkeyText(GetHotkeyName(HotKeys.starshard));
		preset.SetTriggerHotkeyText(GetHotkeyName(HotKeys.trigger));
		preset.SetSpeedUpHotkeyText(GetHotkeyName(HotKeys.fastForward));
		blueprintController.ForceUpdateBlueprintHotkeyTexts();
	}
	private function GetHotkeyName(keyID:NamespaceID):String
	{
		if (Global.Game.IsMobile() || !Main.OptionsManager.ShowHotkeyIndicators())
			return "";
		var keycode = Main.OptionsManager.GetKeyBinding(keyID);
		return keycode != KeyCode.None ? Main.InputManager.GetKeyCodeName(keycode) : "";
	}
	// #endregion

	public function SetUIAndInputDisabled(disabled:Bool):Void
	{
		inputAndUIDisabled = disabled;
		ui.SetUIDisabled(disabled);
	}
	/// <summary>
	/// 更新能量、关卡进度条、手持物品、蓝图状态、星之碎片。
	/// </summary>
	private function UpdateInLevelUI(deltaTime:Float):Void
	{
		var ui = GetUIPreset();
		UpdateEnergy();
		UpdateLevelProgressUI();
		UpdateHeldSlotUI();
		UpdateStarshards();
	}

	// #region 事件回调
	private function UI_OnRaycastReceiverPointerInteractionCallback(area:LawnArea, eventData:PointerEventData, interaction:PointerInteraction):Void
	{
		if (!IsGameRunning())
			return;
		var target = new HeldItemTargetLawn(level, area);
		var pointerParams = InputHelper.GetPointerInteractionParamsFromEventData(eventData, interaction);
		level.DoHeldItemPointerEvent(target, pointerParams);

		switch (interaction)
		{
			case PointerInteraction.Enter:
				OnRaycastReceiverPointerEnter(area, eventData);
			case PointerInteraction.Exit:
				OnRaycastReceiverPointerExit(area, eventData);
			default:
		}
	}
	private function OnRaycastReceiverPointerEnter(area:LawnArea, eventData:PointerEventData):Void
	{
		isPointingLawnArea = true;
		pointingLawnArea = area;
		pointingLawnPointerId = eventData.pointerId;
		UpdateHeldHighlight();
	}
	private function OnRaycastReceiverPointerExit(area:LawnArea, eventData:PointerEventData):Void
	{
		isPointingLawnArea = false;
		pointingLawnPointerId = -1;
		UpdateHeldHighlight();
	}
	private function UI_OnMenuButtonClickCallback():Void
	{
		if (IsGameRunning())
		{
			if (!IsPauseDisabled())
			{
				PauseGame();
				level.PlaySound(LogicSoundID.pause);
				ShowOptionsDialog();
			}
		}
		else
		{
			ShowOptionsDialog();
		}
	}
	private function UI_OnOptionsMenuCloseCallback(needsReload:Bool):Void
	{
		if (!IsGameStarted())
		{
			ui.SetOptionsDialogActive(false);
		}
		else
		{
			ResumeGameDelayed(100);
		}
	}
	private function UI_OnSpeedUpButtonClickCallback():Void
	{
		SwitchSpeedUp();
	}
	private function UI_OnBlueprintPointerInteractionCallback(index:Int, eventData:PointerEventData, interaction:PointerInteraction, conveyor:Bool):Void
	{
		if (!IsGameRunning())
			return;
		var target = new HeldItemTargetBlueprint(level, index, conveyor);
		var pointerParams = InputHelper.GetPointerInteractionParamsFromEventData(eventData, interaction);
		level.DoHeldItemPointerEvent(target, pointerParams);

		switch (interaction)
		{
			case PointerInteraction.Enter:
				OnBlueprintPointerEnter(index, eventData, conveyor);
			case PointerInteraction.Exit:
				OnBlueprintPointerExit(index, eventData, conveyor);
			default:
		}
	}
	private function OnBlueprintPointerEnter(index:Int, eventData:PointerEventData, conveyor:Bool):Void
	{
		pointingBlueprint = index;
		pointingBlueprintPointerId = eventData.pointerId;
		pointingBlueprintConveyor = conveyor;
		UpdateHeldHighlight();
	}
	private function OnBlueprintPointerExit(index:Int, eventData:PointerEventData, conveyor:Bool):Void
	{
		pointingBlueprint = -1;
		pointingBlueprintPointerId = -1;
		pointingBlueprintConveyor = conveyor;
		UpdateHeldHighlight();
	}
	// #endregion

	// #region 属性字段
	private var inputAndUIDisabled:Bool;
	private var isPointingLawnArea:Bool;
	private var pointingLawnArea:LawnArea;
	private var pointingLawnPointerId:Int;
	private var pointingBlueprint:Int;
	private var pointingBlueprintPointerId:Int;
	private var pointingBlueprintConveyor:Bool;

	@:header("UI")
	@:serializeField
	private var ui:LevelUI = null;
	// #endregion

	// ===== LevelController_Update.cs =====
	public function IsGameRunning():Bool
	{
		return isGameStarted && !isPaused && !isGameOver && !IsConsoleActive();
	}
	public function GetGameSpeed():Float
	{
		if (IsConsoleActive())
			return 0;
		if (advancedPause)
			return 0;
		return speedUp && !isGameOver ? Main.OptionsManager.GetFastForwardMultiplier() : 1;
	}
	private function IsConsoleActive():Bool
	{
		return Main.DebugManager.IsConsoleActive();
	}
	private function SwitchSpeedUp():Void
	{
		speedUp = !speedUp;
		GetUIPreset().SetSpeedUp(speedUp);
		level.PlaySound(speedUp ? LogicSoundID.fastForward : LogicSoundID.slowDown);
	}
	private function SwitchAdvancedPause():Void
	{
		advancedPause = !advancedPause;
		level.PlaySound(advancedPause ? LogicSoundID.pause : LogicSoundID.click);
	}

	// #region 逻辑更新
	public function UpdateLogic():Void
	{
		if (IsConsoleActive())
			return;
		if (isGameOver)
		{
			UpdateLogicGameOver();
		}
		else if (!IsGameRunning())
		{
			UpdateLogicNotRunning();
		}
		else
		{
			UpdateLogicRunning();
		}
	}
	private function UpdateLogicGameOver():Void
	{
		var killerCtrl = killerEntity;
		if (killerCtrl != null)
		{
			var killerEnt = killerCtrl.Entity;
			var pos = killerEnt.Position;
			pos.x -= 1;
			pos.z = pos.z * 0.5 + level.GetDoorZ() * 0.5;
			pos.y = pos.y * 0.5 + level.GetGroundY(pos.x, pos.z) * 0.5;
			killerEnt.Position = pos;
			killerCtrl.UpdateFixed();

			var passenger = killerEnt.GetRideablePassenger();
			if (passenger != null)
			{
				passenger.Position = pos + killerEnt.GetPassengerOffset();
				var passengerCtrl = GetEntityController(passenger);
				if (passengerCtrl != null)
				{
					passengerCtrl.UpdateFixed();
				}
			}
		}
		for (entity in entities.copy())
		{
			if (CanUpdateAfterGameOver(entity.Entity))
			{
				entity.Entity.Update();
				entity.UpdateFixed();
			}
		}
	}
	private function UpdateLogicNotRunning():Void
	{
		for (entity in entities.copy())
		{
			var canRunBeforeGameStart = IsGameStarted() || CanUpdateBeforeGameStart(entity.Entity);
			var canRunInPause = !IsGamePaused() || CanUpdateInPause(entity.Entity);
			if (canRunBeforeGameStart && canRunInPause)
			{
				entity.Entity.Update();
				entity.UpdateFixed();
			}
		}
	}
	private function UpdateLogicRunning():Void
	{
		var gameSpeed = GetGameSpeed();
		var times = Std.int(gameSpeed);
		gameRunTimeModular += gameSpeed - times;
		if (gameRunTimeModular > 1)
		{
			times += Std.int(gameRunTimeModular);
			gameRunTimeModular %= 1;
		}

		for (time in 0...times)
		{
			// 用于中断循环。防止Update后游戏结束，然后以下代码连续执行两次。
			if (!IsGameRunning())
				break;
			UpdateLogicOnce();
		}
	}
	private function UpdateLogicOnce():Void
	{
		var entitiesCache = entities.copy();
		level.Update();
		for (entity in entitiesCache)
		{
			entity.UpdateFixed();
		}

		var grids = gridLayout.GetGrids();
		if (grids != null)
		{
			for (grid in grids)
			{
				grid.UpdateFixed();
			}
		}

		for (part in parts)
		{
			part.UpdateLogic();
		}
		ui.UpdateHeldItemModelFixed();
		UpdateEnemyCry();
	}
	// #endregion

	// #region 画面更新
	public function UpdateFrame(deltaTime:Float):Void
	{
		var gameSpeed = GetGameSpeed();

		// 更新实体动画。
		UpdateFrameAnimators(deltaTime, gameSpeed);

		// 更新光标。
		UpdateHeldItemCursorEnabled();

		// 更新UI。
		UpdateFrameUI(deltaTime, gameSpeed);

		// 更新血条。
		UpdateHPBars(deltaTime);

		// 更新网格。
		UpdateGridsFrame(deltaTime, gameSpeed);
		UpdateHeldHighlight();

		// 更新输入。
		UpdateInput();

		// 更新相机。
		levelCamera.ShakeOffset = toVector3(Shakes.GetShake2D());
		UpdateCamera();

		// 设置光照。
		UpdateFrameLighting(deltaTime, gameSpeed);

		// 更新场景。
		UpdateFrameModel(deltaTime, gameSpeed);

		// 更新关卡。
		UpdateFrameLevelEngine(deltaTime, gameSpeed);
	}
	private function UpdateFrameAnimators(deltaTime:Float, gameSpeed:Float):Void
	{
		var perf = Main.PerformanceManager;
		if (IsGameRunning())
		{
			perf.UpdatePerformanceMonitor();
		}
		var maxBatchPercentage = Main.OptionsManager.GetAnimationFrequency();

		entityAnimatorBuffer = [];
		for (entity in entities)
		{
			var modelActive = false;
			var updateAnimatorParams = false;
			var ent = entity.Entity;
			if (isGameOver)
			{
				// 如果游戏结束，则只有在实体是杀死玩家的实体，或者在游戏结束后能行动时，才会动起来。
				var killerCtrl = killerEntity;
				// PORT-NOTE: 显式标注为 Entity，避免推断出 Null<Null<Entity>> 后扩展方法无法解析。
				var killerEnt:Entity = killerCtrl != null ? killerCtrl.Entity : null;
				modelActive = CanUpdateAfterGameOver(ent) || ent == killerEnt || (killerEnt != null && ent == killerEnt.GetRideablePassenger());
				updateAnimatorParams = modelActive;
			}
			else if (!IsGameStarted())
			{
				// 游戏没有开始，则只有在实体可以在游戏开始前行动，或者实体是预览敌人时，才会动起来。
				modelActive = CanUpdateBeforeGameStart(ent) || ent.IsPreviewEnemy();
				updateAnimatorParams = modelActive;
			}
			else
			{
				// 游戏已开始并且没有结束，则只有在游戏没有暂停，或者可以在暂停中更新时，才会动起来。
				modelActive = CanUpdateInPause(ent) || !IsGamePaused();
			}
			var speed = modelActive ? gameSpeed : 0;
			entity.SetSimulationSpeed(speed);
			entity.UpdateFrame(deltaTime * speed);
			if (updateAnimatorParams)
			{
				entity.Entity.UpdateAnimationParameters(entity.Entity.State);
			}

			if (modelActive)
			{
				entity.GetAnimatorsToUpdate(entityAnimatorBuffer);
			}
		}
		UpdateEntityAnimators(entityAnimatorBuffer, deltaTime, gameSpeed, maxBatchPercentage);
	}
	private function UpdateFrameUI(deltaTime:Float, gameSpeed:Float):Void
	{
		var gameRunning = IsGameRunning();
		if (!isGameOver)
		{
			// 游戏运行时更新UI。
			if (gameRunning)
			{
				AdvanceLevelProgress();

				UpdateHeldItemPosition();
				UpdateInLevelUI(deltaTime * gameSpeed);
			}
			// 更新手持物品。
			var speed = gameRunning ? gameSpeed : 0;
			ui.UpdateHeldItemModelFrame(deltaTime * speed);
			ui.SetHeldItemModelSimulationSpeed(speed);
			UpdateTwinkle(gameRunning ? deltaTime : 0);
		}

		var paused = IsGamePaused();
		// 暂停时显示金钱。
		if (paused)
		{
			ShowMoney();
		}

		// 设置射线检测。
		ui.SetRaycastDisabled(IsInputDisabled());

		var uiSimulationSpeed = paused ? 0 : gameSpeed;
		var uiDeltaTime = deltaTime * uiSimulationSpeed;

		var uiPreset = GetUIPreset();
		uiPreset.UpdateFrame(uiDeltaTime);
	}
	private function UpdateFrameModel(deltaTime:Float, gameSpeed:Float):Void
	{
		if (model != null)
		{
			var uiSimulationSpeed = IsGamePaused() ? 0 : gameSpeed;
			var uiDeltaTime = deltaTime * uiSimulationSpeed;
			model.UpdateAnimators(uiDeltaTime);
			model.UpdateFrame(uiDeltaTime);
			model.SetSimulationSpeed(uiSimulationSpeed);
		}
	}
	private function UpdateFrameLighting(deltaTime:Float, gameSpeed:Float):Void
	{
		var uiSimulationSpeed = IsGamePaused() ? 0 : gameSpeed;
		var uiDeltaTime = deltaTime * uiSimulationSpeed;

		var darknessSpeed:Float = 2;
		if (!IsGameStarted() || IsGameOver() || level.IsCleared)
		{
			darknessSpeed = -2;
		}
		darknessFactor = Mathf.Clamp01(darknessFactor + darknessSpeed * uiDeltaTime);
		UpdateLighting();
	}
	private function UpdateFrameLevelEngine(deltaTime:Float, gameSpeed:Float):Void
	{
		if (level == null)
			return;

		ui.SetScreenCover(level.GetScreenCover());
		UpdateCameraByLevel(level);
		UpdateMoney();
		ValidateHeldItem();

		var uiSimulationSpeed = IsGamePaused() ? 0 : gameSpeed;
		for (component in level.GetComponents())
		{
			if (Std.isOfType(component, IMVZ2LevelComponent))
			{
				var comp:IMVZ2LevelComponent = cast component;
				comp.UpdateFrame(deltaTime, uiSimulationSpeed);
			}
		}
		for (part in parts)
		{
			part.UpdateFrame(deltaTime, uiSimulationSpeed);
		}
	}
	// #endregion

	private function CanUpdateBeforeGameStart(entity:Entity):Bool
	{
		return entity.CanUpdateBeforeGameStart();
	}
	private function CanUpdateInPause(entity:Entity):Bool
	{
		return entity.CanUpdateInPause();
	}
	private function CanUpdateAfterGameOver(entity:Entity):Bool
	{
		return entity.CanUpdateAfterGameOver();
	}

	// #region 属性字段
	private var speedUp:Bool;
	private var advancedPause:Bool;
	private var gameRunTimeModular:Float;
	// #endregion

	// ===== LevelController_HeldItem.cs =====
	public function SetHeldItemUI(data:IHeldItemData):Void
	{
		var definition = data.GetDefinition(level);


		if (definition != null)
		{
			// 设置图标。
			var modelID = definition.GetModelID(level, data);
			SetHeldItemModel(modelID, definition, data);

			// 显示触发器图标。
			UpdateHeldItemIcons(definition, data);

			// 设置射线检测。
			UpdateHeldItemRaycaster(definition, data, definition.GetRadius(level, data));

			// 设置光标。
			UpdateHeldItemCursor(data.Type, modelID);
		}

		// 更新网格。
		UpdateHeldHighlight();
	}
	public function GetHeldItemModel():Model
	{
		return ui.GetHeldItemModel();
	}
	public function GetHeldItemModelInterface():IModelInterface
	{
		return heldItemModelInterface;
	}

	private function Awake_HeldItem():Void
	{
		heldItemModelInterface = new HeldItemModelInterface(this);
		ui.SetHeldItemModel(new ModelBuilder(null, GetCamera()));
	}
	private function UpdateHeldItemPosition():Void
	{
		var isPressing = Input.touchCount > 0 || Input.GetMouseButton(0);
		var heldItemPosition:Vector2;
		if (Main.InputManager.GetActivePointerType() == PointerTypes.TOUCH && !isPressing && !level.KeepHeldItemInScreen())
		{
			heldItemPosition = new Vector2(-1000, -1000);
		}
		else
		{
			// PORT-NOTE: C# 依赖 Vector3 -> Vector2 的隐式转换；Haxe 侧显式取 x/y。
			var worldPos = levelCamera.Camera.ScreenToWorldPoint(Main.InputManager.GetPointerScreenPosition());
			heldItemPosition = new Vector2(worldPos.x, worldPos.y);
		}
		ui.SetHeldItemPosition(heldItemPosition);
	}
	private function SetHeldItemModel(modelID:NamespaceID, definition:HeldItemDefinition, data:IHeldItemData):Void
	{
		var viewData = new ModelBuilder(modelID, GetCamera());
		ui.SetHeldItemModel(viewData);
		var model = GetHeldItemModel();
		if (model != null)
		{
			model.transform.localPosition = definition.GetModelOffset(level, data) * LawnToTransScale;
			model.SetShaderInt(ShaderProperties.LIGHT_DISABLED, 1);
			model.ApplyShaderProperties();
			definition.PostSetModel(level, data, heldItemModelInterface);
		}
	}
	private function UpdateHeldItemIcons(definition:HeldItemDefinition, data:IHeldItemData):Void
	{
		var triggerVisible = false;
		if (data.Type == VanillaHeldTypes.blueprintPickup)
		{
			var blueprintPickup = data.GetHoldingEntity(level);
			if (blueprintPickup != null)
			{
				var seedDef = BlueprintPickup.GetSeedDefinition(blueprintPickup);
				if (seedDef != null && seedDef.IsTriggerActive() && seedDef.CanInstantTrigger())
				{
					triggerVisible = true;
				}
			}
		}
		else
		{
			var blueprint = definition.GetSeedPack(level, data);
			// PORT-NOTE: C# 重载 IsTriggerActive(this SeedPack) 在 Haxe 中改名为 IsTriggerActiveOfPack。
			if (blueprint != null && blueprint.IsTriggerActiveOfPack() && blueprint.CanInstantTrigger())
			{
				triggerVisible = true;
			}
		}
		ui.SetHeldItemTrigger(triggerVisible, data.IsInstantTrigger());
		ui.SetHeldItemImbued(data.IsInstantEvoke());
	}
	private function UpdateHeldItemRaycaster(definition:HeldItemDefinition, data:IHeldItemData, radius:Float):Void
	{
		// 设置射线检测图层。
		var layers:Array<Int> = [];
		layers.push(Layers.RAYCAST_RECEIVER);
		layers.push(Layers.GRID);
		layers.push(Layers.DEFAULT);
		layers.push(Layers.PICKUP);
		var layerMask = Layers.GetMask(layers);

		var uiPreset = GetUIPreset();
		uiPreset.SetRaycasterMask(layerMask);
		// PORT-NOTE: C# 的 BaseRaycaster.eventMask 在移植层叫 finalEventMask；
		// mvz2logic.Layers.GetMask 返回 unity.LayerMask 包装对象，取其中的位掩码。
		levelRaycaster.finalEventMask = layerMask.value;

		// 设置射线检测半径。
		var transRadius = radius * LawnToTransScale;
		levelRaycaster.SetHeldItem(definition, data, transRadius);
	}
	private function UpdateHeldItemCursor(heldType:NamespaceID, modelID:NamespaceID):Void
	{
		var isHeldItemNone = heldType == LogicHeldTypes.none || !NamespaceID.IsValid(modelID);
		if (isHeldItemNone)
		{
			if (heldItemCursorSource != null)
			{
				Main.CursorManager.RemoveCursorSource(heldItemCursorSource);
				heldItemCursorSource = null;
			}
		}
		else
		{
			if (heldItemCursorSource == null)
			{
				heldItemCursorSource = new HeldItemCursorSource(this);
				Main.CursorManager.AddCursorSource(heldItemCursorSource);
			}
		}
	}
	private function UpdateHeldItemCursorEnabled():Void
	{
		var enabled = IsGameRunning() && (level != null && !level.IsCleared);
		if (heldItemCursorSource != null && enabled != heldItemCursorSource.Enabled)
		{
			heldItemCursorSource.SetEnabled(enabled);
		}
	}
	public function UpdateEntityHeldTargetColliders(mask:Int):Void
	{
		for (entity in entities)
		{
			entity.UpdateModelColliderActive(mask);
		}
	}
	private function UpdateHeldSlotUI():Void
	{
		var pickaxeDisabled = !level.CanUsePickaxe();
		var starshardDisabled = level.IsStarshardDisabled();
		var uiPreset = GetUIPreset();
		uiPreset.SetStarshardSelected(level.GetHeldItemType() == level.GetStarshardHeldType());
		uiPreset.SetStarshardDisabled(starshardDisabled && level.ShouldShowStarshardDisableIcon());

		var limit = level.GetPickaxeCountLimit();
		var remainCount = level.GetPickaxeRemainCount();
		var pickaxeNumberText = new PickaxeNumberText(level.IsPickaxeCountLimited(), '$remainCount/$limit', remainCount <= 0 ? Color.red : Color.white);
		uiPreset.SetPickaxeSelected(level.IsHoldingPickaxe());
		uiPreset.SetPickaxeDisabled(pickaxeDisabled && level.ShouldShowPickaxeDisableIcon());
		uiPreset.SetPickaxeNumberText(pickaxeNumberText);

		uiPreset.SetTriggerSelected(level.IsHoldingTrigger());
	}
	private function ValidateHeldItem():Void
	{
		var pickaxeDisabled = !level.CanUsePickaxe();
		var starshardDisabled = level.IsStarshardDisabled();
		if (pickaxeDisabled && level.IsHoldingPickaxe())
		{
			level.ResetHeldItem();
		}
		if (starshardDisabled && level.IsHoldingStarshard())
		{
			level.ResetHeldItem();
		}
	}

	// #region 高亮
	private function GetCurrentHeldHighlight():HeldHighlight
	{
		if (!IsGameRunning())
			return HeldHighlight.None;
		if (hoveredEntity != null && hoveredEntity.GetHoveredPointerCount() > 0)
		{
			return GetEntityHeldHighlight(hoveredEntity);
		}
		if (pointingGrid >= 0)
		{
			return GetGridHeldHighlight(pointingGrid, pointingGridPointerId);
		}
		if (pointingBlueprint >= 0)
		{
			return GetBlueprintHeldHighlight(pointingBlueprint, pointingBlueprintPointerId, pointingBlueprintConveyor);
		}
		if (isPointingLawnArea)
		{
			return GetLawnAreaHeldHighlight(pointingLawnArea, pointingLawnPointerId);
		}
		return HeldHighlight.None;
	}
	private function GetEntityHeldHighlight(entity:EntityController):HeldHighlight
	{
		var eventData = entity.GetHoveredPointerEventData(0);
		var pointerId = eventData.pointerId;
		// PORT-NOTE: C# 重载 InputHelper.GetPointerPosition(int pointerId) 在 Haxe 中保留原名
		// （2 参数版本才改名为 GetPointerPositionByButton）。
		var pointerPosition = InputHelper.GetPointerPosition(pointerId);
		var worldPosition = levelCamera.Camera.ScreenToWorldPoint(pointerPosition);
		// PORT-NOTE: C# 的重载 EntityController.GetHeldItemTarget(Vector3 worldPosition, Vector3 screenPosition)
		// 在 Haxe 中改名为 GetHeldItemTargetFromWorldPosition（另一重载保留 GetHeldItemTarget(PointerEventData)）。
		var target = entity.GetHeldItemTargetFromWorldPosition(worldPosition, pointerPosition);
		var pointerParams = InputHelper.GetPointerDataFromEventData(eventData);
		return level.GetHeldHighlight(target, pointerParams);
	}
	private function GetGridHeldHighlight(gridIndex:Int, pointerId:Int):HeldHighlight
	{
		var lane = level.GetGridLaneByIndex(gridIndex);
		var column = level.GetGridColumnByIndex(gridIndex);
		var grid = level.GetGrid(column, lane);
		var gridUI = gridLayout.GetGrid(lane, column);
		if (grid != null && gridUI != null)
		{
			var screenPos = InputHelper.GetPointerPosition(pointerId);
			var worldPos = levelCamera.Camera.ScreenToWorldPoint(screenPos);
			var position = gridUI.TransformWorld2ColliderPosition(worldPos);
			var target = new HeldItemTargetGrid(grid, position, screenPos);
			var type = InputHelper.GetPointerDataFromPointerId(pointerId);
			return level.GetHeldHighlight(target, type);
		}
		return HeldHighlight.None;
	}
	private function GetBlueprintHeldHighlight(blueprintIndex:Int, pointerId:Int, conveyor:Bool):HeldHighlight
	{
		var target = new HeldItemTargetBlueprint(level, blueprintIndex, conveyor);
		var pointerParams = InputHelper.GetPointerDataFromPointerId(pointerId);
		return level.GetHeldHighlight(target, pointerParams);
	}
	private function GetLawnAreaHeldHighlight(area:LawnArea, pointerId:Int):HeldHighlight
	{
		var target = new HeldItemTargetLawn(level, area);
		var pointerParams = InputHelper.GetPointerDataFromPointerId(pointerId);
		return level.GetHeldHighlight(target, pointerParams);
	}
	private function UpdateHeldHighlight():Void
	{
		var highlight = GetCurrentHeldHighlight();
		UpdateHeldHighlightOf(highlight);
	}
	// TODO-PORT: C# 重载 UpdateHeldHighlight(HeldHighlight highlight)，重命名以区分。
	private function UpdateHeldHighlightOf(highlight:HeldHighlight):Void
	{
		if (hoveredEntity != null)
		{
			// PORT-NOTE: C# `hoveredEntity.isActiveAndEnabled`（MonoBehaviour 继承自 Behaviour）。
			// unity shim 把该属性放在 unity.Behaviour 上，而 MonoBehaviour 直接继承 Component，
			// 故这里展开 get_isActiveAndEnabled 的等价判断。
			var activeAndEnabled = hoveredEntity.enabled && hoveredEntity.gameObject != null && hoveredEntity.gameObject.activeInHierarchy;
			if (!activeAndEnabled || hoveredEntity.GetHoveredPointerCount() <= 0)
				SetHoveredEntity(null);
		}
		UpdateGridHighlight(highlight);
		UpdateEntityHighlight(highlight);
	}
	private function UpdateGridHighlight(highlight:HeldHighlight):Void
	{
		ClearGridHighlight();
		if (highlight.mode != HeldHighlightMode.Grid)
			return;
		if (Main.InputManager.GetActivePointerType() == PointerTypes.TOUCH)
		{
			for (gridHighlight in highlight.grids)
			{
				var grid = gridHighlight.grid;
				HighlightAxisGrids(grid.Lane, grid.Column);
			}
		}
		for (gridHighlight in highlight.grids)
		{
			var grid = gridHighlight.grid;
			var targetGridUI = gridLayout.GetGrid(grid.Lane, grid.Column);
			if (targetGridUI != null)
			{
				var color = Color.clear;
				if (highlight.mode == HeldHighlightMode.Grid)
				{
					color = gridHighlight.valid ? Color.green : Color.red;
				}
				var rangeStart = gridHighlight.rangeStart;
				var rangeEnd = gridHighlight.rangeEnd;
				targetGridUI.SetColor(color);
				targetGridUI.SetDisplaySection(rangeStart, rangeEnd);
			}
		}
	}
	private function UpdateEntityHighlight(highlight:HeldHighlight):Void
	{
		if (highlight.mode != HeldHighlightMode.Entity)
		{
			SetHighlightedEntity(null);
			return;
		}
		var targetEntity = highlight.entity;
		if (targetEntity != null)
		{
			var ctrl = GetEntityController(targetEntity);
			SetHighlightedEntity(ctrl);
		}
	}
	// #endregion

	// #region 属性字段
	private var heldItemModelInterface:IModelInterface;
	private var heldItemCursorSource:CursorSource;
	@:serializeField
	private var levelRaycaster:LevelRaycaster = null;
	// #endregion

	// ===== LevelController_Input.cs =====
	private function UpdateInput():Void
	{
		if (IsInputDisabled())
			return;
		UpdatePointerRelease();
		// PORT-NOTE: C# 中 `#if UNITY_EDITOR UpdateKeysDebug(); #endif`，移植版不启用编辑器调试键。
		UpdateKeys();
	}
	private function IsInputDisabled():Bool
	{
		return level == null || level.IsCleared || isOpeningAlmanac || isOpeningStore || inputAndUIDisabled || IsConsoleActive();
	}

	// #region 指针输入
	private function UpdatePointerRelease():Void
	{
		if (Input.touchCount > 0)
		{
			for (position in InputHelper.GetTouchUps())
			{
				OnPointerRelease(position);
			}
		}
		else
		{
			for (position in InputHelper.GetMouseUps(MouseButtons.LEFT))
			{
				OnPointerRelease(position);
			}
		}
	}
	private function OnPointerRelease(pointer:PointerPositionParams):Void
	{
		// PORT-NOTE: C# 使用 UnityEngine.EventSystems.EventSystem.current.RaycastAll + ExecuteEvents.ExecuteHierarchy。
		// HaxeFlixel 中没有 uGUI 事件系统，这里保留流程但依赖兼容层实现。
		var eventSystem = EventSystem.current;
		var results:Array<RaycastResult> = [];
		var pointerId = InputHelper.GetPointerIdByButtonAndType(pointer.button, pointer.type);
		var eventData = new PointerEventData(eventSystem);
		eventData.position = pointer.position;
		eventData.button = cast pointer.button;
		eventData.pointerId = pointerId;
		eventSystem.RaycastAll(eventData, results);
		var first:RaycastResult = null;
		for (r in results)
		{
			if (r.gameObject != null)
			{
				first = r;
				break;
			}
		}
		if (first != null)
		{
			eventData.pointerCurrentRaycast = first;
			var handler = first.gameObject.GetComponentInParent(IPointerReleaseHandler);
			if (handler != null)
				handler.OnPointerRelease(eventData);
		}
	}
	// #endregion

	// #region 键盘
	private function UpdateKeys():Void
	{
		if (Input.GetKeyDown(KeyCode.Space))
		{
			OnPauseKey();
		}
		else if (Input.GetKeyDown(KeyCode.Escape))
		{
			OnOptionsKey();
		}
		if (Input.GetKeyDown(Options.GetKeyBinding(HotKeys.fastForward)))
		{
			OnFastForwardKey();
		}
		if (Input.GetKeyDown(Options.GetKeyBinding(HotKeys.hpBars)))
		{
			OnHPBarsKey();
		}


		if (IsGameRunning())
		{
			var conveyor = level.IsConveyorMode();
			var seedCount = conveyor ? level.GetConveyorSeedPackCount() : level.GetSeedSlotCount();
			for (i in 0...seedCount)
			{
				var key = Options.GetBlueprintKeyBinding(i);
				if (Input.GetKeyDown(key))
				{
					OnBlueprintKey(i, conveyor, cast key);
				}
			}
			if (Input.GetKeyDown(Options.GetKeyBinding(HotKeys.pickaxe)))
			{
				ClickPickaxe();
			}
			if (Input.GetKeyDown(Options.GetKeyBinding(HotKeys.starshard)))
			{
				ClickStarshard();
			}
			if (Input.GetKeyDown(Options.GetKeyBinding(HotKeys.trigger)))
			{
				ClickTrigger();
			}
		}
	}
	private function OnPauseKey():Void
	{
		if (isGameOver || !isGameStarted || levelLoaded)
			return;
		if (!isPaused)
		{
			if (!IsPauseDisabled())
			{
				PauseGame();
				level.PlaySound(LogicSoundID.pause);
				ShowPausedDialog();
			}
		}
		else
		{
			ResumeGame();
		}
	}
	private function OnOptionsKey():Void
	{
		if (isGameOver || !isGameStarted || levelLoaded)
			return;
		if (!isPaused)
		{
			if (!IsPauseDisabled())
			{
				PauseGame();
				level.PlaySound(LogicSoundID.pause);
				ShowOptionsDialog();
			}
		}
		else
		{
			ResumeGame();
		}
	}
	private function OnFastForwardKey():Void
	{
		if (isGameOver || optionsDialogController.IsOpen())
			return;
		SwitchSpeedUp();
	}
	private function OnHPBarsKey():Void
	{
		if (isGameOver || optionsDialogController.IsOpen())
			return;
		if (!IsHPBarsUnlocked())
		{
			level.PlaySound(LogicSoundID.buzzer);
			return;
		}
		Main.OptionsManager.SwitchHPBarEnabled();
		level.PlaySound(Main.OptionsManager.IsHPBarEnabled() ? LogicSoundID.dialogItemShow : LogicSoundID.dialogItemHide);
	}
	private function OnBlueprintKey(i:Int, conveyor:Bool, key:Int):Void
	{
		// PORT-NOTE: C# 的三元表达式两分支类型不同（ConveyorSeedPack / ClassicSeedPack），
		// Haxe 需显式标注公共基类 SeedPack。
		var seedPack:SeedPack = conveyor ? level.GetConveyorSeedPackAt(i) : level.GetSeedPackAt(i);
		if (seedPack == null)
			return;
		var target = new HeldItemTargetBlueprint(level, i, conveyor);
		var pointerParams = new PointerInteractionData();
		var pointerData = new PointerData();
		pointerData.button = key;
		pointerData.type = PointerTypes.KEY;
		pointerParams.pointer = pointerData;
		pointerParams.interaction = PointerInteraction.Key;
		level.DoHeldItemPointerEvent(target, pointerParams);
	}
	// #endregion

	// #region 调试
	private function UpdateKeysDebug():Void
	{
		if (Input.GetKeyDown(KeyCode.F1))
		{
			OnFastKillKey();
		}
		if (Input.GetKeyDown(KeyCode.F2))
		{
			OnSaveKey();
		}
		if (Input.GetKeyDown(KeyCode.F3))
		{
			OnLoadKey();
		}
		if (Input.GetKeyDown(KeyCode.F4))
		{
			OnPerformanceTestKey();
		}
		if (Input.GetKeyDown(KeyCode.F5))
		{
			OnFastKillBossKey();
		}
		if (Input.GetKeyDown(KeyCode.F6))
		{
			OnCommandBlockTestKey();
		}
		if (Input.GetKeyDown(KeyCode.F7))
		{
			OnAdvancedPauseKey();
		}
	}
	private function OnFastKillKey():Void
	{
		for (enemy in level.FindEntities(function(e:Entity) return e.Type == EntityTypes.ENEMY && e.IsHostile(SelfFaction) && !e.IsDead))
		{
			enemy.Die();
		}
	}
	private function OnSaveKey():Void
	{
		if (isGameStarted && !isGameOver)
		{
			LevelManager.SaveLevel();
			Debug.Log("Game Saved!");
		}
	}
	private function OnLoadKey():Void
	{
		if (isGameStarted && !isGameOver)
		{
			Debug.Log("Restarting Game...");
			ReloadLevel();
		}
	}
	private function OnPerformanceTestKey():Void
	{
		for (i in 0...50)
		{
			// PORT-NOTE: C# 重载 SpawnEnemyAtRandomLane(this LevelEngine, NamespaceID) 在 Haxe 中
			// 改名为 SpawnEnemyAtRandomLaneByID（接收 SpawnDefinition 的版本保留原名）。
			level.SpawnEnemyAtRandomLaneByID(VanillaSpawnID.zombie);
		}
	}
	private function OnFastKillBossKey():Void
	{
		for (boss in level.FindEntities(function(e:Entity) return e.Type == EntityTypes.BOSS && !e.IsDead))
		{
			boss.Die();
		}
	}
	private function OnCommandBlockTestKey():Void
	{
		var contraptions = Main.SaveManager.GetUnlockedContraptions();
		var grids = level.GetAllGrids();
		for (i in 0...contraptions.length)
		{
			var contraption = contraptions[i];
			var grid:LawnGrid = null;
			for (g in grids)
			{
				if (g.CanSpawnEntity(contraption))
				{
					grid = g;
					break;
				}
			}
			if (grid == null)
				continue;
			var spawnParams = CommandBlock.GetImitateSpawnParams(contraption);
			grid.SpawnPlacedEntity(VanillaContraptionID.commandBlock, spawnParams);
		}
	}
	private function OnAdvancedPauseKey():Void
	{
		SwitchAdvancedPause();
	}
	// #endregion

	// ===== LevelController_Dialogs.cs =====
	private function Awake_Dialogs():Void
	{
		ui.OnPauseDialogResumeClicked.add(UI_OnPauseDialogResumeClickedCallback);
		ui.OnLevelLoadedDialogButtonClicked.add(UI_OnLevelLoadedDialogOptionClickedCallback);
		ui.OnLevelErrorLoadingDialogButtonClicked.add(UI_OnLevelErrorLoadingDialogOptionClickedCallback);

		ui.OnGameOverRetryButtonClicked.add(UI_OnGameOverRetryButtonClickedCallback);
		ui.OnGameOverBackButtonClicked.add(UI_OnGameOverBackButtonClickedCallback);

		ui.SetPauseDialogActive(false);
		ui.SetOptionsDialogActive(false);
		ui.SetGameOverDialogActive(false);
		ui.SetLevelLoadedDialogVisible(false);
		ui.SetLevelErrorLoadingDialogVisible(false);
		optionsDialogController.OnClose.add(UI_OnOptionsMenuCloseCallback);
	}

	// #region 重新开始确认
	public function ShowRestartConfirmDialog():Void
	{
		var title = Localization._(LogicStrings.RESTART);
		var desc = Localization._(DIALOG_DESC_RESTART);
		Scene.ShowDialogSelectTask(title, desc, function(confirm:Bool):unity.Task
		{
			if (confirm)
			{
				RestartLevel();
			}
			// TODO-PORT: mvz2.scenes.MainSceneController 的回调用的是 unity.Task，而本文件统一用
			// system.threading.tasks.Task（两者是不同 shim），故这里显式返回 unity.Task 的完成实例。
			// 待全局统一 Task shim 后可直接写 Task.CompletedTask。
			return unity.Task.completedTask();
		});
	}
	// #endregion

	// #region 加载失败
	public function ShowLevelErrorLoadingDialog(e:Dynamic):Void
	{
		ShowLevelErrorLoadingDialogWithDesc(Localization._(ERROR_LOAD_LEVEL_EXCEPTION, [Std.string(e)]));
	}
	private function ShowLevelErrorLoadingDialogWithDesc(desc:String):Void
	{
		ui.SetLevelErrorLoadingDialogVisible(true);
		ui.SetLevelErrorLoadingDialogDesc(desc);
	}
	private function ShowLevelLoadedDialog():Void
	{
		ui.SetLevelLoadedDialogVisible(true);
	}
	private function ShowLevelMismatchLoadingDialog(compareResult:LevelDataIdentifierCompareResult):Void
	{
		var errorMessages:Array<String> = [];
		if (compareResult.versionMismatches.length > 0)
		{
			var messages = [for (m in compareResult.versionMismatches) GetVersionMismatchErrorMessage(m)].join("\n");
			var str = Localization._(ERROR_LOAD_LEVEL_IDENTIFIER_VERSION_NOT_MATCH, [messages]);
			errorMessages.push(str);
		}
		if (compareResult.missingMismatches.length > 0)
		{
			var messages = [for (m in compareResult.missingMismatches) GetMissingIdentifierMismatchErrorMessage(m)].join("\n");
			var str = Localization._(ERROR_LOAD_LEVEL_IDENTIFIER_MISSING_IDENTIFIER, [messages]);
			errorMessages.push(str);
		}
		if (compareResult.additionalMismatches.length > 0)
		{
			var messages = [for (m in compareResult.additionalMismatches) GetAdditionalIdentifierMismatchErrorMessage(m)].join("\n");
			var str = Localization._(ERROR_LOAD_LEVEL_IDENTIFIER_ADDITIONAL_IDENTIFIER, [messages]);
			errorMessages.push(str);
		}
		var errorMessageStr = errorMessages.join("\n\n");
		var error = Localization._(ERROR_LOAD_LEVEL_IDENTIFIER_NOT_MATCH, [errorMessageStr]);
		ShowLevelErrorLoadingDialogWithDesc(error);
	}
	private function GetVersionMismatchErrorMessage(pair:LevelDataIdentifierPair):String
	{
		return Localization._(ERROR_LOAD_LEVEL_IDENTIFIER_PAIR, [pair.lhs.spaceName, Std.string(pair.rhs.dataVersion), Std.string(pair.lhs.dataVersion)]);
	}
	private function GetMissingIdentifierMismatchErrorMessage(identifier:LevelDataIdentifier):String
	{
		return Localization._(ERROR_LOAD_LEVEL_IDENTIFIER, [identifier.spaceName, Std.string(identifier.dataVersion)]);
	}
	private function GetAdditionalIdentifierMismatchErrorMessage(identifier:LevelDataIdentifier):String
	{
		var modInfo = Main.ModManager.GetModInfo(identifier.spaceName);
		var name = modInfo != null && modInfo.DisplayName != null ? modInfo.DisplayName : identifier.spaceName;
		return Localization._(ERROR_LOAD_LEVEL_IDENTIFIER, [name, Std.string(identifier.dataVersion)]);
	}
	private function UI_OnLevelLoadedDialogOptionClickedCallback(type:mvz2.ui.level.LevelLoadedDialog.ButtonType):Void
	{
		switch (type)
		{
			case mvz2.ui.level.LevelLoadedDialog.ButtonType.Resume:
				ResumeGameDelayed(100);
				ui.SetLevelLoadedDialogVisible(false);
				levelLoaded = false;
			case mvz2.ui.level.LevelLoadedDialog.ButtonType.Restart:
				ShowRestartConfirmDialog();
			default:
				ExitLevel();
		}
	}
	private function UI_OnLevelErrorLoadingDialogOptionClickedCallback(restart:Bool):Void
	{
		ui.SetLevelErrorLoadingDialogInteractable(false);
		if (restart)
		{
			RestartLevel();
		}
		else
		{
			ExitLevel();
		}
	}
	// #endregion

	// #region 选项
	private function ShowOptionsDialog():Void
	{
		ui.SetOptionsDialogActive(true);

		var context = new OptionContextLevel(level);
		optionsDialogController.Open(context);
	}
	// #endregion

	// #region 暂停
	private function ShowPausedDialog():Void
	{
		var sprite = pauseImages.Random(rng);
		ui.SetPauseDialogActive(true);
		// PORT-NOTE: pauseImages 元素是 unity.Sprite，C# 用的是 GetFinalSprite(Sprite) 重载。
		ui.SetPauseDialogImage(Main.GetFinalSpriteFromSprite(sprite));
	}
	private function UI_OnPauseDialogResumeClickedCallback():Void
	{
		ResumeGameDelayed(100);
	}
	// #endregion

	// #region 游戏结束
	private function ShowGameOverDialog():Void
	{
		var messageKey:String;
		if (killerID != null)
		{
			messageKey = Resources.GetEntityDeathMessage(killerID);
		}
		else
		{
			messageKey = deathMessage;
		}
		ui.SetGameOverDialogActive(true);
		var msg = Localization._p(LogicStrings.CONTEXT_DEATH_MESSAGE, messageKey);
		var message:String;
		if (level.IsEndless())
		{
			var roundsMessage = Localization._pn(LogicStrings.CONTEXT_DEATH_MESSAGE, LogicStrings.DEATH_MESSAGE_ENDLESS, level.CurrentFlag, [level.CurrentFlag]);
			message = Localization._p(LogicStrings.CONTEXT_DEATH_MESSAGE, LogicStrings.DEATH_MESSAGE_ENDLESS_TEMPLATE, [msg, roundsMessage]);
		}
		else
		{
			message = msg;
		}
		ui.SetGameOverDialogMessage(message);
	}
	private function UI_OnGameOverRetryButtonClickedCallback():Void
	{
		ui.SetGameOverDialogInteractable(false);
		RestartLevel();
	}
	private function UI_OnGameOverBackButtonClickedCallback():Void
	{
		ExitLevel();
	}
	// #endregion

	// #region 属性字段
	@:translateMsg("对话框内容")
	public static inline var DIALOG_DESC_RESTART:String = "确认要重新开始关卡吗？\n本关的进度都将丢失。";
	@:translateMsg("对话框内容")
	public static inline var ERROR_LOAD_LEVEL_CORRUPTED:String = "读取关卡失败，文件可能已损坏。";
	@:translateMsg("对话框内容，{0}为错误信息")
	public static inline var ERROR_LOAD_LEVEL_EXCEPTION:String = "加载关卡失败，出现错误：{0}";
	@:translateMsg("对话框内容，{0}为错误信息")
	public static inline var ERROR_LOAD_LEVEL_IDENTIFIER_NOT_MATCH:String = "加载关卡失败，存档状态和当前游戏状态不匹配：\n{0}";
	@:translateMsg("关卡标识符名称，{0}为命名空间名，{1}为数据版本号")
	public static inline var ERROR_LOAD_LEVEL_IDENTIFIER:String = "{0}（版本{1}）";
	@:translateMsg("关卡标识符名称，{0}为命名空间名，{1}为数据版本号，{2}为当前数据版本号")
	public static inline var ERROR_LOAD_LEVEL_IDENTIFIER_PAIR:String = "{0}（版本{1}，当前状态为{2}）";
	@:translateMsg("对话框内容，{0}为不匹配的关卡标识符列表")
	public static inline var ERROR_LOAD_LEVEL_IDENTIFIER_VERSION_NOT_MATCH:String = "版本号不匹配：\n{0}";
	@:translateMsg("对话框内容，{0}为丢失的关卡标识符列表")
	public static inline var ERROR_LOAD_LEVEL_IDENTIFIER_MISSING_IDENTIFIER:String = "丢失的模组：\n{0}";
	@:translateMsg("对话框内容，{0}为多出的关卡标识符列表")
	public static inline var ERROR_LOAD_LEVEL_IDENTIFIER_ADDITIONAL_IDENTIFIER:String = "多出的模组：\n{0}";


	@:header("Dialogs")
	@:serializeField
	private var pauseImages:Array<Sprite> = [];
	@:serializeField
	private var optionsDialogController:OptionsDialogController = null;
	// #endregion

	// ===== LevelController_Transitions.cs =====
	// #region 游戏开始
	private function GameStartInstantTransition():Void
	{
		SetCameraPosition(LevelCameraPosition.Lawn);
		UpdateDifficulty();
		Game.RunCallback(LogicLevelCallbacks.PRE_BATTLE, new LevelCallbackParams(level));
		level.PrepareForBattle();
		StartGame();
	}
	private function GameStartToPreviewTransition():Coroutine
	{
		return Coroutine.create(function(co:CoroutineContext)
		{
			Music.Play(LogicMusicID.choosing);
			// PORT-NOTE: C# 重载 CreatePreviewEnemies(this LevelEngine, Rect) 在 Haxe 中改名为
			// CreatePreviewEnemiesFromEnemyPool（原 2 参数版本保留 CreatePreviewEnemies）。
			level.CreatePreviewEnemiesFromEnemyPool(LevelPositions.GetEnemySpawnRect());
			co.wait(1);
			// PORT-NOTE: `yield return MoveCameraToChoose();` —— 用 co.waitCoroutine 表达
			//   「挂起直到子协程结束」。**不能**写成 `var inner = ...(); while (!inner.finished) co.waitFrames(1);`：
			//   重放模型下每次恢复都会重新调用工厂拿到一个全新的、无人驱动的子协程，循环永不退出
			//   （见 unity/Coroutine.hx 的取舍说明）。waitCoroutine 会自动驱动未被显式启动的子协程。
			co.waitCoroutine(MoveCameraToChoose());
			co.wait(1);
		});
	}
	public function GameStartToLawnTransition():Coroutine
	{
		return Coroutine.create(function(co:CoroutineContext)
		{
			// PORT-NOTE: `yield return MoveCameraToLawn();` —— 见上方 GameStartToPreviewTransition
			//   对 waitCoroutine 用法的说明（工厂轮询写法在重放模型下会永久挂住）。
			co.waitCoroutine(MoveCameraToLawn());
			UpdateDifficulty();
			Game.RunCallback(LogicLevelCallbacks.PRE_BATTLE, new LevelCallbackParams(level));
			level.PrepareForBattle();
			co.wait(0.5);
			PlayReadySetBuild();
		});
	}
	private function GameStartToLawnInstantTransition():Coroutine
	{
		return Coroutine.create(function(co:CoroutineContext)
		{
			Music.Play(LogicMusicID.choosing);
			co.wait(1);
			// PORT-NOTE: `yield return MoveCameraToLawn();` —— 见 GameStartToPreviewTransition 的说明。
			co.waitCoroutine(MoveCameraToLawn());
			co.wait(0.5);
			StartGame();
		});
	}
	private function GameStartTransition():Coroutine
	{
		return Coroutine.create(function(co:CoroutineContext)
		{
			// PORT-NOTE: `yield return GameStartToPreviewTransition();` —— 见 GameStartToPreviewTransition
			//   的说明；这里是「协程等协程」，同样必须用 waitCoroutine。
			co.waitCoroutine(GameStartToPreviewTransition());

			UpdateDifficulty();
			UpdateEnergy();
			level.UpdatePersistentLevelUnlocks();

			var innateBlueprints = Game.GetInnateBlueprints();
			var unlockedContraptions = [for (id in Saves.GetUnlockedContraptions()) if (Main.ResourceManager.IsContraptionInAlmanac(id)) id];
			var unlockedArtifacts = Saves.GetUnlockedArtifacts();
			var seedSlotCount = level.GetSeedSlotCount();
			var willChooseBlueprint = innateBlueprints.length + unlockedContraptions.length > seedSlotCount || unlockedArtifacts.length > 0;

			if (willChooseBlueprint && level.NeedBlueprints())
			{
				UpdateEntityHeldTargetColliders(HeldTargetFlag.Enemy);
				// 选卡。
				var uiPreset = GetUIPreset();
				BlueprintChoosePart.ShowBlueprintChoosePanel(unlockedContraptions);
				uiPreset.SetUIVisibleState(VisibleState.ChoosingBlueprints);
				uiPreset.SetReceiveRaycasts(false);
				co.wait(0.5);
				uiPreset.SetReceiveRaycasts(true);
			}
			else
			{
				// PORT-NOTE: C# `new BlueprintChooseItem(i, innate: true)`；参数槽为 (id, isCommandBlock, innate)。
				var innateChooseItems = [for (i in innateBlueprints) new BlueprintChooseItem(i, false, true)];
				// C# `new BlueprintChooseItem(i)`：两个可选形参都走默认值 false。
				var contraptionChooseItems = [for (i in unlockedContraptions.slice(0, seedSlotCount)) new BlueprintChooseItem(i, false, false)];
				var chooseItems = innateChooseItems.concat(contraptionChooseItems);
				level.SetupBattleBlueprints(chooseItems);
				Game.RunCallback(LogicLevelCallbacks.POST_BLUEPRINT_SELECTION, new PostBlueprintSelectionParams(level, chooseItems));
				// PORT-NOTE: `yield return GameStartToLawnTransition();` —— 见 GameStartToPreviewTransition 的说明。
				co.waitCoroutine(GameStartToLawnTransition());
			}
		});
	}
	// #endregion

	// #region 游戏结束
	private function GameOverByEnemyTransition():Coroutine
	{
		return Coroutine.create(function(co:CoroutineContext)
		{
			Music.Stop();
			co.wait(1);
			// PORT-NOTE: `yield return MoveCameraToHouse();` —— 见 GameStartToPreviewTransition 的说明。
			co.waitCoroutine(MoveCameraToHouse());
			co.wait(3);
			level.PlaySound(LogicSoundID.hit);
			co.wait(0.5);
			level.PlaySound(LogicSoundID.hit);
			co.wait(0.5);
			level.PlaySound(LogicSoundID.hit);
			co.wait(0.5);
			level.PlaySound(LogicSoundID.scream);
			ui.ShowYouDied();
			co.wait(4);
			ShowGameOverDialog();
		});
	}
	private function GameOverNoEnemyTransition():Coroutine
	{
		return Coroutine.create(function(co:CoroutineContext)
		{
			Music.Stop();
			level.PlaySound(LogicSoundID.scream);
			ui.ShowYouDied();
			co.wait(4);
			ShowGameOverDialog();
		});
	}
	// #endregion

	// #region 退出关卡
	private function ExitLevelTransition(delay:Float):Coroutine
	{
		return Coroutine.create(function(co:CoroutineContext)
		{
			co.wait(delay);
			Sounds.Play2D(LogicSoundID.travel);
			Scene.PortalFadeIn(function()
			{
				ExitLevel();
				Scene.PortalFadeOut();
			});
		});
	}
	private function ExitLevelToNoteTransition(noteID:NamespaceID, delay:Float):Coroutine
	{
		return Coroutine.create(function(co:CoroutineContext)
		{
			co.wait(delay);
			ui.SetExitingToNote();
			exitTargetNoteID = noteID;
		});
	}
	private function StartExitLevelTransition(delay:Float):Void
	{
		var endNoteId = level.GetEndNoteID();
		if (NamespaceID.IsValid(endNoteId) && !level.IsRerun)
		{
			StartCoroutine(ExitLevelToNoteTransition(endNoteId, delay));
		}
		else
		{
			StartCoroutine(ExitLevelTransition(delay));
		}
	}
	// #endregion

	// ===== LevelController_Tools.cs =====
	private function Awake_Tools():Void
	{
		var uiPreset = GetUIPreset();
		uiPreset.OnPickaxePointerEnter.add(UI_OnPickaxePointerEnterCallback);
		uiPreset.OnPickaxePointerExit.add(UI_OnPickaxePointerExitCallback);
		uiPreset.OnPickaxePointerDown.add(UI_OnPickaxePointerDownCallback);

		uiPreset.OnStarshardPointerDown.add(UI_OnStarshardPointerDownCallback);

		uiPreset.OnTriggerPointerEnter.add(UI_OnTriggerPointerEnterCallback);
		uiPreset.OnTriggerPointerExit.add(UI_OnTriggerPointerExitCallback);
		uiPreset.OnTriggerPointerDown.add(UI_OnTriggerPointerDownCallback);
	}
	private function StartGame_Tools():Void
	{
		// 可解锁UI
		UpdateToolUIUnlockedActive();
	}
	private function WriteToSerializable_Tools(seri:SerializableLevelController):Void
	{
		seri.energyActive = EnergyActive;
		seri.blueprintsActive = BlueprintsActive;
		seri.pickaxeActive = PickaxeActive;
		seri.starshardActive = StarshardActive;
		seri.triggerActive = TriggerActive;
	}
	private function ReadFromSerializable_Tools(seri:SerializableLevelController):Void
	{
		EnergyActive = seri.energyActive;
		BlueprintsActive = seri.blueprintsActive;
		PickaxeActive = seri.pickaxeActive;
		StarshardActive = seri.starshardActive;
		TriggerActive = seri.triggerActive;
	}
	private function UpdateToolUIUnlockedActive():Void
	{
		var levelUI = GetUIPreset();
		StarshardActive = Saves.IsStarshardUnlocked();
		TriggerActive = Saves.IsTriggerUnlocked();
	}

	// #region 铁镐
	private function ClickPickaxe():Void
	{
		if (!PickaxeActive)
			return;
		if (level.IsHoldingExclusiveItem())
		{
			if (level.CancelHeldItem())
			{
				level.PlaySound(LogicSoundID.tap);
			}
			return;
		}
		if (!level.CanUsePickaxe())
			return;
		level.PlaySound(LogicSoundID.pickaxe);
		// PORT-NOTE: C# 重载 SetHeldItem(this LevelEngine, NamespaceID, int, Action) 在 Haxe 中
		// 改名为 SetHeldItemByType（接收 IHeldItemBuilder 的版本保留 SetHeldItem）。
		level.SetHeldItemByType(LogicHeldTypes.pickaxe);
	}
	private function UI_OnPickaxePointerEnterCallback(eventData:PointerEventData):Void
	{
		if (!IsGameStarted())
			return;
		var tooltipSource = pickaxeTooltipSource;
		if (tooltipSource == null)
		{
			HideTooltip();
			return;
		}
		ShowTooltip(tooltipSource);
	}
	private function UI_OnPickaxePointerExitCallback(eventData:PointerEventData):Void
	{
		HideTooltip();
	}
	private function UI_OnPickaxePointerDownCallback(eventData:PointerEventData):Void
	{
		if (eventData.button != InputButton.Left)
			return;
		if (!IsGameStarted())
			return;
		ClickPickaxe();
	}
	// #endregion

	// #region 星之碎片
	private function ClickStarshard():Void
	{
		if (!StarshardActive)
			return;
		if (level.IsHoldingExclusiveItem())
		{
			if (level.CancelHeldItem())
			{
				level.PlaySound(LogicSoundID.tap);
			}
			return;
		}
		if (!level.CanUseStarshard())
		{
			level.PlaySound(LogicSoundID.buzzer);
			return;
		}
		var heldID = level.GetStarshardHeldType();
		if (NamespaceID.IsValid(heldID))
		{
			level.SetHeldItemByType(heldID);
		}
	}
	private function UpdateStarshards():Void
	{
		var levelUI = GetUIPreset();
		levelUI.SetStarshardCount(level.GetStarshardCount(), level.GetStarshardSlotCount());
	}
	private function SetStarshardIcon():Void
	{
		var levelUI = GetUIPreset();
		var spriteRef = level.GetStarshardIcon();
		var sprite = Main.GetFinalSpriteFromRef(spriteRef);
		if (sprite == null)
		{
			sprite = Main.GetFinalSpriteFromRef(VanillaSprites.starshardDefault);
		}
		levelUI.SetStarshardIcon(sprite);
	}
	private function UI_OnStarshardPointerDownCallback(eventData:PointerEventData):Void
	{
		if (eventData.button != InputButton.Left)
			return;
		if (!IsGameStarted())
			return;
		ClickStarshard();
	}
	// #endregion

	// #region 触发器
	private function ClickTrigger():Void
	{
		if (!TriggerActive)
			return;
		if (level.IsHoldingExclusiveItem())
		{
			if (level.CancelHeldItem())
			{
				level.PlaySound(LogicSoundID.tap);
			}
			return;
		}
		if (!level.CanUseTrigger())
			return;
		level.SetHeldItemByType(LogicHeldTypes.trigger);
	}
	private function UI_OnTriggerPointerEnterCallback(eventData:PointerEventData):Void
	{
		if (!IsGameStarted())
			return;
		var tooltipSource = triggerTooltipSource;
		if (tooltipSource == null)
		{
			HideTooltip();
			return;
		}
		ShowTooltip(tooltipSource);
	}
	private function UI_OnTriggerPointerExitCallback(eventData:PointerEventData):Void
	{
		HideTooltip();
	}
	private function UI_OnTriggerPointerDownCallback(eventData:PointerEventData):Void
	{
		if (eventData.button != InputButton.Left)
			return;
		if (!IsGameStarted())
			return;
		ClickTrigger();
	}
	// #endregion

	// #region 属性字段
	public var EnergyActive(get, set):Bool;
	function get_EnergyActive():Bool return energyActive;
	function set_EnergyActive(value:Bool):Bool
	{
		energyActive = value;
		var uiPreset = GetUIPreset();
		uiPreset.SetEnergyActive(value);
		return value;
	}
	public var BlueprintsActive(get, set):Bool;
	function get_BlueprintsActive():Bool return blueprintsActive;
	function set_BlueprintsActive(value:Bool):Bool
	{
		blueprintsActive = value;
		ui.Blueprints.SetBlueprintsActive(value);
		return value;
	}
	public var PickaxeActive(get, set):Bool;
	function get_PickaxeActive():Bool return pickaxeActive;
	function set_PickaxeActive(value:Bool):Bool
	{
		pickaxeActive = value;
		var uiPreset = GetUIPreset();
		uiPreset.SetPickaxeActive(value);
		return value;
	}
	public var StarshardActive(get, set):Bool;
	function get_StarshardActive():Bool return starshardActive;
	function set_StarshardActive(value:Bool):Bool
	{
		starshardActive = value;
		var uiPreset = GetUIPreset();
		uiPreset.SetStarshardActive(value);
		return value;
	}
	public var TriggerActive(get, set):Bool;
	function get_TriggerActive():Bool return triggerActive;
	function set_TriggerActive(value:Bool):Bool
	{
		triggerActive = value;
		var uiPreset = GetUIPreset();
		uiPreset.SetTriggerActive(value);
		return value;
	}
	private var energyActive:Bool = true;
	private var blueprintsActive:Bool = true;
	private var pickaxeActive:Bool = true;
	private var starshardActive:Bool = true;
	private var triggerActive:Bool = true;
	// #endregion

	// PORT-NOTE: 以下是供同模块的 Tooltip 源类访问私有属性的访问器
	// （C# 中嵌套类可直接访问外部类私有成员，Haxe 模块级类不行）。
	public function getMain():MainManager return Main;
	public function getLocalization():LanguageManager return Localization;
}

// ===== LevelController_Tooltip.cs 中的私有嵌套类 =====
class PickaxeTooltipSource implements ITooltipSource
{
	private var controller:LevelController;
	public function new(level:LevelController)
	{
		this.controller = level;
	}
	public function GetCamera():Camera
	{
		return controller.GetCamera();
	}
	public function GetTarget():ITooltipTarget
	{
		return controller.GetUIPreset().GetPickaxeSlot();
	}
	public function GetContent():TooltipContent
	{
		var error:String = null;
		if (!controller.GetEngine().CanUsePickaxe())
		{
			var disableID = controller.GetEngine().GetPickaxeDisableID();
			var message = Global.Game.GetBlueprintErrorMessage(disableID);
			if (!(message == null || message == ""))
			{
				error = controller.getLocalization()._p(LogicStrings.CONTEXT_BLUEPRINT_ERROR, message);
			}
		}
		var content = new TooltipContent();
		content.name = controller.getLocalization()._(LogicStrings.TOOLTIP_DIG_CONTRAPTION);
		content.error = error;
		content.description = null;
		return content;
	}
}

class TriggerTooltipSource implements ITooltipSource
{
	private var controller:LevelController;
	public function new(level:LevelController)
	{
		this.controller = level;
	}
	public function GetCamera():Camera
	{
		return controller.GetCamera();
	}
	public function GetTarget():ITooltipTarget
	{
		return controller.GetUIPreset().GetCurrentTriggerUI();
	}
	public function GetContent():TooltipContent
	{
		var error:String = null;
		if (controller.GetEngine().CanUseTrigger())
		{
			var disableID = controller.GetEngine().GetTriggerDisableID();
			var message = Global.Game.GetBlueprintErrorMessage(disableID);
			if (!(message == null || message == ""))
			{
				error = controller.getLocalization()._p(LogicStrings.CONTEXT_BLUEPRINT_ERROR, message);
			}
		}
		var content = new TooltipContent();
		content.name = controller.getLocalization()._(LogicStrings.TOOLTIP_TRIGGER_CONTRAPTION);
		content.error = error;
		content.description = null;
		return content;
	}
}

class ArtifactTooltipSource implements ITooltipSource
{
	private var controller:LevelController;
	private var artifactID:NamespaceID;
	private var target:ITooltipTarget;

	public function new(controller:LevelController, artifactID:NamespaceID, target:ITooltipTarget)
	{
		this.controller = controller;
		this.artifactID = artifactID;
		this.target = target;
	}
	public function GetCamera():Camera
	{
		return controller.GetCamera();
	}
	public function GetTarget():ITooltipTarget
	{
		return target;
	}
	public function GetContent():TooltipContent
	{
		var main = controller.getMain();
		var name = main.ResourceManager.GetArtifactName(artifactID);
		var tooltip = main.ResourceManager.GetArtifactTooltip(artifactID);
		var content = new TooltipContent();
		content.name = name;
		content.error = "";
		content.description = tooltip;
		return content;
	}
}

// ===== LevelController_Entities.cs 中的私有嵌套类 =====
class EntityTooltipSource implements ITooltipSource
{
	private var controller:LevelController;
	private var entityCtrl:EntityController;

	public function new(controller:LevelController, entityCtrl:EntityController)
	{
		this.controller = controller;
		this.entityCtrl = entityCtrl;
	}

	public function GetCamera():Camera
	{
		return controller.GetCamera();
	}
	public function GetTarget():ITooltipTarget
	{
		return entityCtrl;
	}

	public function GetContent():TooltipContent
	{
		var main = controller.getMain();
		var name = main.ResourceManager.GetEntityName(entityCtrl.Entity.GetDefinitionID());
		var description = "";
		if (main.SaveManager.IsAlmanacUnlocked())
		{
			var entityID = entityCtrl.Entity.GetDefinitionID();
			if (main.ResourceManager.IsEnemyInAlmanac(entityID) && main.SaveManager.IsEnemyUnlocked(entityID))
			{
				description = main.LanguageManager._p(LogicStrings.CONTEXT_ENTITY_TOOLTIP, LevelController.VIEW_IN_ALMANAC);
			}
		}
		var content = new TooltipContent();
		content.name = name;
		content.description = description;
		return content;
	}
}

// Ported from: Assets/Scripts/MVZ2/Level/LevelController/LevelController_Entities.cs 中的 struct AnimatorUpdateData
class AnimatorUpdateData
{
	public var animator:Animator;
	public var speed:Float;

	public function new(animator:Animator, speed:Float)
	{
		this.animator = animator;
		this.speed = speed;
	}
}

// TODO-PORT: unity.Gizmos（Unity 编辑器专用的调试绘制 API）在 unity shim 中不存在，且 HaxeFlixel
// 没有等价的随手绘制通道。这里保留 LevelController_OnDrawGizmos 的调用点（原样保留 C# 的绘制逻辑），
// 用一个本模块内的空实现占位，使碰撞四叉树/碰撞盒的调试可视化逻辑不丢失、可随时接回真实绘制。
// 若 unity shim 日后补齐 unity.Gizmos，删除本类即可（模块内类型优先于 `import unity.*` 的通配导入）。
private class Gizmos
{
	public static var color:Color = new Color(1, 1, 1, 1);
	public static function DrawWireCube(center:Vector3, size:Vector3):Void {}
}
