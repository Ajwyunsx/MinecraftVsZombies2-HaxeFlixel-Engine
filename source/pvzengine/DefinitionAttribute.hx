// Ported from: Assets/Scripts/Engine/Base/Definitions/DefinitionAttribute.cs
package pvzengine;

// PORT-NOTE: C# 的 Attribute 在 Haxe 中没有运行期对应物，既有移植代码改用编译期元数据
// （如 `@:autoAreaDefinition(VanillaAreaNames.castle)`，见 mvz2/gamecontent/areas/*.hx）。
// 本类保留 C# 的类结构与 `Name` / `Type` 成员以维持 1:1；
// mvz2/modding/ModLoader.hx 通过 `Reflect.field(attribute, "Name")` 读取名称，因此二者为真实字段。
// C#: [AttributeUsage(AttributeTargets.Class, AllowMultiple = false, Inherited = false)]
// abstract
class DefinitionAttribute
{
    public function new(name:String, type:String)
    {
        Name = name;
        Type = type;
    }
    public var Name(default, null):String;
    public var Type(default, null):String;
}
