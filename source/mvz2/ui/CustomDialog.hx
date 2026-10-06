// Ported from: Assets/Scripts/View/Dialogs/CustomDialog.cs
package mvz2.ui;

import flixel.util.FlxSignal.FlxTypedSignal;
import mvz2.ui.ButtonRow;
import mvz2.ui.ElementListUI;
import unity.Mathf;
import unity.RectTransform;
import unity.UnityObject;
import unity.tmpro.TextMeshProUGUI;
import flixel.util.FlxSignal;

class CustomDialog extends Dialog
{
	public function SetInteractable(interactable:Bool):Void
	{
		for (i in 0...buttonRowList.count)
		{
			var row = buttonRowList.getElementAs(i, ButtonRow);
			if (!UnityObject.exists(row))
				continue;
			row.SetInteractable(interactable);
		}
	}
	public function SetDialog(titleText:String, descText:String, options:Array<String>, onSelect:Int->Void):Void
	{
		title.text = titleText;
		desc.text = descText;
		// PORT-NOTE: C# OnOptionSelect 是 Action<int>?（普通委托），Haxe 侧同样用函数字段而非信号。
		OnOptionSelect = onSelect;

		var rowCount = Mathf.CeilToInt(options.length / countPerRow);
		buttonRowList.updateList(rowCount,
			function(i:Int, rect:RectTransform)
			{
				var row = rect.GetComponent(ButtonRow);
				row.UpdateButtons(options.slice(i * countPerRow, i * countPerRow + countPerRow));
			},
			function(rect:RectTransform)
			{
				var row = rect.GetComponent(ButtonRow);
				row.OnButtonClick.add(OnButtonRowItemClickCallback);
			},
			function(rect:RectTransform)
			{
				var row = rect.GetComponent(ButtonRow);
				row.OnButtonClick.remove(OnButtonRowItemClickCallback);
			});
	}
	private function OnButtonRowItemClickCallback(row:ButtonRow, index:Int):Void
	{
		var rowIndex = buttonRowList.indexOfComponent(row);
		var realIndex = rowIndex * countPerRow + index;
		if (OnOptionSelect != null) OnOptionSelect(realIndex);
	}
	private var OnOptionSelect:Int->Void;
	@:serializeField
	private var title:TextMeshProUGUI;
	@:serializeField
	private var desc:TextMeshProUGUI;
	@:serializeField
	private var buttonRowList:ElementListUI;
	@:serializeField
	private var countPerRow:Int = 2;
}
