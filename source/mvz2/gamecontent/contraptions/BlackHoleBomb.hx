// Ported from: Assets/Scripts/Vanilla/GameContent/Contraptions/Chapter4/BlackHoleBomb.cs
package mvz2.gamecontent.contraptions;

import mvz2.gamecontent.effects.Explosion;
import mvz2.gamecontent.effects.VanillaEffectID;
import mvz2.vanilla.audios.VanillaSoundID;
import mvz2.vanilla.callbacks.VanillaLevelCallbacks;
import mvz2.vanilla.contraptions.IExplodeContraptionBehaviour;
import mvz2.vanilla.entities.VanillaEntityExt;
import mvz2.vanilla.entities.VanillaEntityProps;
import mvz2logic.entities.LogicEntityExt;
import mvz2logic.level.LogicLevelExt;
import pvzengine.callbacks.EntityCallbackParams;
import pvzengine.entities.Entity;
using mvz2.vanilla.entities.VanillaEntityExt;
using mvz2logic.entities.LogicContraptionProps;
using mvz2logic.entities.LogicEntityExt;

@:autoEntityBehaviourDefinition(VanillaContraptionNames.blackHoleBomb)
class BlackHoleBomb extends ContraptionBehaviour implements IExplodeContraptionBehaviour
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
    }
    public function Explode(contraption:Entity, range:Float, damage:Float):Void
    {
        ExplodeStatic(contraption, range, damage);
    }
    // PORT-NOTE: C# 中显式接口实现与静态方法同名（Haxe 不允许静态/实例同名字段），静态方法改名为 ExplodeStatic。
    public static function ExplodeStatic(entity:Entity, range:Float, damage:Float):Null<Entity>
    {
        if (entity.IsEvoked())
        {
            return ExplodeEvoked(entity, range);
        }
        else
        {
            return ExplodeNotEvoked(entity, range, damage);
        }
    }
    public static function ExplodeNotEvoked(entity:Entity, range:Float, damage:Float):Null<Entity>
    {
        var blackholeParam = entity.GetSpawnParams();
        blackholeParam.SetProperty(VanillaEntityProps.DAMAGE, damage * DAMAGE_MULTIPLIER);
        blackholeParam.SetProperty(VanillaEntityProps.RANGE, range);
        var blackhole = entity.Spawn(VanillaEffectID.blackhole, entity.GetCenter(), blackholeParam);

        Explosion.Spawn(entity, entity.GetCenter(), range);

        entity.PlaySound(VanillaSoundID.explosion);
        entity.PlaySound(VanillaSoundID.gravitation);
        entity.Level.ShakeScreen(10, 0, 15);
        entity.Level.Triggers.RunCallbackFiltered(VanillaLevelCallbacks.POST_CONTRAPTION_DETONATE, new EntityCallbackParams(entity), entity.GetDefinitionID());

        return blackhole;
    }
    public static function ExplodeEvoked(entity:Entity, range:Float):Null<Entity>
    {
        var fieldParam = entity.GetSpawnParams();
        fieldParam.SetProperty(VanillaEntityProps.RANGE, range);
        var field = entity.Spawn(VanillaEffectID.annihilationField, entity.GetCenter(), fieldParam);

        Explosion.Spawn(entity, entity.GetCenter(), range);

        entity.PlaySound(VanillaSoundID.explosion);
        entity.PlaySound(VanillaSoundID.gravitation);
        entity.Level.ShakeScreen(10, 0, 15);
        entity.Level.Triggers.RunCallbackFiltered(VanillaLevelCallbacks.POST_CONTRAPTION_DETONATE, new EntityCallbackParams(entity), entity.GetDefinitionID());

        return field;
    }
    public static inline var DAMAGE_MULTIPLIER:Float = 0.01;
}
