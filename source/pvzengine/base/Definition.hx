// Ported from: Assets/Scripts/Engine/Base/Definitions/Definition.cs
package pvzengine.base;

import pvzengine.IPropertyKey;
import pvzengine.NamespaceID;
import pvzengine.PropertyDictionary;
import pvzengine.PropertyKey;
import pvzengine.callbacks.CallbackResult;
import pvzengine.callbacks.CallbackType;
import pvzengine.callbacks.ITrigger;
import pvzengine.callbacks.Trigger;

// PORT-NOTE: C# 的 `abstract class` 在 Haxe 中语义不同（Haxe 无抽象类），仍写作普通 class，
// 抽象方法 GetDefinitionType() 用 throw 占位并标注 `// abstract`（见 PORTING.md）。
class Definition
{
    public function new(nsp:String, name:String)
    {
        id = new NamespaceID(nsp, name);
    }
    public function TryGetProperty<T>(name:PropertyKey<T>, value:{ value:Dynamic }):Bool
    {
        return propertyDict.TryGetProperty(name, value);
    }
    public function TryGetPropertyObject(name:IPropertyKey, value:{ value:Dynamic }):Bool
    {
        return propertyDict.TryGetPropertyObject(name, value);
    }
    public function GetProperty<T>(name:PropertyKey<T>):Null<T>
    {
        return propertyDict.GetProperty(name);
    }
    public function GetPropertyObject(name:IPropertyKey):Dynamic
    {
        return propertyDict.GetPropertyObject(name);
    }
    public function SetProperty<T>(name:PropertyKey<T>, value:Null<T>):Void
    {
        propertyDict.SetProperty(name, value);
    }
    public function SetPropertyObject(name:IPropertyKey, value:Dynamic):Void
    {
        propertyDict.SetPropertyObject(name, value);
    }
    public function GetTriggers():Array<ITrigger>
    {
        return triggers.copy();
    }
    // C#: public void AddTrigger<TArgs>(CallbackType<TArgs> callbackID, Action<TArgs, CallbackResult> action, int priority = 0, object? filter = null)
    public function AddTrigger<TArgs>(callbackID:CallbackType<TArgs>, action:TArgs->CallbackResult->Void, priority:Int = 0, filter:Dynamic = null):Void
    {
        triggers.push(new Trigger<TArgs>(callbackID, action, priority, filter));
    }
    public function GetID():NamespaceID
    {
        return id;
    }
    public function ToString():String
    {
        return GetID().ToString();
    }
    // abstract
    public function GetDefinitionType():String
    {
        throw "abstract";
    }
    public var Namespace(get, never):String;
    inline function get_Namespace():String return id.SpaceName;
    public var Name(get, never):String;
    inline function get_Name():String return id.Path;
    private var id:NamespaceID;
    public var propertyDict:PropertyDictionary = new PropertyDictionary();
    public var triggers:Array<ITrigger> = [];
}
