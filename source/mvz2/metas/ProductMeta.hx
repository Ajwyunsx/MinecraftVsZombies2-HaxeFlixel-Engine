// Ported from: Assets/Scripts/MVZ2/Metas/Product/ProductMeta.cs
package mvz2.metas;

import mvz2.io.XMLHelper;
import mvz2logic.resources.SpriteReference;
import pvzengine.NamespaceID;
import system.xml.XmlNode;
using mvz2.io.XMLHelper;  // EXTUSING

class ProductMeta {
    private function new(talks:Array<ProductTalkMeta>, stages:Array<ProductStageMeta>) {
        Talks = talks;
        Stages = stages;
    }

    public var ID(default, null):String = "";
    public var Sprite(default, null):SpriteReference;
    public var BlueprintID(default, null):NamespaceID;
    public var UnlockConditions(default, null):XMLConditionList;
    public var Talks(default, null):Array<ProductTalkMeta>;
    public var Stages(default, null):Array<ProductStageMeta>;
    public var Index(default, null):Int;

    public static function FromXmlNode(node:XmlNode, defaultNsp:String, index:Int):ProductMeta {
        var id = XMLHelper.GetAttribute(node, "id");
        if (id == null) id = "";
        var sprite = XMLHelper.GetAttributeSpriteReference(node, "sprite", defaultNsp);
        var blueprintId = XMLHelper.GetAttributeNamespaceID(node, "blueprintId", defaultNsp);

        var unlockConditions = XMLHelper.GetUnlockConditionsOrObsolete(node, "unlock", "required", defaultNsp);

        var talks:Array<ProductTalkMeta> = [];
        var talksNode = node["talks"];
        if (talksNode != null) {
            for (i in 0...talksNode.ChildNodes.Count) {
                var childNode = talksNode.ChildNodes.getAt(i);
                if (childNode.Name == "talk") {
                    var meta = ProductTalkMeta.FromXmlNode(childNode, defaultNsp);
                    if (meta != null) {
                        talks.push(meta);
                    }
                }
            }
        }

        var stages:Array<ProductStageMeta> = [];
        var stagesNode = node["stages"];
        if (stagesNode != null) {
            for (i in 0...stagesNode.ChildNodes.Count) {
                var childNode = stagesNode.ChildNodes.getAt(i);
                if (childNode.Name == "stage") {
                    var meta = ProductStageMeta.FromXmlNode(childNode, defaultNsp);
                    if (meta != null) {
                        stages.push(meta);
                    }
                }
            }
        }
        var product = new ProductMeta(talks, stages);
        product.ID = id;
        product.Sprite = sprite;
        product.BlueprintID = blueprintId;
        product.UnlockConditions = unlockConditions;
        product.Index = index;
        return product;
    }
    public function GetMessage(characterId:NamespaceID):String {
        for (t in Talks) {
            if (t.Character == characterId) {
                return t.Text;
            }
        }
        return "";
    }
    public function IsEmpty():Bool {
        return ID == null || ID.length == 0;
    }
}
