// Ported from: MongoDB.Bson.Serialization.Attributes.BsonIgnoreExtraElementsAttribute (minimal shim)
package mongodb.bson.serialization.attributes;

class BsonIgnoreExtraElementsAttribute {
    public var Inherited:Bool;

    public function new(?inherited:Bool = true) {
        Inherited = inherited;
    }
}
