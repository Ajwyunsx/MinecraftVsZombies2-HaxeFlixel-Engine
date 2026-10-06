// 集成验证探针：确认 EntityPhysicsBehaviour 的 GetDefinitionType() 与注册分组。
//
// 背景：`Cannot find entity behaviour with ID mvz2:entity_physics` 曾在 16:55 的产物里出现 310 条，
// 17:30 的产物里 0 条。本探针直接实例化该类，确认它到底被 DefinitionGroup 分到哪一组
// （C#/Haxe 都是按 `GetDefinitionType()` 分组，不是按 attribute 声明的 Type）。
import mvz2.gamecontent.entities.EntityPhysicsBuff.EntityPhysicsBehaviour;
import pvzengine.DefinitionGroup;
import pvzengine.base.Definition;

class EntityPhysicsProbe {
	static function main() {
		var inst = new EntityPhysicsBehaviour("mvz2", "entity_physics");
		trace('id=${inst.GetID()} definitionType=${inst.GetDefinitionType()}');
		var group = new DefinitionGroup();
		group.Add(cast inst);
		var asBehaviour = group.GetDefinition("entity_behaviour", inst.GetID());
		var asBuff = group.GetDefinition("buff", inst.GetID());
		trace('查 entity_behaviour -> ${asBehaviour == null ? "null" : Type.getClassName(Type.getClass(asBehaviour))}');
		trace('查 buff            -> ${asBuff == null ? "null" : Type.getClassName(Type.getClass(asBuff))}');
	}
}
