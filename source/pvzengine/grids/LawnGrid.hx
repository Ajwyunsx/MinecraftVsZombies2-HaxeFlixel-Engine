// Ported from: Assets/Scripts/Engine/Level/Grids/LawnGrid.cs
//             以及同目录的 LawnGrid_Aura.cs / LawnGrid_Buff.cs / LawnGrid_Layers.cs /
//             LawnGrid_Model.cs / LawnGrid_Properties.cs / LawnGrid_Serialize.cs
// PORT-NOTE: C# 分部类（partial class）无法跨文件实现，按 PORTING.md 合并为单一 LawnGrid.hx。
//
// PORT-NOTE: 既有上层代码以实例形式调用 C# 的扩展方法（grid.IsWater() / grid.CanSpawnEntity(id) /
//   grid.GetCarrierEntity() / grid.AddBuff(x) 等，见 mvz2/level/LevelController.hx、mvz2/grids/GridController.hx
//   等文件），故沿用移植层的既有做法（同 pvzengine.level.ILevelSourceReference），用 @:using 把这些
//   扩展方法（C# 中静态类）挂到 LawnGrid 上；扩展方法本身仍保留为各自类的静态方法。
package pvzengine.grids;

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
// PORT-NOTE: BuffReference* 系列在 C# 的 BuffReference.cs 内定义于同一模块，故按「模块.子类型」路径导入。
import pvzengine.buffs.BuffReference.BuffReferenceLawnGrid;
import pvzengine.buffs.IBuffList;
import pvzengine.buffs.IModeledBuffTarget;
import pvzengine.buffs.ModelInsertion;
import pvzengine.entities.Entity;
import pvzengine.level.ILevelObject;
import pvzengine.level.ILevelSourceTarget;
import pvzengine.level.IModifiablePropertyTarget;
import pvzengine.level.LevelEngine;
import pvzengine.level.PropertyBlock;
import pvzengine.models.IModelInterface;
import unity.Debug;
import unity.Vector3;

@:using(pvzengine.buffs.BuffTargetExt)
@:using(mvz2logic.grids.LogicGridExt)
@:using(mvz2logic.grids.LogicGridProps)
@:using(mvz2.vanilla.grids.VanillaGridExt)
class LawnGrid implements IAuraSource implements IModifiablePropertyTarget implements ILevelSourceTarget implements IModeledBuffTarget
{
	// #region 构造器
	public function new(level:LevelEngine, definition:GridDefinition, lane:Int, column:Int)
	{
		Level = level;
		Lane = lane;
		Column = column;
		Definition = definition;
		// PORT-NOTE: C# `PropertyBlock(container, params IModifierProvider[] providers)` → Haxe 传数组实参。
		properties = new PropertyBlock(this, [buffs]);
		InitBuffList();
		CreateAuraEffects();
	}
	// #endregion

	// #region 生命周期
	public function Update():Void
	{
		try
		{
			UpdateAuras();
			UpdateBuffs();
		}
		catch (ex:Dynamic)
		{
			Debug.LogError('更新地格时出现错误：${ex}');
		}
	}
	// #endregion

	// #region 位置
	public function GetIndex():Int
	{
		return Level.GetGridIndex(Column, Lane);
	}
	public function GetCenterPosition():Vector3
	{
		var x = Level.GetColumnCenterX(Column);
		var z = Level.GetLaneCenterZ(Lane);
		var y = Level.GetGroundY(x, z);
		return new Vector3(x, y, z);
	}
	public function GetEntityPosition():Vector3
	{
		var x = Level.GetEntityColumnX(Column);
		var z = Level.GetEntityLaneZ(Lane);
		var y = Level.GetGroundY(x, z);
		return new Vector3(x, y, z);
	}
	public function GetGroundY():Float
	{
		var x = Level.GetEntityColumnX(Column);
		var z = Level.GetEntityLaneZ(Lane);
		return Level.GetGroundY(x, z);
	}
	// #endregion

