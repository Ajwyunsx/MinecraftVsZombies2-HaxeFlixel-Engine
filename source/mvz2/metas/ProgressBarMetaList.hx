// Ported from: Assets/Scripts/MVZ2/Metas/ProgressBar/ProgressBarMetaList.cs
package mvz2.metas;

import system.xml.XmlNode;

class ProgressBarMetaList {
    public var metas:Array<ProgressBarMeta>;

    public function new(metas:Array<ProgressBarMeta>) {
        this.metas = metas;
    }

    public static function FromXmlNode(node:XmlNode, defaultNsp:String):ProgressBarMetaList {
        var resources:Array<ProgressBarMeta> = [];
        for (i in 0...node.ChildNodes.Count) {
            var meta = ProgressBarMeta.FromXmlNode(node.ChildNodes.getAt(i), defaultNsp);
            if (meta != null)
                resources.push(meta);
        }
        return new ProgressBarMetaList(resources);
    }
}
