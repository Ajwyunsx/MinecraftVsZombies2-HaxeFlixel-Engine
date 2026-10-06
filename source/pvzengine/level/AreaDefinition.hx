// Ported from: Assets/Scripts/Engine/Level/Level/AreaDefinition.cs
package pvzengine.level;

import pvzengine.NamespaceID;
import pvzengine.base.Definition;
import pvzengine.definitions.EngineDefinitionTypes;
import pvzengine.modifiers.PropertyModifier;

// PORT-NOTE: 既有上层代码有 8 个文件写 `import pvzengine.definitions.AreaDefinition;`（C# 命名空间实为
// PVZEngine.Level），另有 mvz2logic/level/LogicAreaProps.hx 写 `import pvzengine.level.AreaDefinition;`。
// 正典实现放在 C# 命名空间对应的 pvzengine.level，并在 pvzengine/definitions 下提供同名 typedef 别名，
// 两种 import 均可解析。
// PORT-NOTE: C# 中 EngineAreaProps 的扩展方法由既有调用点以实例形式调用（areaDef.GetAreaTags()），
// 故用 @:using 把 EngineAreaProps 的静态扩展挂到本类上。
@:using(pvzengine.level.EngineAreaProps)
class AreaDefinition extends Definition
{
	public function new(nsp:String, name:String)
	{
		super(nsp, name);
	}
	public function Setup(level:LevelEngine):Void {}
	public function PostLoad(level:LevelEngine):Void {}
	public function SetGridLayout(layout:Array<NamespaceID>):Void
	{
		// C#: grids.Clear(); grids.AddRange(layout);
		grids = [];
		for (item in layout)
		{
			grids.push(item);
		}
	}
	public function GetGridLayout():Array<NamespaceID>
	{
		// C#: grids.ToArray()
		return grids.copy();
	}
	public function PrepareForBattle(level:LevelEngine):Void {}
	public function PostHugeWaveEvent(level:LevelEngine):Void {}
	public function PostFinalWaveEvent(level:LevelEngine):Void {}
	public function Update(level:LevelEngine):Void {}
	public function GetGroundY(level:LevelEngine, x:Float, z:Float):Float return 0;
	public function GetModifiers():Array<PropertyModifier>
	{
		return modifiers.copy();
	}
	// C#: protected void AddModifier(PropertyModifier modifier)
	// PORT-NOTE: Haxe 无 protected，private 对子类可见，语义等价（同 pvzengine.grids.GridDefinition）。
	private function AddModifier(modifier:PropertyModifier):Void
	{
		modifiers.push(modifier);
	}
	public override function GetDefinitionType():String return EngineDefinitionTypes.AREA;
	private var grids:Array<NamespaceID> = [];
	private var modifiers:Array<PropertyModifier> = [];
}
