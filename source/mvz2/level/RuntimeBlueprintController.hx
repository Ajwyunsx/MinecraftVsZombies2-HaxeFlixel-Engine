// Ported from: Assets/Scripts/MVZ2/Level/Blueprints/RuntimeBlueprintController.cs
package mvz2.level;

import mvz2.ui.Blueprint;
import mvz2.ui.Blueprint.BlueprintViewData;
import mvz2.ui.Tooltip.TooltipContent;
import mvz2.ui.level.ILevelRaycastReceiver;
import mvz2logic.Global;
// PORT-NOTE: 原 import 写作 mvz2logic.blueprints.LogicBlueprintExt（该类型不存在且未被使用），故删除。
import mvz2logic.games.IGlobalGame;
import mvz2logic.helditems.HeldItemDefinition;
import mvz2logic.helditems.HeldItemTargetBlueprint;
import mvz2logic.helditems.IHeldItemData;
import mvz2logic.inputs.InputHelper;
import mvz2logic.localization.LogicStrings;
import pvzengine.buffs.ModelInsertion;
import pvzengine.level.LevelEngine;
import pvzengine.seedpacks.SeedDefinition;
import pvzengine.seedpacks.SeedPack;
import unity.*;
import unity.Debug;
import unity.eventsystems.PointerEventData;
// PORT-NOTE: 以下类型是同包其他模块的次类型，Haxe 需显式从所属模块导入。
import mvz2.level.BlueprintController.SerializableBlueprintController;
import mvz2.inputs.InputManager;
import mvz2.localization.LanguageManager;
import mvz2.managers.ResourceManager;
import mvz2.options.OptionsManager;
import mvz2.ui.Tooltip;
import pvzengine.base.Definition;
import Main;
// PORT-NOTE: C# 的扩展方法（this 参数形式）在 Haxe 中需显式 using 才能以 `obj.Method()` 调用。
using mvz2logic.blueprints.LogicSeedExt;           // CanPick / CanInstantTrigger / WillInstantEvokeOfPack（SeedPack 版本）
using mvz2logic.blueprints.LogicSeedProps;         // IsTwinkling / IsCommandBlockOfPack（SeedPack 版本）
using mvz2logic.options.LogicOptionExt;            // ShowHotkeyIndicators(this IGlobalOptions)
using mvz2.ui.UIHelper;                            // GetRootCanvas(this RectTransform)

// PORT-NOTE: C# 的 abstract class 在 Haxe 中语义不同（这里仍写作普通 class）。
class RuntimeBlueprintController extends BlueprintController implements ILevelRaycastReceiver
{
	// #region 初始化
	public function Init(controller:ILevelController, ui:Blueprint, index:Int, seedPack:SeedPack):Void
	{
		SeedPack = seedPack;
		ui.gameObject.name = seedPack.GetDefinitionID().toString();
		InitBlueprint(controller, ui, index);
	}
	// #endregion

	// #region 生命周期
	public function UpdateFixed():Void
	{
		var model = GetModel();
		if (model != null)
		{
			model.UpdateFixed();
		}
	}
	public function UpdateFrame(deltaTime:Float):Void
	{
		UpdateView();
		var model = GetModel();
		if (model != null)
		{
			model.UpdateFrame(deltaTime);
			model.UpdateAnimators(deltaTime);
		}
		if (lastIndex != Index)
		{
			lastIndex = Index;
			UpdateHotkeyText();
		}
	}
	override function OnActive():Void
	{
		super.OnActive();
		SeedPack.OnDefinitionChanged.add(OnDefinitionChangedCallback);
		SeedPack.OnModelInsertionAdded.add(OnModelInsertionAddedCallback);
		SeedPack.OnModelInsertionRemoved.add(OnModelInsertionRemovedCallback);

		SeedPack.SetModelInterface(modelInterface);
		UpdateModelInsertions();
	}
	override function OnDeactive():Void
	{
		super.OnDeactive();
		SeedPack.OnDefinitionChanged.remove(OnDefinitionChangedCallback);
		SeedPack.OnModelInsertionAdded.remove(OnModelInsertionAddedCallback);
		SeedPack.OnModelInsertionRemoved.remove(OnModelInsertionRemovedCallback);

		SeedPack.SetModelInterface(null);
	}
	// #endregion

	// #region 模型
	private function UpdateModelInsertions():Void
	{
		var model = GetModel();
		if (model != null)
			model.UpdateModelInsertions(SeedPack.GetModelInsertions());
	}
	// #endregion

	// #region UI
	override public function GetBlueprintViewData():BlueprintViewData
	{
		return Main.ResourceManager.GetBlueprintViewData(SeedPack);
	}
	override public function GetTooltipViewData():TooltipContent
	{
		var viewData = super.GetTooltipViewData();
		viewData.error = GetTooltipErrorMessage();
		return viewData;
	}
	private function GetTooltipErrorMessage():String
	{
		// TODO-PORT: C# 的 `out string? errorMessage` 在 Haxe 中以可选数组参数表达。
		var errors:Array<String> = [];
		if (!CanPick(errors) && errors.length > 0 && !(errors[0] == null || errors[0] == ""))
		{
			return Main.LanguageManager._p(LogicStrings.CONTEXT_BLUEPRINT_ERROR, errors[0]);
		}
		return "";
	}
	// #endregion

