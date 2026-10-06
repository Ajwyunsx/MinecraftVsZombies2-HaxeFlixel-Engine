// Ported from: Assets/Scripts/MVZ2/Managers/MainManager.cs
package mvz2.managers;

import haxe.ds.GenericStack;
import mvz2.cameras.ResolutionManager;
// PORT-NOTE: SerializableUnityCollisionEntity 是 UnityCollisionEntity 模块内的次类型。
import mvz2.collisions.UnityCollisionEntity.SerializableUnityCollisionEntity;
import mvz2.debugs.DebugManager;
import mvz2.states.BootTrace;
import mvz2.globalgames.GlobalGame;
import mvz2.inputs.InputManager;
import mvz2.models.GraphicsManager;
import mvz2.models.ModelFactories;
import mvz2.models.ModelFactory;
import mvz2logic.Global;
import mvz2logic.GlobalParams;
import mvz2logic.options.LogicOptionExt;
import mvz2logic.options.ScreenLayouts;
// PORT-NOTE: 原 import 写作 mvz2logic.Serialization.*，但 Haxe 无法解析含大写字母的包段，
// 实际文件位于 source/mvz2logic/serialization/，故改用小写包路径。
import mvz2logic.serialization.SerializeHelper;
import system.threading.tasks.Task;
import unity.*;
import unity.Debug;
import mvz2.collisions.UnityCollisionEntity;
import mvz2.collisions.UnityCollisionSystem.SerializableUnityCollisionSystem;
import mvz2.collisions.UnityEntityCollider.SerializableUnityEntityCollider;
import mvz2.gamecontent.commands.Load;
import mvz2.globalgames.GlobalAlmanac;
import mvz2.globalgames.GlobalGUI;
import mvz2.globalgames.GlobalModels;
import mvz2.level.BlueprintController.SerializableBlueprintController;
import mvz2.level.ClassicBlueprintController.SerializableClassicBlueprintController;
import mvz2.level.ConveyorBlueprintController.SerializableConveyorBlueprintController;
import mvz2.level.LevelBlueprintChooseController.SerializableLevelBlueprintChooseController;
import mvz2.level.LevelBlueprintController.SerializableLevelBlueprintController;
import mvz2.level.LevelControllerPart.SerializableLevelControllerPart;
import mvz2.level.components.AdviceComponent.SerializableAdviceComponent;
import mvz2.level.components.ArtifactComponent.SerializableArtifactComponent;
import mvz2.level.components.BlueprintComponent.SerializableBlueprintComponent;
import mvz2.level.components.HeldItemComponent.EmptySerializableLevelComponent;
import mvz2.level.components.LightComponent.SerializableLightComponent;
import mvz2.level.components.SoundComponent.SerializableSoundComponent;
import mvz2.level.components.UIComponent.SerializableUIComponent;
import mvz2.models.AreaModel.SerializableAreaModelData;
import mvz2.models.EntityModel.SerializableSpriteModelData;
import mvz2.models.GraphicElement.SerializableGraphicElement;
import mvz2.models.ImageElement.SerializableImageElement;
import mvz2.models.Model.SerializableModelData;
import mvz2.models.ModelGroup.SerializableModelGroup;
import mvz2.models.ModelGroupArea.SerializableModelGroupArea;
import mvz2.models.ModelGroupEntity.SerializableModelGroupEntity;
import mvz2.models.ModelGroupUI.SerializableModelGroupUI;
import mvz2.models.RendererElement.SerializableRendererElement;
import mvz2.models.UIModel.SerializableUIModelData;
import mvz2.saves.UserDataItem.SerializableSaveDataMeta;
import mvz2.saves.UserDataList.SerializableUserDataList;
import mvz2.scenes.MainSceneController;
import mvz2.scenes.SceneLoadingManager;
import mvz2logic.resources.SpriteReference;
import pvzengine.NamespaceID;
import pvzengine.PropertyMapper;
import mvz2.almanacs.AlmanacManager;
import mvz2.audios.MusicManager;
import mvz2.audios.SoundManager;
import mvz2.cameras.ShakeManager;
import mvz2.collisions.UnityCollisionSystem;
import mvz2.collisions.UnityEntityCollider;
import mvz2.cursors.CursorManager;
import mvz2.io.FileManager;
import mvz2.level.BlueprintController;
import mvz2.level.ClassicBlueprintController;
import mvz2.level.ConveyorBlueprintController;
import mvz2.level.LevelBlueprintChooseController;
import mvz2.level.LevelBlueprintController;
import mvz2.level.LevelControllerPart;
import mvz2.level.LevelManager;
import mvz2.level.components.AdviceComponent;
import mvz2.level.components.ArtifactComponent;
import mvz2.level.components.BlueprintComponent;
import mvz2.level.components.HeldItemComponent;
import mvz2.level.components.LightComponent;
import mvz2.level.components.SoundComponent;
import mvz2.level.components.UIComponent;
import mvz2.localization.LanguageManager;
import mvz2.modding.ModManager;
import mvz2.models.AreaModel;
import mvz2.models.EntityModel;
import mvz2.models.GraphicElement;
import mvz2.models.ImageElement;
import mvz2.models.Model;
import mvz2.models.ModelGroup;
import mvz2.models.ModelGroupArea;
import mvz2.models.ModelGroupEntity;
import mvz2.models.ModelGroupUI;
import mvz2.models.ModelManager;
import mvz2.models.RendererElement;
import mvz2.models.UIModel;
import mvz2.options.OptionsManager;
import mvz2.saves.SaveManager;
import mvz2.saves.UserDataItem;
import mvz2.saves.UserDataList;
import mvz2.store.StoreManager;
import mvz2.supporters.SponsorManager;
import unity.scenemanagement.SceneInstance.Scene;
import unity.scenemanagement.SceneManager;
import unity.Application.LogType;
import unity.scenemanagement.SceneInstance;
// PORT-NOTE: C# 的扩展方法（this 参数形式）在 Haxe 中需显式 using 才能以 `obj.Method()` 调用。
using mvz2logic.options.LogicOptionExt;            // HasBloodAndGore(this IGlobalOptions)

