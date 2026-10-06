// Ported from: Assets/Scripts/Logic/Artifacts/Artifact.cs
// Ported from: Assets/Scripts/Logic/Artifacts/Artifact_Properties.cs
// Ported from: Assets/Scripts/Logic/Artifacts/Artifact_Aura.cs
// PORT-NOTE: C# 中 Artifact 是 partial class（三个文件），按 PORTING.md "partial class 合并为一个类文件" 合并到本文件。
package mvz2logic.artifacts;

import haxe.Int64;
import pvzengine.NamespaceID;
import pvzengine.PropertyDictionary;
import pvzengine.PropertyKey;
import pvzengine.auras.AuraEffect;
import pvzengine.auras.AuraEffectDefinition;
import pvzengine.auras.AuraEffectList;
import pvzengine.auras.IAuraSource;
import pvzengine.base.MissingDefinitionException;
import pvzengine.entities.Entity;
import pvzengine.level.ILevelObject;
import pvzengine.level.LevelEngine;
import tools.RandomGenerator;
import unity.Debug;
using mvz2logic.games.LogicGameDefinitionsExt;
using mvz2logic.level.LogicLevelExt;
using mvz2logic.level.LogicLevelProps;

// abstract
class Artifact implements IAuraSource
{
	// #region 构造器
	// PORT-NOTE: C# 有 public Artifact(level, definition) 与 private Artifact(level, definition, rng) 两个构造函数，
	// Haxe 不支持重载，用可选参数合并（rng 为 null 时等价于第一个构造函数）。
	public function new(level:LevelEngine, definition:ArtifactDefinition, ?rng:RandomGenerator)
	{
		if (rng == null)
		{
			rng = CreateRNG(level);
		}
		Level = level;
		Definition = definition;
		RNG = rng;

		CreateAuraEffects();
	}
	// #endregion

	// #region 生命周期
	public function Update():Void
	{
		if (Definition != null)
			Definition.PostUpdate(this);
		UpdateAuras();
	}
	public function PostAdd():Void
	{
		Level.IncreaseLevelObjectReference(this);
		Definition.PostAdd(this);
	}
	public function PostRemove():Void
	{
		Level.DecreaseLevelObjectReference(this);
		Definition.PostRemove(this);
	}
	// #endregion

	// #region 序列化
	public function ToSerializable():SerializableArtifact
	{
		var seri = new SerializableArtifact();
		seri.definitionID = Definition.GetID();
		WritePropertiesToSerializable(seri);
		WriteAurasToSerializable(seri);
		return seri;
	}
	public static function CreateFromSerializable(seri:SerializableArtifact, level:LevelEngine):Null<Artifact>
	{
		var definition = level.Content.GetArtifactDefinition(seri.definitionID);
		if (definition == null)
		{
			var exception = new MissingDefinitionException('Trying to deserialize an artifact with missing definition ${seri.definitionID}.');
			Debug.LogException(exception);
			return null;
		}
		var rng:RandomGenerator;
		if (seri.rng != null)
		{
			rng = RandomGenerator.FromSerializable(seri.rng);
		}
		else
		{
			rng = CreateRNG(level);
		}
		var artifact = new Artifact(level, definition, rng);
		artifact.InitFromSerializable(seri);
		return artifact;
	}
	private function InitFromSerializable(seri:SerializableArtifact):Void
	{
		InitPropertiesFromSerializable(seri);
	}
	public function LoadFromSerializable(seri:SerializableArtifact):Void
	{
		LoadAurasFromSerializable(seri);
	}
	// #endregion

	// #region 杂项
	public function Highlight():Void
	{
		dispatchOnHighlighted();
	}
	private static function CreateRNG(level:LevelEngine):RandomGenerator
	{
		var artifactRNG = level.GetArtifactRNG();
		return new RandomGenerator(artifactRNG.Next());
	}

	// PORT-NOTE: Haxe 中 Artifact 无父类，C# 的 Object.ToString() 覆写改为普通方法声明。
	public function toString():String
	{
		return 'Artifact_${Definition}';
	}
	// #endregion

