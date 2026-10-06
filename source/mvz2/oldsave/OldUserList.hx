// Ported from: Assets/Scripts/OldSave/OldUserList.cs

package mvz2.oldsave;

import haxe.io.Bytes;
import system.io.Stream;
import system.text.Encoding;

class OldUserList {
	public var usernames:Array<String>;

	public function new() {}

	public static function ReadStream(stream:Stream):OldUserList {
		var usernames = new Array<String>();
		for (i in 0...8)
			usernames[i] = null;

		stream.Seek(1, system.io.SeekOrigin.Begin);
		while (stream.Position < stream.Length) {
			var userNo = ReadByte(stream);
			var nameLength = ReadByte(stream);
			var name = ReadString(stream, nameLength, Encoding.UTF8);

			usernames[userNo] = name;
		}
		var result = new OldUserList();
		result.usernames = usernames;
		return result;
	}

	private static function ReadString(fileStream:Stream, length:Int, encoding:Encoding):String {
		var nameBytes = Bytes.alloc(length);
		var count = fileStream.Read(nameBytes, 0, length);
		// PORT-NOTE: C# encoding.GetString(nameBytes) → 只解码实际读到的字节数。
		return encoding.GetString(count == length ? nameBytes : nameBytes.sub(0, count > 0 ? count : 0));
	}

	// PORT-NOTE: system.io.Stream shim 未提供 Stream.ReadByte()，这里按 C# 语义（读 1 字节并前进，流末尾返回 -1）实现。
	private static function ReadByte(stream:Stream):Int {
		var buffer = Bytes.alloc(1);
		if (stream.Read(buffer, 0, 1) <= 0)
			return -1;
		return buffer.get(0);
	}
}