typedef TaskAction = TaskProgress->Task;

class MainManager extends MonoBehaviour
{
	public function Initialize():Task
	{
		InitGameSettings();
		InitSerializable();
		LogInformations();
		// PORT-NOTE: C# 中此处为 `await LoadManagersInit();`，
		// Haxe 侧 Task shim 不支持真正的异步等待，这里按顺序同步执行。
		var loadTask = LoadManagersInit();
		ModManager.PostGameInit();
		initialized = true;
		Scene.Init();
		return loadTask;
	}
	public function UpdateManagerFixed():Void
	{
	}
	public function IsMobile():Bool
	{
		// PORT-NOTE: 对应 C# 中的 `#if UNITY_EDITOR ... #endif` 分支，
		// 移植后不存在 Unity 编辑器构建，故只保留运行平台判断。
		#if (android || ios)
		return true;
		#else
		return false;
		#end
	}
	public function UseMobileLayout():Bool
	{
		if (initialized)
		{
			// PORT-NOTE: C# 中是 IGlobalOptions 的扩展方法（`using MVZ2Logic.Options`），
			// Haxe 扩展方法改为静态调用。
			var screenLayout = LogicOptionExt.GetScreenLayout(OptionsManager);
			if (screenLayout != ScreenLayouts.AUTO)
			{
				return screenLayout == ScreenLayouts.MOBILE;
			}
		}
		return IsMobile();
	}
	public function GetLoadPipeline():Null<TaskPipeline>
	{
		return loadPipeline;
	}
	public function GetInitTask():Null<Task>
	{
		return initTask;
	}
	public function IsFastMode():Bool
	{
		// PORT-NOTE: 对应 C# 中 `#if UNITY_EDITOR return fastMode; #else return false; #endif`。
		// 移植后不存在编辑器构建，故恒定返回 false；fastMode 字段仍保留。
		return false;
	}
	public function InitLoad():Void
	{
		loadPipeline = new TaskPipeline();		loadPipeline.AddTask(new PipelineTask(TASK_LOAD_RESOURCES, function(p:TaskProgress):Task
		{
			var t = ResourceManager.LoadAllModResourcesMain(p);
			FontManager.InitFontSprites();
			return t;
		}));
		loadPipeline.AddTask(new PipelineTask(TASK_LOAD_SPONSORS, function(p:TaskProgress):Task
		{
			// TODO-PORT: SponsorManager.PullSponsors 返回 unity.Task，而本文件（与 mvz2logic 的
			// 异步接口）统一使用 system.threading.tasks.Task；本移植工程同时存在两个 Task shim
			// （13 个文件用 system.threading.tasks.Task，14+ 个用 unity.Task），需全局统一后才能去掉 cast。
			return cast SponsorManager.PullSponsors(p);
		}));

		var task = loadPipeline.Run();
		initTask = task;
		// PORT-NOTE: C# 的 ContinueWith 在 Task shim 中无对应实现，改为同步清理。
		if (task.IsCompleted)
		{
			loadPipeline = null;
			initTask = null;
		}
	}

