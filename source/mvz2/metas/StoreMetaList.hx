// Ported from: Assets/Scripts/MVZ2/Metas/Store/StoreMetaList.cs
package mvz2.metas;

import system.xml.XmlNode;

class StoreMetaList {
    private function new(presets:Array<StorePresetMeta>, chats:Array<StoreChatGroupMeta>, products:Array<ProductMeta>) {
        Presets = presets;
        Chats = chats;
        Products = products;
    }

    public var Presets(default, null):Array<StorePresetMeta>;
    public var LoreTalks(default, null):LoreTalkMetaList;
    public var Chats(default, null):Array<StoreChatGroupMeta>;
    public var Products(default, null):Array<ProductMeta>;

    public static function FromXmlNode(node:XmlNode, defaultNsp:String):StoreMetaList {
        var presetsNode = node["presets"];
        var presets:Array<StorePresetMeta> = [];
        if (presetsNode != null) {
            for (i in 0...presetsNode.ChildNodes.Count) {
                var child = presetsNode.ChildNodes.getAt(i);
                if (child.Name == "preset") {
                    var meta = StorePresetMeta.FromXmlNode(child, defaultNsp);
                    if (meta != null)
                        presets.push(meta);
                }
            }
        }
        var talksNode = node["talks"];
        var loreTalks:LoreTalkMetaList = null;
        if (talksNode != null) {
            loreTalks = LoreTalkMetaList.FromXmlNode(node["talks"], defaultNsp);
        }

        var chatsNode = node["chats"];
        var chats:Array<StoreChatGroupMeta> = [];
        if (chatsNode != null) {
            for (i in 0...chatsNode.ChildNodes.Count) {
                var child = chatsNode.ChildNodes.getAt(i);
                if (child.Name == "group") {
                    var meta = StoreChatGroupMeta.FromXmlNode(child, defaultNsp);
                    if (meta != null)
                        chats.push(meta);
                }
            }
        }
        var productsNode = node["products"];
        var products:Array<ProductMeta> = [];
        if (productsNode != null) {
            for (i in 0...productsNode.ChildNodes.Count) {
                var child = productsNode.ChildNodes.getAt(i);
                if (child.Name == "product") {
                    var meta = ProductMeta.FromXmlNode(child, defaultNsp, i);
                    if (meta != null)
                        products.push(meta);
                }
            }
        }
        var list = new StoreMetaList(presets, chats, products);
        list.LoreTalks = loreTalks;
        return list;
    }
}
