// Ported from: Assets/Scripts/Vanilla/GameContent/Models/VanillaModelID.cs
package mvz2.gamecontent.models;

import mvz2.vanilla.VanillaMod;
import pvzengine.EngineModelID;
import pvzengine.NamespaceID;
using pvzengine.EngineModelID;

class VanillaModelID
{
    public static inline var TYPE_GRID:String = "grid";
    public static inline var TYPE_HELD_ITEM:String = "held";
    public static inline var TYPE_ARMOR:String = "armor";
    public static inline var TYPE_ICON:String = "icon";
    public static inline var TYPE_UI:String = "ui";

    public static var gridPlaceHolder:NamespaceID = Get("grid_placeholder", TYPE_GRID);
    public static var goldenGrid:NamespaceID = Get("golden_grid", TYPE_GRID);
    public static var brokenTile:NamespaceID = Get("broken_tile", TYPE_GRID);

    public static var zombie:NamespaceID = Get("zombie", EngineModelID.TYPE_ENTITY);
    public static var moneyChest:NamespaceID = Get("money_chest", EngineModelID.TYPE_ENTITY);
    public static var blueprintPickup:NamespaceID = Get("blueprint_pickup", EngineModelID.TYPE_ENTITY);
    public static var mapPickup:NamespaceID = Get("map_pickup", EngineModelID.TYPE_ENTITY);
    public static var emerald:NamespaceID = Get("emerald", EngineModelID.TYPE_ENTITY);
    public static var ruby:NamespaceID = Get("ruby", EngineModelID.TYPE_ENTITY);
    public static var sapphire:NamespaceID = Get("sapphire", EngineModelID.TYPE_ENTITY);
    public static var diamond:NamespaceID = Get("diamond", EngineModelID.TYPE_ENTITY);
    public static var pistonPalm:NamespaceID = Get("piston_palm", EngineModelID.TYPE_ENTITY);
    public static var dullahanMain:NamespaceID = Get("dullahan_main", EngineModelID.TYPE_ENTITY);

    public static var boatItem:NamespaceID = Get("boat_item", TYPE_ARMOR);

    public static var pickaxeHeldItem:NamespaceID = Get("pickaxe", TYPE_HELD_ITEM);
    public static var triggerHeldItem:NamespaceID = Get("trigger", TYPE_HELD_ITEM);
    public static var swordHeldItem:NamespaceID = Get("sword", TYPE_HELD_ITEM);
    public static var defaultStartShardHeldItem:NamespaceID = Get("starshard.default", TYPE_HELD_ITEM);
    public static var targetHeldItem:NamespaceID = Get("target", TYPE_HELD_ITEM);
    public static var combat:NamespaceID = Get("combat", TYPE_HELD_ITEM);

    public static var shortCircuit:NamespaceID = Get("short_circuit", TYPE_ICON);
    public static var nocturnal:NamespaceID = Get("nocturnal", TYPE_ICON);
    public static var staticParticles:NamespaceID = Get("static_particles", TYPE_ICON);
    public static var dreamKeyShield:NamespaceID = Get("dream_key_shield", TYPE_ICON);
    public static var terrorParasitized:NamespaceID = Get("terror_parasitized", TYPE_ICON);
    public static var weaknessParticles:NamespaceID = Get("weakness_particles", TYPE_ICON);
    public static var witherParticles:NamespaceID = Get("wither_particles", TYPE_ICON);
    public static var dreamAlarm:NamespaceID = Get("dream_alarm", TYPE_ICON);
    public static var parabotInsected:NamespaceID = Get("parabot_insected", TYPE_ICON);
    public static var knockbackWave:NamespaceID = Get("knockback_wave", TYPE_ICON);
    public static var divineShield:NamespaceID = Get("divine_shield", TYPE_ICON);
    public static var vulnerable:NamespaceID = Get("vulnerable", TYPE_ICON);
    public static var glowingParticles:NamespaceID = Get("glowing_particles", TYPE_ICON);
    public static var gravelOnFace:NamespaceID = Get("gravel_on_face", TYPE_ICON);
    public static var candleCursed:NamespaceID = Get("candle_cursed", TYPE_ICON);
    public static var petrifiedFeet:NamespaceID = Get("petrified_feet", TYPE_ICON);
    public static var shackled:NamespaceID = Get("shackled", TYPE_ICON);
    public static var burning:NamespaceID = Get("burning", TYPE_ICON);

    public static var mindSwap:NamespaceID = Get("mind_swap", TYPE_UI);
    public static var blueprintLock:NamespaceID = Get("blueprint_lock", TYPE_UI);
    public static function GetStarshardHeldItem(areaID:NamespaceID):NamespaceID
    {
        return new NamespaceID(areaID.SpaceName, 'starshard.${areaID.Path}').ToModelID(TYPE_HELD_ITEM);
    }
    static function Get(name:String, type:String):NamespaceID
    {
        return new NamespaceID(VanillaMod.spaceName, name).ToModelID(type);
    }
}