	// #region 贴图
	public function GetFinalSpriteFromRef(spriteRef:Null<SpriteReference>):Null<Sprite>
	{
		if (!SpriteReference.IsValid(spriteRef))
			return null;
		if (!OptionsManager.HasBloodAndGore())
		{
			var id = spriteRef.ID;
			var censoredId = new NamespaceID(id.SpaceName, '${id.Path}_censored');
			var censoredRef:SpriteReference;
			if (spriteRef.IsSheet)
			{
				censoredRef = SpriteReference.FromSheet(censoredId, spriteRef.Index);
			}
			else
			{
				censoredRef = new SpriteReference(censoredId);
			}
			var sprite = LanguageManager.GetCurrentLanguageSprite(censoredRef);
			if (sprite == null)
				sprite = ResourceManager.GetSpriteFromReference(censoredRef);
			if (sprite != null)
				return sprite;
		}
		var result = LanguageManager.GetCurrentLanguageSprite(spriteRef);
		if (result == null)
			result = ResourceManager.GetSpriteFromReference(spriteRef);
		return result;
	}
	// TODO-PORT: C# 重载 GetFinalSprite(Sprite sprite)，Haxe 不支持重载，重命名以区分。
	public function GetFinalSpriteFromSprite(sprite:Sprite):Sprite
	{
		var spriteID = ResourceManager.GetSpriteReference(sprite);
		if (!SpriteReference.IsValid(spriteID))
			return sprite;
		var result = GetFinalSpriteFromRef(spriteID);
		return result != null ? result : sprite;
	}
	// TODO-PORT: C# 重载 GetFinalSprite(SpriteReference spriteRef, string language)，重命名以区分。
	public function GetFinalSpriteLocalized(spriteRef:SpriteReference, language:String):Null<Sprite>
	{
		if (!OptionsManager.HasBloodAndGore())
		{
			var id = spriteRef.ID;
			var censoredId = new NamespaceID(id.SpaceName, '${id.Path}_censored');
			var censoredRef:SpriteReference;
			if (spriteRef.IsSheet)
			{
				censoredRef = SpriteReference.FromSheet(censoredId, spriteRef.Index);
			}
			else
			{
				censoredRef = new SpriteReference(censoredId);
			}
			var sprite = LanguageManager.GetLocalizedSprite(censoredRef, language);
			if (sprite == null)
				sprite = ResourceManager.GetSpriteFromReference(censoredRef);
			if (sprite != null)
				return sprite;
		}
		var result = LanguageManager.GetLocalizedSprite(spriteRef, language);
		if (result == null)
			result = ResourceManager.GetSpriteFromReference(spriteRef);
		return result;
	}
	// TODO-PORT: C# 重载 GetFinalSprite(Sprite sprite, string language)，重命名以区分。
	public function GetFinalSpriteLocalizedFromSprite(sprite:Sprite, language:String):Sprite
	{
		var spriteID = ResourceManager.GetSpriteReference(sprite);
		if (!SpriteReference.IsValid(spriteID))
			return sprite;
		var result = GetFinalSpriteLocalized(spriteID, language);
		return result != null ? result : sprite;
	}
	// #endregion


