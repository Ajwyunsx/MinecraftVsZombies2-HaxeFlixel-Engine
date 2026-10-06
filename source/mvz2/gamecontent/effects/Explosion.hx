// Ported from: Assets/Scripts/Vanilla/GameContent/Effects/Chapter1/Explosion.cs
package mvz2.gamecontent.effects;

import mvz2.vanilla.entities.VanillaEntityExt;
import pvzengine.EngineEntityProps;
import pvzengine.NamespaceID;
import pvzengine.entities.Entity;
import pvzengine.entities.SpawnParams;
import pvzengine.level.LevelEngine;
import unity.Vector3;
import mvz2.gamecontent.effects.VanillaEffectID.VanillaEffectNames;
using mvz2.vanilla.entities.VanillaEntityExt;

@:autoEntityBehaviourDefinition(VanillaEffectNames.explosion)
class Explosion extends EffectBehaviour
{
    // #region 公有方法
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
    }
    public override function Init(entity:Entity):Void
    {
        super.Init(entity);
        entity.SetModelProperty("Size", entity.GetScaledSize());
    }
    public override function Update(entity:Entity):Void
    {
        super.Update(entity);
        entity.SetModelProperty("Size", entity.GetScaledSize());
    }
    // C#: Spawn(Entity spawner, Vector3 position, float radius)
    public static function Spawn(spawner:Entity, position:Vector3, radius:Float):Null<Entity>
    {
        return SpawnWithSize(spawner, position, Vector3.one * (radius * 2));
    }
    // PORT-NOTE: C# 重载 Spawn(Entity spawner, Vector3 position, Vector3 size) 在 Haxe 中重命名以区分（Haxe 不支持重载）。
    public static function SpawnWithSize(spawner:Entity, position:Vector3, size:Vector3):Null<Entity>
    {
        var param = spawner.GetSpawnParams();
        param.SetProperty(EngineEntityProps.SIZE, size);
        return spawner.Spawn(VanillaEffectID.explosion, position, param);
    }
    // PORT-NOTE: C# 重载 Spawn(NamespaceID id, Entity spawner, Vector3 position, Vector3 size) 重命名为 SpawnByID。
    public static function SpawnByID(id:NamespaceID, spawner:Entity, position:Vector3, size:Vector3):Null<Entity>
    {
        var param = spawner.GetSpawnParams();
        param.SetProperty(EngineEntityProps.SIZE, size);
        return spawner.Spawn(id, position, param);
    }
    // C#: Spawn(LevelEngine level, Vector3 position, float radius)
    public static function SpawnOnLevel(level:LevelEngine, position:Vector3, radius:Float):Null<Entity>
    {
        return SpawnOnLevelWithSize(level, position, Vector3.one * (radius * 2));
    }
    // PORT-NOTE: C# 重载 Spawn(LevelEngine level, Vector3 position, Vector3 size) 重命名为 SpawnOnLevelWithSize。
    public static function SpawnOnLevelWithSize(level:LevelEngine, position:Vector3, size:Vector3):Null<Entity>
    {
        var param = new SpawnParams();
        param.SetProperty(EngineEntityProps.SIZE, size);
        return level.Spawn(VanillaEffectID.explosion, position, null, param);
    }
    // PORT-NOTE: C# 重载 Spawn(NamespaceID id, LevelEngine level, Vector3 position, Vector3 size) 重命名为 SpawnByIDOnLevel。
    public static function SpawnByIDOnLevel(id:NamespaceID, level:LevelEngine, position:Vector3, size:Vector3):Null<Entity>
    {
        var param = new SpawnParams();
        param.SetProperty(EngineEntityProps.SIZE, size);
        return level.Spawn(id, position, null, param);
    }
    // #endregion
}
