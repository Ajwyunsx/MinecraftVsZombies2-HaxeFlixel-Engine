import io, re

def patch(path, old, new, must=True):
    s = io.open(path, encoding='utf-8').read()
    if new.strip().split('\n')[0] in s:
        return False
    if old not in s:
        if must:
            print('MISS %s' % path)
        return False
    io.open(path, 'w', encoding='utf-8', newline='').write(s.replace(old, new, 1))
    print('ok %s' % path)
    return True

# ShapeModule fields (secondary type in ParticleSystem.hx)
p = 'source/unity/ParticleSystem.hx'
s = io.open(p, encoding='utf-8').read()
m = re.search(r'class ShapeModule \{(.*?)\n\}', s, re.S)
if m and 'public var scale' not in m.group(1):
    s = s[:m.end(1)] + '''
	// PORT-NOTE: 补全 ShapeModule 的 position/scale/rotation（Unity 的发射形状参数，Flixel 端不参与模拟）。
	public var position:Vector3 = new Vector3();
	public var scale:Vector3 = new Vector3(1, 1, 1);
	public var rotation:Vector3 = new Vector3();''' + s[m.end(1):]
    io.open(p, 'w', encoding='utf-8', newline='').write(s)
    print('ok ShapeModule')

# TextureSheetAnimationModule members
s = io.open(p, encoding='utf-8').read()
if 'spriteCount' not in s:
    s = s.replace('''class TextureSheetAnimationModule {
	public var enabled:Bool = false;''', '''class TextureSheetAnimationModule {
	public var enabled:Bool = false;
	// PORT-NOTE: 补全 spriteCount/GetSprite/SetSprite（sprites 列表由调用方维护）。
	public var spriteCount(get, never):Int;
	private var sprites:Array<Dynamic> = [];
	function get_spriteCount():Int return sprites.length;
	public function GetSprite(index:Int):Dynamic return (index >= 0 && index < sprites.length) ? sprites[index] : null;
	public function SetSprite(index:Int, sprite:Dynamic):Void {
		while (sprites.length <= index) sprites.push(null);
		sprites[index] = sprite;
	}''')
    io.open(p, 'w', encoding='utf-8', newline='').write(s)
    print('ok TextureSheetAnimationModule')

# Vector2.RotateClockwise
p = 'source/unity/Vector2.hx'
s = io.open(p, encoding='utf-8').read()
if 'RotateClockwise' not in s:
    anchor = '    public static function Lerp(a:Vector2, b:Vector2, t:Float):Vector2 {'
    if anchor not in s:
        anchor = s.split('\n')[0]
    add = '''    // PORT-NOTE: 补全 Unity Vector2 相关的角度旋转辅助（顺时针旋转角度，单位度）。
    public function RotateClockwise(degrees:Float):Vector2 {
        var rad = degrees * Math.PI / 180;
        var c = Math.cos(rad);
        var s2 = Math.sin(rad);
        return new Vector2(x * c - y * s2, x * s2 + y * c);
    }
'''
    idx = s.find('\n', s.find('{'))
    s = s[:idx + 1] + add + s[idx + 1:]
    io.open(p, 'w', encoding='utf-8', newline='').write(s)
    print('ok Vector2.RotateClockwise')

# Vector3.Abs
p = 'source/unity/Vector3.hx'
s = io.open(p, encoding='utf-8').read()
if 'function Abs' not in s:
    s = s.replace('    public static function Cross(', '''    // PORT-NOTE: 补全 Vector3.Abs（Unity 静态方法）。
    public static function Abs(v:Vector3):Vector3 return new Vector3(Math.abs(v.x), Math.abs(v.y), Math.abs(v.z));

    public static function Cross(''', 1)
    io.open(p, 'w', encoding='utf-8', newline='').write(s)
    print('ok Vector3.Abs')

# Quaternion.FromToRotation
p = 'source/unity/Quaternion.hx'
s = io.open(p, encoding='utf-8').read()
if 'FromToRotation' not in s:
    s = s.replace('    public static function AngleAxis(', '''    // PORT-NOTE: 补全 Quaternion.FromToRotation（移植层用 Euler 近似）。
    public static function FromToRotation(from:Vector3, to:Vector3):Quaternion {
        return Euler(0, 0, Math.atan2(to.y, to.x) * 180 / Math.PI - Math.atan2(from.y, from.x) * 180 / Math.PI);
    }

    public static function AngleAxis(''', 1)
    io.open(p, 'w', encoding='utf-8', newline='').write(s)
    print('ok Quaternion.FromToRotation')

# Transform.Rotate / Camera.ViewportToWorldPoint
for p, anchor, add in (
    ('source/unity/Transform.hx', '    public function SetParent(', '''    // PORT-NOTE: 补全 Transform.Rotate（旋转由渲染层实现，这里仅保留欧拉角累计）。
    public function Rotate(x:Float, y:Float, z:Float):Void {
        eulerAngles = new Vector3(eulerAngles.x + x, eulerAngles.y + y, eulerAngles.z + z);
    }
'''),
    ('source/unity/Camera.hx', '    public function WorldToScreenPoint(', '''    // PORT-NOTE: 补全 Camera.ViewportToWorldPoint（Flixel 无 3D 视口变换，按屏幕坐标近似返回）。
    public function ViewportToWorldPoint(position:Vector3):Vector3 {
        return new Vector3(position.x * pixelWidth, position.y * pixelHeight, position.z);
    }
''')):
    s = io.open(p, encoding='utf-8').read()
    k = add.strip().split('\n')[0]
    if k in s:
        continue
    if anchor in s:
        s = s.replace(anchor, add + anchor, 1)
    else:
        i = s.find('\n', s.find('{'))
        s = s[:i + 1] + add + s[i + 1:]
    io.open(p, 'w', encoding='utf-8', newline='').write(s)
    print('ok %s' % p)
