// Ported from: System.FormatException (minimal shim)
package system;

class FormatException extends haxe.Exception {
    public function new(?message:String = null, ?previous:haxe.Exception) {
        super(message == null ? "Invalid format" : message, previous);
    }
}
