// Ported from: Assets/Scripts/Engine/Base/BsonSerializers/NamespaceIDSerializer.cs
package pvzengine.bsonserializers;

import pvzengine.NamespaceID;

// PORT-NOTE: C# 中本类继承外部 Tools 库的 `Tools.BsonSerializers.WrappedSerializerBase<T>`
//（该类型在本仓库中不存在，属于外部依赖），并使用 MongoDB.Bson 的读写上下文。
// 工程内的 BSON 序列化已被 SerializeHelper 以「按类型名登记」的等价实现取代
//（见 mvz2logic/serialization/SerializeHelper.hx，其中登记的名字为 "PVZEngine.NamespaceIDSerializer"），
// 因此这里保留 C# 的类名与（去 BSON 化后的）序列化/反序列化行为，不继承不存在的基类。
class NamespaceIDSerializer
{
    public function new(defaultNsp:String)
    {
        this.defaultNsp = defaultNsp;
    }
    // C#: protected override void SerializeValue(BsonSerializationContext context, BsonSerializationArgs args, NamespaceID value)
    public function SerializeValue(value:NamespaceID):Dynamic
    {
        if (value == null)
        {
            return null;
        }
        else
        {
            return value.ToString();
        }
    }

    // C#: protected override NamespaceID DeserializeClassValue(BsonDeserializationContext context, BsonDeserializationArgs args)
    public function DeserializeClassValue(value:Dynamic):Null<NamespaceID>
    {
        // C#: var bsonType = reader.GetCurrentBsonType(); switch (bsonType) { case BsonType.String: ... }
        // 等价实现：只接受字符串。
        if (Std.isOfType(value, String))
        {
            var parsed:Dynamic = NamespaceID.TryParse(cast value, defaultNsp);
            if (parsed != null)
            {
                return cast parsed;
            }
            return null;
        }
        throw CreateCannotDeserializeFromBsonTypeException(value);
    }
    private function CreateCannotDeserializeFromBsonTypeException(bsonType:Dynamic):Dynamic
    {
        return 'Cannot deserialize a NamespaceID from ${Std.string(bsonType)}.';
    }
    private var defaultNsp:String;
}
