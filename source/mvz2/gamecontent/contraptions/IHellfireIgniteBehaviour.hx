// Ported from: Assets/Scripts/Vanilla/GameContent/Contraptions/Chapter4/Hellfire.cs
package mvz2.gamecontent.contraptions;

import pvzengine.entities.Entity;

interface IHellfireIgniteBehaviour
{
    function Ignite(entity:Entity, hellfire:Entity, cursed:Bool):Void;
}