	@:allow(mvz2.managers.MainManager)
	private function Awake():Void
	{
		if (Instance == null)
		{
			Instance = this;
		}
		else
		{
			throw new DuplicateInstanceException(name);
		}
	}
	private function OnApplicationQuit():Void
	{
		SaveManager.SaveToFile(); // 退出游戏后，保存。
	}

	private function InitGameSettings():Void
	{
		// TODO-PORT: 以下 4 行是 Unity 平台相关设置，unity shim 尚未提供对应成员
		// （Screen.sleepTimeout / SleepTimeout / Input.simulateMouseWithTouches /
		//   Application.SetStackTraceLogType / StackTraceLogType）。语义保留在此，待 shim 补齐后启用：
		//   Screen.sleepTimeout = SleepTimeout.NeverSleep;
		//   Input.simulateMouseWithTouches = false;
		//   Application.SetStackTraceLogType(LogType.Log, StackTraceLogType.None);
		//   Application.SetStackTraceLogType(LogType.Warning, StackTraceLogType.ScriptOnly);
		//   Application.SetStackTraceLogType(LogType.Error, StackTraceLogType.Full);
		TaskScheduler.UnobservedTaskException = TaskScheduler_UnobservedTaskException;

		Game = new GlobalGame(this);
		Global.InitGame(Game);
		ModelFactories.SetFactory(new ModelFactory());

		// PORT-NOTE: C# 用反射取程序集里全部类型并注册属性映射表
		// （Assets/Scripts/MVZ2/Managers/MainManager.cs:222~224：
		//   `var levelEngineAssembly = typeof(LevelEngine).Assembly;`
		//   `PropertyMapper.InitPropertyMaps(BuiltinNamespace, levelEngineAssembly.GetTypes());`）。
		// Haxe 侧由 system.reflection.Assembly 从编译期注册表作答，
		// 因此这里传 PVZEngine.Level 程序集的类型（8 个 Engine*Props），语义与 C# 一致。
		// PORT-NOTE: 原实现传 `[]`，导致这 8 个 Engine*Props 的属性键恒为 0（见 tools_build/registry_macro_findings.md §1.2）。
		PropertyMapper.InitPropertyMaps(BuiltinNamespace,
			system.reflection.Assembly.GetAssembly(pvzengine.level.LevelEngine).GetTypes());

		// PORT-NOTE: C# 是对象初始化器 `Global.Init(new GlobalParams { ... })`；
		// Haxe 的 GlobalParams 是普通类（非 @:structInit），必须逐字段赋值。
		var globalParams = new GlobalParams();
		globalParams.models = new GlobalModels(this);
		globalParams.almanac = new GlobalAlmanac(this);
		globalParams.saveData = SaveManager;
		globalParams.options = OptionsManager;
		globalParams.input = InputManager;
		globalParams.level = LevelManager;
		globalParams.music = MusicManager;
		globalParams.gui = new GlobalGUI(this);
		globalParams.scene = Scene;
		globalParams.localization = LanguageManager;
		globalParams.debug = DebugManager;
		globalParams.cursors = CursorManager;
		Global.Init(globalParams);
	}
	private function InitSerializable():Void
	{
		SerializeHelper.init(BuiltinNamespace);
		// MVZ2
		SerializeHelper.RegisterClass(SerializableUserDataList);
		SerializeHelper.RegisterClass(SerializableSaveDataMeta);
		SerializeHelper.RegisterClass(SerializableAdviceComponent);
		SerializeHelper.RegisterClass(SerializableArtifactComponent);
		SerializeHelper.RegisterClass(SerializableLightComponent);
		SerializeHelper.RegisterClass(SerializableUIComponent);
		SerializeHelper.RegisterClass(SerializableSoundComponent);
		SerializeHelper.RegisterClass(SerializableBlueprintComponent);
		SerializeHelper.RegisterClass(EmptySerializableLevelComponent);

		SerializeHelper.RegisterClass(SerializableLevelControllerPart);
		SerializeHelper.RegisterClass(SerializableLevelBlueprintController);
		SerializeHelper.RegisterClass(SerializableLevelBlueprintChooseController);

		SerializeHelper.RegisterClass(SerializableBlueprintController);
		SerializeHelper.RegisterClass(SerializableClassicBlueprintController);
		SerializeHelper.RegisterClass(SerializableConveyorBlueprintController);

		SerializeHelper.RegisterClass(SerializableModelData);
		SerializeHelper.RegisterClass(SerializableSpriteModelData);
		SerializeHelper.RegisterClass(SerializableUIModelData);
		SerializeHelper.RegisterClass(SerializableAreaModelData);

		SerializeHelper.RegisterClass(SerializableModelGroup);
		SerializeHelper.RegisterClass(SerializableModelGroupArea);
		SerializeHelper.RegisterClass(SerializableModelGroupEntity);
		SerializeHelper.RegisterClass(SerializableModelGroupUI);

		SerializeHelper.RegisterClass(SerializableGraphicElement);
		SerializeHelper.RegisterClass(SerializableRendererElement);
		SerializeHelper.RegisterClass(SerializableImageElement);

		SerializeHelper.RegisterClass(SerializableUnityCollisionSystem);
		SerializeHelper.RegisterClass(SerializableUnityCollisionEntity);
		SerializeHelper.RegisterClass(SerializableUnityEntityCollider);
	}
	private function LogInformations():Void
	{
		var sb = new StringBuf();
		sb.add('游戏已启动。\n');
		sb.add('应用程序信息：\n');
		sb.add('platform: ${Application.platform}\n');
		sb.add('version: ${Application.version}\n');
		// TODO-PORT: unity.Application.systemLanguage（Unity 的 SystemLanguage 枚举）在 unity shim 中缺失，
		// 这里退化为 Haxe 的 Sys.systemName()（操作系统名）。待 shim 补齐后改回 Application.systemLanguage。
		sb.add('systemLanguage: ${Sys.systemName()}\n');

		Debug.Log(sb.toString());
	}
	private function LoadManagersInit():Task
	{
		GraphicsManager.Init();
		FontManager.Init();
			BootTrace.step("LoadManagersInit: FontManager 完成");
		InputManager.InitKeys();
			BootTrace.step("LoadManagersInit: InputManager 完成");
		OptionsManager.InitOptions();
			BootTrace.step("LoadManagersInit: OptionsManager 完成");

		// PORT-NOTE: C# 此处为 `await ModManager.LoadModInfos(Game);` 等异步等待链，
		// Haxe 侧 Task shim 不支持等待，改为顺序同步调用。
		// TODO-PORT: ModManager.LoadModInfos 返回 unity.Task，与本文件的 system.threading.tasks.Task 不是同一类型，
		// 待全局统一 Task shim 后去掉 cast。
		var task:Task = cast ModManager.LoadModInfos(Game);
			BootTrace.step("LoadManagersInit: ModManager.LoadModInfos 完成");

		// 在MOD信息加载之后
		ResourceManager.Init();
			BootTrace.step("LoadManagersInit: ResourceManager 完成");
		LanguageManager.InitLanguagePacks();
			BootTrace.step("LoadManagersInit: LanguageManager 完成");

		// 在MOD资源加载之后
		ModManager.InitModLogics(Game);
			BootTrace.step("LoadManagersInit: InitModLogics 完成");
		ModManager.LoadModLogics(Game);
			BootTrace.step("LoadManagersInit: LoadModLogics 完成");
		ModManager.PostReloadMods(Game);
			BootTrace.step("LoadManagersInit: PostReloadMods 完成");
		OptionsManager.LoadOptions();
			BootTrace.step("LoadManagersInit: LoadOptions 完成");

		// 在MOD逻辑加载之后
		SaveManager.Load();
			BootTrace.step("LoadManagersInit: SaveManager.Load 完成");
		DebugManager.LoadCommandParameterSuggestions();
		return task;
	}
	private function TaskScheduler_UnobservedTaskException(e:UnobservedTaskExceptionEventArgs):Void
	{
		if (e.Exception == null)
		{
			Debug.LogError(e);
			return;
		}
		if (e.Exception.InnerException != null)
		{
			Debug.LogError(e.Exception.InnerException);
			return;
		}
		if (e.Exception.InnerExceptions != null)
		{
			for (exception in e.Exception.InnerExceptions)
			{
				Debug.LogError(exception);
			}
			return;
		}
		Debug.LogError(e.Exception);
	}

