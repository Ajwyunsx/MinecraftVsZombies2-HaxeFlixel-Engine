// Ported from: Assets/Scripts/Logic/Command/CommandUtility.cs
package mvz2logic.commands;

import mvz2logic.ParseHelper;
import pvzengine.NamespaceID;

class CommandUtility
{
	public static function SplitCommand(command:String):Array<String>
	{
		if (!StringTools.startsWith(command, COMMAND_CHARACTER))
			return [];
		command = command.substr(1);

		var parts:Array<String> = [];
		var sb = new StringBuf();
		for (i in 0...command.length)
		{
			var c = command.charAt(i);
			if (isWhiteSpace(c))
			{
				parts.push(sb.toString());
				sb = new StringBuf();
			}
			else
			{
				sb.add(c);
			}
		}

		parts.push(sb.toString());
		sb = new StringBuf();

		return parts;
	}
	// PORT-NOTE: C# 用 char.IsWhiteSpace 判断空白字符，Haxe 无直接对应，此处等价实现。
	private static function isWhiteSpace(c:String):Bool
	{
		return c == " " || c == "\t" || c == "\n" || c == "\r" || c == "\x0b" || c == "\x0c"
			|| c == "\u00a0" || c == "\u2028" || c == "\u2029" || c == "\u3000";
	}
	public static function ParseOptionalFloat(text:String, defaultValue:Float):Float
	{
		if (text == DEFAULT_VALUE_PARAMETER)
		{
			return defaultValue;
		}
		return ParseHelper.ParseFloat(text);
	}
	public static function ParseOptionalInt(text:String, defaultValue:Int):Int
	{
		if (text == DEFAULT_VALUE_PARAMETER)
		{
			return defaultValue;
		}
		return ParseHelper.ParseInt(text);
	}
	public static function ParseOptionalNamespaceID(text:String, defaultNsp:String, defaultValue:Null<NamespaceID>):Null<NamespaceID>
	{
		if (text == DEFAULT_VALUE_PARAMETER)
		{
			return defaultValue;
		}
		// PORT-NOTE: C# `out NamespaceID? parsed` → NamespaceID.TryParse 的 {value:Dynamic} 引用容器。
		var ref = { value: (null : Dynamic) };
		return NamespaceID.TryParse(text, defaultNsp, ref) ? cast ref.value : null;
	}
	public static inline var COMMAND_CHARACTER:String = "/";
	public static inline var DEFAULT_VALUE_PARAMETER:String = "~";
}
