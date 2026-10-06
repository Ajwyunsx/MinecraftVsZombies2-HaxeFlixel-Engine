class Probe {
    static function hex(b:haxe.io.Bytes, n:Int):String {
        var s = [];
        for (i in 0...Std.int(Math.min(n, b.length))) s.push(StringTools.hex(b.get(i), 2));
        return s.join(" ");
    }
    static function rawDeflate(src:haxe.io.Bytes):haxe.io.Bytes {
        var z = haxe.zip.Compress.run(src, 9);
        // strip 2-byte zlib header + 4-byte adler32 trailer
        return z.sub(2, z.length - 6);
    }
    static function rawInflate(src:haxe.io.Bytes):haxe.io.Bytes {
        var u = new haxe.zip.Uncompress(-15);
        u.setFlushMode(haxe.zip.FlushMode.SYNC);
        var tmp = haxe.io.Bytes.alloc(1 << 16);
        var buf = new haxe.io.BytesBuffer();
        var pos = 0;
        while (true) {
            var r = u.execute(src, pos, tmp, 0);
            buf.addBytes(tmp, 0, r.write);
            pos += r.read;
            if (r.done) break;
        }
        u.close();
        return buf.getBytes();
    }
    static function main() {
        var src = haxe.io.Bytes.ofString('{"currentUserIndex":0,"metas":[null,null,null,null,null,null,null,null]}');
        // 1. zlib path (current impl)
        var z = haxe.zip.Compress.run(src, 9);
        Sys.println("zlib magic      = " + hex(z, 4) + "   (expect 78 da)");
        Sys.println("zlib roundtrip  = " + (haxe.zip.Uncompress.run(z).toString() == src.toString()));
        // 2. raw deflate
        var rd = rawDeflate(src);
        Sys.println("rawdeflate hdr  = " + hex(rd, 4));
        var back = rawInflate(rd);
        Sys.println("rawdeflate rt   = " + (back.toString() == src.toString()) + "  len=" + back.length);
        // 3. gzip framing
        var crc = haxe.crypto.Crc32.make(src);
        Sys.println("crc32           = " + StringTools.hex(crc, 8));
        var out = new haxe.io.BytesBuffer();
        out.addByte(0x1F); out.addByte(0x8B); out.addByte(0x08); out.addByte(0x00);
        for (_ in 0...4) out.addByte(0x00); // mtime
        out.addByte(0x00); out.addByte(0xFF); // XFL, OS=255 unknown
        out.addBytes(rd, 0, rd.length);
        out.addByte(crc & 0xFF); out.addByte((crc >> 8) & 0xFF); out.addByte((crc >> 16) & 0xFF); out.addByte((crc >>> 24) & 0xFF);
        var n = src.length;
        out.addByte(n & 0xFF); out.addByte((n >> 8) & 0xFF); out.addByte((n >> 16) & 0xFF); out.addByte((n >>> 24) & 0xFF);
        var gz = out.getBytes();
        Sys.println("gzip magic      = " + hex(gz, 4) + "   (expect 1f 8b 08 00)");
        Sys.println("gzip size       = " + gz.length + "  (src=" + src.length + ")");
        // 4. gunzip: strip 10-byte header + 8-byte trailer, raw inflate
        var payload = gz.sub(10, gz.length - 18);
        var gun = rawInflate(payload);
        Sys.println("gzip roundtrip  = " + (gun.toString() == src.toString()) + "  len=" + gun.length);
        // 5. openfl ByteArray ZLIB as reference
        var ba = openfl.utils.ByteArray.fromBytes(src);
        ba.compress(openfl.utils.CompressionAlgorithm.ZLIB);
        var bz = haxe.io.Bytes.ofData(ba);
        Sys.println("openfl zlib mg  = " + hex(bz, 4));
        sys.io.File.saveBytes("probe_out.gz", gz);
        sys.io.File.saveBytes("probe_zlib.bin", z);
        Sys.println("wrote probe_out.gz " + gz.length + " bytes, probe_zlib.bin " + z.length + " bytes");
        Sys.println("PROBE-DONE");
    }
}
