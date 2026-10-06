// Ported from: Assets/Scripts/Vanilla/GameContent/Buffs/Enemies/Chapter2/VortexHopperDragBuff.cs
package mvz2.gamecontent.buffs.enemies;

import mvz2.gamecontent.buffs.VanillaBuffNames;
import mvz2.vanilla.properties.VanillaBuffPropertyMeta;
import mvz2logic.level.LogicLevelExt;
import pvzengine.buffs.Buff;
import pvzengine.definitions.BuffDefinition;
import unity.Mathf;
import unity.Vector3;

@:autoBuffDefinition(VanillaBuffNames.Enemy_vortexHopperDrag)
class VortexHopperDragBuff extends BuffDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
    }
    public override function PostUpdate(buff:Buff):Void
    {
        super.PostUpdate(buff);
        var entity = buff.GetEntity();
        if (entity == null)
            return;
        var center = buff.GetProperty(PROP_CENTER);
        var angle = buff.GetProperty(PROP_ANGLE);
        var radius = buff.GetProperty(PROP_RADIUS);
        angle += 16;
        angle %= 360;
        buff.SetProperty(PROP_ANGLE, angle);

        var pos = entity.Position;
        var x = center.x + Mathf.Cos(angle * Mathf.Deg2Rad) * radius;
        var z = center.z + Mathf.Sin(angle * Mathf.Deg2Rad) * radius;

        var level = entity.Level;
        if (LogicLevelExt.IsWaterAt(level, x, entity.Position.z))
        {
            pos.x = x;
        }
        if (LogicLevelExt.IsWaterAt(level, entity.Position.x, z))
        {
            pos.z = z;
        }

        entity.Position = pos;

        radius = Mathf.Max(20, radius - 3);
        buff.SetProperty(PROP_RADIUS, radius);

        if (!entity.IsDead)
        {
            buff.Remove();
        }
    }
    public static var PROP_CENTER:VanillaBuffPropertyMeta<Vector3> = new VanillaBuffPropertyMeta<Vector3>("Center");
    public static var PROP_RADIUS:VanillaBuffPropertyMeta<Float> = new VanillaBuffPropertyMeta<Float>("Radius");
    public static var PROP_ANGLE:VanillaBuffPropertyMeta<Float> = new VanillaBuffPropertyMeta<Float>("Angle");
}
