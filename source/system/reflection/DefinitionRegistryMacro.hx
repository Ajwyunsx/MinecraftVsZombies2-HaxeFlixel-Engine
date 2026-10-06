// PORT-NOTE: 本文件是移植层的「程序集反射」替代实现，不对应任何 C# 源文件。
//
// 背景：C# 的 ModLoader 用 System.Reflection 扫描程序集（`Assembly.GetTypes()` + 类/字段上的特性）
// 来发现 Definition、ModGlobalCallbacks 与属性区域（region），见
// Assets/Scripts/MVZ2/Modding/ModLoader.cs:57~99 与 Assets/Scripts/MVZ2/Managers/MainManager.cs:222~224。
//
// Haxe 没有运行期特性：工程把 C# 特性改写成了**编译期元数据**
// （`@:autoEntityBehaviourDefinition(...)` / `@:modGlobalCallbacks` /
//  `@:propertyRegistryRegion(...)` / `@:propertyRegistry(...)` 等，见 PORTING.md）。
// `@:` 前缀的元数据不保留到运行期，所以必须有一步编译期扫描把它变成运行期可读的数据。
// 本宏就是那一步，由 `system.reflection.DefinitionRegistry` 的 `@:build` 调用。
//
// 它做的事：
//  1. 遍历 source 根下全部 .hx，剥掉注释后找出「含目标元数据」的候选模块；
//  2. 对候选模块 `Context.getModule` 载入，逐个 ClassType 读**真实**元数据（权威来源）：
//       `@:auto*Definition(...)` / `@:randomChinaEventDefinition(...)` → 定义特性（名称 + 特性类）
//       `@:modGlobalCallbacks`                                      → 全局回调类
//       `@:propertyRegistryRegion(...)`                             → 类级属性区域
//       静态字段上的 `@:propertyRegistry` / `@:entityPropertyRegistry` / `@:levelPropertyRegistry`
//  3. 元数据参数在该类自己的作用域里求值（先 `Context.typeExpr`，失败再按「限定类.静态字段」
//     取该静态字段的编译期字符串字面量）；工程内参数只有「字符串字面量」与「类.静态字段」两种形态；
//  4. 生成 `DefinitionRegistry` 上的静态函数，**为每个类发出直接类引用**（`macro $p{path}`）。
//     这一步同时解决 DCE：这些类原本没人引用、被整批优化掉，正是 `Cannot find entity behaviour`
//     的直接原因（见 tools_build/registry_audio_findings.md）。
//
// 程序集归属按包前缀判定，对应 C# 的 asmdef（Assets/Scripts/**/*.asmdef）：
//   mvz2logic.*                          → MVZ2.Logic
//   mvz2.gamecontent.* / mvz2.vanilla.*  → MVZ2.Vanilla
//   mvz2.view.*                          → MVZ2.View
//   pvzengine.base*                      → PVZEngine.Base
//   其它 pvzengine.*                     → PVZEngine.Level
//   其它 mvz2.*                          → MVZ2
// `Assembly.GetAssembly(typeof(X))` 的三个调用点分别是 VanillaMod(MVZ2.Vanilla)、
// LogicMain(MVZ2.Logic)、LevelEngine(PVZEngine.Level)，该映射与之一致。
package system.reflection;

#if macro
import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Type;
import sys.FileSystem;
#end

class DefinitionRegistryMacro {
	#if macro
	private static inline var META_GLOBAL_CALLBACKS = "modGlobalCallbacks";
	private static inline var META_REGION = "propertyRegistryRegion";
	/** 每个生成函数的记录条数（避免 neko 单函数栈溢出，见 build() 的 PORT-NOTE）。 */
	private static inline var CHUNK_SIZE = 100;
	private static var META_FIELD_REGIONS = ["propertyRegistry", "entityPropertyRegistry", "levelPropertyRegistry"];

