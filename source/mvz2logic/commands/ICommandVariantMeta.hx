// Ported from: Assets/Scripts/Logic/Command/ICommandMeta.cs
package mvz2logic.commands;

interface ICommandVariantMeta
{
	public var Description(get, never):String;
	public var Subname(get, never):String;
	public var Parameters(get, never):Array<ICommandParameterMeta>;
	function GetGrammarText(commandName:String):String;
}

// PORT-NOTE: C# ICommandVariantMeta 的默认实现（GetMaxCommandPartCount 等）在 Haxe 接口中无法保留，
// 这里抽出为静态辅助方法，调用处可用 Haxe `using` 还原为 `meta.GetMaxCommandPartCount()` 形式。
class ICommandVariantMetaHelper
{
	public static function GetMaxCommandPartCount(meta:ICommandVariantMeta):Int
	{
		return GetCommandPartIndexOfParameter(meta, meta.Parameters.length);
	}
	public static function GetCommandPartIndexOfParameter(meta:ICommandVariantMeta, parameterIndex:Int):Int
	{
		var index = parameterIndex + 1;
		if (HasSubname(meta))
		{
			index++;
		}
		return index;
	}
	public static function GetParameterIndexOfCommandPart(meta:ICommandVariantMeta, partIndex:Int):Int
	{
		var index = partIndex - 1;
		if (HasSubname(meta))
		{
			index--;
		}
		return index;
	}
	public static function HasSubname(meta:ICommandVariantMeta):Bool
	{
		// C#: !String.IsNullOrEmpty(Subname)
		return meta.Subname != null && meta.Subname.length > 0;
	}
}
