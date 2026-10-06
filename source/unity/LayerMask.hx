package unity;

class LayerMask {
    public var value:Int;

    public function new(value:Int = 0) {
        this.value = value;
    }

    // PORT-NOTE: Haxe 移植层没有 Unity 的 layer 注册表，这里返回名称的哈希映射到固定索引；
    // 仅用于逻辑层的位掩码比较。
    public static function NameToLayer(layerName:String):Int {
        return switch (layerName) {
            case "Default": 0;
            case "Grid": 8;
            case "RaycastReceiver": 9;
            case "Pickup": 10;
            case "LightTexture": 11;
            default: 0;
        }
    }

    public static function GetMask(layers:Array<String>):Int {
        var mask = 0;
        for (name in layers) {
            mask |= 1 << NameToLayer(name);
        }
        return mask;
    }
}
