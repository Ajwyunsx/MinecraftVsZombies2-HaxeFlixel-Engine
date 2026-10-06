// Ported from: System.IO.SearchOption (minimal shim)
package system.io;

enum abstract SearchOption(Int) from Int to Int {
    var TopDirectoryOnly = 0;
    var AllDirectories = 1;
}
