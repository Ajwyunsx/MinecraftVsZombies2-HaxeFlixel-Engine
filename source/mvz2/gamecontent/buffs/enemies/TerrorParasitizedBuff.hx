// Ported from: Assets/Scripts/Vanilla/GameContent/Buffs/Enemies/Chapter2/TerrorParasitiziedBuff.cs
// C# 文件名 TerrorParasitiziedBuff.cs（拼写如此），其中顶层类名为 TerrorParasitizedBuff。
package mvz2.gamecontent.buffs.enemies;

import mvz2.gamecontent.buffs.VanillaBuffNames;
import mvz2.gamecontent.damages.VanillaDamageEffects;
import mvz2.gamecontent.difficulties.VanillaDifficultyLevelProps;
import mvz2.gamecontent.enemies.VanillaEnemyID;
import mvz2.gamecontent.models.VanillaModelID;
import mvz2.vanilla.audios.VanillaSoundID;
import mvz2.vanilla.entities.VanillaEntityExt;
import mvz2.vanilla.models.VanillaModelKeys;
import mvz2.vanilla.properties.VanillaBuffPropertyMeta;
import mvz2logic.callbacks.LogicLevelCallbacks;
import mvz2logic.entities.LogicEntityExt;
import mvz2logic.models.LogicModelHelper;
import pvzengine.buffs.Buff;
import pvzengine.callbacks.CallbackResult;
import pvzengine.callbacks.LevelCallbacks;
import pvzengine.damages.DamageEffectList;
import pvzengine.definitions.BuffDefinition;
import pvzengine.entities.Entity;
import pvzengine.callbacks.LevelCallbacks.EntityDeathParams;

// PORT-NOTE: C# 扩展方法 host.TakeDamage(...) 在 Haxe 侧以静态方法 + `using` 提供（PORTING.md §扩展方法）。
using mvz2.vanilla.entities.VanillaEntityExt;

@:autoBuffDefinition(VanillaBuffNames.Enemy_terrorParasitized)
class TerrorParasitizedBuff extends BuffDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
        AddModelInsertion(LogicModelHelper.ANCHOR_CENTER, VanillaModelKeys.terrorParasitized, VanillaModelID.terrorParasitized);
        AddTrigger(LogicLevelCallbacks.ENTITY_DEATH_EFFECTS, EntityDeathEffectsCallback);
    }
    public override function PostAdd(buff:Buff):Void
    {
        super.PostAdd(buff);
        buff.SetProperty(PROP_PARASITE_HEALTH, -50.0);
    }
    public override function PostUpdate(buff:Buff):Void
    {
        super.PostUpdate(buff);
        var entity = buff.GetEntity();
        if (entity == null)
            return;
        var health = buff.GetProperty(PROP_PARASITE_HEALTH);
        health += HEALTH_SPEED;
        buff.SetProperty(PROP_PARASITE_HEALTH, health);

        var iconModel = buff.GetInsertedModel(VanillaModelKeys.terrorParasitized);
        if (iconModel != null)
        {
            iconModel.SetAnimationBool("Awake", health > 0);
        }
        if (health >= MAX_PARASITE_HEALTH)
        {
            SpawnParasites(entity, health);
            buff.Remove();
        }
    }
    public static function SpawnParasites(host:Entity, health:Float):Void
    {
        var level = host.Level;
        var count = VanillaDifficultyLevelProps.GetParasitizedTerrorCount(level);
        for (i in 0...count)
        {
            // C#: host.SpawnWithParams(...)?.Let(e => { e.Health = health; });
            var parasite = VanillaEntityExt.SpawnWithParams(host, VanillaEnemyID.parasiteTerror, host.GetCenter());
            if (parasite != null)
            {
                parasite.Health = health;
            }
        }
        host.TakeDamage(DAMAGE, new DamageEffectList([VanillaDamageEffects.IGNORE_ARMOR, VanillaDamageEffects.SELF_DAMAGE, VanillaDamageEffects.MUTE]), host);
        LogicEntityExt.PlaySound(host, VanillaSoundID.bloody);
        VanillaEntityExt.EmitBlood(host);
    }
    private function EntityDeathEffectsCallback(param:EntityDeathParams, result:CallbackResult):Void
    {
        var entity = param.entity;
        var info = param.deathInfo;
        for (buff in entity.GetBuffs(TerrorParasitizedBuff))
        {
            var health = buff.GetProperty(PROP_PARASITE_HEALTH);
            if (health > 0)
            {
                SpawnParasites(entity, health);
            }
            buff.Remove();
        }
    }
    public static inline var HEALTH_SPEED:Float = 1 / 6;
    public static inline var MAX_PARASITE_HEALTH:Float = 50;
    public static var PROP_PARASITE_HEALTH:VanillaBuffPropertyMeta<Float> = new VanillaBuffPropertyMeta<Float>("ParasiteHealth");
    public static inline var DAMAGE:Float = 100;
}
