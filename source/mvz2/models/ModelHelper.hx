// Ported from: Assets/Scripts/View/Models/ModelHelper.cs
package mvz2.models;

import unity.Component;

class ModelHelper
{
	// C# 扩展方法 List<T>.ReplaceList(IEnumerable<T>)
	public static function ReplaceList<T>(list:Array<T>, targets:Array<T>):Void
	{
		var removed = Lambda.filter(list, e -> !targets.contains(e));
		for (e in removed)
		{
			list.remove(e);
		}
		for (e in targets)
		{
			if (!list.contains(e))
				list.push(e);
		}
	}
	// C# 扩展方法 Component.IsDirectChild<T>(T group)
	public static function IsDirectChild<T>(child:Component, group:T):Bool
	{
		return child.GetComponentInParent(Type.getClass(group)) == group;
	}
}