	/**
	 * 元数据名 → 定义类型常量。与 C# 的各 `AutoXxxDefinitionAttribute` 构造器一一对应：
	 * Assets/Scripts/Engine/Level/Definitions/DefinitionAttribute.cs（PVZEngine 部分）、
	 * Assets/Scripts/Logic/Definitions/DefinitionAttribute.cs（MVZ2Logic 部分）、
	 * Assets/Scripts/Vanilla/Frameworks/Definitions/DefinitionAttributes.cs（randomChinaEvent）。
	 */
	private static var DEFINITION_TYPES = [
		"autoAreaDefinition" => "area",
		"autoRechargeDefinition" => "recharge",
		"autoSeedDefinition" => "seed",
		"autoSpawnDefinition" => "spawn",
		"autoStageDefinition" => "stage",
		"autoBuffDefinition" => "buff",
		"autoGridDefinition" => "grid",
		"autoEntityDefinition" => "entity",
		"autoArmorDefinition" => "armor",
		"autoArmorBehaviourDefinition" => "armor_behaviour",
		"autoEntityBehaviourDefinition" => "entity_behaviour",
		"autoPlacementDefinition" => "placement",
		"autoShellDefinition" => "shell",
		"autoSeedOptionDefinition" => "seed_option",
		"autoNoteDefinition" => "note",
		"autoArtifactDefinition" => "artifact",
		"autoHeldItemDefinition" => "held_item",
		"autoHeldItemBehaviourDefinition" => "held_item_behaviour",
		"autoIZombieLayoutDefinition" => "i_zombie_layout",
		"autoCommandDefinition" => "command",
		"autoOptionWidgetDefinition" => "option_widget",
		"autoMapElementDefinition" => "map_element",
		"autoMapElementBehaviourDefinition" => "map_element_behaviour",
		"randomChinaEventDefinition" => "mvz2:random_china_event"
	];
	/** 收集到的类记录（供注入的函数生成表达式）。 */
	private static var classes:Array<Dynamic> = null;

	/** DefinitionRegistry 的 `@:build` 入口。 */
	public static function build():Array<Field> {
		collect();
		var fields = Context.getBuildFields();
		// PORT-NOTE: 933 条记录如果塞进一个函数体，会生成过大的函数体（局部栈/编译都吃力）。
		// 这里按 100 条一块切成多个函数，再用 __classes() 串起来；cpp 目标同样受益（单个函数体更小、编译更快）。
		var chunkNames:Array<String> = [];
		var i = 0;
		var index = 0;
		while (i < classes.length) {
			var elements:Array<Expr> = [];
			var end = i + CHUNK_SIZE;
			while (i < end && i < classes.length) {
				elements.push(classExpr(classes[i]));
				i++;
			}
			var name = "__classes_" + index;
			chunkNames.push(name);
			// PORT-NOTE: 早期写法是 `return [expr0, expr1, ...]`（100 元素数组字面量），
			// 每个字面量元素占一个局部栈槽。改成逐条 `push` 构造，局部栈只随「元素个数为 1」增长。
			// 注：neko 目标下 `Stack check failed for function scope` 与此写法无关、依旧复现，
			// 属 neko 代码生成的固有限制（见 tools_build/registry_macro_findings.md §5）。
			var pushes:Array<Expr> = [];
			for (el in elements)
				pushes.push(macro result.push($el));
			var chunkExpr:Expr = macro {
				var result:Array<Dynamic> = [];
				$b{pushes};
				return result;
			};
			fields.push({
				name: name,
				access: [APrivate, AStatic],
				kind: FFun({args: [], ret: macro :Array<Dynamic>, expr: chunkExpr}),
				pos: Context.currentPos()
			});
			index++;
		}
		var concats:Array<Expr> = [];
		for (n in chunkNames) {
			var call:Expr = {
				expr: ECall({expr: EConst(CIdent(n)), pos: Context.currentPos()}, []),
				pos: Context.currentPos()
			};
			concats.push(macro result = result.concat($call));
		}
		var combineExpr:Expr = macro {
			var result:Array<Dynamic> = [];
			$b{concats};
			return result;
		};
		var kind = FFun({args: [], ret: macro :Array<Dynamic>, expr: combineExpr});
		// 源码里有一个同名占位方法（让本类在宏未生效时也能独立类型检查），这里替换其实现。
		var replaced = false;
		for (f in fields) {
			if (f.name == "__classes") {
				f.kind = kind;
				replaced = true;
				break;
			}
		}
		if (!replaced) {
			fields.push({
				name: "__classes",
				access: [APrivate, AStatic],
				kind: kind,
				pos: Context.currentPos()
			});
		}
		return fields;
	}

