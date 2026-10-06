// Ported from: Assets/Scripts/Vanilla/Frameworks/Entities/IDestroyBySpikesEntityBehaviour.cs
package mvz2.vanilla.entities;

import pvzengine.armors.Armor;
import pvzengine.entities.Entity;

interface IDestroyBySpikesEntityBehaviour
{
    function CanBeDestroyedBySpikes(entity:Entity, source:Entity):Bool;
    function DestroyBySpikes(entity:Entity, source:Entity):Void;
}

interface IDestroyBySpikesArmorBehaviour
{
    function CanBeDestroyedBySpikes(armor:Armor, source:Entity):Bool;
    function DestroyBySpikes(armor:Armor, source:Entity):Void;
}
