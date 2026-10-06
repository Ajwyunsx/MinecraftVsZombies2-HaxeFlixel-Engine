// Ported from: System.IO.FileNotFoundException (minimal shim)
package system.io;

class FileNotFoundException extends IOException {
    public function new(?message:String = null) {
        super(message == null ? "File not found" : message);
    }
}
