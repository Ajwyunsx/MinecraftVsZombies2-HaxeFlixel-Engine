// Ported from: Assets/Scripts/Vanilla/GameContent/Contraptions/Chapter3/GiantBowl.cs
package mvz2.gamecontent.contraptions;

import mvz2.gamecontent.pickups.VanillaPickupID;
import mvz2.vanilla.audios.VanillaSoundID;
import mvz2.vanilla.entities.VanillaEntityExt;
import mvz2.vanilla.properties.VanillaEntityPropertyMeta;
import mvz2logic.entities.LogicEntityExt;
import pvzengine.EngineEntityProps;
import pvzengine.NamespaceID;
import pvzengine.damages.DeathInfo;
import pvzengine.entities.Entity;
import pvzengine.modifiers.ColorModifier;
import tools.FrameTimer;
import unity.Color;
import unity.Mathf;
using mvz2.vanilla.entities.VanillaEntityProps;
using mvz2logic.entities.LogicEntityExt;

@:autoEntityBehaviourDefinition(VanillaContraptionNames.giantBowl)
class GiantBowl extends ContraptionBehaviour
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
        AddModifier(new ColorModifier(EngineEntityProps.COLOR_OFFSET, PROP_PRODUCE_COLOR));
    }
    public override function Init(entity:Entity):Void
    {
        super.Init(entity);
        var productionTimer = new FrameTimer(PRODUCT_TIME);
        SetProductionTimer(entity, productionTimer);
    }
    override function UpdateAI(entity:Entity):Void
    {
        super.UpdateAI(entity);
        var timer = GetProductionTimer(entity);
        if (timer != null)
        {
            if (GetPointCount(entity) < MAX_STARSHARD_COUNT)
            {
                timer.Run(entity.GetProduceSpeed());
                if (timer.Expired)
                {
                    timer.Reset();
                    AddPointCount(entity, 1);
                    entity.PlaySound(VanillaSoundID.starshardUse);
                }
            }
            else
            {
                timer.Reset();
            }
        }
        var pointsAngle = GetPointsAngle(entity);
        pointsAngle += ANGLE_SPEED;
        pointsAngle %= 360;
        SetPointsAngle(entity, pointsAngle);

        var pointsRadial = GetPointsRadial(entity);
        pointsRadial += RADIAL_SPEED;
        pointsRadial %= Mathf.PI * 2;
        SetPointsRadial(entity, pointsRadial);
    }
    override function UpdateLogic(entity:Entity):Void
    {
        super.UpdateLogic(entity);

        var produceColor = Color.clear;
        var timer = GetProductionTimer(entity);
        var thresold = PRODUCT_TIME * 0.5;
        var progress = thresold - (timer != null ? timer.Frame : 0);
        if (progress > 0)
        {
            var x = Mathf.Pow(progress / (PRODUCT_TIME / 12.5), 3);
            var alpha = (-Mathf.Cos(x) + 1) * 0.25;
            produceColor = Color.white;
            produceColor.a = alpha;
        }
        SetProduceColor(entity, produceColor);

        entity.SetModelProperty("Count", GetPointCount(entity));
        entity.SetModelProperty("Angle", GetPointsAngle(entity));
        entity.SetModelProperty("Radial", (Mathf.Sin(GetPointsRadial(entity)) + 1) * 0.5);
    }

    public override function CanEvoke(entity:Entity):Bool
    {
        if (GetPointCount(entity) >= MAX_STARSHARD_COUNT)
            return false;
        return super.CanEvoke(entity);
    }

    override function OnEvoke(contraption:Entity):Void
    {
        super.OnEvoke(contraption);
        AddPointCount(contraption, 1);
    }

    public override function PostDeath(entity:Entity, damageInfo:DeathInfo):Void
    {
        super.PostDeath(entity, damageInfo);
        var points = GetPointCount(entity);
        for (i in 0...points)
        {
            entity.Spawn(VanillaPickupID.starshard, entity.Position);
        }
        SetPointCount(entity, 0);
    }

    public static function GetProduceColor(entity:Entity):Color return entity.GetProperty(PROP_PRODUCE_COLOR);
    public static function SetProduceColor(entity:Entity, value:Color):Void entity.SetProperty(PROP_PRODUCE_COLOR, value);

    public static function GetProductionTimer(entity:Entity):Null<FrameTimer> return entity.GetBehaviourFieldNS(ID, FIELD_PRODUCTION_TIMER);
    public static function SetProductionTimer(entity:Entity, value:FrameTimer):Void entity.SetBehaviourFieldNS(ID, FIELD_PRODUCTION_TIMER, value);

    public static function GetPointCount(entity:Entity):Int return entity.GetBehaviourFieldNS(ID, FIELD_POINT_COUNT);
    public static function SetPointCount(entity:Entity, value:Int):Void entity.SetBehaviourFieldNS(ID, FIELD_POINT_COUNT, value);
    public static function AddPointCount(entity:Entity, value:Int):Void SetPointCount(entity, GetPointCount(entity) + value);

    public static function GetPointsAngle(entity:Entity):Float return entity.GetBehaviourFieldNS(ID, FIELD_POINTS_ANGLE);
    public static function SetPointsAngle(entity:Entity, value:Float):Void entity.SetBehaviourFieldNS(ID, FIELD_POINTS_ANGLE, value);

    public static function GetPointsRadial(entity:Entity):Float return entity.GetBehaviourFieldNS(ID, FIELD_POINTS_RADIAL);
    public static function SetPointsRadial(entity:Entity, value:Float):Void entity.SetBehaviourFieldNS(ID, FIELD_POINTS_RADIAL, value);


    static var FIELD_PRODUCTION_TIMER:VanillaEntityPropertyMeta<FrameTimer> = new VanillaEntityPropertyMeta<FrameTimer>("ProductionTimer");
    static var FIELD_POINT_COUNT:VanillaEntityPropertyMeta<Int> = new VanillaEntityPropertyMeta<Int>("PointCount");
    static var FIELD_POINTS_ANGLE:VanillaEntityPropertyMeta<Float> = new VanillaEntityPropertyMeta<Float>("PointsAngle");
    static var FIELD_POINTS_RADIAL:VanillaEntityPropertyMeta<Float> = new VanillaEntityPropertyMeta<Float>("PointsRadial");
    static var PROP_PRODUCE_COLOR:VanillaEntityPropertyMeta<Color> = new VanillaEntityPropertyMeta<Color>("ProduceColor");

    public static inline var MAX_STARSHARD_COUNT:Int = 5;
    public static inline var PRODUCT_TIME:Int = 1800;
    public static inline var ANGLE_SPEED:Float = 3;
    public static inline var RADIAL_SPEED:Float = 0.05;
    static var ID:NamespaceID = VanillaContraptionID.giantBowl;
}
