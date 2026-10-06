// Ported from: Assets/Scripts/Engine/Base/Definitions/DefintionGroup.cs
// PORT-NOTE: 原 C# 文件名拼写为 "DefintionGroup.cs"（缺少 i），Haxe 的模块名必须与主类型名一致，
// 因此此处文件名/模块名按类型名写作 DefinitionGroup（见 pvzengine/base/DefinitionGroup.hx 别名）。
package pvzengine;

import pvzengine.base.Definition;

class DefinitionGroup
{
    public function new()
    {
    }
    public function Add(definition:Definition):Void
    {
        if (definition == null)
            return;
        var type = definition.GetDefinitionType();
        if (!lists.exists(type))
        {
            lists.set(type, new DefinitionList());
        }
        lists.get(type).Add(definition);
    }
    // C#: public T? GetDefinition<T>(string type, NamespaceID? id) where T : Definition
    // PORT-NOTE: Haxe 无法按运行期泛型过滤（T 在 C# 中是显式类型实参），返回值通过 cast 得到；
    // 由于同一 type 分组内只会有该类型系列的 Definition，行为与 C# 一致。
    public function GetDefinition<T:Definition>(type:String, id:Null<NamespaceID>):Null<T>
    {
        if (!lists.exists(type))
        {
            return null;
        }
        return cast lists.get(type).GetDefinition(id);
    }
    // C#: public T[] GetDefinitions<T>(string type) where T : Definition
    // PORT-NOTE: 同 GetDefinition —— 增加类型对象参数版本，供 IGameContent 的实现者使用
    // （既有调用点 mvz2logic/games/LogicGameDefinitionsExt.hx 以 `provider.GetDefinitions(Class, type)` 调用）。
    public function GetDefinitionsOfType<T:Definition>(cl:Class<T>, type:String):Array<T>
    {
        if (!lists.exists(type))
        {
            return [];
        }
        return lists.get(type).GetAllDefinitionsOf(cl);
    }
    // C#: public T? GetDefinition<T>(string type, NamespaceID? id) 的类型对象版本（供 IGameContent 实现者使用）。
    public function GetDefinitionOfType<T:Definition>(cl:Class<T>, type:String, id:Null<NamespaceID>):Null<T>
    {
        if (!lists.exists(type))
        {
            return null;
        }
        return lists.get(type).GetDefinitionOfType(cl, id);
    }
    // C#: public Definition[] GetDefinitions() —— 返回所有分组中的全部定义。
    public function GetDefinitions():Array<Definition>
    {
        var result:Array<Definition> = [];
        for (list in lists)
        {
            result = result.concat(list.GetAllDefinitions());
        }
        return result;
    }
    public var lists:Map<String, DefinitionList> = new Map<String, DefinitionList>();
}
