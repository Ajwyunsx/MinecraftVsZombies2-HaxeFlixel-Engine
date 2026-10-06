// Ported from: Assets/Scripts/MVZ2/Metas/Options/OptionWidgetMeta.cs
package mvz2.metas;

import mvz2.io.XMLHelper;
import mvz2logic.options.OptionWidgetType;
import pvzengine.Log;
import pvzengine.NamespaceID;
import system.xml.XmlNode;
using mvz2.io.XMLHelper;  // EXTUSING
using pvzengine.PropertyKeyHelper;  // EXTUSING

class OptionWidgetMeta {
    public var Type(default, null):OptionWidgetType;
    public var ID(default, null):String;
    public var Order(default, null):Int;
    public var Category(default, null):NamespaceID;
    public var Label(default, null):String = "";
    public var Tooltip(default, null):String = "";
    public var SliderMinValue(default, null):Float;
    public var SliderMaxValue(default, null):Float;
    public var SliderWholeNumber(default, null):Bool;

    public function new(type:OptionWidgetType, iD:String, category:NamespaceID) {
        Type = type;
        ID = iD;
        Category = category;
    }
    public static function FromXmlNode(node:XmlNode, defaultNsp:String, order:Int):OptionWidgetMeta {
        var id = XMLHelper.GetAttribute(node, "id");
        if (id == null || id.length == 0) {
            Log.LogError('The id of a OptionWidgetMeta is invalid.');
            return null;
        }
        var category = XMLHelper.GetAttributeNamespaceID(node, "category", defaultNsp);
        if (!NamespaceID.IsValid(category)) {
            Log.LogError('The category of a OptionWidgetMeta is invalid.');
            return null;
        }
        var label = XMLHelper.GetAttribute(node, "label");
        if (label == null) label = "";
        var tooltipNode = node["tooltip"];
        var tooltip = "";
        if (tooltipNode != null) {
            tooltip = XMLHelper.ConcatNodeParagraphs(tooltipNode);
        }

        var minValueAttr = XMLHelper.GetAttributeFloat(node, "minValue");
        var minValue = minValueAttr != null ? minValueAttr : 0.0;
        var maxValueAttr = XMLHelper.GetAttributeFloat(node, "maxValue");
        var maxValue = maxValueAttr != null ? maxValueAttr : 1.0;
        var wholeNumberAttr = XMLHelper.GetAttributeBool(node, "wholeNumber");
        var wholeNumber = wholeNumberAttr != null ? wholeNumberAttr : false;

        var type:OptionWidgetType = OptionWidgetType.Button;
        if (typeDict.exists(node.Name)) {
            type = typeDict.get(node.Name);
        }
        var meta = new OptionWidgetMeta(type, id, category);
        meta.Label = label;
        meta.Tooltip = tooltip;
        meta.SliderMinValue = minValue;
        meta.SliderMaxValue = maxValue;
        meta.SliderWholeNumber = wholeNumber;
        meta.Order = order;
        return meta;
    }
    private static var typeDict:Map<String, OptionWidgetType> = [
        "button" => OptionWidgetType.Button,
        "toggle" => OptionWidgetType.Toggle,
        "dropdown" => OptionWidgetType.Dropdown,
        "slider" => OptionWidgetType.Slider,
    ];
}
