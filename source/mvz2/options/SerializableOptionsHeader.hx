// Ported from: Assets/Scripts/MVZ2/Options/SerializableOptionsHeader.cs
package mvz2.options;

// [Serializable]
// [BsonIgnoreExtraElements]
class SerializableOptionsHeader {
    public var version:Int;

    public function new(version:Int) {
        this.version = version;
    }
}