	// #region 逻辑
	// TODO-PORT: C# 的 `out string? errorMessage` 在 Haxe 中按本工程约定用可选数组参数表达
	//（错误信息放在 errors[0]，见 GetTooltipErrorMessage）。
	public function CanPick(?outError:Array<String>):Bool
	{
		// PORT-NOTE: C# 重载 CanPick(this SeedPack, out string?) 在 Haxe 中改名为 CanPickWithError，
		// out 参数用 tools.Ref<Null<String>> 表达。
		var errorRef:tools.Ref<Null<String>> = new tools.Ref<Null<String>>(null);
		var result = SeedPack.CanPickWithError(errorRef);
		if (outError != null)
		{
			outError.push(errorRef.value);
		}
		return result;
	}
	public function ShouldBlueprintTwinkle(seedPack:SeedPack):Bool
	{
		if (SeedPack.IsTwinkling())
		{
			return true;
		}
		else if (Level.IsHoldingTrigger() && SeedPack.CanInstantTrigger())
		{
			return true;
		}
		else if (Level.IsHoldingStarshard() && SeedPack.WillInstantEvokeOfPack())
		{
			return true;
		}
		return false;
	}
	// #endregion

	// #region 事件回调
	private function OnDefinitionChangedCallback(seedDef:SeedDefinition):Void
	{
		ui.UpdateView(Main.ResourceManager.GetBlueprintViewData(SeedPack));
	}
	private function OnModelInsertionAddedCallback(insertion:ModelInsertion):Void
	{
		var model = GetModel();
		if (model != null)
			model.AddModelInsertion(insertion);
	}
	private function OnModelInsertionRemovedCallback(insertion:ModelInsertion):Void
	{
		var model = GetModel();
		if (model != null)
			model.RemoveModelInsertion(insertion.key);
	}
	// #endregion

	override public function GetSeedDefinition():SeedDefinition
	{
		return SeedPack.Definition;
	}
	override public function IsCommandBlock():Bool
	{
		return SeedPack.IsCommandBlockOfPack();
	}
	// abstract
	public function IsInConveyor():Bool
	{
		throw "abstract";
	}

	// #region 热键
	public function ForceUpdateBlueprintHotkeyText():Void
	{
		UpdateHotkeyText();
	}
	private function UpdateHotkeyText():Void
	{
		var name = GetHotkeyName();
		ui.SetHotkeyText(name);
	}
	private function GetHotkeyName():String
	{
		if (Global.Game.IsMobile() || !Main.OptionsManager.ShowHotkeyIndicators())
			return "";
		var hotkey = Main.OptionsManager.GetBlueprintKeyBinding(Index);
		return hotkey != KeyCode.None ? Main.InputManager.GetKeyCodeName(hotkey) : "";
	}
	// #endregion

	// #region ILevelRaycastReceiver接口实现
	public function IsValidReceiver(level:LevelEngine, definition:HeldItemDefinition, data:IHeldItemData, eventData:PointerEventData):Bool
	{
		if (definition == null)
			return false;
		if (Index < 0)
			return false;
		var target = new HeldItemTargetBlueprint(level, Index, IsInConveyor());
		var pointer = InputHelper.GetPointerDataFromEventData(eventData);
		return definition.IsValidFor(target, data, pointer);
	}
	public function GetSortingLayer():Int
	{
		var rectTrans = Std.downcast(transform, RectTransform);
		var canvas = rectTrans != null ? rectTrans.GetRootCanvas() : null;
		if (canvas == null)
			return 0;
		return canvas.sortingLayerID;
	}
	public function GetSortingOrder():Int
	{
		var rectTrans = Std.downcast(transform, RectTransform);
		var canvas = rectTrans != null ? rectTrans.GetRootCanvas() : null;
		if (canvas == null)
			return 0;
		return canvas.sortingOrder;
	}
	// #endregion

	// #region 序列化
	public function ToSerializable():SerializableBlueprintController
	{
		var serializable = CreateSerializable();
		var model = GetModel();
		if (model != null)
		{
			serializable.model = model.ToSerializable();
		}
		return serializable;
	}
	public function LoadFromSerializable(serializable:SerializableBlueprintController):Void
	{
		var model = GetModel();
		if (model != null && serializable.model != null)
		{
			model.LoadFromSerializable(serializable.model);
			UpdateModelInsertions();
		}
		LoadSerializable(serializable);
	}
	// abstract
	public function CreateSerializable():SerializableBlueprintController
	{
		throw "abstract";
	}
	public function LoadSerializable(serializable:SerializableBlueprintController):Void { }

	// #endregion

	// #region 属性字段
	public var SeedPack(default, null):SeedPack = null;
	private var lastIndex:Int = -1;
	// #endregion
}
