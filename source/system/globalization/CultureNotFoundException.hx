// Ported from: System.Globalization.CultureNotFoundException (minimal shim)
package system.globalization;

class CultureNotFoundException extends haxe.Exception {
    public var InvalidCultureName:String;

    public function new(?message:String, ?invalidCultureName:String) {
        super(message);
        InvalidCultureName = invalidCultureName;
    }
}
