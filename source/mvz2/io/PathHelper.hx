// Ported from: (no C# counterpart)
// PORT-NOTE: 原 C# 直接调用 `System.IO.Path.Combine`（2 参重载与 params 重载）。
// 移植时调用点统一收敛到本辅助类型，因此这里提供两种等价调用形式：
//   PathHelper.combine(a, b, c, ...)  与  PathHelper.combine(paths:Array<String>)
package mvz2.io;

class PathHelper
{
	private function new() {}

	public static function combine(a:Dynamic, ?b:Dynamic, ?c:Dynamic, ?d:Dynamic, ?e:Dynamic, ?f:Dynamic):String
	{
		var parts:Array<String> = [];
		collect(a, parts);
		collect(b, parts);
		collect(c, parts);
		collect(d, parts);
		collect(e, parts);
		collect(f, parts);
		var sep = Sys.systemName() == "Windows" ? "\\" : "/";
		var result = "";
		for (part in parts)
		{
			if (part == null || part.length == 0)
				continue;
			if (result.length == 0)
			{
				result = part;
				continue;
			}
			var base = result;
			while (base.length > 0 && (StringTools.endsWith(base, "\\") || StringTools.endsWith(base, "/")))
				base = base.substr(0, base.length - 1);
			var next = part;
			while (next.length > 0 && (StringTools.startsWith(next, "\\") || StringTools.startsWith(next, "/")))
				next = next.substr(1);
			result = base + sep + next;
		}
		return result;
	}

	private static function collect(value:Dynamic, out:Array<String>):Void
	{
		if (value == null)
			return;
		if (Std.isOfType(value, Array))
		{
			for (item in (cast value:Array<Dynamic>))
				collect(item, out);
			return;
		}
		out.push(Std.string(value));
	}
}
