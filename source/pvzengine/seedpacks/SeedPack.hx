// Ported from: Assets/Scripts/Engine/Level/SeedPacks/SeedPack.cs
//             以及同目录的 SeedPack_Aura.cs / SeedPack_Buff.cs / SeedPack_Model.cs / SeedPack_Properties.cs
// PORT-NOTE: C# 分部类（partial class）无法跨文件实现，按 PORTING.md 合并为单一 SeedPack.hx。
//
// PORT-NOTE: C# 中 EngineSeedProps 的扩展方法（seed.GetRecharge() / SetStartRecharge() / IsCharged() 等）
//   被既有上层代码以实例形式调用（mvz2/gamecontent/contraptions/DesirePot.hx、mvz2logic/level/LogicLevelExt.hx 等），
//   故沿用移植层既有做法（同 pvzengine.level.ILevelSourceReference），用 @:using 挂到 SeedPack 上。
package pvzengine.seedpacks;

import flixel.util.FlxSignal.FlxTypedSignal;
import haxe.Int64;
import pvzengine.IPropertyKey;
import pvzengine.NamespaceID;
import pvzengine.PropertyKey;
import pvzengine.auras.AuraEffect;
import pvzengine.auras.AuraEffectDefinition;
import pvzengine.auras.AuraEffectList;
import pvzengine.auras.IAuraSource;
import pvzengine.buffs.Buff;
import pvzengine.buffs.BuffList;
import pvzengine.buffs.BuffReference;
import pvzengine.buffs.IBuffList;
import pvzengine.buffs.IModeledBuffTarget;
import pvzengine.buffs.ModelInsertion;
import pvzengine.entities.Entity;
import pvzengine.level.ILevelObject;
import pvzengine.level.IModifiablePropertyTarget;
import pvzengine.level.LevelEngine;
import pvzengine.level.PropertyBlock;
import pvzengine.models.IModelInterface;
import unity.Mathf;
using pvzengine.ContentProviderHelper;
using pvzengine.buffs.BuffTargetExt;

@:using(pvzengine.buffs.BuffTargetExt)
// PORT-NOTE: C# 为 `abstract class SeedPack`（含 abstract Exists() / GetBuffReference()）。
//   按 PORTING.md「抽象类仍写 class」改为普通 class，抽象方法以 throw "abstract" 占位。
class SeedPack implements IModifiablePropertyTarget implements IAuraSource implements IModeledBuffTarget
{
	// #region 构造器
	public function new(level:LevelEngine, definition:SeedDefinition, id:Int64)
	{
		ID = id;
		Level = level;
		Definition = definition;

		// PORT-NOTE: C# `PropertyBlock(container, params IModifierProvider[] providers)` → Haxe 传数组实参。
		properties = new PropertyBlock(this, [buffs]);
		InitBuffs();
		CreateAuraEffects();
	}
	// #endregion

	// #region 生命周期
	public function Update(rechargeSpeed:Float):Void
	{
		OnUpdate(rechargeSpeed);
		UpdateAuras();
		UpdateBuffs();
		Definition.Update(this, rechargeSpeed);
	}
	// C#: protected virtual void OnUpdate(float rechargeSpeed)
	private function OnUpdate(rechargeSpeed:Float):Void
	{
	}
	// #endregion

	// #region 消耗
	public function GetCost():Int
	{
		var cost = GetProperty(EngineSeedProps.COST);
		cost = Mathf.Max(cost, 0);
		return Mathf.FloorToInt(cost);
	}
	// #endregion

	// #region 充能
	public function GetRechargeDefinition():Null<RechargeDefinition>
	{
		var rechargeID = this.GetRechargeID();
		if (rechargeID == null)
			return null;
		return Level.Content.GetRechargeDefinition(rechargeID);
	}
	public function GetStartMaxRecharge():Int
	{
		var rechargeDef = GetRechargeDefinition();
		if (rechargeDef == null)
			return 0;
		return rechargeDef.GetStartMaxRecharge();
	}
	public function GetUsedMaxRecharge():Int
	{
		var rechargeDef = GetRechargeDefinition();
		if (rechargeDef == null)
			return 0;
		return rechargeDef.GetMaxRecharge();
	}
	// #endregion

	// #region 杂项
	public function GetDefinitionID():NamespaceID
	{
		return Definition.GetID();
	}
	public function ChangeDefinition(definition:SeedDefinition):Void
	{
		Definition = definition;
		properties.ClearFallbackCaches();
		UpdateAllBuffedProperties(true);
		OnDefinitionChanged.dispatch(definition);
	}
	// C#: public abstract bool Exists();
	public function Exists():Bool
	{
		throw "abstract";
	}
	// #endregion