	/** 生成一条类记录的表达式（含类引用与特性类引用）。 */
	private static function classExpr(c:Dynamic):Expr {
		var clsRef = pathExpr(c.path);
		var defExprs:Array<Expr> = [];
		for (d in (cast c.defs:Array<Dynamic>)) {
			var attrExpr:Expr = d.attr == null ? macro null : pathExpr(cast d.attr);
			var typeExpr:Expr = d.type == null ? macro null : macro $v{cast d.type};
			defExprs.push(macro {name: $v{cast d.name}, attr: $attrExpr, meta: $v{cast d.meta}, type: $typeExpr});
		}
		var fieldExprs:Array<Expr> = [];
		for (f in (cast c.fields:Array<Dynamic>)) {
			fieldExprs.push(macro {name: $v{cast f.name}, type: $v{cast f.type}, region: $v{cast f.region}});
		}
		var regionExpr:Expr = c.region == null ? macro null : macro $v{cast c.region};
		return macro {
			cls: $clsRef,
			// `name` 必须是 Haxe 运行期 `Type.getClassName(cls)` 的返回值（DefinitionRegistry 按它查表），
			// 次类型是 `pack.TypeName` 而不是 `pack.Module.TypeName`（见 runtimeName）。
			name: $v{cast c.name},
			assembly: $v{cast c.assembly},
			// PORT-NOTE: 记录字段名是 `isAbstract`（见 describeClass）；早期写成
			// `Reflect.field(c, "abstract")`，键名对不上 → 恒为 null → Assembly.IsAbstract 恒 false，
			// 抽象定义类（BlueprintHeldItemBehaviour）会被错误实例化。
			isAbstract: $v{cast Reflect.field(c, "isAbstract")},
			defs: [$a{defExprs}],
			callbacks: $v{cast c.callbacks},
			region: $regionExpr,
			fields: [$a{fieldExprs}]
		};
	}

	private static function pathExpr(path:String):Expr {
		var parts = path.split(".");
		return macro $p{parts};
	}

	/** 扫描并收集全部带目标元数据的类。 */
	private static function collect():Array<Dynamic> {
		if (classes != null)
			return classes;
		var root = findSourceRoot();
		if (root == null) {
			Context.warning("DefinitionRegistryMacro：找不到 source 根，注册表为空。", Context.currentPos());
			classes = [];
			return classes;
		}
		var simpleNames = new Map<String, String>();
		var candidates = [];
		walk(root, root, candidates, simpleNames);

		var out:Array<Dynamic> = [];
		var failed = 0;
		for (mod in candidates) {
			var types:Array<Type> = null;
			try {
				types = Context.getModule(mod);
			} catch (e:Dynamic) {
				failed++;
				continue;
			}
			if (types == null)
				continue;
			for (t in types) {
				switch (t) {
					case TInst(ref, _):
						var rec = describeClass(ref.get(), simpleNames);
						if (rec != null)
							out.push(rec);
					default:
				}
			}
		}
		Sys.println('[DefinitionRegistry] 候选模块=${candidates.length} 收录类型=${out.length} 跳过=$failed');
		classes = out;
		return classes;
	}

	/** 归一化元数据名。Haxe 把 `@:foo` 形式的元数据存成 `:foo`（带冒号前缀），
	 * 而无冒号的 `@foo` 存成 `foo`；本宏只关心前者，统一去掉前缀后比较。 */
	private static function metaNameOf(meta:MetadataEntry):String {
		var n = meta.name;
		if (StringTools.startsWith(n, ":"))
			n = n.substr(1);
		return n;
	}

