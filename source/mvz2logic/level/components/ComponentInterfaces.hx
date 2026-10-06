// Ported from: Assets/Scripts/Logic/Level/ComponentInterfaces.cs
package mvz2logic.level.components;

import haxe.Int64;
import mvz2logic.artifacts.Artifact;
import mvz2logic.artifacts.ArtifactDefinition;
import mvz2logic.helditems.IHeldItemBuilder;
import mvz2logic.helditems.IHeldItemData;
import mvz2logic.talk.ITalkController;
import pvzengine.NamespaceID;
import pvzengine.entities.Entity;
import pvzengine.level.ILevelComponent;
import pvzengine.models.IModelInterface;
import system.threading.tasks.Task;
import unity.Vector2;
import unity.Vector3;

interface IAdviceComponent extends ILevelComponent
{
	function ShowAdvice(context:String, textKey:String, priority:Int, timeout:Int, args:Array<String>):Void;
	function ShowAdvicePlural(context:String, textKey:String, textPlural:String, n:Int64, priority:Int, timeout:Int, args:Array<String>):Void;
	// TODO-PORT: C# 接口还有一个带默认实现的重载 ShowAdvicePlural(context, textKey, n, priority, timeout, args)
	// （转发为 textPlural = textKey），Haxe 接口不支持默认方法与方法重载，故省略。
	function HideAdvice():Void;
}

interface IAreaComponent extends ILevelComponent
{
	function GetAreaModelInterface():IModelInterface;
}

interface IHeldItemComponent extends ILevelComponent
{
	function SetHeldItem(builder:IHeldItemBuilder):Void;
	function ResetHeldItem():Void;
	function CancelHeldItem():Bool;
	function GetHeldItemModelInterface():Null<IModelInterface>;
	var Data(get, never):IHeldItemData;
}

interface ILogicComponent extends ILevelComponent
{
	function BeginLevel():Void;
	function StopLevel():Void;
	function SaveStateData():Void;
	function ReloadLevel():Task;
	function IsGamePaused():Bool;
	function IsGameStarted():Bool;
	function IsGameOver():Bool;
	function IsGameRunning():Bool;
}

interface IMusicComponent extends ILevelComponent
{
	function Play(id:NamespaceID):Void;
	function Stop():Void;
	function IsPlayingMusic(id:NamespaceID):Bool;
	function SetPlayingMusic(id:NamespaceID):Void;
	function GetMusicVolume():Float;
	function SetMusicVolume(volume:Float):Void;
	function GetSubtrackWeight():Float;
	function SetSubtrackWeight(volume:Float):Void;
}

interface ISoundComponent extends ILevelComponent
{
	function PlaySoundAt(id:NamespaceID, position:Vector3, pitch:Float = 1, volume:Float = 1):Void; // TODO-PORT: C# 中名为 PlaySound 的重载之一，Haxe 不支持重载
	function PlaySound(id:NamespaceID, pitch:Float = 1, volume:Float = 1):Void;
	function StopAllLoopSounds():Void;
	function IsPlayingSound(id:NamespaceID):Bool;
	function IsPlayingLoopSound(id:NamespaceID):Bool;
	function HasLoopSoundEntity(id:NamespaceID, entityId:Int64):Bool;
	function AddLoopSoundEntity(id:NamespaceID, entityId:Int64):Bool;
	function RemoveLoopSoundEntity(id:NamespaceID, entityId:Int64):Bool;
	function HasLoopSoundEntities(id:NamespaceID):Bool;
	function GetLoopSounds():Array<NamespaceID>;
}

interface ITalkComponent extends ILevelComponent extends ITalkController
{
}

interface IBlueprintComponent extends ILevelComponent
{
	function SetConveyorMode(value:Bool):Void;
	function IsConveyorMode():Bool;
}

