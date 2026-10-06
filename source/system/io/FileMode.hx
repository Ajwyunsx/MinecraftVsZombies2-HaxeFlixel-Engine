// Ported from: System.IO.FileMode (minimal shim)
package system.io;

enum abstract FileMode(Int) from Int to Int {
    var CreateNew = 1;
    var Create = 2;
    var Open = 3;
    var OpenOrCreate = 4;
    var Truncate = 5;
    var Append = 6;
}