	/** 读取单个类的真实元数据；没有目标元数据时返回 null。 */
	private static function describeClass(cls:ClassType, simpleNames:Map<String, String>):Dynamic {
		var defs:Array<Dynamic> = [];
		var callbacks = false;
		var region:String = null;
		var fields:Array<Dynamic> = [];

		for (meta in cls.meta.get()) {
			var name = metaNameOf(meta);
			if (name == META_GLOBAL_CALLBACKS) {
				callbacks = true;
			} else if (name == META_REGION) {
				region = evalArg(meta.params.length > 0 ? meta.params[0] : null, cls, simpleNames);
			} else if (isDefinitionMeta(name)) {
				var defName = evalArg(meta.params.length > 0 ? meta.params[0] : null, cls, simpleNames);
				var attrPath = simpleNames.get(attributeClassSimpleName(name));
				defs.push({name: defName, attr: attrPath, meta: name, type: DEFINITION_TYPES.get(name)});
			}
		}

		for (f in cls.statics.get()) {
			for (meta in f.meta.get()) {
				var name = metaNameOf(meta);
				if (META_FIELD_REGIONS.indexOf(name) < 0)
					continue;
				var fieldRegion = evalArg(meta.params.length > 0 ? meta.params[0] : null, cls, simpleNames);
				var typeName:String = null;
				if (name == "entityPropertyRegistry")
					typeName = "entity";
				else if (name == "levelPropertyRegistry")
					typeName = "level";
				fields.push({name: f.name, type: typeName, region: fieldRegion});
			}
		}

		if (defs.length == 0 && !callbacks && region == null && fields.length == 0)
			return null;

		return {
			path: classPath(cls),
			name: runtimeName(cls),
			assembly: assemblyOf(cls),
			isAbstract: isAbstract(cls),
			defs: defs,
			callbacks: callbacks,
			region: region,
			fields: fields
		};
	}

	private static function isDefinitionMeta(name:String):Bool {
		if (name == "randomChinaEventDefinition")
			return true;
		if (!StringTools.startsWith(name, "auto") || !StringTools.endsWith(name, "Definition"))
			return false;
		var mid = name.substr(4, name.length - 4 - "Definition".length);
		// 排除注释里举例用的占位写法 `@:autoXxxDefinition`。
		return mid.length > 0 && mid != "Xxx";
	}

	/** `autoEntityBehaviourDefinition` → `AutoEntityBehaviourDefinitionAttribute`。 */
	private static function attributeClassSimpleName(metaName:String):String {
		return metaName.substr(0, 1).toUpperCase() + metaName.substr(1) + "Attribute";
	}

	/**
	 * 求值元数据参数。工程内参数有三种形态：
	 *   1. 字符串字面量（`@:levelPropertyRegistry("gem_stage")`）；
	 *   2. `限定类.静态字段名`（`@:propertyRegistryRegion(PropertyRegions.entity)`）；
	 *   3. **裸标识符**（`@:propertyRegistry(PROP_REGION)`，PROP_REGION 是被标注类自己的静态常量）。
	 * 先在该类自己的作用域里试 `Context.typeExpr`，失败再按静态字段字面量解析。
	 * PORT-NOTE: 形态 3 之前未处理，导致 40 处字段级区域标注（PROP_REGION / REGION_NAME）解析为 null，
	 * 这些属性被 PropertyMapper 当成「无区域」跳过、永不注册。
	 */
	private static function evalArg(e:Expr, cls:ClassType, simpleNames:Map<String, String>):Null<String> {
		if (e == null)
			return null;
		switch (e.expr) {
			case EConst(CString(s)):
				return s;
			case EConst(CIdent(id)):
				// 裸标识符：取被标注类自己的静态字符串常量（`PROP_REGION` / `REGION_NAME` 的常见写法）。
				return staticStringOf(cls, id);
			default:
		}
		try {
			var te = Context.typeExpr(e);
			switch (te.expr) {
				case TConst(TString(s)):
					return s;
				default:
			}
		} catch (err:Dynamic) {
			// 落到下面的静态字段解析。
		}
		switch (e.expr) {
			case EField(q, fieldName):
				return resolveStaticString(q, fieldName, cls, simpleNames);
			default:
		}
		return null;
	}

	/** 解析 `Qualifier.field` 形式的编译期字符串常量。 */
	private static function resolveStaticString(q:Expr, fieldName:String, cls:ClassType,
		simpleNames:Map<String, String>):Null<String> {
		var qualifier:String = switch (q.expr) {
			case EConst(CIdent(id)): id;
			default: return null;
		};
		var own = staticStringOf(cls, fieldName);
		if (own != null && (qualifier == cls.name || qualifier == "this"))
			return own;
		var target = simpleNames.get(qualifier);
		if (target == null)
			return own;
		var other = staticStringOfTypePath(target, fieldName);
		return other != null ? other : own;
	}

