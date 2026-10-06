// Ported from: Assets/Scripts/Vanilla/GameContent/Placements/VanillaPlaceMethods.cs
package mvz2.gamecontent.placements;

import pvzengine.placements.PlaceMethod;

class VanillaPlaceMethods
{
    public static var entity:PlaceMethod = new EntityPlaceMethod();
    public static var upgrade:PlaceMethod = new UpgradePlaceMethod();
    public static var upgradeSideBySide:PlaceMethod = new UpgradeSideBySidePlaceMethod();
    public static var drivenser:PlaceMethod = new DrivenserPlaceMethod();
    public static var firstAid:PlaceMethod = new FirstAidPlaceMethod();
    public static var enemy:PlaceMethod = new EnemyPlaceMethod();
}