	@:translateMsg("初始化任务名称")
	public static inline var TASK_LOAD_RESOURCES:String = "加载中……";
	@:translateMsg("初始化任务名称")
	public static inline var TASK_LOAD_SPONSORS:String = "获取赞助者列表……";
	public static var Instance(default, null):MainManager = null;
	public var Game(default, null):GlobalGame = null;
	public var BuiltinNamespace(get, never):String;
	function get_BuiltinNamespace():String return builtinNamespace;
	public var CoroutineManager(get, never):mvz2.managers.CoroutineManager;
	function get_CoroutineManager():mvz2.managers.CoroutineManager return coroutine;
	public var ResourceManager(get, never):ResourceManager;
	function get_ResourceManager():ResourceManager return resource;
	public var ModelManager(get, never):ModelManager;
	function get_ModelManager():ModelManager return model;
	public var SoundManager(get, never):SoundManager;
	function get_SoundManager():SoundManager return sound;
	public var MusicManager(get, never):MusicManager;
	function get_MusicManager():MusicManager return music;
	public var LevelManager(get, never):mvz2.level.LevelManager;
	function get_LevelManager():mvz2.level.LevelManager return level;
	public var LanguageManager(get, never):LanguageManager;
	function get_LanguageManager():LanguageManager return lang;
	public var SaveManager(get, never):SaveManager;
	function get_SaveManager():SaveManager return save;
	public var ModManager(get, never):ModManager;
	function get_ModManager():ModManager return mod;
	public var CursorManager(get, never):mvz2.cursors.CursorManager;
	function get_CursorManager():mvz2.cursors.CursorManager return cursor;
	public var ShakeManager(get, never):ShakeManager;
	function get_ShakeManager():ShakeManager return shake;
	public var FileManager(get, never):FileManager;
	function get_FileManager():FileManager return file;
	public var FontManager(get, never):FontManager;
	function get_FontManager():FontManager return fontManager;
	public var OptionsManager(get, never):OptionsManager;
	function get_OptionsManager():OptionsManager return options;
	public var ResolutionManager(get, never):ResolutionManager;
	function get_ResolutionManager():ResolutionManager return resolution;
	public var SceneManager(get, never):SceneLoadingManager;
	function get_SceneManager():SceneLoadingManager return sceneLoadingManager;
	public var AlmanacManager(get, never):AlmanacManager;
	function get_AlmanacManager():AlmanacManager return almanacManager;
	public var StoreManager(get, never):StoreManager;
	function get_StoreManager():StoreManager return storeManager;
	public var InputManager(get, never):InputManager;
	function get_InputManager():InputManager return inputManager;
	public var SponsorManager(get, never):SponsorManager;
	function get_SponsorManager():SponsorManager return sponsorManager;
	public var GraphicsManager(get, never):GraphicsManager;
	function get_GraphicsManager():GraphicsManager return graphicsManager;
	public var DebugManager(get, never):DebugManager;
	function get_DebugManager():DebugManager return debugManager;
	public var Scene(get, never):MainSceneController;
	function get_Scene():MainSceneController return scene;
	public var PerformanceManager(get, never):PerformanceManager;
	function get_PerformanceManager():PerformanceManager return performanceManager;
	public var TalkManager(get, never):TalkManager;
	function get_TalkManager():TalkManager return talkManager;