	private static function staticStringOf(cls:ClassType, fieldName:String):Null<String> {
		for (f in cls.statics.get()) {
			if (f.name != fieldName)
				continue;
			var e = f.expr();
			if (e == null)
				return null;
			switch (e.expr) {
				case TConst(TString(s)): return s;
				default: return null;
			}
		}
		return null;
	}

	private static function staticStringOfTypePath(path:String, fieldName:String):Null<String> {
		var t:Type = null;
		try {
			t = Context.getType(path);
		} catch (e:Dynamic) {
			return null;
		}
		if (t == null)
			return null;
		switch (t) {
			case TInst(ref, _): return staticStringOf(ref.get(), fieldName);
			default:
		}
		return null;
	}

	/**
	 * 等价于 C# 的 `type.IsAbstract`。Haxe 没有抽象类，工程按 PORTING.md 用类声明上方的
	 * `// abstract` 注释标记（共 81 处）；这些类在 C# 里 `IsAbstract == true`，ModLoader 会跳过实例化。
	 */
	private static function isAbstract(cls:ClassType):Bool {
		for (meta in cls.meta.get()) {
			if (meta.name == "abstract" || meta.name == ":abstract")
				return true;
		}
		var rel = cls.module.split(".").join("/") + ".hx";
		for (cp in Context.getClassPath()) {
			var full = StringTools.replace(cp, "\\", "/") + "/" + rel;
			if (!FileSystem.exists(full))
				continue;
			try {
				var lines = sys.io.File.getContent(full).split("\n");
				for (i in 0...lines.length) {
					var trimmed = StringTools.trim(lines[i]);
					if (!StringTools.startsWith(trimmed, "class ") || lines[i].indexOf(cls.name) < 0)
						continue;
					var j = i - 1;
					while (j >= 0) {
						var prev = StringTools.trim(lines[j]);
						if (prev == "// abstract")
							return true;
						if (prev.length == 0 || StringTools.startsWith(prev, "@:") || StringTools.startsWith(prev, "//"))
							{
								j--;
								continue;
							}
						break;
					}
					break;
				}
			} catch (e:Dynamic) {}
			break;
		}
		return false;
	}

	private static function classPath(cls:ClassType):String {
		var modBase = cls.module.split(".").pop();
		if (cls.name == modBase)
			return cls.pack.concat([cls.name]).join(".");
		// 次类型（同模块里第 2 个及以后的类）：pack.Module.Type（模块限定路径，供 `macro $p{}` 发出类引用）。
		return cls.pack.concat([modBase, cls.name]).join(".");
	}

	/**
	 * Haxe 运行期 `Type.getClassName(cls)` 的返回值（次类型是 `pack.TypeName`，**不含**模块名）。
	 *
	 * PORT-NOTE: 早期记录的 `name` 用的是 `classPath()`（`pack.Module.Type`），
	 * 而 `DefinitionRegistry.getRecordOfClass()` 是拿 `Type.getClassName(cls)` 去查的，
	 * 两者对**次类型**不一致 → 那 6 个次类型（EntityPhysicsBehaviour / ClassicBlueprintHeldItemBehaviour /
	 * ConveyorBlueprintHeldItemBehaviour / ShowHotkeysOptionsToggle / RedstoneDropStageBehaviour /
	 * LogicMapElementProps）的记录永远查不到，它们的 defs / region / fields 全部丢失
	 * （boot-trace 里 `Cannot find entity behaviour with ID mvz2:entity_physics`）。
	 * 这里把「类引用路径」与「运行期名字」分开：`path` 用于发出引用，`name` 用于运行期查表。
	 */
	private static function runtimeName(cls:ClassType):String {
		return cls.pack.concat([cls.name]).join(".");
	}

	/** 按包前缀映射到 C# 程序集名（见文件头注释）。 */
	private static function assemblyOf(cls:ClassType):String {
		var pack = cls.pack.join(".");
		if (StringTools.startsWith(pack, "mvz2logic"))
			return "MVZ2.Logic";
		if (StringTools.startsWith(pack, "mvz2.gamecontent") || StringTools.startsWith(pack, "mvz2.vanilla"))
			return "MVZ2.Vanilla";
		if (StringTools.startsWith(pack, "mvz2.view"))
			return "MVZ2.View";
		if (pack == "pvzengine" || StringTools.startsWith(pack, "pvzengine.base"))
			return "PVZEngine.Base";
		if (StringTools.startsWith(pack, "pvzengine"))
			return "PVZEngine.Level";
		return "MVZ2";
	}

