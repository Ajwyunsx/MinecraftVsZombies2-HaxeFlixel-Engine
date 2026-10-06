// Ported from: Assets/Scripts/View/Level/Artifact/ArtifactChoosingDialog.cs
package mvz2.ui.level;

import mvz2.ui.level.ArtifactSelectItem;

import flixel.util.FlxSignal.FlxTypedSignal;
import mvz2.ui.ElementList;
import unity.GameObject;
import unity.ui.Button;
import unity.MonoBehaviour;
import mvz2.ui.level.ArtifactSelectItem.ArtifactSelectItemViewData;
import flixel.util.FlxSignal;

class ArtifactChoosingDialog extends unity.MonoBehaviour
{
	public function UpdateArtifacts(items:Array<ArtifactSelectItemViewData>):Void
	{
		artifactList.updateList(items.length,
			function(i:Int, obj:GameObject)
			{
				var item = obj.GetComponent(ArtifactSelectItem);
				item.UpdateItem(items[i]);
			},
			function(obj:GameObject)
			{
				var item = obj.GetComponent(ArtifactSelectItem);
				item.OnClick.add(OnItemClickedCallback);
				item.OnPointerEnterSignal.add(OnItemPointerEnterCallback);
				item.OnPointerExitSignal.add(OnItemPointerExitCallback);
			},
			function(obj:GameObject)
			{
				var item = obj.GetComponent(ArtifactSelectItem);
				item.OnClick.remove(OnItemClickedCallback);
				item.OnPointerEnterSignal.remove(OnItemPointerEnterCallback);
				item.OnPointerExitSignal.remove(OnItemPointerExitCallback);
			});
	}
	public function GetArtifactSelectItem(index:Int):Null<ArtifactSelectItem>
	{
		return artifactList.getElementAs(index, ArtifactSelectItem);
	}
	private function Awake():Void
	{
		backButton.onClick.AddListener(() -> OnBackButtonClicked.dispatch());
	}
	private function OnItemClickedCallback(item:ArtifactSelectItem):Void
	{
		OnItemClicked.dispatch(artifactList.indexOfComponent(item));
	}
	private function OnItemPointerEnterCallback(item:ArtifactSelectItem):Void
	{
		OnItemPointerEnter.dispatch(artifactList.indexOfComponent(item));
	}
	private function OnItemPointerExitCallback(item:ArtifactSelectItem):Void
	{
		OnItemPointerExit.dispatch(artifactList.indexOfComponent(item));
	}
	public var OnItemClicked:FlxTypedSignal<Int->Void> = new FlxTypedSignal();
	public var OnItemPointerEnter:FlxTypedSignal<Int->Void> = new FlxTypedSignal();
	public var OnItemPointerExit:FlxTypedSignal<Int->Void> = new FlxTypedSignal();
	public var OnBackButtonClicked:FlxTypedSignal<Void->Void> = new FlxTypedSignal();
	@:serializeField
	private var artifactList:ElementList;
	@:serializeField
	private var backButton:Button;
}
