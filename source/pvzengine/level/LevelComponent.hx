// Ported from: Assets/Scripts/Engine/Level/Level/LevelComponent.cs (abstract class LevelComponent)
// PORT-NOTE: 同文件中的接口 ILevelComponent 已按既有调用点的 import 形式拆到
//   pvzengine/level/ILevelComponent.hx（见该文件的说明），本模块只保留抽象类。
package pvzengine.level;

import pvzengine.NamespaceID;

// PORT-NOTE: C# `abstract class LevelComponent`。Haxe 的 `abstract` 关键字语义不同（编译期抽象类型），
// 按 PORTING.md 仍写作普通 class，抽象方法用 throw 占位。
class LevelComponent implements ILevelComponent
{
	public function new(level:LevelEngine, id:NamespaceID)
	{
		Level = level;
		this.id = id;
	}
	public function PostAttach(level:LevelEngine):Void {}
	public function PostDetach(level:LevelEngine):Void {}
	public function OnStart():Void {}
	public function Update():Void {}
	public function ToSerializable():ISerializableLevelComponent
	{
		// abstract
		throw 'abstract';
	}
	public function InitFromSerializable(seri:ISerializableLevelComponent):Void
	{
		// abstract
		throw 'abstract';
	}
	public function LoadFromSerializable(seri:ISerializableLevelComponent):Void
	{
		// abstract
		throw 'abstract';
	}

	public function GetID():NamespaceID return id;
	public var Level(default, null):LevelEngine;
	private var id:NamespaceID;
}
