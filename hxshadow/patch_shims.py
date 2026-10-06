import io

# 1) FormatUsage: add Render
p = 'source/unity/FormatUsage.hx'
s = io.open(p, encoding='utf-8').read()
if 'var Render' not in s:
    s = s.replace('\tvar MSAA8x = 13;', '\tvar MSAA8x = 13;\n\tvar Render = 14;\n\tvar BeginRender = 15;')
    io.open(p, 'w', encoding='utf-8', newline='').write(s)
    print('FormatUsage +Render')

# 2) Application: add targetFrameRate
p = 'source/unity/Application.hx'
s = io.open(p, encoding='utf-8').read()
if 'targetFrameRate' not in s:
    s = s.replace('    public static var isPlaying:Bool = true;',
                  '    public static var isPlaying:Bool = true;\n'
                  '    // PORT-NOTE: \u8865\u5168 Application.targetFrameRate\uff08-1 \u8868\u793a\u5e73\u53f0\u9ed8\u8ba4\uff09\u3002\n'
                  '    public static var targetFrameRate:Int = -1;')
    io.open(p, 'w', encoding='utf-8', newline='').write(s)
    print('Application +targetFrameRate')

# 3) Animator: layers
p = 'source/unity/Animator.hx'
s = io.open(p, encoding='utf-8').read()
if 'GetLayerIndex' not in s:
    add = '''	// PORT-NOTE: \u8865\u5168 Animator \u7684 Layer \u76f8\u5173 API\uff08Unity \u52a8\u753b\u5c42\uff09\uff1b
	// \u79fb\u690d\u5c42\u53ea\u4fdd\u7559\u5355\u5c42\uff0c\u56e0\u6b64\u6309\u540d\u5b57\u8bb0\u5f55\u6743\u91cd\u3002
	public var layerCount(get, never):Int;
	function get_layerCount():Int return 1;
	private var layerWeights:Map<String, Float> = new Map();
	public function GetLayerIndex(layerName:String):Int return layerName == null ? -1 : 0;
	public function GetLayerWeight(layerIndex:Int):Float {
		return layerWeights.exists(Std.string(layerIndex)) ? layerWeights.get(Std.string(layerIndex)) : 1;
	}
	public function SetLayerWeight(layerIndex:Int, weight:Float):Void {
		layerWeights.set(Std.string(layerIndex), weight);
	}
	public function GetCurrentAnimatorStateInfo(layerIndex:Int):AnimatorStateInfo {
		var info = new AnimatorStateInfo();
		info.fullPathHash = StringToHash(GetCurrentAnimationName());
		info.shortNameHash = info.fullPathHash;
		return info;
	}
'''
    s = s.replace('	public function SetBool(name:String, value:Bool):Void {', add + '\n	public function SetBool(name:String, value:Bool):Void {')
    io.open(p, 'w', encoding='utf-8', newline='').write(s)
    print('Animator +layers')
