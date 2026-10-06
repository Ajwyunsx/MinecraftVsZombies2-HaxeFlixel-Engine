// Ported from: Assets/Scripts/Logic/Options/IOptionContext.cs
package mvz2logic.options;

import mvz2logic.games.IGlobalOptions;
import pvzengine.NamespaceID;
import pvzengine.level.LevelEngine;
import tools.Ref;

// PORT-NOTE: C# 的 `out T value` 参数在 Haxe 中用 tools.Ref<T> 还原引用语义。
interface IOptionContext
{
	function CacheOptionBool(id:NamespaceID, value:Bool):Void;
	function CacheOptionInt(id:NamespaceID, value:Int):Void;
	function CacheOptionFloat(id:NamespaceID, value:Float):Void;
	function CacheOptionString(id:NamespaceID, value:String):Void;
	function CacheOptionID(id:NamespaceID, value:Null<NamespaceID>):Void;
	function TryGetCachedOptionBool(id:NamespaceID, value:Ref<Bool>):Bool;
	function TryGetCachedOptionInt(id:NamespaceID, value:Ref<Int>):Bool;
	function TryGetCachedOptionFloat(id:NamespaceID, value:Ref<Float>):Bool;
	function TryGetCachedOptionString(id:NamespaceID, value:Ref<String>):Bool;
	function TryGetCachedOptionID(id:NamespaceID, value:Ref<Null<NamespaceID>>):Bool;
	function FlushCachedOptions(options:IGlobalOptions):Void;
	function SetNeedReload():Void;
	function NeedsReload():Bool;
}

interface IOptionContextMainmenu extends IOptionContext
{
}

interface IOptionContextMap extends IOptionContext
{
}

interface IOptionContextLevel extends IOptionContext
{
	function GetLevel():LevelEngine;
}
