// Ported from: System.IO.SeekOrigin (minimal shim)
package system.io;

enum abstract SeekOrigin(Int) from Int to Int {
    var Begin = 0;
    var Current = 1;
    var End = 2;
}
