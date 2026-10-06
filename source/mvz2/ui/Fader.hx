// Ported from: Assets/Scripts/View/Widgets/Faders/Fader.cs
package mvz2.ui;

import flixel.util.FlxSignal.FlxTypedSignal;
import unity.Mathf;
import unity.MonoBehaviour;
import unity.Time;
import flixel.util.FlxSignal;

// abstract
class Fader<T> extends unity.MonoBehaviour
{
	public var Value(get, set):Null<T>;
	function get_Value():Null<T> return _value;
	function set_Value(value:Null<T>):Null<T>
	{
		SetValueWithoutNotify(value);
		OnValueChanged.dispatch(value);
		return value;
	}
	public var StartValue(get, never):Null<T>;
	function get_StartValue():Null<T> return startValue;
	public var EndValue(get, never):Null<T>;
	function get_EndValue():Null<T> return endValue;
	public var Time(get, never):Float;
	function get_Time():Float return time;
	public var Duration(get, never):Float;
	function get_Duration():Float return duration;
	public var OnValueChanged:FlxTypedSignal<Null<T>->Void> = new FlxTypedSignal();
	public var OnFadeFinished:FlxTypedSignal<Null<T>->Void> = new FlxTypedSignal();

	private var startValue:Null<T>;
	private var endValue:Null<T>;
	private var time:Float = 0;
	private var duration:Float = -1;
	private var _value:Null<T>;

	public function IsFading():Bool
	{
		return duration >= 0;
	}
	public function StartFade(target:T, duration:Float):Void
	{
		startValue = Value;
		endValue = target;
		time = 0;
		this.duration = duration;
	}
	public function StopFade():Void
	{
		time = 0;
		duration = -1;
	}
	public function SetValueWithoutNotify(value:Null<T>):Void
	{
		_value = value;
	}
	function Update():Void
	{
		if (IsFading())
		{
			if (duration == 0)
			{
				Value = EndValue;
				OnFadeFinished.dispatch(Value);
				StopFade();
			}
			else
			{
				time = Mathf.Min(time + unity.Time.deltaTime, duration);
				Value = LerpValue(StartValue, EndValue, time / duration);
				if (time >= duration)
				{
					OnFadeFinished.dispatch(Value);
					StopFade();
				}
			}
		}
	}
	// abstract
	function LerpValue(start:Null<T>, end:Null<T>, t:Float):Null<T>
	{
		throw "abstract";
	}
}
