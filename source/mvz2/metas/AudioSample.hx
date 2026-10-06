// Ported from: Assets/Scripts/MVZ2/Metas/AudioSample.cs
package mvz2.metas;

import mvz2logic.ParseHelper;
import pvzengine.Log;
import pvzengine.NamespaceID;
import system.xml.XmlNode;
import mvz2logic.ParseHelper.OutFloat;
using mvz2logic.ParseHelper;  // EXTUSING

class AudioSample {
    public var path:NamespaceID;
    public var weight:Float;

    public function new(path:NamespaceID, weight:Float) {
        this.path = path;
        this.weight = weight;
    }

    public static function FromXmlNode(node:XmlNode, defaultNsp:String):AudioSample {
        var pathAttr = node.Attributes["path"]; // PORT-NOTE: shim 的 XmlAttributeCollection 提供 @:arrayAccess。
        var path = pathAttr != null ? NamespaceID.TryParse(pathAttr.Value, defaultNsp) : null;
        if (path == null) {
            Log.LogError('The path of an AudioSample is invalid.');
            return null;
        }
        var weight = 1.0;
        var weightAttribute = node.Attributes["weight"];
        if (weightAttribute != null) {
            // PORT-NOTE: C# 的 out 参数在 Haxe 中用 OutFloat 容器。
            var floatRef:OutFloat = {value: 0};
            if (ParseHelper.TryParseFloat(weightAttribute.Value, floatRef)) {
                weight = floatRef.value;
            }
        }
        return new AudioSample(path, weight);
    }
}
