package mvz2.globalgames;

import mvz2.managers.MainManager;
import mvz2logic.games.IGlobalGame;
import mvz2logic.modding.IModLogic;
import pvzengine.NamespaceID;
import pvzengine.base.Definition;
import pvzengine.base.DefinitionGroup;
import pvzengine.callbacks.CallbackResult;
import pvzengine.callbacks.CallbackSystem;
import pvzengine.callbacks.CallbackType;
import pvzengine.callbacks.ITrigger;
import pvzengine.properties.IPropertyKey;
import pvzengine.properties.PropertyDictionary;
import pvzengine.properties.PropertyKey;
import unity.Coroutine;

// Ported from: Assets/Scripts/MVZ2/Global/GlobalGame.cs
// PORT-NOTE: C# `out T? value` parameters are expressed as a mutable `{value:T}` structure;
// `IEnumerator` coroutines become unity.Coroutine.
class GlobalGame implements IGlobalGame {
    public function new(main:MainManager) {
        this.main = main;
    }
    public function IsMobile():Bool {
        return main.IsMobile();
    }
    public function UseMobileLayout():Bool {
        return main.UseMobileLayout();
    }
    public function StartCoroutine(coroutine:Coroutine):Coroutine {
        return main.CoroutineManager.StartCoroutine(coroutine);
    }
    public function GetAllUnlockConditions():Array<NamespaceID> {
        return main.ResourceManager.GetAllUnlockConditions();
    }

    // #region 属性
    public function SetProperty<T>(name:PropertyKey<T>, value:T):Void propertyDict.SetProperty(name, value);
    public function GetProperty<T>(name:PropertyKey<T>):T return propertyDict.GetProperty(name);
    public function TryGetProperty<T>(name:PropertyKey<T>, value:{value:T}):Bool return propertyDict.TryGetProperty(name, value);
    public function GetPropertyNames():Array<IPropertyKey> return propertyDict.GetPropertyNames();
    // #endregion

    // #region 定义
    // PORT-NOTE: C# `T? GetDefinition<T>(string type, NamespaceID? id)`；Haxe 无法书写显式类型实参，
    // 按工程约定（同 unity.GameObject.GetComponent）改为传入类型对象，见 pvzengine/IGameContent.hx 的 PORT-NOTE。
    public function GetDefinition<T:Definition>(cl:Class<T>, type:String, id:Null<NamespaceID>):Null<T> {
        return definitionGroup.GetDefinitionOfType(cl, type, id);
    }
    public function GetDefinitions<T:Definition>(cl:Class<T>, type:String):Array<T> {
        return definitionGroup.GetDefinitionsOfType(cl, type);
    }
    public function GetDefinitionsAll():Array<Definition> {
        return definitionGroup.GetDefinitions();
    }
    public function AddMod(mod:IModLogic):Void {
        for (def in mod.GetDefinitions()) {
            definitionGroup.Add(def);
        }
        for (trigger in mod.GetTriggers()) {
            callbacks.AddCallback(trigger);
        }
    }
    // #endregion

    // #region 回调
    public function AddTrigger(trigger:ITrigger):Void {
        callbacks.AddCallback(trigger);
    }
    public function RemoveTrigger(trigger:ITrigger):Bool {
        return callbacks.RemoveCallback(trigger);
    }

    public function RunCallback<TArgs>(callbackType:CallbackType<TArgs>, args:TArgs):Void {
        callbacks.RunCallback(callbackType, args);
    }
    public function RunCallbackWithResult<TArgs>(callbackType:CallbackType<TArgs>, args:TArgs, result:CallbackResult):Void {
        callbacks.RunCallbackWithResult(callbackType, args, result);
    }

    public function RunCallbackFiltered<TArgs>(callbackType:CallbackType<TArgs>, args:TArgs, filter:Dynamic):Void {
        callbacks.RunCallbackFiltered(callbackType, args, filter);
    }
    public function RunCallbackWithResultFiltered<TArgs>(callbackType:CallbackType<TArgs>, args:TArgs, result:CallbackResult, filter:Dynamic):Void {
        callbacks.RunCallbackWithResultFiltered(callbackType, args, result, filter);
    }
    // #endregion

    public var DefaultNamespace(get, never):String;
    inline function get_DefaultNamespace():String return main.BuiltinNamespace;

    private var main:MainManager;
    private var propertyDict:PropertyDictionary = new PropertyDictionary();
    private var definitionGroup:DefinitionGroup = new DefinitionGroup();
    private var callbacks:CallbackSystem = new CallbackSystem();
}
