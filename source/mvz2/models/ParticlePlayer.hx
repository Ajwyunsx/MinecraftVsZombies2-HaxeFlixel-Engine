// Ported from: Assets/Scripts/View/Models/Particles/ParticlePlayer.cs
package mvz2.models;

import flixel.util.FlxSignal.FlxTypedSignal;
import unity.ParticleSystem.MinMaxCurve;  // SUBIMPORT
import mvz2logic.Global;
import unity.GameObject;
import unity.Mathf;
import unity.ParticleSystem;
import unity.ParticleSystemCurveMode;
import unity.UnityObject;
using mvz2logic.options.LogicOptionExt;  // EXTUSING

// @:RequireComponent(ParticleSystem)
class ParticlePlayer extends unity.MonoBehaviour
{
	public function SetSimulationSpeed(speed:Float):Void
	{
		var main = Particles.main;
		main.simulationSpeed = speed;
	}
	public function ToSerializable():SerializableParticleSystem
	{
		return new SerializableParticleSystem(Particles);
	}
	public function LoadFromSerializable(serializable:SerializableParticleSystem):Void
	{
		serializable.Load(Particles);
	}
	public function GetAmountMultiplier():Float
	{
		var options = Global.Options;
		var multiplier = options != null ? options.GetParticleAmount() : 1.0;
		return multiplier * (1 - minAmount) + minAmount;
	}
	function Awake():Void
	{
		var particleSystem = Particles;
		if (!UnityObject.exists(particleSystem))
		{
			// 部分由场景 prefab 转换出的装饰节点只有 ParticlePlayer，尚未带回
			// Unity ParticleSystem 组件。Unity 中这种对象不会进入可用粒子流程，
			// 这里安全跳过，避免 hxcpp 对 null 的 main/emission 访问导致启动闪退。
			return;
		}
		var multiplier = GetAmountMultiplier();

		var main = particleSystem.main;
		main.maxParticles = Mathf.RoundToInt(main.maxParticles * multiplier);

		var emission = particleSystem.emission;
		emission.rateOverTimeMultiplier *= multiplier;
		emission.rateOverDistanceMultiplier *= multiplier;
		for (i in 0...emission.burstCount)
		{
			var burst = emission.GetBurst(i);
			burst.count = MultiplyCurve(burst.count, multiplier);
			emission.SetBurst(i, burst);
		}
	}
	function Update():Void
	{
		if (particlesToEmit > 0 && Particles.main.simulationSpeed > 0)
		{
			Particles.Emit(particlesToEmit);
			particlesToEmit = 0;
		}
	}
	public function OverrideRateOverTime(rate:Float):Void
	{
		var emission = Particles.emission;
		emission.rateOverTimeMultiplier = rate * GetAmountMultiplier();
	}
	public function OverrideRateOverDistance(rate:Float):Void
	{
		var emission = Particles.emission;
		emission.rateOverDistanceMultiplier = rate * GetAmountMultiplier();
	}
	public function Emit(count:Float):Void
	{
		var intCount = Std.int(count * GetAmountMultiplier());
		emitModular += count - intCount;
		if (emitModular > 1)
		{
			intCount += Std.int(emitModular);
			emitModular %= 1;
		}
		if (intCount <= 0)
			return;
		particlesToEmit += intCount;
	}
	public static function MultiplyCurve(curve:MinMaxCurve, multiplier:Float):MinMaxCurve
	{
		switch (curve.mode)
		{
			case ParticleSystemCurveMode.Constant:
				var result = new MinMaxCurve();
				result.mode = curve.mode;
				result.constant = curve.constant * multiplier;
				return result;
			case ParticleSystemCurveMode.TwoConstants:
				var result = new MinMaxCurve();
				result.mode = curve.mode;
				result.constantMax = curve.constantMax * multiplier;
				result.constantMin = curve.constantMin * multiplier;
				return result;
			case ParticleSystemCurveMode.Curve:
				var result = new MinMaxCurve();
				result.mode = curve.mode;
				result.curve = curve.curve;
				result.curveMultiplier = curve.curveMultiplier * multiplier;
				return result;
			case ParticleSystemCurveMode.TwoCurves:
				var result = new MinMaxCurve();
				result.mode = curve.mode;
				result.curveMin = curve.curveMin;
				result.curveMax = curve.curveMax;
				result.curveMultiplier = curve.curveMultiplier * multiplier;
				return result;
		}
		return curve;
	}
	function OnParticleCollision(other:GameObject):Void
	{
		OnParticleCollisionEvent.dispatch(this, other);
	}
	public var Particles(get, never):ParticleSystem;
	function get_Particles():ParticleSystem
	{
		if (!UnityObject.exists(particles))
			particles = GetComponent(ParticleSystem);
		return particles;
	}
	public var OnParticleCollisionEvent:FlxTypedSignal<ParticlePlayer->GameObject->Void> = new FlxTypedSignal();
	private var particles:Null<ParticleSystem>;
	@:serializeField
	private var minAmount:Float = 0;
	private var emitModular:Float = 0;
	private var particlesToEmit:Int = 0;
}
