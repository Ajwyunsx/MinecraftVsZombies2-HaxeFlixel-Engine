// Ported from: Assets/Scripts/Vanilla/GameContent/Effects/Chapter1/ElectricArc.cs
package mvz2.gamecontent.effects;

import pvzengine.entities.Entity;
import unity.Mathf;
import unity.Vector3;
import mvz2.gamecontent.effects.VanillaEffectID.VanillaEffectNames;

@:autoEntityBehaviourDefinition(VanillaEffectNames.electricArc)
class ElectricArc extends EffectBehaviour
{
    // #region 公有方法
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
    }
    public override function Init(entity:Entity):Void
    {
        super.Init(entity);
        entity.SetModelProperty("Source", entity.Position);
        SetPointCount(entity, 50);
    }
    public override function Update(entity:Entity):Void
    {
        super.Update(entity);
        entity.SetModelProperty("Source", entity.Position);
    }
    public static function Connect(arc:Entity, position:Vector3):Void
    {
        arc.SetModelProperty("Source", arc.Position);
        arc.SetModelProperty("Dest", position);
        var t = (position - arc.Position).magnitude / 500;
        var count = Mathf.Lerp(3, 50, t);
        SetPointCount(arc, Mathf.FloorToInt(count));
    }
    public static function SetPointCount(arc:Entity, count:Int):Void
    {
        arc.SetModelProperty("PointCount", count);
    }
    public static function UpdateArc(arc:Entity):Void
    {
        arc.TriggerModel("Update");
    }
    // #endregion
}
