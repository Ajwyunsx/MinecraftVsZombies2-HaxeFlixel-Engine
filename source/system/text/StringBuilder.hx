// Ported from: System.Text.StringBuilder (minimal shim)
package system.text;

class StringBuilder {
    private var buffer:StringBuf;

    public function new(?value:String) {
        buffer = new StringBuf();
        if (value != null) buffer.add(value);
        Length = 0;
    }

    public var Length:Int;

    public function Append(value:Dynamic):StringBuilder {
        var s = value == null ? "" : Std.string(value);
        buffer.add(s);
        Length += s.length;
        return this;
    }

    public function AppendLine(value:Dynamic):StringBuilder {
        Append(value);
        return Append("\n");
    }

    public function Insert(index:Int, value:Dynamic):StringBuilder {
        var s = value == null ? "" : Std.string(value);
        var current = ToString();
        if (index < 0) index = 0;
        if (index > current.length) index = current.length;
        buffer = new StringBuf();
        buffer.add(current.substr(0, index));
        buffer.add(s);
        buffer.add(current.substr(index));
        Length = current.length + s.length;
        return this;
    }

    public function Clear():StringBuilder {
        buffer = new StringBuf();
        Length = 0;
        return this;
    }

    public function ToString():String {
        return buffer.toString();
    }
}
