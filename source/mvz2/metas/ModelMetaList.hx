// Ported from: Assets/Scripts/MVZ2/Metas/Model/ModelMetaList.cs
package mvz2.metas;

import system.xml.XmlNode;

class ModelMetaList {
    public var metas:Array<ModelMeta>;
    public var armorConfigs:Array<ModelArmorConfigMeta>;

    public function new(metas:Array<ModelMeta>, armorConfigs:Array<ModelArmorConfigMeta>) {
        this.metas = metas;
        this.armorConfigs = armorConfigs;
    }

    public static function FromXmlNode(node:XmlNode, defaultNsp:String):ModelMetaList {
        var metas:Array<ModelMeta> = [];
        var armorConfigs:Array<ModelArmorConfigMeta> = [];
        for (i in 0...node.ChildNodes.Count) {
            var child = node.ChildNodes.getAt(i);
            switch (child.Name) {
                case "model":
                    var meta = ModelMeta.FromXmlNode(child, defaultNsp);
                    if (meta != null)
                        metas.push(meta);
                case "armorconfig":
                    var armorConfig = ModelArmorConfigMeta.FromXmlNode(child, defaultNsp);
                    if (armorConfig != null)
                        armorConfigs.push(armorConfig);
                default:
            }
        }
        return new ModelMetaList(metas, armorConfigs);
    }
}
