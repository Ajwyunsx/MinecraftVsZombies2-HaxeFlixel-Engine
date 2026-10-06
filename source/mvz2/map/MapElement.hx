package mvz2.map;

import mvz2.ui.map.MapElementButton;
import mvz2logic.maps.IMapInterface;
import mvz2logic.maps.MapElementDefinition;
import pvzengine.base.NamespaceIDReference;
import pvzengine.NamespaceID;
import pvzengine.properties.IPropertyKey;
import pvzengine.properties.PropertyDictionary;
import pvzengine.properties.PropertyKey;
import unity.MonoBehaviour;
import pvzengine.base.Definition;
import mvz2logic.maps.IMapElement;

// Ported from: Assets/Scripts/MVZ2/Map/MapElement.cs
// PORT-NOTE: the two C# partial class parts (MapElement.cs and MapElement_Properties.cs) are
// merged into this single class.
class MapElement extends MonoBehaviour implements IMapElement {
    public function Init(map:IMapInterface, definition:MapElementDefinition):Void {
        mapValue = map;
        Definition = definition;
    }
    public function SetActive(value:Bool):Void {
        gameObject.SetActive(value);
    }

    private function Awake():Void {
        // PORT-NOTE: C# 的 `[SerializeField] private MapElementButton? button` 由 prefab 注入。
        // 地图元素节点（Map/MapElement.prefab）把按钮挂在**子节点**上，所以注入走
        // `ScenePrefabInjector` 时按子节点名定位；这里补一层「同一 GameObject 上没有就向下找」的
        // 兜底，避免 prefab 数据未接入时 `button.OnClick` 空引用（Awake 里直接解引用）。
        if (button == null && gameObject != null)
            button = gameObject.GetComponentInChildren(MapElementButton, true);
        if (button != null)
            button.OnClick.add(OnClickCallback);
    }
    private function OnClickCallback(button:MapElementButton):Void {
        Definition.OnClick(this);
    }

    // PORT-NOTE: IMapElement 要求 (get, never)，因此改为只读属性 + 私有后备字段。
    public var Map(get, never):IMapInterface;
    private var mapValue:IMapInterface = null;
    private function get_Map():IMapInterface return mapValue;
    public var Definition(default, null):MapElementDefinition = null;
    @:serializeField
    private var button:MapElementButton;
    public var definitionID:NamespaceIDReference;

    // ---- MapElement_Properties.cs ----
    public function GetProperty<T>(name:PropertyKey<T>):T {
        var outValue:{value:T} = {value: null};
        if (properties.TryGetProperty(name, outValue)) {
            return outValue.value;
        }
        if (Definition.TryGetProperty(name, outValue)) {
            return outValue.value;
        }
        var count = Definition.GetBehaviourCount();
        for (i in 0...count) {
            var behaviour = Definition.GetBehaviourAt(i);
            if (behaviour.TryGetProperty(name, outValue)) {
                return outValue.value;
            }
        }
        return null;
    }

    public function GetPropertyObject(name:IPropertyKey):Dynamic {
        var outValue:{value:Dynamic} = {value: null};
        if (properties.TryGetPropertyObject(name, outValue)) {
            return outValue.value;
        }
        if (Definition.TryGetPropertyObject(name, outValue)) {
            return outValue.value;
        }
        var count = Definition.GetBehaviourCount();
        for (i in 0...count) {
            var behaviour = Definition.GetBehaviourAt(i);
            if (behaviour.TryGetPropertyObject(name, outValue)) {
                return outValue.value;
            }
        }
        return null;
    }

    public function SetProperty<T>(name:PropertyKey<T>, value:T):Void {
        properties.SetProperty(name, value);
    }

    public function SetPropertyObject(name:IPropertyKey, value:Dynamic):Void {
        properties.SetPropertyObject(name, value);
    }

    private var properties:PropertyDictionary = new PropertyDictionary();
}
