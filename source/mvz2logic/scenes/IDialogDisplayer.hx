// Ported from: Assets/Scripts/Logic/Scene/IDialogDisplayer.cs
package mvz2logic.scenes;

import system.threading.tasks.Task;
import tools.Ref;

interface IDialogDisplayer
{
	function ShowDialog(title:String, desc:String, options:Array<String>, onSelect:Int->Void):Void;
}

interface IDialogDisplayerAsync
{
	// PORT-NOTE: C# Task<int> -> Haxe shim 的 Task 非泛型，返回值改为通过 out 参数给出。
	function ShowDialogAsync(title:String, desc:String, options:Array<String>, result:Ref<Int>):Task;
}