	/** 定位工程的 source 根（含 system/reflection/DefinitionRegistry.hx 的那个 classpath 项）。 */
	private static function findSourceRoot():Null<String> {
		for (cp in Context.getClassPath()) {
			var normalized = StringTools.replace(cp, "\\", "/");
			if (StringTools.endsWith(normalized, "/"))
				normalized = normalized.substr(0, normalized.length - 1);
			if (FileSystem.exists(normalized + "/system/reflection/DefinitionRegistry.hx")
				&& FileSystem.exists(normalized + "/Main.hx"))
				return normalized;
		}
		return null;
	}

	/** 递归收集候选模块（源码文本含目标元数据），并建「简单类名 → 全路径」索引。 */
	private static function walk(root:String, dir:String, out:Array<String>, simpleNames:Map<String, String>):Void {
		if (!FileSystem.exists(dir))
			return;
		for (name in FileSystem.readDirectory(dir)) {
			var path = dir + "/" + name;
			if (FileSystem.isDirectory(path)) {
				walk(root, path, out, simpleNames);
			} else if (StringTools.endsWith(name, ".hx")) {
				var rel = path.substr(root.length + 1);
				var mod = rel.substr(0, rel.length - 3).split("/").join(".");
				var text:String = null;
				try {
					text = sys.io.File.getContent(path);
				} catch (e:Dynamic) {
					continue;
				}
				var code = stripComments(text);
				for (clsName in extractClassNames(code))
					if (!simpleNames.exists(clsName))
						simpleNames.set(clsName, mod + "." + clsName);
				if (hasTargetMeta(code))
					out.push(mod);
			}
		}
	}

	/** 从已剥注释的源码文本里取顶层类名（含 abstract 类与次类型）。 */
	private static function extractClassNames(code:String):Array<String> {
		var result:Array<String> = [];
		var re = ~/^[ \t]*(?:abstract[ \t]+class|class)[ \t]+([A-Za-z_][A-Za-z0-9_]*)/gm;
		var rest = code;
		var offset = 0;
		while (re.match(rest)) {
			var m = re.matchedPos();
			result.push(re.matched(1));
			offset += m.pos + m.len;
			rest = code.substr(offset);
		}
		return result;
	}

	/** 源码文本里是否存在真实（非注释）的目标元数据行。 */
	private static function hasTargetMeta(code:String):Bool {
		for (line in code.split("\n")) {
			var t = StringTools.trim(line);
			if (!StringTools.startsWith(t, "@:"))
				continue;
			var rest = t.substr(2);
			var open = rest.indexOf("(");
			var metaName = StringTools.trim(open >= 0 ? rest.substr(0, open) : rest);
			if (metaName == META_GLOBAL_CALLBACKS || metaName == META_REGION || META_FIELD_REGIONS.indexOf(metaName) >= 0)
				return true;
			if (isDefinitionMeta(metaName))
				return true;
		}
		return false;
	}

	/** 去掉行注释与块注释（用于避免被 PORT-NOTE 里举例的元数据文本误导）。 */
	private static function stripComments(text:String):String {
		var out = new StringBuf();
		var inBlock = false;
		for (line in text.split("\n")) {
			var i = 0;
			var buf = new StringBuf();
			while (i < line.length) {
				if (inBlock) {
					var end = line.indexOf("*/", i);
					if (end < 0) {
						i = line.length;
					} else {
						inBlock = false;
						i = end + 2;
					}
					continue;
				}
				var slash = line.indexOf("//", i);
				var blockStart = line.indexOf("/*", i);
				if (slash >= 0 && (blockStart < 0 || slash < blockStart)) {
					buf.add(line.substring(i, slash));
					i = line.length;
				} else if (blockStart >= 0) {
					buf.add(line.substring(i, blockStart));
					inBlock = true;
					i = blockStart + 2;
				} else {
					buf.add(line.substr(i));
					i = line.length;
				}
			}
			out.add(buf.toString());
			out.add("\n");
		}
		return out.toString();
	}
	#end
}
