// Ported from: Assets/Scripts/MVZ2/Options/Dialog/OptionContext.cs
package mvz2.options;

import mvz2logic.games.IGlobalOptions;
import mvz2logic.options.IOptionContext;
import pvzengine.NamespaceID;
import tools.Ref;

// abstract
class OptionContext implements IOptionContext {
    public function new() {}

    public function CacheOptionBool(id:NamespaceID, value:Bool):Void {
        cacheOptionBool.set(id, value);
    }
    public function CacheOptionInt(id:NamespaceID, value:Int):Void {
        cacheOptionInt.set(id, value);
    }
    public function CacheOptionFloat(id:NamespaceID, value:Float):Void {
        cacheOptionFloat.set(id, value);
    }
    public function CacheOptionString(id:NamespaceID, value:String):Void {
        cacheOptionString.set(id, value);
    }
    public function CacheOptionID(id:NamespaceID, value:NamespaceID):Void {
        cacheOptionID.set(id, value);
    }

    // PORT-NOTE: IOptionContext 定义为 out 参数，Haxe 统一用 tools.Ref<T> 容器实现。
    public function TryGetCachedOptionBool(id:NamespaceID, value:Ref<Bool>):Bool {
        if (!cacheOptionBool.exists(id)) return false;
        value.value = cacheOptionBool.get(id);
        return true;
    }
    public function TryGetCachedOptionInt(id:NamespaceID, value:Ref<Int>):Bool {
        if (!cacheOptionInt.exists(id)) return false;
        value.value = cacheOptionInt.get(id);
        return true;
    }
    public function TryGetCachedOptionFloat(id:NamespaceID, value:Ref<Float>):Bool {
        if (!cacheOptionFloat.exists(id)) return false;
        value.value = cacheOptionFloat.get(id);
        return true;
    }
    public function TryGetCachedOptionString(id:NamespaceID, value:Ref<String>):Bool {
        if (!cacheOptionString.exists(id)) return false;
        value.value = cacheOptionString.get(id);
        return true;
    }
    public function TryGetCachedOptionID(id:NamespaceID, value:Ref<Null<NamespaceID>>):Bool {
        if (!cacheOptionID.exists(id)) return false;
        value.value = cacheOptionID.get(id);
        return true;
    }
    public function FlushCachedOptions(options:IGlobalOptions):Void {
        for (key in cacheOptionBool.keys()) {
            options.SetOptionBool(key, cacheOptionBool.get(key));
        }
        for (key in cacheOptionInt.keys()) {
            options.SetOptionInt(key, cacheOptionInt.get(key));
        }
        for (key in cacheOptionFloat.keys()) {
            options.SetOptionFloat(key, cacheOptionFloat.get(key));
        }
        for (key in cacheOptionString.keys()) {
            options.SetOptionString(key, cacheOptionString.get(key));
        }
        for (key in cacheOptionID.keys()) {
            options.SetOptionID(key, cacheOptionID.get(key));
        }
        cacheOptionBool.clear();
        cacheOptionInt.clear();
        cacheOptionFloat.clear();
        cacheOptionString.clear();
        cacheOptionID.clear();
    }
    public function SetNeedReload():Void {
        needReload = true;
    }
    public function NeedsReload():Bool {
        return needReload;
    }
    private var cacheOptionBool:Map<NamespaceID, Bool> = new Map();
    private var cacheOptionInt:Map<NamespaceID, Int> = new Map();
    private var cacheOptionFloat:Map<NamespaceID, Float> = new Map();
    private var cacheOptionString:Map<NamespaceID, String> = new Map();
    private var cacheOptionID:Map<NamespaceID, NamespaceID> = new Map();
    public var needReload:Bool;
}
