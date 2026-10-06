// Ported from: Assets/Scripts/Engine/Level/Callbacks/LevelCallbacks.cs
// PORT-NOTE: 该 C# 文件中的 5 个共用参数结构体（EmptyCallbackParams / StringCallbackParams / LevelCallbackParams /
//   SeedPackCallbackParams / EntityCallbackParams）被上层以 `import pvzengine.callbacks.X;` 引用（共 56 个文件），
//   而 Haxe 中同一个包内不允许出现第二个同名类型（模块子类型与外层模块同名会报 "Type name ... is redefined"），
//   因此这 5 个结构体各自独立成模块（pvzengine/callbacks/X.hx），本文件不再重复声明。
//   其余结构体按 PORTING.md「其余类放同文件底部」保留在 LevelCallbacks 模块内，
//   上层调用点以 LevelCallbacks.X 引用（如 mvz2/gamecontent/armors/ReflectiveBarrier.hx 的 LevelCallbacks.EntityDeathParams）。
// PORT-NOTE: C# static class 的 readonly static 字段 → Haxe class 的 static var（与上层
//   mvz2logic/callbacks/LogicCallbacks.hx 的写法一致）。
// PORT-NOTE: C# 嵌套 struct（声明在 static class LevelCallbacks 内部）→ Haxe 模块子类型，访问路径一致。
package pvzengine.callbacks;

import pvzengine.NamespaceID;
import pvzengine.armors.Armor;
import pvzengine.damages.ArmorDestroyInfo;
import pvzengine.damages.DeathInfo;
import pvzengine.entities.Entity;
import pvzengine.entities.EntityCollision;
import pvzengine.level.LevelEngine;
import unity.Vector3;

class LevelCallbacks
{
	public static var POST_ENTITY_INIT:CallbackType<EntityCallbackParams> = new CallbackType<EntityCallbackParams>();
	public static var POST_ENTITY_UPDATE:CallbackType<EntityCallbackParams> = new CallbackType<EntityCallbackParams>();
	public static var POST_ENTITY_REMOVE:CallbackType<EntityCallbackParams> = new CallbackType<EntityCallbackParams>();

	public static var POST_ENTITY_CONTACT_GROUND:CallbackType<PostEntityContactGroundParams> = new CallbackType<PostEntityContactGroundParams>();
	public static var POST_ENTITY_LEAVE_GROUND:CallbackType<EntityCallbackParams> = new CallbackType<EntityCallbackParams>();

	public static var PRE_ENTITY_COLLISION:CallbackType<PreEntityCollisionParams> = new CallbackType<PreEntityCollisionParams>();
	public static var POST_ENTITY_COLLISION:CallbackType<PostEntityCollisionParams> = new CallbackType<PostEntityCollisionParams>();

	public static var PRE_ENTITY_DEATH:CallbackType<EntityDeathParams> = new CallbackType<EntityDeathParams>();
	public static var POST_ENTITY_DEATH:CallbackType<EntityDeathParams> = new CallbackType<EntityDeathParams>();
	public static var POST_ENTITY_REVIVE:CallbackType<EntityCallbackParams> = new CallbackType<EntityCallbackParams>();

	public static var POST_EQUIP_ARMOR:CallbackType<ArmorParams> = new CallbackType<ArmorParams>();
	public static var POST_DESTROY_ARMOR:CallbackType<PostArmorDestroyParams> = new CallbackType<PostArmorDestroyParams>();
	public static var POST_REMOVE_ARMOR:CallbackType<ArmorParams> = new CallbackType<ArmorParams>();

	public static var POST_ENEMY_SPAWNED:CallbackType<EntityCallbackParams> = new CallbackType<EntityCallbackParams>();

	public static var POST_LEVEL_SETUP:CallbackType<LevelCallbackParams> = new CallbackType<LevelCallbackParams>();
	public static var POST_LEVEL_START:CallbackType<LevelCallbackParams> = new CallbackType<LevelCallbackParams>();
	public static var POST_LEVEL_UPDATE:CallbackType<LevelCallbackParams> = new CallbackType<LevelCallbackParams>();
	public static var POST_LEVEL_CLEAR:CallbackType<LevelCallbackParams> = new CallbackType<LevelCallbackParams>();
	public static var POST_PREPARE_FOR_BATTLE:CallbackType<LevelCallbackParams> = new CallbackType<LevelCallbackParams>();
	public static var POST_HUGE_WAVE_EVENT:CallbackType<LevelCallbackParams> = new CallbackType<LevelCallbackParams>();
	public static var POST_FINAL_WAVE_EVENT:CallbackType<LevelCallbackParams> = new CallbackType<LevelCallbackParams>();

	public static var POST_WAVE:CallbackType<PostWaveParams> = new CallbackType<PostWaveParams>();
	public static var POST_WAVE_FINISHED:CallbackType<PostWaveParams> = new CallbackType<PostWaveParams>();
	public static var POST_GAME_OVER:CallbackType<PostGameOverParams> = new CallbackType<PostGameOverParams>();
}

class PostEntityContactGroundParams
{
	public var entity:Entity;
	public var velocity:Vector3 = new Vector3(0, 0, 0); // PORT-NOTE: C# Vector3 为 struct，默认 (0,0,0)；显式初始化避免 abstract-over-class 的 null 解引用
}

class PreEntityCollisionParams
{
	public var collision:EntityCollision;
}

class PostEntityCollisionParams
{
	public var collision:EntityCollision;
	public var state:Int;
}

class EntityDeathParams
{
	public var entity:Entity;
	public var deathInfo:DeathInfo;

	public function new(entity:Entity, deathInfo:DeathInfo)
	{
		this.entity = entity;
		this.deathInfo = deathInfo;
	}
}

class ArmorParams
{
	public var entity:Entity;
	public var slot:NamespaceID;
	public var armor:Armor;
	public var info:ArmorDestroyInfo;
}

class PostArmorDestroyParams
{
	public var entity:Entity;
	public var slot:NamespaceID;
	public var armor:Armor;
	public var info:ArmorDestroyInfo;
}

class PostWaveParams
{
	public var level:LevelEngine;
	public var wave:Int;

	public function new(level:LevelEngine, wave:Int)
	{
		this.level = level;
		this.wave = wave;
	}
}

class PostGameOverParams
{
	public var level:LevelEngine;
	public var type:Int;
	public var killer:Entity;
	public var message:String;
}
