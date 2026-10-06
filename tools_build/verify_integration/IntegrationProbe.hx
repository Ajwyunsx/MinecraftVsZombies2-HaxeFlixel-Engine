// 集成验证用探针：复刻 MainManager.Initialize（C# MainManager.cs:222~224）与
// ModLoader.LoadAssemblies（C# ModLoader.cs:57~70）两条属性注册链路，检查属性键是否真的非 0。
//
// C# 原逻辑：
//   MainManager.cs:222~224
//     var levelEngineAssembly = typeof(LevelEngine).Assembly;          // PVZEngine.Level
//     var logicAssembly = typeof(LogicDefinitionTypes).Assembly;       // MVZ2.Logic
//     PropertyMapper.InitPropertyMaps(BuiltinNamespace, levelEngineAssembly.GetTypes());
//   ModLoader.cs:60~64
//     foreach (assembly in assemblies) PropertyMapper.InitPropertyMaps(nsp, assembly.GetTypes());
//   其中 assemblies = [GetAssembly(VanillaMod)=MVZ2.Vanilla, GetAssembly(LogicMain)=MVZ2.Logic]
//
// 运行：haxe -cp source -cp tools_build/verify_integration -lib ... -main IntegrationProbe --interp
import system.reflection.Assembly;
import pvzengine.IPropertyKey;
import pvzengine.PropertyMapper;
import pvzengine.PropertyMeta;
import pvzengine.entities.EngineEntityProps;
import mvz2logic.entities.LogicEntityProps;
import mvz2.vanilla.VanillaMod;
import mvz2logic.LogicMain;
import pvzengine.level.LevelEngine;

class IntegrationProbe {
	static function main() {
		var nsp = "mvz2";
		// ① ModLoader 链路（两个 mod 程序集）
		var modAssemblies = [
			Assembly.GetAssembly(VanillaMod),
			Assembly.GetAssembly(LogicMain)
		];
		for (a in modAssemblies) {
			var types = a.GetTypes();
			trace('mod assembly=${a.name} types=${types.length}');
			PropertyMapper.InitPropertyMaps(nsp, types);
		}
		// ② MainManager 链路（引擎程序集）
		var levelEngineAssembly = Assembly.GetAssembly(LevelEngine);
		trace('levelEngine assembly=${levelEngineAssembly.name} types=${levelEngineAssembly.GetTypes().length}');
		PropertyMapper.InitPropertyMaps(nsp, levelEngineAssembly.GetTypes());

		// ③ 抽样检查键值
		report("EngineEntityProps.GRAVITY", EngineEntityProps.GRAVITY);
		report("EngineEntityProps.TINT", EngineEntityProps.TINT);
		report("EngineEntityProps.COLOR_OFFSET", EngineEntityProps.COLOR_OFFSET);
		report("EngineEntityProps.FLIP_X", EngineEntityProps.FLIP_X);
		report("EngineEntityProps.INVINCIBLE", EngineEntityProps.INVINCIBLE);
		report("LogicEntityProps.UNLOCK", LogicEntityProps.UNLOCK);
		report("LogicEntityProps.NAME", LogicEntityProps.NAME);
	}

	static function report(label:String, meta:Dynamic) {
		var m:IPropertyMeta = cast meta;
		var k:IPropertyKey = cast meta;
		trace('  $label key=${k.Key} name=${m.GetPropertyName()}');
	}
}
