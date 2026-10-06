import io

# 1) SaveManager: more extension usings
p = 'source/mvz2/saves/SaveManager.hx'
s = io.open(p, encoding='utf-8').read()
add = ['using mvz2logic.games.LogicGameExt;  // EXTUSING',
       'using mvz2logic.artifacts.LogicArtifactProps;  // EXTUSING',
       'using mvz2logic.difficulties.LogicDifficultyProps;  // EXTUSING']
lines = s.split('\n')
idxs = [i for i, l in enumerate(lines) if l.strip().startswith('import ') or l.strip().startswith('using ')]
base = idxs[-1]
k = 0
for a in add:
    if a.split(';')[0] + ';' not in s:
        lines.insert(base + 1 + k, a)
        k += 1
io.open(p, 'w', encoding='utf-8', newline='').write('\n'.join(lines))
print('SaveManager usings +%d' % k)

# 2) ModelGroup: string hashCode -> local helper
p = 'source/mvz2/models/ModelGroup.hx'
s = io.open(p, encoding='utf-8').read()
old = '		var hash = name.hashCode();'
new = ('		// PORT-NOTE: Haxe \u7684 String \u6ca1\u6709 hashCode\uff08StringTools \u4e5f\u65e0\uff09\uff0c\u7528\u7b80\u6613\u5b57\u7b26\u4e32\u54c8\u5e0c\u66ff\u4ee3 C# string.GetHashCode\u3002\n'
       '		var hash = StringHash.of(name);')
assert old in s, 'modelgroup'
s = s.replace(old, new)
if 'class StringHash' not in s:
    s = s.rstrip('\n') + '''

// PORT-NOTE: \u7b80\u6613\u5b57\u7b26\u4e32\u54c8\u5e0c\uff08C# string.GetHashCode \u7684\u5bf9\u5e94\u7269\uff09\u3002
class StringHash {
	public static function of(s:String):Int {
		var h = 0;
		if (s != null) {
			for (i in 0...s.length)
				h = 31 * h + s.charCodeAt(i);
		}
		return h & 0x7FFFFFFF;
	}
}
'''
io.open(p, 'w', encoding='utf-8', newline='').write(s)
print('ModelGroup hash ok')

# 3) ModelManager: FlxSprite-based sprite metrics
p = 'source/mvz2/models/ModelManager.hx'
s = io.open(p, encoding='utf-8').read()
old = '''            var sprSize = spr.rect.size; // PORT-NOTE: C# 为 spr.rect.size
            var pivot = spr.pivot;
            var pixelsPerUnit = spr.pixelsPerUnit;'''
new = '''            // PORT-NOTE: \u79fb\u690d\u5c42 SpriteRenderer.sprite \u662f FlxSprite\uff0c\u65e0 Unity Sprite \u7684 rect/pivot/pixelsPerUnit\u3002
            // TODO-PORT: \u7528 FlxSprite \u7684 frameWidth/frameHeight \u4e0e origin \u8fd1\u4f3c\uff0cPPU \u53d6\u9ed8\u8ba4 100\u3002
            var sprSize = new Vector2(spr.frameWidth, spr.frameHeight);
            var pivot = new Vector2(spr.origin.x, spr.origin.y);
            var pixelsPerUnit = 100.0;'''
assert old in s, 'modelmanager'
s = s.replace(old, new)
io.open(p, 'w', encoding='utf-8', newline='').write(s)
print('ModelManager ok')
