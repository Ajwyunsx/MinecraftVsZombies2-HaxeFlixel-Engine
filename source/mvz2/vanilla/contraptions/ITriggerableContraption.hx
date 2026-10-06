// Ported from: Assets/Scripts/Vanilla/Frameworks/Contraptions/ITriggerableContraption.cs
package mvz2.vanilla.contraptions;

import pvzengine.entities.Entity;

interface ITriggerableContraption
{
    function CanTrigger(contraption:Entity):Bool;
    function Trigger(contraption:Entity):Void;
}