	// #region 序列化
	// C#: protected void SaveToSerializable(SerializableSeedPack seri)
	private function SaveToSerializable(seri:SerializableSeedPack):Void
	{
		seri.id = ID;
		seri.seedID = Definition.GetID();
		SavePropertiesToSerializable(seri);
		SaveBuffsToSerializable(seri);
		SaveAurasToSerializable(seri);
	}
	// C#: protected void InitFromSerializable(SerializableSeedPack seri)
	private function InitFromSerializable(seri:SerializableSeedPack):Void
	{
		InitPropertiesFromSerializable(seri);
		InitBuffsFromSerializable(seri);
	}
	public function LoadFromSerializable(level:LevelEngine, seri:SerializableSeedPack):Void
	{
		LoadBuffsFromSerializable(seri);
		LoadAurasFromSerializable(seri);
		UpdateAllBuffedProperties(false);
	}
	// #endregion

	// #region ILevelObject接口实现
	// PORT-NOTE: C# 显式接口实现（`LevelEngine ILevelObject.GetLevel() => Level;`）在 Haxe 中只能写成普通公开方法。
	public function GetLevel():LevelEngine return Level;
	public function GetEntity():Null<Entity> return null;
	public function GetChildrenObjects():Array<ILevelObject>
	{
		var results:Array<ILevelObject> = [];
		for (buff in buffs)
		{
			results.push(buff);
		}
		return results;
	}
	public function OnAddToLevel(level:LevelEngine):Void
	{
		auras.PostAdd();
	}
	public function OnRemoveFromLevel(level:LevelEngine):Void
	{
		auras.PostRemove();
	}
	// #endregion

	// #region 事件
	public var OnDefinitionChanged:FlxTypedSignal<SeedDefinition->Void> = new FlxTypedSignal();
	// #endregion

	// #region 属性字段
	public var ID(default, null):Int64;
	public var Level(default, null):LevelEngine;
	public var Definition(default, null):SeedDefinition;
	// #endregion

	// ===================== SeedPack_Aura.cs =====================
	private function CreateAuraEffects():Void
	{
		var auraCount = Definition.GetAuraCount();
		for (i in 0...auraCount)
		{
			var auraDef = Definition.GetAuraAt(i);
			auras.Add(Level, new AuraEffect(auraDef, i, this));
		}
	}
	private function UpdateAuras():Void
	{
		auras.Update();
	}

	// #region 获取
	// PORT-NOTE: C# AuraEffectList.Get<T>() 与 Get(AuraEffectDefinition) 为重载，Haxe 不支持重载，
	// 泛型版在移植层命名为 GetOfType（与 pvzengine.buffs.Buff、mvz2logic.artifacts.Artifact 一致）。
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
	private function SaveAurasToSerializable(seri:SerializableSeedPack):Void
	{
		seri.auras = [for (a in auras.GetAll()) a.ToSerializable()];
	}
	private function LoadAurasFromSerializable(seri:SerializableSeedPack):Void
	{
		if (seri.auras == null)
			return;
		auras.LoadFromSerializable(Level, seri.auras);
	}
	// #endregion

	private var auras:AuraEffectList = new AuraEffectList();

	// ===================== SeedPack_Buff.cs =====================
	private function InitBuffs():Void
	{
		buffs.OnModelInsertionAdded.add(OnModelInsertionAddedCallback);
		buffs.OnModelInsertionRemoved.add(OnModelInsertionRemovedCallback);
	}
	private function UpdateBuffs():Void
	{
		buffs.Update();
	}

	// #region 事件回调
	private function OnModelInsertionAddedCallback(insertion:ModelInsertion):Void
	{
		OnModelInsertionAdded.dispatch(insertion);
	}
	private function OnModelInsertionRemovedCallback(insertion:ModelInsertion):Void
	{
		OnModelInsertionRemoved.dispatch(insertion);
	}
	// #endregion

	// #region 增益
	// C#: public abstract BuffReference GetBuffReference(Buff buff);
	public function GetBuffReference(buff:Buff):BuffReference
	{
		throw "abstract";
	}
	// #endregion

	// #region 序列化
	private function SaveBuffsToSerializable(seri:SerializableSeedPack):Void
	{
		seri.buffs = buffs.ToSerializable();
	}
	private function InitBuffsFromSerializable(seri:SerializableSeedPack):Void
	{
		buffs.InitFromSerializable(seri.buffs, Level, this);
	}
	private function LoadBuffsFromSerializable(seri:SerializableSeedPack):Void
	{
		if (seri.buffs != null)
			buffs.LoadFromSerializable(seri.buffs);
	}
	// #endregion

	// #region 事件
	public var OnModelInsertionAdded:FlxTypedSignal<ModelInsertion->Void> = new FlxTypedSignal();
	public var OnModelInsertionRemoved:FlxTypedSignal<ModelInsertion->Void> = new FlxTypedSignal();
	// #endregion

