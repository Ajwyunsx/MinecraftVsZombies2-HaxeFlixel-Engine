// Ported from: Assets/Scripts/MVZ2/Metas/Command/CommandMeta.cs
package mvz2.metas;

import mvz2.debugs.DebugManager;
import mvz2.io.XMLHelper;
import mvz2logic.commands.ICommandParameterMeta;
import mvz2logic.commands.ICommandVariantMeta;
import system.xml.XmlNode;
using mvz2.io.XMLHelper;  // EXTUSING

class CommandMetaVariant implements ICommandVariantMeta {
    // PORT-NOTE: ICommandVariantMeta 以只读属性（get, never）声明接口成员，Haxe 中必须用属性实现，
    // 故 C# 的 public 字段改为「只读属性 + 私有后端字段」。
    public var Subname(get, never):String;
    public var Description(get, never):String;
    public var Parameters(get, never):Array<ICommandParameterMeta>;

    inline function get_Subname():String return subnameValue;
    inline function get_Description():String return descriptionValue;
    inline function get_Parameters():Array<ICommandParameterMeta> return parametersValue;

    private var subnameValue:String = "";
    private var descriptionValue:String = "";
    private var parametersValue:Array<ICommandParameterMeta>;

    private function new(parameters:Array<ICommandParameterMeta>) {
        parametersValue = parameters;
    }
    public static function FromXmlNode(node:XmlNode, defaultNsp:String):CommandMetaVariant {
        var subname = XMLHelper.GetAttribute(node, "subname");
        if (subname == null) subname = "";

        var descriptionNode = node["description"];
        var description = descriptionNode != null ? descriptionNode.InnerText : "";

        var paramList:Array<ICommandParameterMeta> = [];
        var paramsNode = node["params"];
        if (paramsNode != null) {
            for (i in 0...paramsNode.ChildNodes.Count) {
                var childNode = paramsNode.ChildNodes.getAt(i);
                if (childNode.Name == "param") {
                    paramList.push(CommandMetaParam.FromXmlNode(childNode, defaultNsp));
                }
            }
        }
        var variant = new CommandMetaVariant(paramList);
        variant.subnameValue = subname;
        variant.descriptionValue = description;
        return variant;
    }

    public function GetGrammarText(commandName:String):String {
        var sb = new StringBuf();
        sb.add(DebugManager.COMMAND_CHARACTER);
        sb.add(commandName);
        if (Subname != null && Subname.length > 0) {
            sb.add(' ${Subname}');
        }
        for (param in Parameters) {
            if (param.Optional) {
                sb.add(' [${param.Name}]');
            } else {
                sb.add(' <${param.Name}>');
            }
        }
        return sb.toString();
    }
}
