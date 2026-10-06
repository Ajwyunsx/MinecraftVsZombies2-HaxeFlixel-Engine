// Ported from: Assets/Scripts/Vanilla/GameContent/RandomChinaEvents/Pokers/AceOfClubsEvent.cs
package mvz2.gamecontent.randomchinaevents;

import mvz2.gamecontent.contraptions.VanillaContraptionID;
import mvz2.gamecontent.pickups.VanillaPickupID;
import mvz2.vanilla.localization.VanillaStrings;
import mvz2.vanilla.pickups.VanillaPickupProps;
import mvz2logic.blueprints.LogicBlueprintID;
import pvzengine.entities.Entity;
import unity.Vector3;
using mvz2.vanilla.entities.VanillaEntityExt;

@:randomChinaEventDefinition(VanillaRandomChinaEventNames.aceOfClubs)
class AceOfClubsEvent extends AceAbstractEvent
{
    public function new(nsp:String, path:String)
    {
        super(nsp, path, NAME, DESCRIPTION);
    }
    override function Transform(target:Entity, china:Entity):Void
    {
        var param = china.GetSpawnParams();
        param.SetProperty(VanillaPickupProps.CONTENT_ID, LogicBlueprintID.FromEntity(VanillaContraptionID.tnt));
        // C#: china.Spawn(...)?.Let(e => { e.Velocity = Vector3.up * 2f; });
        var e = china.Spawn(VanillaPickupID.blueprintPickup, target.Position, param);
        if (e != null)
        {
            e.Velocity = Vector3.up * 2;
        }
    }
    @:translateMsg("随机瓷器事件名称", VanillaStrings.CONTEXT_RANDOM_CHINA_EVENT_NAME)
    public static inline var NAME:String = "梅花A";
    @:translateMsg("随机瓷器事件描述", VanillaStrings.CONTEXT_RANDOM_CHINA_EVENT_DESCRIPTION)
    public static inline var DESCRIPTION:String = "将所有怪物和掉落物变为TNT蓝图";
}
