// Ported from: Assets/Scripts/Engine/Level/Level/LevelComponent.cs (interface ILevelComponent)
// PORT-NOTE: C# 把 ILevelComponent 与 LevelComponent 放在同一个文件里；但既有上层调用点以
//   `import pvzengine.level.ILevelComponent;`（mvz2/level/components/UnityLevelComponent.hx、
//   mvz2logic/level/components/ComponentInterfaces.hx）按包路径直接引用该接口，Haxe 无法解析
//   模块子类型的包路径写法，故按移植层既有做法（同 pvzengine/level/ILevelSourceTarget.hx）
//   把接口拆分为独立模块；LevelComponent 仍在 LevelComponent.hx 中。
package pvzengine.level;

import pvzengine.NamespaceID;

interface ILevelComponent
{
	function GetID():NamespaceID;
	function PostAttach(level:LevelEngine):Void;
	function PostDetach(level:LevelEngine):Void;
	function OnStart():Void;
	function Update():Void;
	function ToSerializable():ISerializableLevelComponent;
	function InitFromSerializable(seri:ISerializableLevelComponent):Void;
	function LoadFromSerializable(seri:ISerializableLevelComponent):Void;
}
