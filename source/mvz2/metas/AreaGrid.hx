// Ported from: Assets/Scripts/MVZ2/Metas/AreaMeta.cs
// PORT-NOTE: C# 同文件中的 AreaGrid 在 Haxe 侧单独成模块（包 mvz2.metas 的类按类名建模块，
// 以便 `import mvz2.metas.*` 一类的通配导入与裸类名引用都能解析）。
package mvz2.metas;

import mvz2.io.XMLHelper;
import pvzengine.Log;
import pvzengine.NamespaceID;
import system.xml.XmlNode;
using mvz2.io.XMLHelper;  // EXTUSING
using pvzengine.PropertyKeyHelper;  // EXTUSING

class AreaGrid {
    public function new(id:NamespaceID) {
        ID = id;
    }

    public var ID:NamespaceID;
    public var YOffset:Float;

    public static function FromXmlNode(node:XmlNode, defaultNsp:String):AreaGrid {
        var id = XMLHelper.GetAttributeNamespaceID(node, "id", defaultNsp);
        if (!NamespaceID.IsValid(id)) {
            Log.LogError("The ID of an AreaGrid is invalid.");
            return null;
        }
        var yOffsetAttr = XMLHelper.GetAttributeFloat(node, "yOffset");
        var yOffset = yOffsetAttr != null ? yOffsetAttr : 0;
        var grid = new AreaGrid(id);
        grid.YOffset = yOffset;
        return grid;
    }
}
