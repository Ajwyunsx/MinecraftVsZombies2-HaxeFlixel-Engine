package coverage;

#if macro
import haxe.macro.Context;
import haxe.macro.Expr;
import sys.FileSystem;
import sys.io.File;
#end

/**
 * 验证工具：强制把 source/ 下每一个 .hx 模块（含其中的次类型）载入类型检查，
 * 用来确认 `--macro include('pkg', true)` 没有静默跳过未被引用的模块。
 * 用法：haxe ... --macro "coverage.CoverageCheck.run()"
 */
class CoverageCheck
{
	#if macro
	public static function run(sourceRoot:String = "source"):Array<Field>
	{
		var modules = [];
		walk(sourceRoot, modules);
		var failed = [];
		var ok = 0;
		for (m in modules)
		{
			try
			{
				var mod = Context.getModule(m);
				if (mod == null || mod.length == 0)
					failed.push(m + " :: module has no types");
				else
					ok++;
			}
			catch (e:Dynamic)
			{
				failed.push(m + " :: " + Std.string(e));
			}
		}
		Sys.println('[CoverageCheck] 模块总数=' + modules.length + " 类型化成功=" + ok + " 失败=" + failed.length);
		for (f in failed)
			Sys.println("[CoverageCheck] FAIL " + f);
		return null;
	}

	static function walk(dir:String, out:Array<String>):Void
	{
		if (!FileSystem.exists(dir))
			return;
		for (name in FileSystem.readDirectory(dir))
		{
			var path = dir + "/" + name;
			if (FileSystem.isDirectory(path))
				walk(path, out);
			else if (StringTools.endsWith(name, ".hx"))
			{
				var rel = path.substr("source/".length);
				rel = rel.substr(0, rel.length - 3);
				out.push(rel.split("/").join("."));
			}
		}
	}
	#end
}