	// #region 属性字段
	// PORT-NOTE: C# 显式接口实现 `IBuffList IBuffTarget.Buffs => buffs;`，Haxe 中改为属性 getter。
	public var Buffs(get, never):IBuffList;
	private function get_Buffs():IBuffList return buffs;
	private var buffs:BuffList = new BuffList();
	// #endregion 属性

	// ===================== SeedPack_Model.cs =====================
	// #region 模型
	public function SetModelInterface(model:Null<IModelInterface>):Void
	{
		modelInterface = model;
	}
	public function GetModelInterface():Null<IModelInterface>
	{
		return modelInterface;
	}
	// C#: IModeledBuffTarget.GetInsertedModel(NamespaceID key) => this.GetChildModel(key);
	public function GetInsertedModel(key:NamespaceID):Null<IModelInterface>
	{
		var model = GetModelInterface();
		return model != null ? model.GetChildModel(key) : null;
	}
	// #endregion

	// #region 属性字段
	private var modelInterface:Null<IModelInterface>;
	// #endregion

	// ===================== SeedPack_Properties.cs =====================
	// #region 属性
	public function GetProperty<T>(name:PropertyKey<T>, ignoreBuffs:Bool = false):T
	{
		return properties.GetProperty(name, ignoreBuffs);
	}
	public function SetProperty<T>(name:PropertyKey<T>, value:T):Void
	{
		properties.SetProperty(name, value);
	}
	private function UpdateAllBuffedProperties(triggersEvaluation:Bool):Void
	{
		properties.UpdateAllModifiedProperties(triggersEvaluation);
	}
	public function GetFallbackProperty(name:IPropertyKey, value:{ value:Dynamic }):Bool
	{
		if (Definition != null && Definition.TryGetPropertyObject(name, value))
		{
			return true;
		}
		value.value = null;
		return false;
	}
	public function OnPropertyChanged(name:IPropertyKey, beforeValue:Dynamic, afterValue:Dynamic, triggersEvaluation:Bool):Void
	{
	}
	// #endregion

	// #region 序列化
	private function SavePropertiesToSerializable(seri:SerializableSeedPack):Void
	{
		seri.properties = properties.ToSerializable();
	}
	private function InitPropertiesFromSerializable(seri:SerializableSeedPack):Void
	{
		properties.LoadFromSerializable(seri.properties);
	}
	// #endregion

	// #region 属性字段
	private var properties:PropertyBlock;
	// #endregion

	// ===================== 调用点兼容转发方法 =====================
	// PORT-NOTE: 以下方法在 C# 中是 EngineSeedProps 的扩展方法（静态方法），既有上层代码以实例形式调用
	//   （seedPack.GetMaxRecharge() / SetStartRecharge() / IsCharged() / GetRecharge() / AddRecharge() 等，
	//   见 mvz2/gamecontent/contraptions/DesirePot.hx、mvz2logic/level/LogicLevelExt.hx、mvz2/level/ClassicBlueprintController.hx 等）。
	//   Haxe 的 @:using 扩展方法不会沿继承链生效，而调用点的静态类型常为子类（如
	//   `var seedPack:ClassicSeedPack` / `level.GetAllSeedPacks()` 的元素类型），故按「以既有调用点为准」
	//   在此提供同名实例转发方法；EngineSeedProps 中的静态版本保持 C# 原样。
	// #region 调用点兼容（C# 扩展方法 → 实例转发）
	public function GetRechargeSpeed():Float return EngineSeedProps.GetRechargeSpeed(this);
	public function GetRecharge():Float return EngineSeedProps.GetRecharge(this);
	public function SetRecharge(value:Float):Void EngineSeedProps.SetRecharge(this, value);
	public function AddRecharge(value:Float):Void EngineSeedProps.AddRecharge(this, value);
	public function GetRechargeID():Null<NamespaceID> return EngineSeedProps.GetRechargeID(this);
	public function IsStartRecharge():Bool return EngineSeedProps.IsStartRecharge(this);
	public function SetStartRecharge(value:Bool):Void EngineSeedProps.SetStartRecharge(this, value);
	public function IsDisabled():Bool return EngineSeedProps.IsDisabled(this);
	public function GetDisableID():Null<NamespaceID> return EngineSeedProps.GetDisableID(this);
	public function FullRecharge():Void EngineSeedProps.FullRecharge(this);
	public function IsCharged():Bool return EngineSeedProps.IsCharged(this);
	public function ResetRecharge():Void EngineSeedProps.ResetRecharge(this);
	public function GetMaxRecharge():Int return EngineSeedProps.GetMaxRecharge(this);
	public function GetDrawnConveyorSeed():Null<NamespaceID> return EngineSeedProps.GetDrawnConveyorSeed(this);
	public function SetDrawnConveyorSeed(value:Null<NamespaceID>):Void EngineSeedProps.SetDrawnConveyorSeed(this, value);
	// #endregion
}
