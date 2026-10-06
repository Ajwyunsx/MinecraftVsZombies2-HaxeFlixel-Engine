// Ported from: Assets/Scripts/Vanilla/Frameworks/Contraptions/IExplodeContraptionBehaviour.cs
package mvz2.vanilla.contraptions;

import pvzengine.entities.Entity;

interface IExplodeContraptionBehaviour
{
    function Explode(contraption:Entity, range:Float, damage:Float):Void;
}
