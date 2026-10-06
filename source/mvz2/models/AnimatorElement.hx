// Ported from: Assets/Scripts/View/Models/Elements/AnimatorElement.cs
package mvz2.models;
import mvz2.models.Model.SerializableAnimator;  // IMPORTAUTO

import pvzengine.models.IAnimatorInterface;
import unity.Animator;

// @:RequireComponent(Animator)
class AnimatorElement extends unity.MonoBehaviour implements IAnimatorInterface
{
	public var Animator(get, never):Animator;
	function get_Animator():Animator
	{
		if (animator == null)
		{
			animator = GetComponent(unity.Animator);
		}
		return animator;
	}
	public function SetTrigger(name:String):Void
	{
		Animator.SetTrigger(name);
	}

	public function SetBool(name:String, value:Bool):Void
	{
		Animator.SetBool(name, value);
	}

	public function SetInt(name:String, value:Int):Void
	{
		Animator.SetInteger(name, value);
	}

	public function SetFloat(name:String, value:Float):Void
	{
		Animator.SetFloat(name, value);
	}

	public function GetLayerWeight(name:String):Float
	{
		var index = Animator.GetLayerIndex(name);
		if (index < 0)
			return 0;
		return Animator.GetLayerWeight(index);
	}
	public function SetLayerWeight(name:String, value:Float):Void
	{
		var index = Animator.GetLayerIndex(name);
		if (index < 0)
			return;
		Animator.SetLayerWeight(index, value);
	}
	public function ToSerializable():Null<SerializableAnimator>
	{
		if (Animator == null)
			return null;
		return new SerializableAnimator(Animator);
	}
	private var animator:Animator = null;
	public var elementName:Null<String>;
}
