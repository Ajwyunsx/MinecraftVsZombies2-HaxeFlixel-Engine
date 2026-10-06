package system.reflection;

// Minimal System.Reflection.Assembly shim.
//
// PORT-NOTE: Haxe 没有程序集概念。C# 侧 ModLoader（Assets/Scripts/MVZ2/Modding/ModLoader.cs:57~99）
// 与 MainManager（Assets/Scripts/MVZ2/Managers/MainManager.cs:222~224）用
// `Assembly.GetTypes()` + 类/字段特性来发现 Definition / ModGlobalCallbacks / 属性区域。
// 移植层把这些特性改写成编译期元数据（`@:auto*Definition(...)` / `@:modGlobalCallbacks` /
// `@:propertyRegistryRegion(...)` / `@:propertyRegistry(...)`），由 system.reflection.DefinitionRegistry
// 的编译期宏扫描成运行期数据（见 DefinitionRegistry.hx 与 DefinitionRegistryMacro.hx）。
//
// 本类就是那批数据上的「程序集」视图：`GetAssembly(typeof(X))` 记下 X 所属的 C# 程序集名
// （由宏按包前缀判定，与 asmdef 一致），随后 GetTypes / IsAbstract / HasCustomAttribute /
// GetCustomAttributes / InvokeConstructor 都按这个名字过滤 DefinitionRegistry 的记录。
// ModLoader 通过 `Reflect.field(assembly, "GetTypes")` 动态调用，因此这里的方法名必须与 C# 一致。
class Assembly {
	public var name:String;

	public function new(?name:String = "") {
		this.name = name;
	}

	/**
	 * C#: `Assembly.GetAssembly(Type)` —— 取类型所在的程序集。
	 * 移植层用类型全名当参数（既有调用点是 `GetAssembly(VanillaMod)` 这类类引用）。
	 */
	public static function GetAssembly(type:Class<Dynamic>):Assembly {
		if (type == null)
			return new Assembly("");
		var rec:Dynamic = DefinitionRegistry.getRecordOfClass(type);
		if (rec != null)
			return new Assembly(cast rec.assembly);
		// 兜底：没有元数据记录的类型按包前缀判定（与宏里的映射保持一致）。
		return new Assembly(assemblyNameOfPath(Type.getClassName(type)));
	}
	public static function GetExecutingAssembly():Assembly {
		return new Assembly("Assembly");
	}
	public function ToString():String return name;

	// #region 运行期反射（数据来自 DefinitionRegistry 的编译期扫描）
	/** C#: `Assembly.GetTypes()`。返回本程序集里有定义/回调/属性区域元数据的类。 */
	public function GetTypes():Array<Class<Dynamic>> {
		var result:Array<Class<Dynamic>> = [];
		for (rec in DefinitionRegistry.getClassesOfAssembly(name))
			result.push(cast rec.cls);
		return result;
	}
	/** C#: `Type.IsAbstract`。Haxe 侧由宏按 `// abstract` 注释标记判定（见 PORTING.md）。 */
	public function IsAbstract(type:Class<Dynamic>):Bool {
		var rec:Dynamic = DefinitionRegistry.getRecordOfClass(type);
		return rec != null && rec.isAbstract == true;
	}
	/** C#: `type.GetCustomAttribute<T>() != null`。attributeName 传 C# 特性类名。 */
	public function HasCustomAttribute(type:Class<Dynamic>, attributeName:String):Bool {
		var rec:Dynamic = DefinitionRegistry.getRecordOfClass(type);
		if (rec == null)
			return false;
		if (attributeName == "ModGlobalCallbacksAttribute")
			return rec.callbacks == true;
		if (attributeName == "DefinitionAttribute")
			return (cast rec.defs:Array<Dynamic>).length > 0;
		for (d in (cast rec.defs:Array<Dynamic>)) {
			if (matchesAttributeName(cast d.attr, cast d.meta, attributeName))
				return true;
		}
		return false;
	}
	/**
	 * C#: `type.GetCustomAttributes<DefinitionAttribute>()`。
	 * 返回可读 `Name` / `Type` 的实例（ModLoader 只用 `attribute.Name`）。
	 * PORT-NOTE: 这里返回带同名字段的轻量对象而不是真的构造 `pvzengine.DefinitionAttribute`，
	 * 以免 `system`（.NET shim 层）反向依赖游戏逻辑层；调用点只读 `Name`，语义一致。
	 *
	 * PORT-NOTE: C# 的 `GetCustomAttributes<DefinitionAttribute>()` 按**基类**匹配，所以传入
	 * 基类名 `"DefinitionAttribute"` 时所有 `AutoXxxDefinitionAttribute` 都必须命中。
	 * 注册表记录里的 `attr` 是编译期发出的**类引用**（运行期 `Class<Dynamic>`），
	 * 不是字符串；早期版本把它 `cast` 成 `String`，在任何真实目标上都会抛
	 * `Unexpected value VPrototype(Class<...>), expected string`（interp 实测），
	 * 于是 ModLoader 一个定义都注册不到。见 matchesAttributeName 的实现。
	 */
	public function GetCustomAttributes(type:Class<Dynamic>, attributeName:String):Array<Dynamic> {
		var result:Array<Dynamic> = [];
		var rec:Dynamic = DefinitionRegistry.getRecordOfClass(type);
		if (rec == null)
			return result;
		for (d in (cast rec.defs:Array<Dynamic>)) {
			if (!matchesAttributeName(cast d.attr, cast d.meta, attributeName))
				continue;
			result.push({Name: d.name, Type: d.type != null ? d.type : definitionTypeOf(cast d.meta)});
		}
		return result;
	}
	/**
	 * C#: `type.GetConstructor(new[]{typeof(string), typeof(string)}).Invoke(new object[]{nsp, name})`。
	 * 移植层等价于 `Type.createInstance(type, [nsp, name])`；构造失败返回 null（C# 里也是 null）。
	 */
	public function InvokeConstructor(type:Class<Dynamic>, args:Array<Dynamic>):Dynamic {
		if (type == null)
			return null;
		try {
			return Type.createInstance(type, args);
		} catch (e:Dynamic) {
			return null;
		}
	}
	// #endregion

