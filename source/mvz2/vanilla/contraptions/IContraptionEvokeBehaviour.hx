// Ported from: Assets/Scripts/Vanilla/Frameworks/Contraptions/IContraptionEvokeBehaviour.cs
package mvz2.vanilla.contraptions;

import pvzengine.entities.Entity;

interface IContraptionEvokeBehaviour
{
    function CanEvoke(contraption:Entity):Bool;
    function Evoke(contraption:Entity):Void;
}
