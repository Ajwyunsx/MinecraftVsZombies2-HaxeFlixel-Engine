// Ported from: Assets/Scripts/View/Talk/TalkItem.cs
package mvz2.ui.talk;

import unity.Animator;
import unity.Sprite;
import unity.ui.Image;
import unity.MonoBehaviour;

class TalkItem extends unity.MonoBehaviour
{
	public function SetShowing(showing:Bool):Void
	{
		animator.SetBool("Showing", showing);
	}
	public function ForceShow():Void
	{
		animator.SetTrigger("Show");
	}
	public function SetSprite(sprite:Null<Sprite>):Void
	{
		iconImage.sprite = sprite;
	}
	@:serializeField
	private var animator:Animator;
	@:serializeField
	private var iconImage:Image;
}
