// Ported from: Assets/Scripts/Logic/Resources/SpriteReference.cs
package mvz2logic.resources;

import mvz2logic.ParseHelper;
import pvzengine.NamespaceID;
import tools.Ref;

// [Serializable]
class SpriteReference
{
	// PORT-NOTE: C# 有两个构造函数 (id) 与 (id, index)，Haxe 不支持重载，用静态工厂 + 主构造函数。
	public function new(id:NamespaceID)
	{
		this.id = id;
		valid = CheckValidation();
	}
	public static function FromSheet(id:NamespaceID, index:Int):SpriteReference
	{
		var reference = new SpriteReference(id);
		reference.isSheet = true;
		reference.index = index;
		reference.valid = reference.CheckValidation();
		return reference;
	}
	// PORT-NOTE: C# `out SpriteReference? parsed` -> tools.Ref<SpriteReference>。
	public static function TryParse(str:String, defaultNsp:String, parsed:Ref<SpriteReference>):Bool
	{
		parsed.value = null;
		var leftBracketIndex = str.lastIndexOf("[");
		var rightBracketIndex = str.lastIndexOf("]");
		if (leftBracketIndex < 0)
		{
			// PORT-NOTE: C# `out NamespaceID? parsed` → pvzengine.NamespaceID.TryParse 的 {value:Dynamic} 引用容器。
			var idRef = { value: (null : Dynamic) };
			if (!NamespaceID.TryParse(str, defaultNsp, idRef))
				return false;
			else
			{
				parsed.value = new SpriteReference(cast idRef.value);
				return true;
			}
		}
		else
		{
			if (leftBracketIndex >= rightBracketIndex)
				return false;

			var bracketContent = str.substring(leftBracketIndex + 1, rightBracketIndex);
			var indexRef:Ref<Int> = new Ref<Int>(0);
			if (!ParseHelper.TryParseInt(bracketContent, indexRef))
				return false;

			var idStr = str.substring(0, leftBracketIndex);
			var idRef = { value: (null : Dynamic) };
			if (!NamespaceID.TryParse(idStr, defaultNsp, idRef))
				return false;

			parsed.value = FromSheet(cast idRef.value, indexRef.value);
			return true;
		}
	}
	public static function Parse(str:String, defaultNsp:String):SpriteReference
	{
		var parsed = new Ref<SpriteReference>(null);
		if (TryParse(str, defaultNsp, parsed))
		{
			return parsed.value;
		}
		throw new haxe.Exception('Invalid SpriteReference ${str}.');
	}
	public static function IsValid(sprRef:Null<SpriteReference>):Bool
	{
		if (sprRef == null)
			return false;
		if (!sprRef.valid)
			return false;
		return true;
	}
	private function CheckValidation():Bool
	{
		if (!NamespaceID.IsValid(ID))
			return false;
		if (Index < 0)
			return false;
		return true;
	}
	public function GetHashCode():Int
	{
		// PORT-NOTE: C# 的 NamespaceID.GetHashCode()/bool.GetHashCode() 在 Haxe 中无对应，用等价实现。
		var hash = id == null ? 0 : id.GetHashCode();
		hash = hash * 31 + (IsSheet ? 1 : 0);
		hash = hash * 31 + Index;
		return hash;
	}
	public function Equals(obj:Dynamic):Bool
	{
		if (Std.isOfType(obj, SpriteReference))
		{
			var otherRef:SpriteReference = cast obj;
			return otherRef.id == id && otherRef.IsSheet == IsSheet && otherRef.Index == Index;
		}
		return false; // PORT-NOTE: C# base.Equals(obj) 为引用相等
	}
	// PORT-NOTE: C# 定义了 operator == / !=，Haxe 不支持运算符重载，调用处请改用 Equals。
	// PORT-NOTE: C# struct 的 Object.ToString() 覆写 → Haxe 无父类，取消 override。
	public function toString():String
	{
		return '${id}${IsSheet ? '[${Index}]' : ""}';
	}

	public var ID(get, never):NamespaceID;
	private function get_ID():NamespaceID return id;
	public var IsSheet(get, never):Bool;
	private function get_IsSheet():Bool return isSheet;
	public var Index(get, never):Int;
	private function get_Index():Int return index;

	// [SerializeField]
	private var id:NamespaceID;
	// [SerializeField]
	private var isSheet:Bool;
	// [SerializeField]
	private var index:Int;

	// [NonSerialized]
	private var valid:Bool;
}
