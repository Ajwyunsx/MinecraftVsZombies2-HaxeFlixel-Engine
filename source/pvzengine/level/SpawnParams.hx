// Ported from: Assets/Scripts/Engine/Level/Entities/SpawnParams.cs
// PORT-NOTE: 该 C# 文件位于 Level/Entities/ 目录，但其 namespace 为 PVZEngine.Level，
//   按「包名以 namespace 为准」的规则放在 pvzengine/level/ 下；
//   既有调用点也大量以 `import pvzengine.entities.SpawnParams;` 引用，故在
//   pvzengine/entities/SpawnParams.hx 提供同名 typedef 别名。
package pvzengine.level;

import pvzengine.IPropertyKey;
import pvzengine.PropertyDictionary;
import pvzengine.PropertyKey;
import pvzengine.entities.Entity;

class SpawnParams
{
	public function new() {}

	public function SetProperty<T>(key:PropertyKey<T>, value:Null<T>):Void
	{
		properties.SetProperty(key, value);
	}
	public function SetPropertyObject(key:IPropertyKey, value:Dynamic):Void
	{
		properties.SetPropertyObject(key, value);
	}
	public function Apply(entity:Entity):Void
	{
		if (EntityParent != null)
		{
			entity.SetParent(EntityParent);
		}
		for (property in properties.GetPropertyNames())
		{
			entity.SetPropertyObject(property, properties.GetPropertyObject(property));
		}
		if (OnApply != null)
		{
			OnApply(entity);
		}
	}
	// PORT-NOTE: C# `event Action<Entity>? OnApply`。既有调用点写作 `param.OnApply = function(e:Entity) {...}`
	//   （直接赋值，非 +=），故此处保留为可赋值/可调用的函数字段。
	public var OnApply:Null<Entity->Void>;
	public var EntityParent:Null<Entity>;
	private var properties:PropertyDictionary = new PropertyDictionary();
}
