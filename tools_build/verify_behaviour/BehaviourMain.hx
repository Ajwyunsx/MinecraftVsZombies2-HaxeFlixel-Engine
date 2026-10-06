// 工作包①（实体行为注册链路）自检程序。
//
// 复刻 ModLoader.LoadAssemblies + DefinitionGroup 查询：
//   Assembly.GetAssembly(VanillaMod).GetTypes()
//   → Assembly.GetCustomAttributes(type, "DefinitionAttribute")
//   → Assembly.InvokeConstructor(type, [nsp, name])
//   → Mod.AddDefinition(def)
//   → GetEntityBehaviourDefinition(new NamespaceID(nsp, name))
// 最后一步就是 EntityDefinition.CacheContents 里报
// `Cannot find entity behaviour with ID mvz2:*` 的那次查询。
import system.reflection.Assembly;
import system.reflection.DefinitionRegistry;
import pvzengine.NamespaceID;
import pvzengine.base.Definition;
import pvzengine.entities.EntityBehaviourDefinition;
import pvzengine.definitions.EngineDefinitionTypes;
import mvz2.vanilla.VanillaMod;
import mvz2logic.LogicMain;

class BehaviourMain {
	static function main() {
		var nsp = "mvz2";
		var assemblies = [Assembly.GetAssembly(VanillaMod), Assembly.GetAssembly(LogicMain)];

		var registered:Array<Definition> = [];
		var byID:Map<String, Definition> = new Map();
		var totalTypes = 0;
		var withDefinitionAttr = 0;
		var instantiated = 0;
		var notDefinition = 0;
		var behaviourCount = 0;
		var callbacks = 0;

		for (assembly in assemblies) {
			var types = assembly.GetTypes();
			totalTypes += types.length;
			for (type in types) {
				if (assembly.HasCustomAttribute(type, "ModGlobalCallbacksAttribute") && !assembly.IsAbstract(type))
					callbacks++;
				if (assembly.IsAbstract(type))
					continue;
				for (a in assembly.GetCustomAttributes(type, "DefinitionAttribute")) {
					var name:String = Reflect.field(a, "Name");
					if (name == null)
						continue;
					var inst:Dynamic = assembly.InvokeConstructor(type, [nsp, name]);
					if (inst == null) {
						notDefinition++;
						continue;
					}
					instantiated++;
					if (Std.isOfType(inst, Definition)) {
						var def:Definition = cast inst;
						registered.push(def);
						// PORT-NOTE: 键里带定义类型，避免同名 ID 的不同类型定义互相掩盖
						// （如 entity_physics 在 C# 里注册的是 buff，不是 entity_behaviour）。
						byID.set(Std.string(def.GetID()) + '|' + def.GetDefinitionType(), def);
						if (Std.isOfType(def, EntityBehaviourDefinition))
							behaviourCount++;
					} else {
						notDefinition++;
					}
				}
			}
		}
		withDefinitionAttr = registered.length;

		trace('types=$totalTypes 带DefinitionAttribute的类型=$withDefinitionAttr '
			+ '实例化成功=$instantiated 非Definition=$notDefinition 其中behaviour=$behaviourCount callbacks=$callbacks');

		// 关键：复刻 EntityDefinition.CacheContents 的按 ID 查询。
		var probes = ["armor_entity", "entity_physics", "timeout_remove", "fadeout_by_timeout", "boss_common"];
		var found = 0;
		for (p in probes) {
			var id = new NamespaceID(nsp, p);
			var def = byID.get(Std.string(id) + '|' + EngineDefinitionTypes.ENTITY_BEHAVIOUR);
			if (def != null) {
				found++;
				trace('  lookup ${id} -> OK (${Type.getClassName(Type.getClass(def))})');
			} else {
				trace('  lookup ${id} -> MISSING  <-- 会触发 Cannot find entity behaviour 告警');
			}
		}
		trace('probe lookup: $found/${probes.length}');
		trace('DefinitionRegistry 记录数=' + DefinitionRegistry.getClasses().length);
	}
}
