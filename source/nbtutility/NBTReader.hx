// Ported from: NBTUtility.dll (NBTReader) — 外部预编译库，仓库内无 C# 源码

package nbtutility;

import haxe.io.Bytes;
import system.io.Stream;
import system.text.Encoding;

// PORT-NOTE: NBTUtility 为预编译 DLL，其 NBTReader 源码不在仓库中；
// 这里按 NBT 二进制格式（大端、标签树）重写最小等价读取器。
class NBTReader {
	public static inline var TagEnd = 0;
	public static inline var TagByte = 1;
	public static inline var TagShort = 2;
	public static inline var TagInt = 3;
	public static inline var TagLong = 4;
	public static inline var TagFloat = 5;
	public static inline var TagDouble = 6;
	public static inline var TagByteArray = 7;
	public static inline var TagString = 8;
	public static inline var TagList = 9;
	public static inline var TagCompound = 10;
	public static inline var TagIntArray = 11;
	public static inline var TagLongArray = 12;

	public var stream:Stream;
	public var encoding:Encoding;

	public function new(stream:Stream, ?encoding:Encoding) {
		this.stream = stream;
		this.encoding = encoding != null ? encoding : Encoding.UTF8;
	}

	// 读取根标签（必定为复合标签）。
	public function ReadRoot():NBTData {
		var type = ReadByte();
		if (type == TagEnd)
			return new NBTData();
		if (type != TagCompound)
			throw 'Root NBT tag is not a compound: ${type}';
		ReadString(); // 根标签名，无实际用途
		return ReadCompound();
	}

	public function ReadByte():Int {
		return readBuffer(1).get(0);
	}
	public function ReadUnsignedShort():Int {
		var b = readBuffer(2);
		return (b.get(0) << 8) | b.get(1);
	}
	public function ReadShort():Int {
		var b = readBuffer(2);
		var v = (b.get(0) << 8) | b.get(1);
		return v >= 0x8000 ? v - 0x10000 : v;
	}
	public function ReadInt():Int {
		var b = readBuffer(4);
		return (b.get(0) << 24) | (b.get(1) << 16) | (b.get(2) << 8) | b.get(3);
	}
	public function ReadLong():haxe.Int64 {
		return readBuffer(8).getInt64(0);
	}
	public function ReadFloat():Float {
		return readBuffer(4).getFloat(0);
	}
	public function ReadDouble():Float {
		return readBuffer(8).getDouble(0);
	}
	public function ReadString():String {
		var length = ReadUnsignedShort();
		if (length <= 0)
			return "";
		return readBuffer(length).toString();
	}
	public function ReadBytes(length:Int):Bytes {
		return readBuffer(length);
	}

	public function ReadTag(type:Int):Dynamic {
		switch (type) {
			case TagByte:
				return ReadByte();
			case TagShort:
				return ReadShort();
			case TagInt:
				return ReadInt();
			case TagLong:
				return ReadLong();
			case TagFloat:
				return ReadFloat();
			case TagDouble:
				return ReadDouble();
			case TagByteArray:
				return ReadBytes(ReadInt());
			case TagString:
				return ReadString();
			case TagList:
				return ReadList();
			case TagCompound:
				return ReadCompound();
			case TagIntArray:
				var count = ReadInt();
				var ints = new Array<Int>();
				for (i in 0...count)
					ints.push(ReadInt());
				return ints;
			case TagLongArray:
				var longCount = ReadInt();
				var longs = new Array<haxe.Int64>();
				for (i in 0...longCount)
					longs.push(ReadLong());
				return longs;
			case _:
				throw 'Unknown NBT tag type: ${type}';
		}
	}

	public function ReadCompound():NBTData {
		var data = new NBTData();
		while (true) {
			var type = ReadByte();
			if (type == TagEnd)
				break;
			var name = ReadString();
			data.set(name, ReadTag(type));
		}
		return data;
	}

	public function ReadList():Array<Dynamic> {
		var elementType = ReadByte();
		var length = ReadInt();
		var result = new Array<Dynamic>();
		for (i in 0...length) {
			result.push(ReadTag(elementType));
		}
		return result;
	}

	private function readBuffer(count:Int):Bytes {
		var buffer = Bytes.alloc(count);
		var offset = 0;
		while (offset < count) {
			var read = stream.Read(buffer, offset, count - offset);
			if (read <= 0)
				throw "Unexpected end of NBT stream";
			offset += read;
		}
		return buffer;
	}
}