	private var initTask:Null<Task>;
	private var loadPipeline:Null<TaskPipeline>;
	private var initialized:Bool = false;

	@:serializeField
	private var builtinNamespace:String = "mvz2";
	@:serializeField
	private var fastMode:Bool;
	@:serializeField
	private var coroutine:CoroutineManager = null;
	@:serializeField
	private var resource:ResourceManager = null;
	@:serializeField
	private var model:ModelManager = null;
	@:serializeField
	private var sound:SoundManager = null;
	@:serializeField
	private var music:MusicManager = null;
	@:serializeField
	private var level:mvz2.level.LevelManager = null;
	@:serializeField
	private var lang:LanguageManager = null;
	@:serializeField
	private var save:SaveManager = null;
	@:serializeField
	private var mod:ModManager = null;
	@:serializeField
	private var cursor:mvz2.cursors.CursorManager = null;
	@:serializeField
	private var shake:ShakeManager = null;
	@:serializeField
	private var file:FileManager = null;
	@:serializeField
	private var fontManager:FontManager = null;
	@:serializeField
	private var options:OptionsManager = null;
	@:serializeField
	private var resolution:ResolutionManager = null;
	@:serializeField
	private var sceneLoadingManager:SceneLoadingManager = null;
	@:serializeField
	private var almanacManager:AlmanacManager = null;
	@:serializeField
	private var storeManager:StoreManager = null;
	@:serializeField
	private var inputManager:InputManager = null;
	@:serializeField
	private var sponsorManager:SponsorManager = null;
	@:serializeField
	private var graphicsManager:GraphicsManager = null;
	@:serializeField
	private var debugManager:DebugManager = null;
	@:serializeField
	private var performanceManager:PerformanceManager = null;
	@:serializeField
	private var talkManager:TalkManager = null;
	@:serializeField
	private var scene:MainSceneController = null;
}

