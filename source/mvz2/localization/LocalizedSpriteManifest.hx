// Ported from: Assets/Scripts/MVZ2/Localization/LocalizedSpriteManifest.cs
package mvz2.localization;

class LocalizedSpriteManifest {
    public var sprites:Array<LocalizedSprite>;
    public var spritesheets:Array<LocalizedSpriteSheet>;
}

class LocalizedSprite {
    public var name:String;
    public var texture:String;
    public var pivotX:Float;
    public var pivotY:Float;
}

class LocalizedSpriteSheet {
    public var name:String;
    public var texture:String;
    public var slices:Array<LocalizedSpriteSheetSlice>;
}

class LocalizedSpriteSheetSlice {
    public var x:Float;
    public var y:Float;
    public var width:Float;
    public var height:Float;
    public var pivotX:Float;
    public var pivotY:Float;
}
