// Ported from: Assets/Scripts/Engine/Base/Definitions/DefinitionList.cs
package pvzengine;

import pvzengine.base.Definition;

class DefinitionList
{
    public function new() {}
    public function GetAllDefinitions():Array<Definition>
    {
        return definitions.copy();
    }
    // C#: public T[] GetAllDefinitions<T>() where T : Definition （用 OfType<T>() 过滤）
    // PORT-NOTE: Haxe 无法按运行期泛型过滤（C# 的 T 是显式类型实参），改为传入类型对象，
    // 与工程内既有约定一致（如 unity.GameObject.GetComponent<T>(type:Class<T>)）。
    public function GetAllDefinitionsOf<T:Definition>(cl:Class<T>):Array<T>
    {
        var result:Array<T> = [];
        for (definition in definitions)
        {
            if (Std.isOfType(definition, cl))
            {
                result.push(cast definition);
            }
        }
        return result;
    }
    public function GetDefinition(id:Null<NamespaceID>):Null<Definition>
    {
        for (definition in definitions)
        {
            if (definition.GetID() == id)
                return definition;
        }
        return null;
    }
    // C#: public T? GetDefinition<T>(NamespaceID? id) where T : Definition
    // PORT-NOTE: 同 GetAllDefinitionsOf —— 显式类型实参改为类型对象参数。
    public function GetDefinitionOfType<T:Definition>(cl:Class<T>, id:Null<NamespaceID>):Null<T>
    {
        for (definition in definitions)
        {
            if (Std.isOfType(definition, cl) && definition.GetID() == id)
                return cast definition;
        }
        return null;
    }
    public function Add(definition:Definition):Void
    {
        definitions.push(definition);
    }
    public function Clear():Void
    {
        definitions = [];
    }
    private var definitions:Array<Definition> = [];
}
