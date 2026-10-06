// Ported from: Assets/Scripts/Logic/Entities/LogicEntityExt.cs
package mvz2logic.entities;

import mvz2logic.Global;
import mvz2logic.contents.buffs.entities.DamageColorBuff;
import mvz2logic.games.LogicGameDefinitionsExt;
import mvz2logic.level.LogicLevelExt;
import pvzengine.NamespaceID;
import pvzengine.entities.EngineEntityExt;
import pvzengine.entities.Entity;
import pvzengine.entities.EntityBehaviourDefinition;
import pvzengine.entities.EntityTypes;
import pvzengine.level.LevelEngine;
import unity.Bounds;
import unity.Vector3;

// PORT-NOTE: C# 扩展方法 (this Entity entity)/(this LevelEngine level) 改为静态方法，接收者作为第一个参数。
class LogicEntityExt
{
	//region 护甲
	public static function GetArmorDisplayPosition(entity:Entity, slot:NamespaceID, armorID:NamespaceID):Vector3
	{
		var shapeID = LogicEntityProps.GetShapeID(entity);
		if (shapeID != null)
		{
			var shapeDef = LogicGameDefinitionsExt.GetShapeDefinition(Global.Game, shapeID);
			if (shapeDef != null)
			{
				var offset = shapeDef.GetArmorPosition(slot, armorID);
				offset = Vector3.Scale(offset, entity.GetFinalDisplayScale());
				return offset + entity.Position;
			}
		}
		var bounds = entity.GetBounds();
		return bounds.center + Vector3.up * bounds.extents.y;
	}
	public static function GetArmorDisplayScale(entity:Entity, slot:NamespaceID, armorID:NamespaceID):Vector3
	{
		var shapeID = LogicEntityProps.GetShapeID(entity);
		if (shapeID != null)
		{
			var shapeDef = LogicGameDefinitionsExt.GetShapeDefinition(Global.Game, shapeID);
			if (shapeDef != null)
			{
				var offset = shapeDef.GetArmorScale(slot, armorID);
				offset = Vector3.Scale(offset, entity.GetFinalDisplayScale());
				return offset;
			}
		}
		return Vector3.one;
	}
	public static function GetArmorOffset(entity:Entity, slot:NamespaceID, armorID:NamespaceID):Vector3
	{
		var shapeID = LogicEntityProps.GetShapeID(entity);
		if (shapeID != null)
		{
			var shapeMeta = LogicGameDefinitionsExt.GetShapeDefinition(Global.Game, shapeID);
			if (shapeMeta != null)
			{
				return shapeMeta.GetArmorPosition(slot, armorID);
			}
		}
		return Vector3.zero;
	}
	public static function GetArmorScale(entity:Entity, slot:NamespaceID, armorID:NamespaceID):Vector3
	{
		var shapeID = LogicEntityProps.GetShapeID(entity);
		if (shapeID != null)
		{
			var shapeDef = LogicGameDefinitionsExt.GetShapeDefinition(Global.Game, shapeID);
			if (shapeDef != null)
			{
				return shapeDef.GetArmorScale(slot, armorID);
			}
		}
		return Vector3.one;
	}
	//endregion

	//region 音效
	public static function PlaySound(entity:Entity, soundID:NamespaceID, pitch:Float = 1, volume:Float = 1):Void
	{
		LogicLevelExt.PlaySoundAt(entity.Level, soundID, entity.Position, pitch, volume);
	}
	public static function PlaySoundIfNotNull(entity:Entity, soundID:Null<NamespaceID>, pitch:Float = 1, volume:Float = 1):Void
	{
		if (soundID == null)
			return;
		PlaySound(entity, soundID, pitch, volume);
	}
	public static function PlayCrySound(entity:Entity, soundID:NamespaceID, pitchMultiplier:Float = 1, volume:Float = 1):Void
	{
		var pitch = LogicEnemyProps.GetCryPitch(entity) * pitchMultiplier;
		PlaySound(entity, soundID, pitch, volume);
	}
	public static function PlayDeathSound(entity:Entity):Void
	{
		var deathSound = LogicEntityProps.GetDeathSound(entity);
		if (NamespaceID.IsValid(deathSound))
			PlayCrySound(entity, deathSound);
	}
	//endregion

	//region 阵营
	public static function IsFriendlyEntity(entity:Entity):Bool
	{
		return IsFriendlyFaction(entity.Level, entity.GetFaction());
	}
	public static function IsHostileEntity(entity:Entity):Bool
	{
		return IsHostileFaction(entity.Level, entity.GetFaction());
	}
	public static function IsFriendlyFaction(level:LevelEngine, faction:Int):Bool
	{
		return EngineEntityExt.IsFriendly(faction, level.Option.LeftFaction);
	}
	public static function IsHostileFaction(level:LevelEngine, faction:Int):Bool
	{
		return !IsFriendlyFaction(level, faction);
	}
	//endregion

	//region 可伤害实体
	public static function IsVulnerableEntity(entity:Entity):Bool
	{
		return entity.Type == EntityTypes.PLANT || entity.Type == EntityTypes.ENEMY || entity.Type == EntityTypes.OBSTACLE || entity.Type == EntityTypes.BOSS;
	}
	//endregion

	//region 存活
	public static function IsAliveEnemy(entity:Entity):Bool
	{
		if (entity.Type != EntityTypes.ENEMY)
			return false;
		if (entity.IsDead && !LogicEnemyProps.AssumeAlive(entity))
			return false;
		if (LogicEnemyProps.IsNotActiveEnemy(entity))
			return false;
		if (!entity.IsHostile(entity.Level.Option.LeftFaction))
			return false;
		return true;
	}
	//endregion

	//region 伤害闪烁
	public static function DamageBlink(entity:Entity):Void
	{
		// TODO-PORT: C# 泛型方法 HasBuff<T>()/AddBuff<T>()，Haxe 无隐式泛型推断，改为传入类型。
		if (entity != null && !entity.HasBuff(DamageColorBuff))
			entity.AddBuff(DamageColorBuff);
	}
	//endregion

	//region 镜像列
	public static function GetMirroredColumn(entity:Entity, column:Int, whenFaceRight:Bool):Int
	{
		if (entity.IsFacingLeft() == whenFaceRight)
		{
			return entity.Level.GetMaxColumnCount() - column - 1;
		}
		return column;
	}
	public static function GetMirroredX(entity:Entity, x:Float, whenFaceRight:Bool):Float
	{
		if (entity.IsFacingLeft() == whenFaceRight)
		{
			return entity.Level.GetLawnCenterX() * 2 - x;
		}
		return x;
	}
	//endregion

	public static function UpdateAnimationParameters(entity:Entity, state:Int):Void
	{
		// TODO-PORT: C# 泛型方法 GetBehaviour<T>()，Haxe 无隐式泛型推断，改为传入类型；
		// pvzengine.EntityDefinition.GetBehaviour 额外约束了 T:EntityBehaviourDefinition（C# 无此约束），
		// 而 IEnemyAnimationBehaviour 未继承 EntityBehaviourDefinition，故用 cast 绕过（运行期 Std.isOfType 行为一致）。
		var typeClass:Class<EntityBehaviourDefinition> = cast IEnemyAnimationBehaviour;
		var behaviour:Null<IEnemyAnimationBehaviour> = cast entity.Definition.GetBehaviour(typeClass);
		if (behaviour != null)
		{
			behaviour.UpdateAnimationParameters(entity, state);
		}
	}

	private function new() {}
}
