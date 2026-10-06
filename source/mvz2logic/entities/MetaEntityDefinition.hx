// Ported from: Assets/Scripts/Logic/Entities/MetaEntityDefinition.cs
package mvz2logic.entities;

import pvzengine.entities.EntityDefinition;

class MetaEntityDefinition extends EntityDefinition
{
	public function new(type:Int, nsp:String, name:String)
	{
		super(nsp, name);
		this.type = type;
	}
	// PORT-NOTE: C# 的 `public override int Type => type;` 映射为覆盖只读属性的 getter。
	override function get_Type():Int return type;
	private var type:Int;
}
