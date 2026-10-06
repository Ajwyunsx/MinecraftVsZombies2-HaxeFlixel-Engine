import io

# 1) Animator shim: runtimeAnimatorController
p = 'source/unity/Animator.hx'
s = io.open(p, encoding='utf-8').read()
if 'runtimeAnimatorController' not in s:
    s = s.replace('	public var enabled:Bool = true;',
                  '''	// PORT-NOTE: \u8865\u5168 Unity \u7684 runtimeAnimatorController\uff08\u79fb\u690d\u5c42\u7528\u7a7a\u5bf9\u8c61\u8868\u793a\u201c\u65e0\u63a7\u5236\u5668\u201d\uff09\u3002
	public var runtimeAnimatorController:Dynamic = null;
	public var enabled:Bool = true;''')
    io.open(p, 'w', encoding='utf-8', newline='').write(s)
    print('Animator +runtimeAnimatorController')

# 2) ModelAnchor: string hashCode
p = 'source/mvz2/models/ModelAnchor.hx'
s = io.open(p, encoding='utf-8').read()
old = '		keyHash = key != null ? key.hashCode() : 0;'
new = '		// PORT-NOTE: Haxe \u7684 String \u65e0 hashCode\uff0c\u7528\u7b80\u6613\u5b57\u7b26\u4e32\u54c8\u5e0c\u66ff\u4ee3 C# string.GetHashCode\u3002\n		keyHash = key != null ? ModelAnchor.hashCodeOf(key) : 0;'
assert old in s, 'anchor'
s = s.replace(old, new)
if 'function hashCodeOf' not in s:
    s = s.rstrip('\n')
    # insert helper before the last closing brace of the class
    idx = s.rfind('}')
    helper = '''	// PORT-NOTE: \u7b80\u6613\u5b57\u7b26\u4e32\u54c8\u5e0c\uff08C# string.GetHashCode \u7684\u5bf9\u5e94\u7269\uff09\u3002
	public static function hashCodeOf(s:String):Int {
		var h = 0;
		if (s != null) {
			for (i in 0...s.length)
				h = 31 * h + s.charCodeAt(i);
		}
		return h & 0x7FFFFFFF;
	}
'''
    s = s[:idx] + helper + s[idx:]
    s += '\n'
io.open(p, 'w', encoding='utf-8', newline='').write(s)
print('ModelAnchor ok')

# 3) ModelFactory: nullable seed to match IModelFactory
p = 'source/mvz2/models/ModelFactory.hx'
s = io.open(p, encoding='utf-8').read()
old = '    public function CreateModel(id:NamespaceID, camera:Camera, parent:Transform, seed:Int = 0):Model {'
new = ('    // PORT-NOTE: IModelFactory \u7684\u7b7e\u540d\u4e3a (id:Null<NamespaceID>, camera, parent, ?seed:Int)\uff0c\u8fd9\u91cc\u5bf9\u9f50\u3002\n'
       '    public function CreateModel(id:Null<NamespaceID>, camera:Camera, parent:Transform, ?seed:Int = 0):Null<Model> {')
if old in s:
    s = s.replace(old, new)
    io.open(p, 'w', encoding='utf-8', newline='').write(s)
    print('ModelFactory ok')
else:
    print('ModelFactory pattern not found')
