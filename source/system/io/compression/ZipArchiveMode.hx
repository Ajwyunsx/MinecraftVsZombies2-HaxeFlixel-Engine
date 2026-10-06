package system.io.compression;

// Minimal System.IO.Compression.ZipArchiveMode shim.
enum abstract ZipArchiveMode(Int) {
    var Read = 0;
    var Create = 1;
    var Update = 2;
}
