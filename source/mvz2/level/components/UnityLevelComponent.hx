// Ported from: Assets/Scripts/MVZ2/Level/Components/UnityLevelComponent.cs
package mvz2.level.components;

import mvz2.level.LevelController;
import pvzengine.NamespaceID;
import pvzengine.NamespaceIDReference;
import pvzengine.level.ISerializableLevelComponent;
import pvzengine.level.ILevelComponent;
import pvzengine.level.LevelEngine;
import unity.*;
import unity.Debug;
// PORT-NOTE: 以下类型是同包其他模块的次类型，Haxe 需显式从所属模块导入。
import mvz2.level.components.HeldItemComponent.EmptySerializableLevelComponent;
import mvz2.level.components.MVZ2Component.IMVZ2LevelComponent;

// PORT-NOTE: C# 的 abstract class 在 Haxe 中语义不同（abstract 是编译期的抽象类型）。
class UnityLevelComponent extends MonoBehaviour implements ILevelComponent implements IMVZ2LevelComponent
{
	public function PostAttach(level:LevelEngine):Void {}
	public function PostDetach(level:LevelEngine):Void {}
	public function ToSerializable():ISerializableLevelComponent
	{
		return new EmptySerializableLevelComponent();
	}
	public function InitFromSerializable(seri:ISerializableLevelComponent):Void
	{
	}
	public function LoadFromSerializable(seri:ISerializableLevelComponent):Void
	{
	}
	public function OnStart():Void
	{
	}
	public function OnUpdate():Void
	{
	}
	public function PostLevelLoad():Void
	{
	}
	public function PostDispose():Void
	{
	}
	public function UpdateFrame(deltaTime:Float, simulationSpeed:Float):Void
	{
	}
	public function Update():Void OnUpdate();
	public function GetID():NamespaceID
	{
		return id.Get();
	}
	public var Level(get, never):LevelEngine;
	function get_Level():LevelEngine return Controller.GetEngine();
	public var Controller(get, never):LevelController;
	function get_Controller():LevelController return levelController;
	@:serializeField
	private var levelController:LevelController = null;
	@:serializeField
	private var id:NamespaceIDReference = null;
}
