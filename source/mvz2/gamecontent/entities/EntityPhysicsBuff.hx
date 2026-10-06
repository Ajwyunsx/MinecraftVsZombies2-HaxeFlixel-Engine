// Ported from: Assets/Scripts/Vanilla/GameContent/Entities/EntityPhysicsBuff.cs
// PORT-NOTE: 原 C# 文件名 EntityPhysicsBuff.cs，文件内类名为 EntityPhysicsBehaviour，
// 按 PORTING.md「一个 C# 文件 → 一个同名 .hx 文件」保留文件名，类名保持与 C# 一致。
package mvz2.gamecontent.entities;

import mvz2.vanilla.entities.VanillaEntityBehaviourNames;
import mvz2.vanilla.entities.VanillaEntityProps;
import mvz2.vanilla.properties.VanillaEntityPropertyMeta;
import pvzengine.definitions.EntityBehaviourDefinition;
import pvzengine.entities.EngineEntityProps;
import pvzengine.entities.Entity;
import pvzengine.modifiers.FloatModifier;
import pvzengine.modifiers.NumberOperator;

@:autoBuffDefinition(VanillaEntityBehaviourNames.entityPhysics)
class EntityPhysicsBehaviour extends EntityBehaviourDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
        AddModifier(new FloatModifier(EngineEntityProps.FRICTION, NumberOperator.Multiply, PROP_FRICTION));
    }
    public override function Init(entity:Entity):Void
    {
        super.Init(entity);
        entity.SetProperty(PROP_FRICTION, 1.0);
        UpdateMultipliers(entity);
    }
    public override function Update(entity:Entity):Void
    {
        super.Update(entity);
        UpdateMultipliers(entity);
    }
    function UpdateMultipliers(entity:Entity):Void
    {
        var friction:Float = 1;
        if (!entity.IsOnGround && !VanillaEntityProps.KeepGroundFriction(entity))
        {
            friction = 0.1;
        }
        entity.SetProperty(PROP_FRICTION, friction);
    }
    public static var PROP_FRICTION:VanillaEntityPropertyMeta<Float> = new VanillaEntityPropertyMeta<Float>("friction");
}
