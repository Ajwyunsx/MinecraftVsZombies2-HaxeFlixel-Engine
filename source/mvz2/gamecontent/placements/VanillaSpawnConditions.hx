// Ported from: Assets/Scripts/Vanilla/GameContent/Placements/VanillaSpawnConditions.cs
package mvz2.gamecontent.placements;

import pvzengine.placements.SpawnCondition;

class VanillaSpawnConditions
{
    public static var any:SpawnCondition = new AnySpawnCondition();
    public static var normal:SpawnCondition = new NormalSpawnCondition();
    public static var buried:SpawnCondition = new BuriedSpawnCondition();
    public static var aquatic:SpawnCondition = new AquaticSpawnCondition();
    public static var pad:SpawnCondition = new PadSpawnCondition();
    public static var dreamSilk:SpawnCondition = new DreamSilkSpawnCondition();
    public static var coolingCell:SpawnCondition = new CoolingCellSpawnCondition();
    public static var suspension:SpawnCondition = new SuspensionSpawnCondition();
    public static var devourer:SpawnCondition = new DevourerSpawnCondition();
}
