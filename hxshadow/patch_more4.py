import io

# 1) SpriteRenderer.sprite: two sprite representations coexist (unity.Sprite + flixel.FlxSprite)
p = 'source/unity/SpriteRenderer.hx'
s = io.open(p, encoding='utf-8').read()
if 'public var sprite:Dynamic' not in s:
    s = s.replace('	public var sprite:FlxSprite;',
                  '	// PORT-NOTE: \u79fb\u690d\u5c42\u540c\u65f6\u5b58\u5728\u4e24\u79cd Sprite \u8868\u793a\uff08unity.Sprite \u8d44\u6e90\u5bf9\u8c61\u4e0e flixel.FlxSprite \u6e32\u67d3\u5bf9\u8c61\uff09\uff0c\n'
                  '	// \u6545\u5b57\u6bb5\u7c7b\u578b\u653e\u5bbd\u4e3a Dynamic \u4ee5\u517c\u5bb9\u4e24\u8005\u3002\n'
                  '	public var sprite:Dynamic;')
    io.open(p, 'w', encoding='utf-8', newline='').write(s)
    print('SpriteRenderer.sprite -> Dynamic')

# 2) ParticleSystem.textureSheetAnimation (used by ParticleTextureTranslator)
p = 'source/unity/ParticleSystem.hx'
s = io.open(p, encoding='utf-8').read()
if 'textureSheetAnimation' not in s:
    s = s.replace('    public var main:MainModule = new MainModule();',
                  '	// PORT-NOTE: \u8865\u5168 textureSheetAnimation\u5360\u4f4d\uff08\u79fb\u690d\u5c42\u4e0d\u5b9e\u73b0\u5b50\u7c92\u5b50 sprite sheet \u52a8\u753b\uff09\u3002\n'
                  '	public var textureSheetAnimation:TextureSheetAnimationModule = new TextureSheetAnimationModule();\n'
                  '	public var main(get, never):MainModule;')
    s = s.rstrip('\n') + '''

// PORT-NOTE: UnityEngine.ParticleSystem.TextureSheetAnimationModule \u7684\u6700\u5c0f\u5360\u4f4d\u5b9e\u73b0\u3002
class TextureSheetAnimationModule {
	public var enabled:Bool = false;
	public var mode:Dynamic = null;
	public var numTilesX:Int = 1;
	public var numTilesY:Int = 1;
	public var animation:Dynamic = null;
	public function new() {}
}
'''
    io.open(p, 'w', encoding='utf-8', newline='').write(s)
    print('ParticleSystem +textureSheetAnimation')
