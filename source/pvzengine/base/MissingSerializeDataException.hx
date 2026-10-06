// Ported from: Assets/Scripts/Engine/Base/MissingSerializeDataException.cs
package pvzengine.base;

// PORT-NOTE: C# 的 3 个构造函数重载（/message/message+inner）在 Haxe 中合并为一个可选参数构造函数。
class MissingSerializeDataException extends haxe.Exception
{
    public function new(?message:String = null, ?innerException:haxe.Exception = null)
    {
        super(message, innerException);
    }
    // C#: public static MissingSerializeDataException Property<T>(string propertyName)
    //     消息为 $"{typeof(T).Name}.{propertyName}"。
    // PORT-NOTE: Haxe 没有运行期泛型（无法取得 T 的名字），消息退化为 propertyName；
    // 另外 Haxe 不支持在调用点书写显式类型参数（`Property<T>("x")` 语法不合法），
    // 因此既有调用点中的 `Property<X>("name")` 形式需要写成 `Property("name")`。
    public static function Property<T>(propertyName:String):MissingSerializeDataException
    {
        var fullName = propertyName;
        return new MissingSerializeDataException('Missing serialization property $fullName.');
    }
}
