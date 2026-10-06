import io

p = 'source/unity/Animator.hx'
s = io.open(p, encoding='utf-8').read()
add = '''	// PORT-NOTE: \u8865\u5168 Unity Animator \u7684 hash \u64ad\u653e/\u5207\u6362 API\uff08Model \u7684\u5e8f\u5217\u5316\u6062\u590d\u9700\u8981\uff09\u3002
	public function GetNextAnimatorStateInfo(layerIndex:Int):AnimatorStateInfo {
		var info = new AnimatorStateInfo();
		info.fullPathHash = StringToHash(GetCurrentAnimationName());
		info.shortNameHash = info.fullPathHash;
		return info;
	}
	public function GetAnimatorTransitionInfo(layerIndex:Int):AnimatorTransitionInfo {
		return new AnimatorTransitionInfo();
	}
	public function PlayHash(stateNameHash:Int, layer:Int = -1, normalizedTime:Float = 0):Void {
		Play(GetCurrentAnimationName(), layer, normalizedTime);
	}
	public function CrossFadeInFixedTime(stateHashName:Int, transitionDuration:Float, layer:Int = -1, fixedTime:Float = 0, normalizedTime:Float = 0):Void {}
	public function CrossFadeHash(stateHashName:Int, transitionDuration:Float, layer:Int = -1, normalizedTime:Float = 0, transitionOffset:Float = 0):Void {}
	public function Update(deltaTime:Float):Void {}
'''
if 'PlayHash' not in s:
    s = s.replace('	public function SetBool(name:String, value:Bool):Void {', add + '\n	public function SetBool(name:String, value:Bool):Void {')
    # parameters must be public for Model/SerializableAnimator
    s = s.replace('	private var parameters:Map<String, Dynamic> = new Map();',
                  '	// PORT-NOTE: C# \u7684 Animator.parameters \u4e3a\u516c\u5f00\u5c5e\u6027\uff0c\u8fd9\u91cc\u6539\u4e3a public\u3002\n	public var parameters:Map<String, Dynamic> = new Map();')
    io.open(p, 'w', encoding='utf-8', newline='').write(s)
    print('Animator +play/crossfade/parameters')