	// #region ILevelObject接口实现
	// PORT-NOTE: C# 显式接口实现（Entity? ILevelObject.GetEntity() 等）在 Haxe 中为普通公开方法。
	public function GetEntity():Null<Entity>
	{
		return null;
	}
	public function GetLevel():LevelEngine
	{
		return Level;
	}
	public function Exists():Bool
	{
		return Level.HasArtifact(Definition.GetID());
	}
	public function OnAddToLevel(level:LevelEngine):Void
	{
		auras.PostAdd();
	}
	public function OnRemoveFromLevel(level:LevelEngine):Void
	{
		auras.PostRemove();
	}
	public function GetChildrenObjects():Array<ILevelObject>
	{
		// C#: yield break;
		return [];
	}
	// #endregion

	// #region 事件
	// PORT-NOTE: C# event Action<Artifact>? OnHighlighted -> Array<Artifact->Void>；+= / -= 改为 push / remove。
	public var OnHighlighted:Array<Artifact->Void> = [];
	private function dispatchOnHighlighted():Void
	{
		for (f in OnHighlighted.copy())
		{
			f(this);
		}
	}
	// #endregion

	// #region 属性字段
	public var Level(default, null):LevelEngine;
	public var Definition(default, null):ArtifactDefinition;
	public var RNG(default, null):RandomGenerator;
	// #endregion

	// ===================== Artifact_Properties.cs =====================
	// #region 属性
	public function SetProperty<T>(name:PropertyKey<T>, value:Null<T>):Void
	{
		propertyDict.SetProperty(name, value);
	}
	public function GetProperty<T>(name:PropertyKey<T>):Null<T>
	{
		// PORT-NOTE: C# `out T value` → PropertyDictionary.TryGetProperty 的 {value:T} 引用容器。
		var thisProp = { value: (null : Null<T>) };
		if (propertyDict.TryGetProperty(name, thisProp))
			return thisProp.value;
		return Definition.GetProperty(name);
	}
	// #endregion

	// #region 序列化
	private function WritePropertiesToSerializable(seri:SerializableArtifact):Void
	{
		seri.propertyDict = propertyDict.ToSerializable();
	}
	private function InitPropertiesFromSerializable(seri:SerializableArtifact):Void
	{
		propertyDict.LoadFromSerializable(seri.propertyDict);
	}
	// #endregion

	// #region 属性字段
	private var propertyDict:PropertyDictionary = new PropertyDictionary();
	// #endregion

	// ===================== Artifact_Aura.cs =====================
	public function CreateAuraEffects():Void
	{
		var auraDefs = Definition.GetAuras();
		for (i in 0...auraDefs.length)
		{
			var auraDef = auraDefs[i];
			auras.Add(Level, new AuraEffect(auraDef, i, this));
		}
	}
	private function UpdateAuras():Void
	{
		auras.Update();
	}

	// #region 获取
	// PORT-NOTE: C# AuraEffectList.Get<T>() 与 Get(AuraEffectDefinition) 为重载，Haxe 不支持重载，
	// 泛型版在移植层命名为 GetOfType（构造时把类对象作为参数传入）。
	public function GetAuraEffect<T:AuraEffectDefinition>():AuraEffect
	{
		return auras.GetOfType();
	}
	public function GetAuraEffects():Array<AuraEffect>
	{
		return auras.GetAll();
	}
	// #endregion

	// #region 序列化
	private function WriteAurasToSerializable(seri:SerializableArtifact):Void
	{
		seri.auras = [for (a in auras.GetAll()) a.ToSerializable()];
	}
	private function LoadAurasFromSerializable(seri:SerializableArtifact):Void
	{
		if (seri.auras == null)
			return;
		auras.LoadFromSerializable(Level, seri.auras);
	}
	// #endregion

	// #region 属性字段
	private var auras:AuraEffectList = new AuraEffectList();
	// #endregion
}
