// Ported from: Assets/Scripts/Vanilla/GameContent/Enemies/VanillaSpawnID.cs
package mvz2.gamecontent.enemies;

import mvz2.vanilla.VanillaMod;
import pvzengine.NamespaceID;

class VanillaSpawnID
{
    public static var zombie:NamespaceID = GetFromEntity(VanillaEnemyID.zombie);
    public static var flagZombie:NamespaceID = GetFromEntity(VanillaEnemyID.flagZombie);
    public static var leatherCappedZombie:NamespaceID = GetFromEntity(VanillaEnemyID.leatherCappedZombie);
    public static var ironHelmettedZombie:NamespaceID = GetFromEntity(VanillaEnemyID.ironHelmettedZombie);
    public static var diamondHelmettedZombie:NamespaceID = GetFromEntity(VanillaEnemyID.diamondHelmettedZombie);

    public static var skeleton:NamespaceID = GetFromEntity(VanillaEnemyID.skeleton);
    public static var gargoyle:NamespaceID = GetFromEntity(VanillaEnemyID.gargoyle);
    public static var ghost:NamespaceID = GetFromEntity(VanillaEnemyID.ghost);
    public static var mummy:NamespaceID = GetFromEntity(VanillaEnemyID.mummy);
    public static var necromancer:NamespaceID = GetFromEntity(VanillaEnemyID.necromancer);

    public static var spider:NamespaceID = GetFromEntity(VanillaEnemyID.spider);
    public static var caveSpider:NamespaceID = GetFromEntity(VanillaEnemyID.caveSpider);
    public static var ghast:NamespaceID = GetFromEntity(VanillaEnemyID.ghast);
    public static var motherTerror:NamespaceID = GetFromEntity(VanillaEnemyID.motherTerror);

    public static var mesmerizer:NamespaceID = GetFromEntity(VanillaEnemyID.mesmerizer);
    public static var berserker:NamespaceID = GetFromEntity(VanillaEnemyID.berserker);
    public static var dullahan:NamespaceID = GetFromEntity(VanillaEnemyID.dullahan);
    public static var hellChariot:NamespaceID = GetFromEntity(VanillaEnemyID.hellChariot);

    public static var mutantZombie:NamespaceID = GetFromEntity(VanillaEnemyID.mutantZombie);


    public static var boneWall:NamespaceID = GetFromEntity(VanillaEnemyID.boneWall);
    public static var napstablook:NamespaceID = GetFromEntity(VanillaEnemyID.napstablook);
    public static var megaMutantZombie:NamespaceID = GetFromEntity(VanillaEnemyID.megaMutantZombie);

    public static var undeadFlyingObjectBlitz:NamespaceID = Get(VanillaSpawnNames.undeadFlyingObjectBlitz);
    public static function GetFromEntity(entityID:NamespaceID):NamespaceID
    {
        return entityID;
    }
    public static function Get(spawnPath:String):NamespaceID
    {
        return new NamespaceID(VanillaMod.spaceName, spawnPath);
    }
}
