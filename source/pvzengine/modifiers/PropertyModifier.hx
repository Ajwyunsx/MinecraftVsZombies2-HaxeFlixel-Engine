// Ported from: Assets/Scripts/Engine/Level/Modifiers/PropertyModifier.cs
package pvzengine.modifiers;

import pvzengine.IPropertyKey;
import pvzengine.PropertyKey;
import pvzengine.buffs.IBuffTarget;

interface IPropertyModifier
{
	function GetModifierValue(buff:IModifierSource):Dynamic;
}

class PropertyModifier implements IPropertyModifier
{
	public function new(priority:Int)
	{
		Priority = priority;
	}
	// virtual
	public function PostAdd(container:IModifierSource, target:IBuffTarget):Void
	{
	}
	// virtual
	public function PostRemove(container:IModifierSource, target:IBuffTarget):Void
	{
	}
	// abstract
	public function GetModifierValue(container:IModifierSource):Dynamic
	{
		throw "abstract";
	}
	// abstract
	public function GetCalculator():ModifierCalculator
	{
		throw "abstract";
	}
	function get_PropertyName():IPropertyKey
	{
		throw "abstract";
	}
	function get_ConstValue():Dynamic
	{
		throw "abstract";
	}
	function get_UsingContainerPropertyName():IPropertyKey
	{
		throw "abstract";
	}
	public var PropertyName(get, never):IPropertyKey;
	public var ConstValue(get, never):Dynamic;
	public var UsingContainerPropertyName(get, never):IPropertyKey;
	public var Priority:Int;
	public var NoStack:Bool = false;

	// PORT-NOTE: 无法引用 IModifierSource 之外的泛型信息时，用于判断某个 Dynamic 值是否是「属性键」而非「常量值」。
	// C# 通过构造函数重载区分这两种情况，Haxe 不支持重载，只能运行期判断。
	public static function IsPropertyKeyLike(value:Dynamic):Bool
	{
		return ResolveKey(value) != null;
	}
	// PORT-NOTE: 从 Dynamic 值中解析出属性键。优先读取包装类（例如 PropertyMeta 这类
	// 「隐式转换为 PropertyKey」的类型）内部持有的 key 字段；否则若值本身实现了 IPropertyKey 则直接使用。
	// TODO-PORT: PropertyMeta 与 PropertyKey 的关系（继承 / abstract @:from / 包装类）由 Base 工作包定稿，
	// 此处按「实现了 IPropertyKey，或持有 key 字段」的启发式判定，定稿后需要复核。
	public static function ResolveKey(value:Dynamic):IPropertyKey
	{
		if (value == null)
			return null;
		if (Reflect.isObject(value))
		{
			var inner = Reflect.field(value, "key");
			if (inner == null)
				inner = Reflect.field(value, "get_key");
			if (inner != null && Std.isOfType(inner, IPropertyKey))
				return inner;
		}
		if (Std.isOfType(value, IPropertyKey))
			return value;
		return null;
	}
}

// PORT-NOTE: C# 中 PropertyModifier 有两个同名类型（arity 0 / 1），Haxe 不能同名，
// 泛型版本改名为 PropertyModifierT<T>（对应 PropertyModifier<T>）。
class PropertyModifierT<T> extends PropertyModifier
{
	public function new(propertyName:PropertyKey<T>, value:Dynamic, priority:Int = 0)
	{
		super(priority);
		PropertyNameGeneric = propertyName;
		var key = PropertyModifier.ResolveKey(value);
		if (key != null)
		{
			usingContainerPropertyName = true;
			UsingContainerPropertyNameGeneric = cast key;
		}
		else
		{
			usingContainerPropertyName = false;
			ConstValueGeneric = cast value;
		}
	}
	public override function GetModifierValue(container:IModifierSource):Dynamic
	{
		return GetModifierValueGeneric(container);
	}
	public function GetModifierValueGeneric(container:IModifierSource):Null<T>
	{
		// PORT-NOTE: C# 用 `PropertyKeyHelper.IsValid(UsingContainerPropertyName)` 判断是「属性键」还是「常量值」；
		// Haxe 中未使用属性键时该字段为 null，故改用构造期记录的布尔标记（语义等价）。
		if (usingContainerPropertyName)
		{
			// PORT-NOTE: Haxe 不支持在调用点书写显式类型参数，T 由 PropertyKey<T> 参数推断。
			return container.GetProperty(UsingContainerPropertyNameGeneric);
		}
		else
		{
			return ConstValueGeneric;
		}
	}
	public function FitsConditionGeneric(modifierValue:Null<T>):Bool
	{
		if (Condition == null)
			return true;
		return Condition(modifierValue);
	}
	override function get_PropertyName():IPropertyKey
	{
		return PropertyNameGeneric;
	}
	override function get_ConstValue():Dynamic
	{
		return ConstValueGeneric;
	}
	override function get_UsingContainerPropertyName():IPropertyKey
	{
		return UsingContainerPropertyNameGeneric;
	}
	public var PropertyNameGeneric(default, null):PropertyKey<T>;
	public var ConstValueGeneric(default, null):Null<T>;
	public var Condition:Null<ModifierCondition<T>>;
	public var UsingContainerPropertyNameGeneric(default, null):PropertyKey<T>;
	private var usingContainerPropertyName:Bool = false;
}

typedef ModifierCondition<T> = Null<T> -> Bool;
