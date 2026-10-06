// Ported from: Assets/Scripts/Engine/Level/Placements/PlaceMethod.cs (class PlaceOutput)
// PORT-NOTE: 见 PlaceMethod.hx 的说明：PlaceOutput 从 PlaceMethod.cs 拆到独立模块，以便
//   `import pvzengine.placements.PlaceOutput;` 能被解析。
package pvzengine.placements;

import pvzengine.entities.Entity;
import pvzengine.entities.EntityDefinition;

class PlaceOutput
{
	public var entity:Null<Entity>;
	public var placeDefinition:Null<EntityDefinition>;
	public var increaseTakenConveyorSeed:Bool;
	public var isCommandBlock:Bool;
	private var invalid:Bool;

	public function new(entity:Null<Entity>, placeDefinition:Null<EntityDefinition>)
	{
		this.entity = entity;
		this.placeDefinition = placeDefinition;
	}
	public function IsInvalid():Bool
	{
		return invalid;
	}

	// C#: public static readonly PlaceOutput InvalidOutput = new PlaceOutput(null, null) { invalid = true };
	// PORT-NOTE: C# 对象初始化器 → 静态构造辅助方法（Haxe 无对象初始化器语法）。
	public static var InvalidOutput:PlaceOutput = CreateInvalidOutput();

	private static function CreateInvalidOutput():PlaceOutput
	{
		var output = new PlaceOutput(null, null);
		output.invalid = true;
		return output;
	}
}
