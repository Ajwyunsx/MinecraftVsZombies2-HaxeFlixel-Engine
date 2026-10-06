// Ported from: Assets/Scripts/Vanilla/GameContent/Maps/DreamKeyMapElement.cs
package mvz2.gamecontent.izombie;

import mvz2.gamecontent.maps.VanillaMapElementBehaviourNames;
import mvz2.gamecontent.maps.VanillaMapID;
import mvz2.gamecontent.talk.VanillaTalkID;
import mvz2logic.Global;
import mvz2logic.maps.IMapElement;
import mvz2logic.maps.MapElementBehaviourDefinition;
import mvz2logic.unlocks.LogicUnlockGroupID;
using mvz2logic.talk.ITalkController;

@:autoMapElementBehaviourDefinition(VanillaMapElementBehaviourNames.dreamKey)
class DreamKeyMapElement extends MapElementBehaviourDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
    }
    public override function OnClick(element:IMapElement):Void
    {
        var map = element.Map;
        map.SetRaycastBlockerActive(true);
        var mapID = map.GetMapID();
        if (!Global.Saves.IsGroupUnlocked(LogicUnlockGroupID.chapter_Dream) && mapID == VanillaMapID.halloween)
        {
            var talkSystem = map.GetTalkSystem();
            talkSystem.SimpleStartTalk(VanillaTalkID.halloweenFinal, 0, 0);
        }
        else
        {
            var targetMap = mapID == VanillaMapID.halloween ? VanillaMapID.dream : VanillaMapID.halloween;
            map.ChangeMap(targetMap);
        }
    }
}
