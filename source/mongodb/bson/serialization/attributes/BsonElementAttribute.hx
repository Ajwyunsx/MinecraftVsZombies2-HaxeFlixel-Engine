// Ported from: MongoDB.Bson.Serialization.Attributes.BsonElementAttribute (minimal shim)
package mongodb.bson.serialization.attributes;

class BsonElementAttribute {
    public var ElementName:String;

    public function new(?elementName:String) {
        ElementName = elementName;
    }
}
