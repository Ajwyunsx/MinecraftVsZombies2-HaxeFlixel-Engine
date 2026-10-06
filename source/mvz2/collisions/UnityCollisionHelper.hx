package mvz2.collisions;

import pvzengine.collisions.EntityCollisionHelper;
import pvzengine.entities.EntityTypes;

// Ported from: Assets/Scripts/MVZ2/Collision/UnityCollisionHelper.cs
class UnityCollisionHelper {
    private function new() {}

    public static function ToEntityLayerMask(objLayer:Int):Int {
        if (object2EntityLayerMap.exists(objLayer))
            return object2EntityLayerMap.get(objLayer);
        return 0;
    }
    public static function ToObjectLayerMask(entityLayer:Int):Int {
        var objLayer = 0;
        for (key in entity2ObjectLayerMap.keys()) {
            if ((entityLayer & key) == 0)
                continue;
            objLayer |= 1 << entity2ObjectLayerMap.get(key);
        }
        return objLayer;
    }
    public static function ToObjectLayer(entityType:Int):Int {
        if (typeLayerMap.exists(entityType)) {
            return typeLayerMap.get(entityType);
        }
        return 0;
    }

    private static var typeLayerMap:Map<Int, Int> = [
        EntityTypes.PLANT => LAYER_CONTRAPTION,
        EntityTypes.ENEMY => LAYER_ENEMY,
        EntityTypes.OBSTACLE => LAYER_OBSTACLE,
        EntityTypes.BOSS => LAYER_BOSS,
        EntityTypes.CART => LAYER_CART,
        EntityTypes.PICKUP => LAYER_PICKUP,
        EntityTypes.PROJECTILE => LAYER_PROJECTILE,
        EntityTypes.EFFECT => LAYER_EFFECT,
    ];
    private static var entity2ObjectLayerMap:Map<Int, Int> = [
        EntityCollisionHelper.MASK_PLANT => LAYER_CONTRAPTION,
        EntityCollisionHelper.MASK_ENEMY => LAYER_ENEMY,
        EntityCollisionHelper.MASK_OBSTACLE => LAYER_OBSTACLE,
        EntityCollisionHelper.MASK_BOSS => LAYER_BOSS,
        EntityCollisionHelper.MASK_CART => LAYER_CART,
        EntityCollisionHelper.MASK_PICKUP => LAYER_PICKUP,
        EntityCollisionHelper.MASK_PROJECTILE => LAYER_PROJECTILE,
        EntityCollisionHelper.MASK_EFFECT => LAYER_EFFECT,
    ];
    private static var object2EntityLayerMap:Map<Int, Int> = [
        LAYER_CONTRAPTION => EntityCollisionHelper.MASK_PLANT,
        LAYER_ENEMY => EntityCollisionHelper.MASK_ENEMY,
        LAYER_OBSTACLE => EntityCollisionHelper.MASK_OBSTACLE,
        LAYER_BOSS => EntityCollisionHelper.MASK_BOSS,
        LAYER_CART => EntityCollisionHelper.MASK_CART,
        LAYER_PICKUP => EntityCollisionHelper.MASK_PICKUP,
        LAYER_PROJECTILE => EntityCollisionHelper.MASK_PROJECTILE,
        LAYER_EFFECT => EntityCollisionHelper.MASK_EFFECT,
    ];

    public static inline var LAYER_CONTRAPTION:Int = 24;
    public static inline var LAYER_ENEMY:Int = 25;
    public static inline var LAYER_OBSTACLE:Int = 26;
    public static inline var LAYER_BOSS:Int = 27;
    public static inline var LAYER_CART:Int = 28;
    public static inline var LAYER_PICKUP:Int = 29;
    public static inline var LAYER_PROJECTILE:Int = 30;
    public static inline var LAYER_EFFECT:Int = 31;
}
