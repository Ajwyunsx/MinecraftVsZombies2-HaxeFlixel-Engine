// PORT-NOTE: 本文件是移植层的「程序集反射」替代实现，不对应任何 C# 源文件。
//
// 背景：C# 的 ModLoader 用 System.Reflection 扫描程序集（`Assembly.GetTypes()` +
// 类/字段上的特性）来发现 Definition、ModGlobalCallbacks 与属性区域（region）。
// Haxe 没有运行期特性，工程把 C# 特性改写成了**编译期元数据**
// （`@:autoEntityBehaviourDefinition(...)` / `@:modGlobalCallbacks` /
//  `@:propertyRegistryRegion(...)` / `@:propertyRegistry(...)` 等，见 PORTING.md）。
// 这些 `@:` 前缀元数据不会保留到运行期，所以必须有一步编译期扫描把结果变成运行期可读的数据。
//
// 本类就是那一步：它作为 `system.reflection.Assembly` 的编译期构建宏被调用
// （见 Assembly.hx 顶部的 `@:build`），扫描 source/ 下全部模块，收集上述元数据，
// 并把结果作为静态方法注入到 Assembly 类里（`__typeNames()` / `__typeMeta()` / `__fieldMeta()`）。
// Assembly 的运行期方法（GetTypes / IsAbstract / HasCustomAttribute / ...）再从这些数据作答，
// 因此 ModLoader 里既有的动态调用形式（`Reflect.field(assembly, "GetTypes")`）无需改动。
//
// 设计要点：
//  * 元数据参数是表达式（如 `VanillaEntityBehaviourNames.armorEntity`），必须在**该模块自身的作用域**里
//    求值。宏里 `Context.typeExpr` 对被扫描模块的裸标识符解析不了（它的作用域是调用点），
//    所以这里在**被标注的类上**注入一个隐藏静态方法，由编译器在该类自己的作用域里求值
//    （`@:autoBuild` 做不到，因为基类不止一个；`@:build` 挂在每个类上又必须改 800+ 个文件）。
//    实际做法见 `scan()`：先用源文本找出「元数据 → 类名」，再用 `Context.getModule` 把模块载入并
//    读取该类的 `@:xxx` 元数据；参数用 `Context.typeExpr` 求值，失败时退回源文本字面量解析。
//  * 只收集「带元数据的类」，不会把 2478 个模块全量拖进编译（DCE 仍然有效）。
package mvz2.registry;

#if macro
import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Type;
import sys.FileSystem;
import sys.io.File;
#end

class DefinitionRegistryMacro {
	#if macro
	/** 收集结果：类全名 → 该类的定义/回调元数据。 */
	private static var typeMeta:Map<String, Array<Dynamic>> = new Map();
	/** 类全名 → 类上标注的属性区域名。 */
	private static var regionMeta:Map<String, String> = new Map();
	/** 类全名 → 静态字段名 → 该字段上的属性区域信息 {type, region}。 */
	private static var fieldMeta:Map<String, Map<String, Dynamic>> = new Map();
	/** 类全名 → 是否为 abstract（Haxe 无 abstract 类，靠 `// abstract` 注释标记，见 PORTING.md）。 */
	private static var abstractTypes:Map<String, Bool> = new Map();
	/** 已扫描过的模块名，避免重复扫描。 */
	private static var scanned:Bool = false;

	/** Assembly 的 `@:build` 入口。 */
	public static function build():Array<Field> {
		scan();
		var fields = Context.getBuildFields();
		fields.push(injectData("__registryTypeNames", macro :Array<String>, macro $v{collectTypeNames()}));
		fields.push(injectData("__registryTypeMeta", macro :Array<Dynamic>, macro $v{collectTypeMeta()}));
		fields.push(injectData("__registryRegionMeta", macro :Array<Dynamic>, macro $v{collectRegionMeta()}));
		fields.push(injectData("__registryFieldMeta", macro :Array<Dynamic>, macro $v{collectFieldMeta()}));
		fields.push(injectData("__registryAbstractTypes", macro :Array<String>, macro $v{collectAbstractTypes()}));
		return fields;
	}

	private static function injectData(name:String, ret:ComplexType, value:Expr):Field {
		return {
			name: name,
			access: [APrivate, AStatic],
			kind: FFun({args: [], ret: ret, expr: macro return $value}),
			pos: Context.currentPos()
		};
	}
	#end
}