enum abstract PlatformMode(Int) from Int to Int
{
	var Default = 0;
	var Mobile = 1;
	var Standalone = 2;
}

class DuplicateInstanceException extends haxe.Exception
{
	public function new(?message:String)
	{
		super(message != null ? message : "");
	}
	public static function fromName(instanceName:String):DuplicateInstanceException
	{
		return new DuplicateInstanceException('There\'s already an instance of $instanceName in the game.');
	}
}

class TaskPipeline
{
	// PORT-NOTE: Haxe 不会为没有显式构造函数的类生成默认构造函数，`new TaskPipeline()` 需要它。
	public function new() {}
	public function Run():Task
	{
		SetCurrentTask(0);
		for (i in 0...tasks.length)
		{
			var task = tasks[i];
			task.Run();
			SetCurrentTask(i + 1);
		}
		var t = new Task();
		t.SetCompleted();
		return t;
	}
	public function AddTask(child:PipelineTask):Void
	{
		tasks.push(child);
	}
	public function RemoveTask(child:PipelineTask):Void
	{
		tasks.remove(child);
	}
	public function SetCurrentTask(index:Int):Void
	{
		currentTaskIndex = index;
	}
	public function IsFinished():Bool
	{
		return currentTaskIndex >= tasks.length;
	}
	public function GetCurrentTaskName():String
	{
		var task = GetCurrentTask();
		if (task == null)
			return "";
		return task.GetName();
	}
	public function GetCurrentProgressName():Null<String>
	{
		var task = GetCurrentTask();
		if (task == null)
			return "";
		return task.GetProgressName();
	}
	public function GetProgress():Float
	{
		if (tasks.length > 0)
		{
			var sum = 0.0;
			for (c in tasks)
				sum += c.GetProgress();
			return sum / tasks.length;
		}
		return 1;
	}
	private function GetCurrentTask():Null<PipelineTask>
	{
		if (currentTaskIndex < 0 || currentTaskIndex >= tasks.length)
			return null;
		return tasks[currentTaskIndex];
	}
	private var currentTaskIndex:Int;
	private var tasks:Array<PipelineTask> = [];
	private var progress:Float;
}

