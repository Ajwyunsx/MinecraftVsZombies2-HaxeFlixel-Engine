// Ported from: Assets/Scripts/Vanilla/GameContent/Effects/Prologue/FloatingText.cs
package mvz2.gamecontent.effects;

import mvz2.vanilla.entities.VanillaEntityExt;
import mvz2.vanilla.properties.VanillaEntityPropertyMeta;
import mvz2logic.entities.LogicEntityExt;
import mvz2logic.level.LogicLevelExt;
import pvzengine.EngineEntityProps;
import pvzengine.entities.Entity;
import pvzengine.modifiers.NumberOperator;
import pvzengine.modifiers.Vector3Modifier;
import unity.Mathf;
import unity.Vector3;
import mvz2.gamecontent.effects.VanillaEffectID.VanillaEffectNames;
using mvz2.vanilla.entities.VanillaEntityProps;

@:autoEntityBehaviourDefinition(VanillaEffectNames.floatingText)
class FloatingText extends EffectBehaviour
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
        AddModifier(new Vector3Modifier(EngineEntityProps.MODEL_POSITION_OFFSET, NumberOperator.Add, PROP_MODEL_OFFSET));
    }
    public override function Init(entity:Entity):Void
    {
        super.Init(entity);
        entity.SetModelProperty("Color", entity.GetTint());
        entity.SetModelProperty("Text", GetText(entity));
    }
    public override function Update(entity:Entity):Void
    {
        super.Update(entity);
        entity.SetModelProperty("Color", entity.GetTint());
        entity.SetModelProperty("Text", GetText(entity));
        var zOffset = Mathf.Lerp(10, 0, entity.Timeout / (entity.GetMaxTimeout() : Float));
        entity.SetModelPositionOffset(Vector3.forward * zOffset);
    }
    public static function GetText(entity:Entity):Null<String>
    {
        return entity.GetBehaviourField(PROP_TEXT);
    }
    public static function SetText(entity:Entity, value:String):Void
    {
        entity.SetBehaviourField(PROP_TEXT, value);
    }
    public static function GetModelOffset(entity:Entity):Vector3
    {
        return entity.GetBehaviourField(PROP_MODEL_OFFSET);
    }
    public static function SetModelOffset(entity:Entity, value:Vector3):Void
    {
        entity.SetBehaviourField(PROP_MODEL_OFFSET, value);
    }

    public static var PROP_TEXT:VanillaEntityPropertyMeta<String> = new VanillaEntityPropertyMeta<String>("Text");
    public static var PROP_MODEL_OFFSET:VanillaEntityPropertyMeta<Vector3> = new VanillaEntityPropertyMeta<Vector3>("model_offset");
}
