// Ported from: Assets/Scripts/MVZ2/Metas/Command/CommandMetaList.cs
package mvz2.metas;

import system.xml.XmlNode;

class CommandMetaList {
    public var metas:Array<CommandMeta>;

    public function new(metas:Array<CommandMeta>) {
        this.metas = metas;
    }

    public static function FromXmlNode(node:XmlNode, defaultNsp:String):CommandMetaList {
        var resources:Array<CommandMeta> = [];
        for (i in 0...node.ChildNodes.Count) {
            var meta = CommandMeta.FromXmlNode(node.ChildNodes.getAt(i), defaultNsp);
            if (meta != null) {
                resources.push(meta);
            }
        }
        return new CommandMetaList(resources);
    }
}