interface IUIComponent extends ILevelComponent
{
	function ScreenToLawnPositionByY(screenPosition:Vector2, y:Float):Vector3;
	function ScreenToLawnPositionByZ(screenPosition:Vector2, y:Float):Vector3;
	function ScreenToLawnPositionByRelativeY(screenPosition:Vector2, relativeY:Float):Vector3;
	function ShakeScreen(startAmplitude:Float, endAmplitude:Float, time:Int):Void;

	function ShowMoney():Void;
	function SetMoneyFade(fade:Bool):Void;

	function SetEnergyActive(visible:Bool):Void;
	function IsEnergyActive():Bool;
	function SetBlueprintsActive(visible:Bool):Void;
	function AreBlueprintsActive():Bool;
	function SetPickaxeActive(visible:Bool):Void;
	function IsPickaxeActive():Bool;
	function SetStarshardActive(visible:Bool):Void;
	function IsStarshardActive():Bool;
	function SetTriggerActive(visible:Bool):Void;
	function IsTriggerActive():Bool;

	function SetHintArrowPointToBlueprint(index:Int):Void;
	function SetHintArrowPointToPickaxe():Void;
	function SetHintArrowPointToTrigger():Void;
	function SetHintArrowPointToStarshard():Void;
	function SetHintArrowPointToEntity(entity:Entity):Void;
	function HideHintArrow():Void;

	function SetProgressBarToBoss(barStyle:NamespaceID):Void;
	function SetProgressBarToStage():Void;

	function PauseGame(level:Int = 0):Void;
	function ResumeGame(level:Int = 0):Void;
	function ResumeGameDelayed(level:Int = 0):Void;

	function SetUIAndInputDisabled(value:Bool):Void;
	function ShowDialog(title:String, desc:String, options:Array<String>, ?onSelect:Int->Void):Void;
	function SetAreaModelPreset(name:String):Void;

	function TriggerModelAnimator(name:String):Void;
	function SetModelAnimatorBool(name:String, value:Bool):Void;
	function SetModelAnimatorInt(name:String, value:Int):Void;
	function SetModelAnimatorFloat(name:String, value:Float):Void;

	function UpdateLevelName():Void;
	function FlickerEnergy():Void;
}

interface IMoneyComponent extends ILevelComponent
{
	function AddMoney(value:Int):Void;
	function GetMoney():Int;
	function GetDelayedMoney():Int;
	function AddDelayedMoney(entity:Entity, value:Int):Void;
	function RemoveDelayedMoney(entity:Entity):Bool;
	function ClearDelayedMoney():Void;
}

interface ILightComponent extends ILevelComponent
{
	function IsIlluminated(entity:Entity):Bool;
	function IsIlluminatedBy(entity:Entity, lightSourceID:Int64):Bool;
	function GetIlluminationLightSources(entity:Entity):Array<Int64>;
	function GetIlluminationLightSourcesNonAlloc(entity:Entity, results:Map<Int64, Bool>):Void;
	function GetIlluminatingEntities(lightSourceID:Int64):Array<Int64>;
	function GetIlluminatingEntitiesNonAlloc(lightSourceID:Int64, results:Map<Int64, Bool>):Void;
	function GetIlluminationCount(lightSourceID:Int64):Int;
}

interface IArtifactComponent extends ILevelComponent
{
	function SetSlotCount(count:Int):Void;
	function GetSlotCount():Int;
	function ReplaceArtifacts(definitions:Null<Array<Null<ArtifactDefinition>>>):Void;
	function ReplaceArtifact(slot:Int, definition:Null<ArtifactDefinition>):Void;
	function SetArtifact(slot:Int, artifact:Null<Artifact>):Void;
	function GetArtifacts():Array<Null<Artifact>>;
	function HasArtifact(artifactID:NamespaceID):Bool;
	function GetArtifactIndexByID(artifactID:NamespaceID):Int; // TODO-PORT: C# 重载 GetArtifactIndex(NamespaceID)，Haxe 不支持重载
	function GetArtifactIndex(artifact:Artifact):Int;
	function GetArtifactAt(index:Int):Null<Artifact>;
}
