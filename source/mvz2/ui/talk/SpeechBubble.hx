// Ported from: Assets/Scripts/View/Talk/SpeechBubble.cs
package mvz2.ui.talk;

import unity.Animator;
import unity.tmpro.TextMeshProUGUI;
import unity.MonoBehaviour;

class SpeechBubble extends unity.MonoBehaviour
{
	public function SetShowing(showing:Bool):Void
	{
		animator.SetBool("Show", showing);
	}
	public function ForceReshow():Void
	{
		animator.SetTrigger("Reshow");
	}
	public function SetDirection(direction:SpeechBubbleDirection):Void
	{
		animator.SetInteger("Direction", (cast direction : Int));
	}
	public function SetText(text:String):Void
	{
		talkText.text = text;
	}
	@:serializeField
	private var animator:Animator;
	@:serializeField
	private var talkText:TextMeshProUGUI;
}

enum abstract SpeechBubbleDirection(Int)
{
	var Right = 0;
	var Down = 1;
	var Left = 2;
	var Up = 3;
}
