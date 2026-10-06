// Ported from: System.IO.DirectoryNotFoundException (minimal shim)
package system.io;

class DirectoryNotFoundException extends IOException {
    public function new(?message:String = null) {
        super(message == null ? "Directory not found" : message);
    }
}
