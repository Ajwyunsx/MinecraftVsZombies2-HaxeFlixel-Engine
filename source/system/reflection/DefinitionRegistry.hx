// PORT-NOTE: 本文件是移植层的「程序集反射」替代实现，不对应任何 C# 源文件。
//
// C# 侧 ModLoader / MainManager 用 System.Reflection 扫描程序集：
//   Assets/Scripts/MVZ2/Modding/ModLoader.cs:57~99
//   Assets/Scripts/MVZ2/Managers/MainManager.cs:222~224
// Haxe 没有运行期反射与特性，工程把 C# 特性改写成了编译期元数据
// （`@:auto*Definition(...)` / `@:modGlobalCallbacks` / `@:propertyRegistryRegion(...)` / ...），
// 由 DefinitionRegistryMacro 在编译期扫描后生成到本类（`@:build` 注入的 `__classes()`）。
//
// 本类提供运行期查询，并作为 `system.reflection.Assembly` 的数据源：
// 每个 Assembly 实例按名字（MVZ2.Vanilla / MVZ2.Logic / PVZEngine.Level / ...）过滤记录，
// 于是 ModLoader 里既有的 `Reflect.field(assembly, "GetTypes")` 等调用形式可以原样工作。
//
// PORT-NOTE: `Assembly.GetAssembly(typeof(X))` 在 C# 里取的是 X **所在程序集**，而移植层的
// `Assembly.GetAssembly` 只拿得到类型名（见 Assembly.hx）。两者最终都指向同一批记录：
// 过滤键就是类记录里的 `assembly` 字段，由宏按包前缀判定（与 asmdef 一致）。
package system.reflection;

@:build(system.reflection.DefinitionRegistryMacro.build())
class DefinitionRegistry {
	/** 按需惰性构建的「程序集名 → 类记录」索引。 */
	private static var byAssembly:Map<String, Array<Dynamic>> = null;

	public static function getClasses():Array<Dynamic> {
		return __classes();
	}

	/** 取某个程序集（按 C# 程序集名）里的全部类型记录。 */
	public static function getClassesOfAssembly(assemblyName:String):Array<Dynamic> {
		ensureIndex();
		if (assemblyName == null || !byAssembly.exists(assemblyName))
			return [];
		return byAssembly.get(assemblyName);
	}

	public static function getAssemblyNames():Array<String> {
		ensureIndex();
		return [for (k in byAssembly.keys()) k];
	}

	/**
	 * 按类取记录。
	 * PORT-NOTE: 记录的 `name` 与 Haxe 运行期 `Type.getClassName(cls)` 一致（见宏的 runtimeName），
	 * 但历史/外部形态可能是 `pack.Module.Type`（模块限定路径），因此两条键都试一次。
	 */
	public static function getRecordOfClass(cls:Class<Dynamic>):Dynamic {
		if (cls == null)
			return null;
		var name = Type.getClassName(cls);
		for (rec in __classes()) {
			if (rec.name == name)
				return rec;
		}
		// 兜底：`pack.TypeName` 与 `pack.Module.TypeName` 互相匹配（模块名 == 首段之后的类名时）。
		for (rec in __classes()) {
			var rn:String = rec.name;
			if (rn == null)
				continue;
			if (StringTools.endsWith(rn, "." + name) || StringTools.endsWith(name, "." + rn))
				return rec;
		}
		return null;
	}

	private static function ensureIndex():Void {
		if (byAssembly != null)
			return;
		byAssembly = new Map();
		for (rec in __classes()) {
			var key:String = rec.assembly;
			if (!byAssembly.exists(key))
				byAssembly.set(key, []);
			byAssembly.get(key).push(rec);
		}
	}

	// PORT-NOTE: 下面这个方法由 system.reflection.DefinitionRegistryMacro 在编译期注入
	// （`@:build`），内容是从 source/ 扫描出的全部带定义/回调/属性区域元数据的类记录。
	// 记录字段：cls(类引用) / name(全路径) / assembly(C# 程序集名) / abstract /
	//          defs[{name, attr, meta}] / callbacks / region / fields[{name, type, region}]。
	private static function __classes():Array<Dynamic> {
		return [];
	}
}
