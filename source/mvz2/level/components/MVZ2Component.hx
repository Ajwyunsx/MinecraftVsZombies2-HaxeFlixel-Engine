// Ported from: Assets/Scripts/MVZ2/Level/Components/MVZ2Component.cs
package mvz2.level.components;

import mvz2.level.LevelController;
import mvz2.managers.MainManager;
import pvzengine.NamespaceID;
import pvzengine.level.ISerializableLevelComponent;
import pvzengine.level.LevelComponent;
import pvzengine.level.LevelEngine;
// PORT-NOTE: 以下类型是同包其他模块的次类型，Haxe 需显式从所属模块导入。
import mvz2.level.components.HeldItemComponent.EmptySerializableLevelComponent;
import Main;

interface IMVZ2LevelComponent
{
	public function PostLevelLoad():Void;
	public function UpdateFrame(deltaTime:Float, simulationSpeed:Float):Void;
	public function PostDispose():Void;
}

// PORT-NOTE: C# 的 abstract class 在 Haxe 中语义不同（abstract 是编译期的抽象类型）。
// 这里仍写作普通 class，抽象方法以空实现 + 注释标注。
class MVZ2Component extends LevelComponent implements IMVZ2LevelComponent
{
	public function new(level:LevelEngine, id:NamespaceID, controller:LevelController)
	{
		super(level, id);
		Controller = controller;
	}
	override public function ToSerializable():ISerializableLevelComponent
	{
		return new EmptySerializableLevelComponent();
	}
	override public function InitFromSerializable(seri:ISerializableLevelComponent):Void
	{
	}
	override public function LoadFromSerializable(seri:ISerializableLevelComponent):Void
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
	public var Main(get, never):MainManager;
	function get_Main():MainManager return MainManager.Instance;
	public var Controller(default, null):LevelController;
}
