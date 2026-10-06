// Ported from: System.Guid (minimal shim)
package system;

class Guid {
    public static function NewGuid():Guid {
        return new Guid();
    }

    private var value:String;

    public function new(?value:String) {
        this.value = value != null ? value : generate();
    }

    public function ToString(?format:String):String {
        if (format == "N") return value.split("-").join("");
        return value;
    }

    private static function generate():String {
        var chars = "0123456789abcdef";
        var sb = new StringBuf();
        for (i in 0...32) {
            if (i == 8 || i == 12 || i == 16 || i == 20) sb.add("-");
            sb.add(chars.charAt(Std.random(16)));
        }
        return sb.toString();
    }
}
