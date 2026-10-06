package unity;

// Minimal UnityEngine.SortingLayer shim.
//
// PORT-NOTE: 排序层是**工程级配置**（`ProjectSettings/TagManager.asset` 的 `m_SortingLayers`），
// Unity 用它在运行期把名字与 uniqueID 互查；SpriteRenderer 同时有 `sortingLayerName`（编辑器里填）
// 与 `sortingLayerID`（序列化进 prefab 的哈希）。移植层原先只有 "Default" 一层，
// 于是**所有 14 个工程排序层都退化成 0**，按层排序完全失效
// （`mvz2/ui/UiRenderer.hx` 的 `stableSortWorldSprites` 正是按 sortingLayerID 排序，
// 而 prefab 里 Background=-2057763135 / Almanac=1742501395 / Talk=1660876549 …）。
//
// 下面的表逐条抄自 `ProjectSettings/TagManager.asset` 的 `m_SortingLayers`（**顺序即 Unity 的
// 渲染层级顺序**，下标就是 `SortingLayer.value`）。uniqueID 在 YAML 里是无符号 32 位，
// Unity 的 `SortingLayer.id` 是 Int32，所以这里存同一批位的 Int32 表示
// （2237204161 → -2057763135），与 prefab 导出的 `sortingLayerID` 逐位一致。
class SortingLayer {
    /** 名字，顺序 = `TagManager.asset` 里 `m_SortingLayers` 的声明顺序 = 渲染层级顺序。 */
    private static var names:Array<String> = [
        "Background", "Ground", "Receivers", "Night", "Grid", "Carriers", "Shadow",
        "BackUI", "Default", "Foreground", "VolumeLight", "Pickups", "FrontUI",
        "CollectedPickups", "Talk", "Money", "BlueprintChoose", "Almanac", "Dialog", "ScreenCover"
    ];
    /** 名字 -> Int32 层 ID（YAML uniqueID 的有符号表示）。 */
    private static var ids:Map<String, Int> = [
        "Background" => -2057763135,
        "Ground" => -1699733281,
        "Receivers" => 683829979,
        "Night" => -367218617,
        "Grid" => -1992807571,
        "Carriers" => -2028222091,
        "Shadow" => -1508385975,
        "BackUI" => -2092243167,
        "Default" => 0,
        "Foreground" => -4036897,
        "VolumeLight" => 1572647217,
        "Pickups" => -238001431,
        "FrontUI" => -184251447,
        "CollectedPickups" => 1191350193,
        "Talk" => 1660876549,
        "Money" => -347959239,
        "BlueprintChoose" => 1393130353,
        "Almanac" => 1742501395,
        "Dialog" => -1816132019,
        "ScreenCover" => 1206696159
    ];
    /** 层 ID -> 层级序号（`SortingLayer.value`）。 */
    private static var order:Map<Int, Int> = buildOrder();

    private static function buildOrder():Map<Int, Int> {
        var result = new Map<Int, Int>();
        for (i in 0...names.length)
            result.set(ids.get(names[i]), i);
        return result;
    }

    /** Unity 的 `SortingLayer.layers`：按层级顺序列出全部层。 */
    public static var layers(get, never):Array<SortingLayerInfo>;
    static function get_layers():Array<SortingLayerInfo> {
        var result:Array<SortingLayerInfo> = [];
        for (i in 0...names.length) {
            var name = names[i];
            result.push(new SortingLayerInfo(name, ids.get(name), i));
        }
        return result;
    }

    /** Unity 的 `SortingLayer.IDToName`：未知 ID 返回空串。 */
    public static function IDToName(id:Int):String {
        for (name in names) {
            if (ids.get(name) == id) return name;
        }
        return "";
    }
    /** Unity 的 `SortingLayer.NameToID`：未知名字返回 0（Default）。 */
    public static function NameToID(name:String):Int {
        return name != null && ids.exists(name) ? ids.get(name) : 0;
    }
    /** Unity 的 `SortingLayer.GetLayerValueFromID`：该层在层级里的序号（`SortingLayer.value`）。 */
    public static function GetLayerValueFromID(id:Int):Int {
        var value = order.get(id);
        return value != null ? value : order.get(0);
    }

    /**
     * 移植层新增：`(排序层, 同层内 sortingOrder)` 的字典序排序键。
     * `mvz2.ui.UiRenderer` 用它稳定排序世界空间 SpriteRenderer。
     * PORT-NOTE: `sortingOrder` 的有效范围远小于 100000（工程内实测 |order| ≤ 20000），
     * 因此这个打包不会溢出。
     */
    public static function SortKeyOf(id:Int, sortingOrder:Int):Int {
        return GetLayerValueFromID(id) * 100000 + sortingOrder;
    }

    /** 供工程/测试注册额外层（Unity 的层是编辑器资产，移植层允许运行期补充）。 */
    public static function RegisterLayer(name:String, id:Int):Void {
        if (name == null || ids.exists(name))
            return;
        order.set(id, names.length);
        ids.set(name, id);
        names.push(name);
    }
}

class SortingLayerInfo {
    public var name:String;
    public var id:Int;
    /** Unity 的 `SortingLayer.value` 是"该层在 layers 里的下标"，用于比较排序先后。 */
    public var value:Int;
    public function new(name:String, id:Int, value:Int) {
        this.name = name;
        this.id = id;
        this.value = value;
    }
}
