// Ported from: Assets/Scripts/Engine/Level/Damage/DeathInfo.cs
package pvzengine.damages;

import haxe.Int64;
import pvzengine.NamespaceID;
import pvzengine.entities.Entity;
import pvzengine.level.ILevelSourceReference;
// PORT-NOTE: C# 中 ISerializableSourceReference 与 ILevelSourceReference 同处一个文件；
// 本工程已按既有调用点（mvz2logic/artifacts/ArtifactSourceReference.hx 等）把它拆成独立模块
// pvzengine/level/ISerializableSourceReference.hx，故此处使用短包路径导入。
import pvzengine.level.ISerializableSourceReference;
import pvzengine.level.LevelEngine;

class DeathInfo
{
    // PORT-NOTE: C# 有两个构造函数：
    //   DeathInfo(Entity entity, DamageEffectList effects, ILevelSourceReference? source, DamageResultValues? damage = null)
    //   DeathInfo(LevelEngine level, SerializableDeathInfo seri)
    // Haxe 不支持构造函数重载，而两处调用点都存在（Entity.Die 用 4 参形式、Entity_Serialize 用 2 参反序列化形式），
    // 故合并为单一构造函数并按首参类型分派：首参为 LevelEngine 时走反序列化分支。
    public function new(entityOrLevel:Dynamic, effectsOrSerializable:Dynamic = null, source:Null<ILevelSourceReference> = null, damage:Null<DamageResultValues> = null)
    {
        if (Std.isOfType(entityOrLevel, LevelEngine))
        {
            LoadFromSerializable(cast entityOrLevel, cast effectsOrSerializable);
            return;
        }
        Effects = cast effectsOrSerializable;
        Entity = cast entityOrLevel;
        Source = source;
        Damage = damage;
    }
    // C#: public DeathInfo(LevelEngine level, SerializableDeathInfo seri)
    public function LoadFromSerializable(level:LevelEngine, seri:SerializableDeathInfo):Void
    {
        var ent = level.FindEntityByID(seri.entityID);
        if (ent == null)
        {
            throw 'Cannot find the entity with id ${seri.entityID} while loading SerializableDeathInfo.';
        }
        Entity = ent;
        Effects = new DamageEffectList(seri.effects);
        Source = seri.source != null ? seri.source.ToDeserialized(level) : null;
        Damage = seri.damage;
    }
    public function HasEffect(effect:NamespaceID):Bool
    {
        if (Effects == null)
            return false;
        return Effects.HasEffect(effect);
    }
    public var Effects(default, null):DamageEffectList;
    public var Entity(default, null):Entity;
    public var Source:Null<ILevelSourceReference>;
    public var Damage(default, null):Null<DamageResultValues>;
}
