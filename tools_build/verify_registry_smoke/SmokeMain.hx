import system.reflection.Assembly;
import system.reflection.DefinitionRegistry;

class SmokeMain {
	static function main() {
		var all = DefinitionRegistry.getClasses();
		trace('records=' + all.length);
		var names = DefinitionRegistry.getAssemblyNames();
		trace('assemblies=' + names);
		for (n in names) trace('  ' + n + ' -> ' + DefinitionRegistry.getClassesOfAssembly(n).length);
		var vanilla = Assembly.GetAssembly(mvz2.vanilla.VanillaMod);
		trace('VanillaMod assembly=' + vanilla.name);
		var types = vanilla.GetTypes();
		trace('vanilla types=' + types.length);
		var logic = Assembly.GetAssembly(mvz2logic.LogicMain);
		trace('LogicMain assembly=' + logic.name + ' types=' + logic.GetTypes().length);
		// 关键断言：ArmorEntityBehaviour 必须可被找到
		var found = false;
		for (t in types) if (Type.getClassName(t) == 'mvz2.gamecontent.entities.ArmorEntityBehaviour') found = true;
		trace('ArmorEntityBehaviour found=' + found);
	}
}
