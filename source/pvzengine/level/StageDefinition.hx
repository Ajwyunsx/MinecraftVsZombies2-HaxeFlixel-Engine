// Ported from: Assets/Scripts/Engine/Level/Level/StageDefinition.cs
package pvzengine.level;

import pvzengine.base.Definition;
import pvzengine.definitions.EngineDefinitionTypes;
import pvzengine.entities.Entity;
import pvzengine.modifiers.PropertyModifier;
import unity.Debug;

// PORT-NOTE: 既有上层代码有 16 个文件写 `import pvzengine.definitions.StageDefinition;`（C# 命名空间实为
// PVZEngine.Level），另有 40+ 个文件写 `import pvzengine.level.StageDefinition;`。
// 正典实现放在 C# 命名空间对应的 pvzengine.level，并在 pvzengine/definitions 下提供同名 typedef 别名，
// 两种 import 均可解析。
// PORT-NOTE: C# 中 EngineLevelProps 的 SetStartEnergy/SetRechargeSpeed 有一个以 StageDefinition 为
// 接收者的重载，既有调用点（mvz2/modding/ModLoader.hx）以实例形式调用，故用 @:using 挂上扩展。
@:using(pvzengine.level.EngineLevelProps)
class StageDefinition extends Definition
{
	public function new(nsp:String, name:String)
	{
		super(nsp, name);
		SetProperty(EngineStageProps.WAVES_PER_FLAG, 10);
		SetProperty(EngineLevelProps.RECHARGE_SPEED, 1.0);
	}
	private function ExecuteBehaviours(action:StageBehaviour->Void, debugName:String):Void
	{
		for (b in behaviours)
		{
			try
			{
				action(b);
			}
			catch (ex:Dynamic)
			{
				Debug.LogError('关卡行为${b}在执行${debugName}时出现错误：${ex}');
			}
		}
	}
	public function Setup(level:LevelEngine):Void
	{
		ExecuteBehaviours(b -> b.Setup(level), "Setup");
		OnSetup(level);
	}
	public function Start(level:LevelEngine):Void
	{
		ExecuteBehaviours(b -> b.Start(level), "Start");
		OnStart(level);
	}
	public function Update(level:LevelEngine):Void
	{
		ExecuteBehaviours(b -> b.Update(level), "Update");
		OnUpdate(level);
	}
	public function PrepareForBattle(level:LevelEngine):Void
	{
		ExecuteBehaviours(b -> b.PrepareForBattle(level), "PrepareForBattle");
		OnPrepareForBattle(level);
	}
	public function PostWave(level:LevelEngine, wave:Int):Void
	{
		ExecuteBehaviours(b -> b.PostWave(level, wave), "PostWave");
		OnPostWave(level, wave);
	}
	public function PostHugeWaveEvent(level:LevelEngine):Void
	{
		ExecuteBehaviours(b -> b.PostHugeWaveEvent(level), "PostHugeWaveEvent");
		OnPostHugeWave(level);
	}
	public function PostFinalWaveEvent(level:LevelEngine):Void
	{
		ExecuteBehaviours(b -> b.PostFinalWaveEvent(level), "PostFinalWaveEvent");
		OnPostFinalWave(level);
	}
	public function PostEnemySpawned(entity:Entity):Void
	{
		ExecuteBehaviours(b -> b.PostEnemySpawned(entity), "PostEnemySpawned");
		OnPostEnemySpawned(entity);
	}
	public function OnSetup(level:LevelEngine):Void {}
	public function OnStart(level:LevelEngine):Void {}
	public function OnUpdate(level:LevelEngine):Void {}
	public function OnPrepareForBattle(level:LevelEngine):Void {}
	public function OnPostWave(level:LevelEngine, wave:Int):Void {}
	public function OnPostHugeWave(level:LevelEngine):Void {}
	public function OnPostFinalWave(level:LevelEngine):Void {}
	public function OnPostEnemySpawned(entity:Entity):Void {}
	// C#: protected void AddBehaviour(StageBehaviour behaviour)
	// PORT-NOTE: Haxe 无 protected，private 对子类可见，语义等价。
	private function AddBehaviour(behaviour:StageBehaviour):Void
	{
		behaviours.push(behaviour);
	}
	// PORT-NOTE: C# 有两个重载 HasBehaviour<T>() where T : StageBehaviour 与 HasBehaviour(StageBehaviour)。
	// Haxe 不支持重载，合并为单方法 + Dynamic 形参：
	//   传入 StageBehaviour 实例时按引用比较；传入 Class<T>（既有调用点 LogicLevelExt.HasBehaviourType、
	//   LogicLevelExt.HasBehaviour）时按类型比较。
	public function HasBehaviour(behaviour:Dynamic):Bool
	{
		if (Std.isOfType(behaviour, StageBehaviour))
		{
			for (beh in behaviours)
			{
				if (beh == behaviour)
					return true;
			}
			return false;
		}
		for (b in behaviours)
		{
			if (Std.isOfType(b, cast behaviour))
				return true;
		}
		return false;
	}
	// PORT-NOTE: C# 泛型方法 GetBehaviour<T>() 在 Haxe 中无法由类型参数取得运行期类型，
	// 故以可选参数传入类型对象：`GetBehaviour(T)`。
	// TODO-PORT: 既有调用点 mvz2/vanilla/level/VanillaLevelExt.hx:48 写作 `GetBehaviour<T>()`（无实参），
	// Haxe 无法解析运行期类型，此时返回 null。集成阶段建议把该调用点改为 `GetBehaviour(T)`。
	public function GetBehaviour<T:StageBehaviour>(?typeClass:Class<T>):Null<T>
	{
		if (typeClass == null)
			return null;
		for (b in behaviours)
		{
			if (Std.isOfType(b, typeClass))
				return cast b;
		}
		return null;
	}
	public function GetModifiers():Array<PropertyModifier>
	{
		// C#: behaviours.SelectMany(b => b.GetModifiers()).ToArray()
		var results:Array<PropertyModifier> = [];
		for (b in behaviours)
		{
			results = results.concat(b.GetModifiers());
		}
		return results;
	}
	public override function GetDefinitionType():String return EngineDefinitionTypes.STAGE;
	private var behaviours:Array<StageBehaviour> = [];
}
