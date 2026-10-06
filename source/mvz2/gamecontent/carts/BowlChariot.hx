// Ported from: Assets/Scripts/Vanilla/GameContent/Carts/BowlChariot.cs
package mvz2.gamecontent.carts;

import mvz2.gamecontent.carts.VanillaCartID.VanillaCartNames;
import mvz2.gamecontent.projectiles.VanillaProjectileID;
import mvz2.vanilla.carts.VanillaCartExt;
import mvz2.vanilla.entities.VanillaEntityExt;
import mvz2.vanilla.entities.VanillaEntityProps;
import mvz2.vanilla.projectiles.VanillaProjectileProps;
import pvzengine.entities.EngineEntityProps;
import pvzengine.entities.Entity;
import unity.Vector3;

@:autoEntityBehaviourDefinition(VanillaCartNames.bowlChariot)
class BowlChariot extends CartBehaviour
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
    }
    public override function Update(entity:Entity):Void
    {
        super.Update(entity);
        entity.SetModelProperty("Running", VanillaCartExt.IsCartTriggered(entity));
    }
    public override function PostTrigger(entity:Entity):Void
    {
        super.PostTrigger(entity);
        var scale = new Vector3(0.6666, 0.6666, 0.6666);
        var param = VanillaEntityExt.GetSpawnParams(entity);
        param.SetProperty(VanillaProjectileProps.PIERCING, true);
        param.SetProperty(EngineEntityProps.DISPLAY_SCALE, scale);
        param.SetProperty(EngineEntityProps.SCALE, scale);
        param.SetProperty(VanillaEntityProps.DAMAGE, 100.0);
        // PORT-NOTE: C# `?.Let(e => {...})` → 显式判空块。
        var e = entity.Spawn(VanillaProjectileID.boulder, entity.Position + new Vector3(0, 16, 0), param);
        if (e != null)
        {
            e.Velocity = Vector3.right * 10;
        }
    }
}