class PipelineTask
{
	public function new(name:String, action:TaskAction, ?progress:TaskProgress)
	{
		this.name = name;
		this.action = action;
		this.progress = progress != null ? progress : new TaskProgress();
	}
	public function GetProgress():Float
	{
		return progress.GetProgress();
	}
	public function Run():Task
	{
		if (action == null)
			return Task.CompletedTask;
		return action(this.progress);
	}
	public function GetName():String
	{
		return name;
	}
	public function GetProgressName():Null<String>
	{
		return progress.GetCurrentTaskName();
	}
	private var name:String;
	private var progress:TaskProgress;
	private var action:TaskAction;
}

class TaskProgress
{
	public function new()
	{
	}
	public function AddChild():TaskProgress
	{
		var progress = new TaskProgress();
		children.push(progress);
		return progress;
	}
	public function AddChildren(count:Int):Array<TaskProgress>
	{
		var array = new Array<TaskProgress>();
		array.resize(count);
		for (i in 0...count)
		{
			array[i] = AddChild();
		}
		return array;
	}
	public function GetProgress():Float
	{
		if (children.length > 0)
		{
			var sum = 0.0;
			for (c in children)
				sum += c.GetProgress();
			return sum / children.length;
		}
		return progress;
	}
	public function SetProgress(progress:Float, ?taskName:String):Void
	{
		this.progress = progress;
		if (taskName != null)
			SetCurrentTaskName(taskName);
	}
	public function GetCurrentTaskName():Null<String>
	{
		if (children.length > 0)
		{
			var name:String = null;
			for (c in children)
			{
				if (c.progress < 1)
				{
					var n = c.GetCurrentTaskName();
					if (n != null && n != "")
					{
						name = n;
						break;
					}
				}
			}
			if (taskName != null && taskName != "")
			{
				if (name == null || name == "")
					return '${taskName}/';
				else
					return '${taskName}/${name}';
			}
			else
			{
				if (name == null || name == "")
					return "";
				else
					return name;
			}
		}
		return taskName;
	}
	public function SetCurrentTaskName(name:String):Void
	{
		this.taskName = name;
	}
	private var progress:Float;
	private var taskName:Null<String>;
	private var children:Array<TaskProgress> = [];
}

// PORT-NOTE: System.Threading.Tasks.TaskScheduler / UnobservedTaskExceptionEventArgs /
// AggregateException 在移植层没有 shim（全仓库只有本文件使用，见 C# MainManager.cs
// 的 `TaskScheduler.UnobservedTaskException += ...`），此处按最小实现补在模块内。
class TaskScheduler
{
	public static var UnobservedTaskException:UnobservedTaskExceptionEventArgs->Void = null;
}

class UnobservedTaskExceptionEventArgs
{
	public var Exception:AggregateException;
	public function new(?exception:AggregateException)
	{
		Exception = exception;
	}
}

class AggregateException
{
	public var InnerException:Dynamic;
	public var InnerExceptions:Array<Dynamic>;
	public function new(?innerException:Dynamic, ?innerExceptions:Array<Dynamic>)
	{
		InnerException = innerException;
		InnerExceptions = innerExceptions;
	}
}