	// #region 内部
	/**
	 * 特性类名匹配（`AutoEntityBehaviourDefinitionAttribute` ↔ `autoEntityBehaviourDefinition`）。
	 *
	 * PORT-NOTE: C# 里 `GetCustomAttributes<DefinitionAttribute>()` 传的是**基类**，
	 * `AttributeUsage(Inherited=false)` 只影响继承，不影响「基类是否匹配派生特性」——
	 * 所有 `AutoXxxDefinitionAttribute : DefinitionAttribute` 都会命中 `"DefinitionAttribute"`。
	 * 移植层因此除了比较特性自身的简单类名，还要在 attributeName == "DefinitionAttribute" 时
	 * 无条件命中任何定义特性（注册表里 `defs` 里的每一条本来就是一个 DefinitionAttribute 派生实例）。
	 *
	 * `attr` 由宏发出为**类引用**（运行期 `Class<Dynamic>`）；为兼容旧的字符串记录形式，
	 * 这里对字符串与 Class 两种形态都做处理。
	 */
	private static function matchesAttributeName(attr:Dynamic, metaName:Null<String>, attributeName:String):Bool {
		if (attributeName == null)
			return false;
		if (attributeName == "DefinitionAttribute")
			return true;
		var simple:String = simpleNameOf(attr);
		if (simple == null && metaName != null) {
			// `autoEntityBehaviourDefinition` → `AutoEntityBehaviourDefinitionAttribute`
			simple = metaName.substr(0, 1).toUpperCase() + metaName.substr(1) + "Attribute";
		}
		return simple == attributeName;
	}

	/** 取 `attr` 的简单类名：支持类引用（宏发出的形态）与字符串路径（旧形态）。 */
	private static function simpleNameOf(attr:Dynamic):Null<String> {
		if (attr == null)
			return null;
		if (Std.isOfType(attr, String))
			return (cast attr:String).split(".").pop();
		if (Std.isOfType(attr, Class)) {
			var full = Type.getClassName(cast attr);
			return full == null ? null : full.split(".").pop();
		}
		return null;
	}

	/** 元数据名 → C# 定义类型常量（与 pvzengine.definitions.EngineDefinitionTypes 一致）。 */
	private static function definitionTypeOf(metaName:Null<String>):String {
		if (metaName == null)
			return "";
		if (metaName == "randomChinaEventDefinition")
			return "mvz2:random_china_event";
		// `autoEntityBehaviourDefinition` → `entity_behaviour`（见 EngineDefinitionTypes）。
		var mid = metaName.substr(4, metaName.length - 4 - "Definition".length);
		return ~/([a-z0-9])([A-Z])/g.replace(mid, "$1_$2").toLowerCase();
	}

	/** 与 DefinitionRegistryMacro.assemblyOf 保持一致的包前缀映射。 */
	public static function assemblyNameOfPath(path:String):String {
		if (path == null)
			return "";
		var pack = path;
		var lastDot = path.lastIndexOf(".");
		if (lastDot >= 0)
			pack = path.substr(0, lastDot);
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
	// #endregion
}
