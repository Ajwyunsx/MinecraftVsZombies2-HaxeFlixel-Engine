// Ported from: System.IO.IOException (minimal shim)
package system.io;

class IOException extends haxe.Exception {
    public function new(?message:String = null, ?previous:haxe.Exception) {
        super(message == null ? "I/O error" : message, previous);
    }
}
