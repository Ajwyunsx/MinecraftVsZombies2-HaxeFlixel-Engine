// Ported from: Assets/Scripts/Vanilla/GameContent/Buffs/Pickups/Chapter5/AbsorbedByUFOBuff.cs
package mvz2.gamecontent.buffs.pickups;

import mvz2.gamecontent.buffs.VanillaBuffNames;
import mvz2.gamecontent.enemies.UFOBehaviourBlue;
import mvz2.vanilla.pickups.VanillaPickupProps;
import mvz2.vanilla.properties.VanillaBuffPropertyMeta;
import pvzengine.buffs.Buff;
import pvzengine.definitions.BuffDefinition;
import pvzengine.entities.EngineEntityProps;
import pvzengine.entities.EntityID;
import pvzengine.modifiers.BooleanModifier;
import pvzengine.modifiers.FloatModifier;
import pvzengine.modifiers.NumberOperator;
import tools.FrameTimer;

@:autoBuffDefinition(VanillaBuffNames.Pickup_absorbedByUFO)
class AbsorbedByUFOBuff extends BuffDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
        AddModifier(new FloatModifier(EngineEntityProps.GRAVITY, NumberOperator.Multiply, 0));
        AddModifier(new BooleanModifier(VanillaPickupProps.NO_COLLECT, true));
        AddModifier(new BooleanModifier(VanillaPickupProps.NO_LIMIT_IN_SCREEN, true));
    }
    public override function PostUpdate(buff:Buff):Void
    {
        super.PostUpdate(buff);
        var entity = buff.GetEntity();
        if (entity != null)
        {
            var ufoID = GetUFOID(buff);
            var ufo = ufoID == null ? null : ufoID.GetEntity(buff.Level);
            // PORT-NOTE: C# 直接调用 ufo.ExistsAndAlive()（扩展方法容忍 null），Haxe 侧显式判空。
            if (ufo == null || !ufo.ExistsAndAlive())
            {
                buff.Remove();
                return;
            }

            var distance = ufo.Position - entity.Position;
            var velocity = entity.Velocity;
            velocity = velocity * (1 - MOVE_FACTOR) + distance.normalized * ABSORB_SPEED * MOVE_FACTOR;
            entity.Velocity = velocity;

            if (distance.sqrMagnitude <= SQR_ABSORB_DISTANCE)
            {
                entity.Remove();
                buff.Remove();
                UFOBehaviourBlue.AddAbsorbedEntityID(ufo, entity.GetDefinitionID());
            }
        }
    }
    public static function GetUFOID(buff:Buff):Null<EntityID> return buff.GetProperty(PROP_UFO);
    public static function SetUFOID(buff:Buff, value:EntityID):Void buff.SetProperty(PROP_UFO, value);
    public static inline var ABSORB_SPEED:Float = 10;
    public static inline var ABSORB_DISTANCE:Float = 20;
    public static inline var SQR_ABSORB_DISTANCE:Float = ABSORB_DISTANCE * ABSORB_DISTANCE;
    public static inline var MOVE_FACTOR:Float = 0.2;
    public static var PROP_UFO:VanillaBuffPropertyMeta<EntityID> = new VanillaBuffPropertyMeta<EntityID>("ufo");
    public static var PROP_TIMER:VanillaBuffPropertyMeta<FrameTimer> = new VanillaBuffPropertyMeta<FrameTimer>("timer");
}
