// Ported from: Assets/Scripts/Vanilla/GameContent/Buffs/Contraption/Chapter1/SacrificedBuff.cs
package mvz2.gamecontent.buffs.contraptions;

import mvz2.gamecontent.buffs.VanillaBuffNames;
import mvz2.vanilla.entities.VanillaEntityProps;
import mvz2.vanilla.modifiers.VanillaModifierPriorities;
import mvz2.vanilla.properties.VanillaBuffPropertyMeta;
import mvz2logic.entities.LogicEntityProps;
import mvz2logic.models.SortingLayers.ShaderProperties;
import pvzengine.buffs.Buff;
import pvzengine.definitions.BuffDefinition;
import pvzengine.entities.EngineEntityProps;
import pvzengine.modifiers.BooleanModifier;
import pvzengine.modifiers.FloatModifier;
import pvzengine.modifiers.NumberOperator;
import pvzengine.modifiers.Vector3Modifier;
import unity.Vector3;

@:autoBuffDefinition(VanillaBuffNames.Contraption_sacrificed)
class SacrificedBuff extends BuffDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
        AddModifier(new FloatModifier(EngineEntityProps.GRAVITY, NumberOperator.Set, -0.5, VanillaModifierPriorities.FORCE));
        AddModifier(new Vector3Modifier(LogicEntityProps.LIGHT_RANGE, NumberOperator.Multiply, PROP_LIGHT_RANGE));
        AddModifier(new BooleanModifier(VanillaEntityProps.AI_FROZEN, true));
    }
    public override function PostUpdate(buff:Buff):Void
    {
        super.PostUpdate(buff);
        var time = buff.GetProperty(PROP_TIME);
        time++;
        buff.SetProperty(PROP_TIME, time);

        var percentage = time / MAX_TIME;
        buff.SetProperty(PROP_LIGHT_RANGE, Vector3.one * (1 - percentage));

        var entity = buff.GetEntity();
        if (entity == null)
            return;
        entity.RenderRotation += Vector3.forward * time;
        entity.SetShaderFloat(ShaderProperties.BURN_VALUE, percentage);
        entity.ApplyShaderProperties();

        if (time >= MAX_TIME)
        {
            entity.Remove();
        }
    }
    public static var PROP_TIME:VanillaBuffPropertyMeta<Int> = new VanillaBuffPropertyMeta<Int>("Time");
    public static var PROP_LIGHT_RANGE:VanillaBuffPropertyMeta<Vector3> = new VanillaBuffPropertyMeta<Vector3>("LightRange");
    public static inline var MAX_TIME:Int = 30;
}
