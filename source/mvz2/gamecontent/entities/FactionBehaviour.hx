// Ported from: Assets/Scripts/Vanilla/GameContent/Entities/FactionBehaviour.cs
package mvz2.gamecontent.entities;

import mvz2.vanilla.entities.VanillaEntityBehaviourNames;
import mvz2.vanilla.properties.VanillaEntityPropertyMeta;
import pvzengine.definitions.EntityBehaviourDefinition;
import pvzengine.entities.EngineEntityProps;
import pvzengine.entities.Entity;
import pvzengine.modifiers.BooleanModifier;

@:autoEntityBehaviourDefinition(VanillaEntityBehaviourNames.faction)
class FactionBehaviour extends EntityBehaviourDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
        AddModifier(new BooleanModifier(EngineEntityProps.FLIP_X, PROP_FLIP_X));
    }
    public override function Init(entity:Entity):Void
    {
        super.Init(entity);
        UpdateFlipX(entity);
    }
    public override function Update(entity:Entity):Void
    {
        super.Update(entity);
        UpdateFlipX(entity);
    }
    function UpdateFlipX(entity:Entity):Void
    {
        var targetFaction = entity.GetFaction();
        var faceRight = targetFaction == entity.Level.Option.LeftFaction;
        entity.SetProperty(PROP_FLIP_X, entity.FaceLeftAtDefault() == faceRight);
    }

    public static var PROP_FLIP_X:VanillaEntityPropertyMeta<Bool> = new VanillaEntityPropertyMeta<Bool>("FlipX");
}