	// #region ILevelObject实现
	// PORT-NOTE: C# 显式接口实现（`LevelEngine ILevelObject.GetLevel() => Level;`）在 Haxe 中只能写成普通公开方法。
	public function GetLevel():LevelEngine return Level;
	public function GetEntity():Null<Entity> return null;
	public function Exists():Bool return true;
	public function OnAddToLevel(level:LevelEngine):Void
	{
	}
	public function OnRemoveFromLevel(level:LevelEngine):Void
	{
	}
	public function GetChildrenObjects():Array<ILevelObject>
	{
		var results:Array<ILevelObject> = [];
		for (buff in buffs)
		{
			results.push(buff);
		}
		return results;
	}
	// #endregion

	// #region 杂项
	// PORT-NOTE: C# 的 `override string ToString()` 在 Haxe 中写作不带 override 的 toString()（LawnGrid 无父类）。
	public function toString():String
	{
		return 'LawnGrid_${Lane}x${Column}';
	}
	// #endregion

	// #region 属性
	public var Level(default, null):LevelEngine;
	public var Lane:Int;
	public var Column:Int;
	public var Definition:GridDefinition;
	// #endregion 属性

	// ===================== LawnGrid_Aura.cs =====================
	private function CreateAuraEffects():Void
	{
		var count = Definition.GetAuraCount();
		for (i in 0...count)
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
	private function WriteAurasToSerializable(seri:SerializableGrid):Void
	{
		seri.auras = [for (a in auras.GetAll()) a.ToSerializable()];
	}
	private function LoadAurasFromSerializable(seri:SerializableGrid):Void
	{
		if (seri.auras == null)
			return;
		auras.LoadFromSerializable(Level, seri.auras);
	}
	// #endregion

	private var auras:AuraEffectList = new AuraEffectList();

	// ===================== LawnGrid_Buff.cs =====================
	// #region 生命周期
	public function UpdateBuffs():Void
	{
		buffs.Update();
	}
	// #endregion

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
	public function GetBuffReference(buff:Buff):BuffReference
	{
		return new BuffReferenceLawnGrid(GetIndex(), buff.ID);
	}
	private function InitBuffList():Void
	{
		buffs.OnModelInsertionAdded.add(OnModelInsertionAddedCallback);
		buffs.OnModelInsertionRemoved.add(OnModelInsertionRemovedCallback);
	}
	// #endregion

	// #region 序列化
	private function WriteBuffsToSerializable(seri:SerializableGrid):Void
	{
		seri.buffs = buffs.ToSerializable();
	}
	private function InitBuffsFromSerializable(seri:SerializableGrid):Void
	{
		buffs.InitFromSerializable(seri.buffs, Level, this);
	}
	private function LoadBuffsFromSerializable(seri:SerializableGrid):Void
	{
		if (seri.buffs != null)
			buffs.LoadFromSerializable(seri.buffs);
	}
	// #endregion

	// #region 事件
	public var OnModelInsertionAdded:FlxTypedSignal<ModelInsertion->Void> = new FlxTypedSignal();
	public var OnModelInsertionRemoved:FlxTypedSignal<ModelInsertion->Void> = new FlxTypedSignal();
	// #endregion

	// #region 属性
	// PORT-NOTE: C# 显式接口实现 `IBuffList IBuffTarget.Buffs => buffs;`，Haxe 中改为属性 getter。
	public var Buffs(get, never):IBuffList;
	private function get_Buffs():IBuffList return buffs;
	private var buffs:BuffList = new BuffList();
	// #endregion 属性

	// ===================== LawnGrid_Layers.cs =====================
	// #region 添加占据实体
	// PORT-NOTE: C# HashSet<T> → Haxe Map<T, Bool>（PORTING.md 约定）。
	private function GetOrCreateLayerEntityHashSet(layer:NamespaceID):Map<Entity, Bool>
	{
		var hashSet = layerEntities.get(layer);
		if (hashSet == null)
		{
			hashSet = new Map<Entity, Bool>();
			layerEntities.set(layer, hashSet);
		}
		return hashSet;
	}
	private function AddReversedLayerEntity(layer:NamespaceID, entity:Entity):Void
	{
		var layerHashSet = reverseLayerEntities.get(entity);
		if (layerHashSet != null)
		{
			layerHashSet.set(layer, true);
		}
		else
		{
			layerHashSet = [layer => true];
			reverseLayerEntities.set(entity, layerHashSet);
		}
	}
	public function AddLayerEntity(layer:NamespaceID, entity:Entity):Void
	{
		var hashSet = GetOrCreateLayerEntityHashSet(layer);
		hashSet.set(entity, true);
		AddReversedLayerEntity(layer, entity);
	}
	// #endregion

	// #region 移除占据实体
	public function RemoveLayerEntity(layer:NamespaceID, entity:Entity):Void
	{
		var hashSet = layerEntities.get(layer);
		if (hashSet != null)
		{
			hashSet.remove(entity);
			if (!hashSet.keys().hasNext())
			{
				layerEntities.remove(layer);
			}
		}
		var reverseHashSet = reverseLayerEntities.get(entity);
		if (reverseHashSet != null)
		{
			reverseHashSet.remove(layer);
			if (!reverseHashSet.keys().hasNext())
			{
				reverseLayerEntities.remove(entity);
			}
		}
	}
	public function RemoveGridEntity(entity:Entity):Void
	{
		var reversedHashSet = reverseLayerEntities.get(entity);
		if (reversedHashSet != null)
		{
			for (layer in reversedHashSet.keys())
			{
				var hashSet = layerEntities.get(layer);
				if (hashSet != null)
				{
					hashSet.remove(entity);
					if (!hashSet.keys().hasNext())
					{
						layerEntities.remove(layer);
					}
				}
			}
			reversedHashSet.clear();
			reverseLayerEntities.remove(entity);
		}
	}
	// #endregion

	// #region 获取占据实体
	public function GetLayerEntity(layer:NamespaceID):Null<Entity>
	{
		var hashSet = layerEntities.get(layer);
		if (hashSet != null)
		{
			for (entity in hashSet.keys())
			{
				return entity;
			}
		}
		return null;
	}
	public function GetLayerEntities(layer:NamespaceID):Array<Entity>
	{
		var hashSet = layerEntities.get(layer);
		if (hashSet != null)
		{
			return [for (entity in hashSet.keys()) entity];
		}
		return [];
	}
	// PORT-NOTE: C# 重载 GetLayerEntities(NamespaceID, List<Entity>)，Haxe 不支持重载，重命名为 GetLayerEntitiesNonAlloc。
	public function GetLayerEntitiesNonAlloc(layer:NamespaceID, results:Array<Entity>):Void
	{
		var hashSet = layerEntities.get(layer);
		if (hashSet != null)
		{
			for (entity in hashSet.keys())
			{
				results.push(entity);
			}
		}
	}
	public function IsEntityOnLayer(entity:Entity, layer:NamespaceID):Bool
	{
		var hashSet = layerEntities.get(layer);
		if (hashSet != null)
		{
			return hashSet.exists(entity);
		}
		return false;
	}
	public function HasEntity(entity:Entity):Bool
	{
		return reverseLayerEntities.exists(entity);
	}
	public function IsEmpty():Bool
	{
		return !layerEntities.keys().hasNext();
	}
	public function GetEntities():Array<Entity>
	{
		return [for (entity in reverseLayerEntities.keys()) entity];
	}
	public function GetLayers():Array<NamespaceID>
	{
		return [for (layer in layerEntities.keys()) layer];
	}
	// #endregion

	// #region 获取实体占据层
	public function GetEntityLayers(entity:Entity):Array<NamespaceID>
	{
		var reverseHashSet = reverseLayerEntities.get(entity);
		if (reverseHashSet != null)
		{
			return [for (layer in reverseHashSet.keys()) layer];
		}
		return [];
	}
	public function GetEntityLayersNonAlloc(entity:Entity, results:Array<NamespaceID>):Void
	{
		var reverseHashSet = reverseLayerEntities.get(entity);
		if (reverseHashSet != null)
		{
			for (layer in reverseHashSet.keys())
			{
				results.push(layer);
			}
		}
	}
	// #endregion

	// #region 序列化
	private function WriteLayersToSerializable(seri:SerializableGrid):Void
	{
		var lists:Map<String, Array<Int64>> = new Map();
		for (layer in layerEntities.keys())
		{
			lists.set(layer.toString(), [for (entity in layerEntities.get(layer).keys()) entity.ID]);
		}
		seri.layerEntityLists = lists;
	}
	private function LoadLayersFromSerializable(seri:SerializableGrid):Void
	{
		layerEntities.clear();
		reverseLayerEntities.clear();
		// C#: #pragma warning disable CS0612（使用已过时的 layerEntities 字段）
		if (seri.layerEntityLists != null)
		{
			for (layerName in seri.layerEntityLists.keys())
			{
				var layer = NamespaceID.ParseStrict(layerName);
				var entityHashSet:Map<Entity, Bool> = new Map();
				for (entityID in seri.layerEntityLists.get(layerName))
				{
					var entity = Level.FindEntityByID(entityID);
					if (entity == null)
						continue;

					entityHashSet.set(entity, true);
					AddReversedLayerEntity(layer, entity);
				}
				layerEntities.set(layer, entityHashSet);
			}
		}
		else if (seri.layerEntities != null)
		{
			for (layerName in seri.layerEntities.keys())
			{
				var layer = NamespaceID.ParseStrict(layerName);
				var entity = Level.FindEntityByID(seri.layerEntities.get(layerName));
				if (entity == null)
					continue;

				var layerHashSet:Map<NamespaceID, Bool> = [layer => true];
				var entityHashSet:Map<Entity, Bool> = [entity => true];
				layerEntities.set(layer, entityHashSet);
				reverseLayerEntities.set(entity, layerHashSet);
			}
		}
	}
	// #endregion

	// #region 属性
	private var layerEntities:Map<NamespaceID, Map<Entity, Bool>> = new Map();
	private var reverseLayerEntities:Map<Entity, Map<NamespaceID, Bool>> = new Map();
	// #endregion 属性

	// ===================== LawnGrid_Model.cs =====================
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

	// #region 属性
	private var modelInterface:Null<IModelInterface>;
	// #endregion 属性

	// ===================== LawnGrid_Properties.cs =====================
	// #region 属性
	public function GetProperty<T>(name:PropertyKey<T>, ignoreBuffs:Bool = false):T
	{
		return properties.GetProperty(name, ignoreBuffs);
	}
	public function SetProperty<T>(name:PropertyKey<T>, value:T):Void
	{
		properties.SetProperty(name, value);
	}
	public function SetPropertyObject(name:IPropertyKey, value:Dynamic):Void
	{
		properties.SetPropertyObject(name, value);
	}
	// #endregion

	// #region IModifiablePropertyTarget实现
	public function GetFallbackProperty(name:IPropertyKey, value:{ value:Dynamic }):Bool
	{
		if (Definition == null)
		{
			value.value = null;
			return false;
		}
		return Definition.TryGetPropertyObject(name, value);
	}
	public function OnPropertyChanged(name:IPropertyKey, beforeValue:Dynamic, afterValue:Dynamic, triggersEvaluation:Bool):Void
	{
	}
	// #endregion

	// #region 序列化
	private function WritePropertiesToSerializable(seri:SerializableGrid):Void
	{
		seri.properties = properties.ToSerializable();
	}
	private function LoadPropertiesFromSerializable(seri:SerializableGrid):Void
	{
		properties.LoadFromSerializable(seri.properties);
	}
	// #endregion

	// #region 属性
	private var properties:PropertyBlock;
	// #endregion 属性

	// ===================== LawnGrid_Serialize.cs =====================
	// #region 序列化
	public function ToSerializable():SerializableGrid
	{
		var seri = new SerializableGrid();
		seri.lane = Lane;
		seri.column = Column;
		seri.definitionID = Definition.GetID();
		WriteAurasToSerializable(seri);
		WritePropertiesToSerializable(seri);
		WriteBuffsToSerializable(seri);
		WriteLayersToSerializable(seri);
		return seri;
	}
	public function InitFromSerializable(seri:SerializableGrid):Void
	{
		LoadPropertiesFromSerializable(seri);
		InitBuffsFromSerializable(seri);
	}
	public function LoadFromSerializable(seri:SerializableGrid):Void
	{
		LoadLayersFromSerializable(seri);
		// 增益
		LoadBuffsFromSerializable(seri);
		// 光环
		LoadAurasFromSerializable(seri);
		// 加载后更新
		properties.UpdateAllModifiedProperties(false);
	}
	// #endregion
}
