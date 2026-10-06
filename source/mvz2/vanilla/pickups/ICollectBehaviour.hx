// Ported from: Assets/Scripts/Vanilla/Frameworks/Pickups/ICollectBehaviour.cs
package mvz2.vanilla.pickups;

import pvzengine.entities.Entity;

interface ICollectBehaviour
{
    function CanAutoCollect(pickup:Entity):Bool;
    function CanCollect(pickup:Entity):Bool;
    function PostCollect(pickup:Entity):Void;
}
