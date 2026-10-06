// Ported from: Assets/Scripts/Vanilla/GameContent/Buffs/Boss/Chapter1/FrankensteinSteelBuff.cs
package mvz2.gamecontent.buffs.bosses;

import mvz2.gamecontent.buffs.VanillaBuffNames;
import mvz2.gamecontent.projectiles.VanillaProjectileID;
import mvz2.gamecontent.shells.VanillaShellID;
import mvz2.vanilla.audios.VanillaSoundID;
import mvz2.vanilla.callbacks.VanillaLevelCallbacks;
import pvzengine.callbacks.CallbackResult;
import pvzengine.definitions.BuffDefinition;
import pvzengine.entities.EngineEntityProps;
import pvzengine.entities.Entity;
import pvzengine.modifiers.NamespaceIDModifier;
import pvzengine.modifiers.SetOperator;
import tools.geometrical.Geometry;
import unity.Vector2;
import unity.Vector3;
import mvz2.vanilla.callbacks.VanillaLevelCallbacks.PreProjectileHitParams;
using mvz2logic.entities.LogicEntityExt;

@:autoBuffDefinition(VanillaBuffNames.Boss_frankensteinSteel)
class FrankensteinSteelBuff extends BuffDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
        AddModifier(new NamespaceIDModifier(EngineEntityProps.SHELL, SetOperator.Set, VanillaShellID.metal));
        AddTrigger(VanillaLevelCallbacks.PRE_PROJECTILE_HIT, PreProjectileHitCallback, VanillaProjectileID.knife);
    }
    function PreProjectileHitCallback(param:PreProjectileHitParams, result:CallbackResult):Void
    {
        var hitInput = param.hit;
        var other = hitInput.Other;
        if (!other.HasBuff(FrankensteinSteelBuff))
            return;
        var knife = hitInput.Projectile;
        knife.SetFaction(other.GetFaction());

        DeflectKnife(other, knife);
        knife.PlaySound(VanillaSoundID.shieldHit);

        result.SetFinalValue(false);
    }
    function DeflectKnife(self:Entity, knife:Entity):Void
    {
        var size = self.GetScaledSize();
        var thisX = self.Position.x;
        var thisZ = self.Position.z;
        var xExtent = size.x / 2;
        var zExtent = size.z / 2;
        var knifeX = knife.Position.x;
        var knifeZ = knife.Position.z;
        var knifeXSpeed = knife.Velocity.x;
        var knifeZSpeed = knife.Velocity.z;

        var leftUp = new Vector2(thisX - xExtent, thisZ + zExtent);
        var leftDown = new Vector2(thisX - xExtent, thisZ - zExtent);
        var rightUp = new Vector2(thisX + xExtent, thisZ + zExtent);
        var rightDown = new Vector2(thisX + xExtent, thisZ - zExtent);

        var otherDirection2D = new Vector2(knifeXSpeed, knifeZSpeed).normalized;
        var longRange = otherDirection2D * 100;
        var otherLastPos2D = new Vector2(knifeX, knifeZ) - longRange;
        var otherPos2D = new Vector2(knifeX, knifeZ) + longRange;

        var normal = Vector3.zero;

        if (knifeZSpeed > 0 && knifeZ <= self.Position.z)
        {
            if (Geometry.DoLinesIntersect(otherLastPos2D, otherPos2D, leftDown, rightDown))
            {
                normal = Vector3.back;
            }
        }
        else if (knifeZSpeed < 0 && knifeZ >= self.Position.z)
        {
            if (Geometry.DoLinesIntersect(otherLastPos2D, otherPos2D, leftUp, rightUp))
            {
                normal = Vector3.forward;
            }
        }

        if (knifeXSpeed > 0 && knifeX <= self.Position.x)
        {
            if (Geometry.DoLinesIntersect(otherLastPos2D, otherPos2D, leftUp, leftDown))
            {
                normal = Vector3.left;
            }
        }
        else if (knifeXSpeed < 0 && knifeX >= self.Position.x)
        {
            if (Geometry.DoLinesIntersect(otherLastPos2D, otherPos2D, rightUp, rightDown))
            {
                normal = Vector3.right;
            }
        }
        knife.Velocity = Vector3.Reflect(knife.Velocity, normal.normalized);
    }
}
