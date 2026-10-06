import io

# 1) Task shim: awaitResult
p = 'source/system/threading/tasks/Task.hx'
s = io.open(p, encoding='utf-8').read()
if 'awaitResult' not in s:
    s = s.replace('''	public function SetCompleted():Void
	{
		IsCompleted = true;
	}''', '''	public function SetCompleted():Void
	{
		IsCompleted = true;
	}

	// PORT-NOTE: C# \u7684 `await task` \u5728\u79fb\u690d\u5c42\u5199\u4f5c awaitResult()\uff08\u963b\u585e\u7b49\u5f85\u5e76\u53d6\u56de\u7ed3\u679c\uff09\u3002
	public var Result:Dynamic = null;
	public function awaitResult():Dynamic
	{
		return Result;
	}''')
    io.open(p, 'w', encoding='utf-8', newline='').write(s)
    print('Task +awaitResult')

# 2) TaskCompletionSource: propagate result
p = 'source/system/threading/tasks/TaskCompletionSource.hx'
s = io.open(p, encoding='utf-8').read()
s = s.replace('''		// PORT-NOTE: Task shim \u7a7a\u58f3\uff0c\u4ec5\u8bb0\u5f55\u5b8c\u6210\u72b6\u6001\uff0c\u4e0d\u4f20\u64ad\u56de\u8c03\u3002
		Task.SetCompleted();''', '''		// PORT-NOTE: Task shim \u7a7a\u58f3\uff0c\u4ec5\u8bb0\u5f55\u5b8c\u6210\u72b6\u6001\u4e0e\u7ed3\u679c\uff0c\u4e0d\u4f20\u64ad\u56de\u8c03\u3002
		Task.Result = result;
		Task.SetCompleted();''')
io.open(p, 'w', encoding='utf-8', newline='').write(s)
print('TaskCompletionSource ok')

# 3) SortingGroup static
p = 'source/unity/rendering/SortingGroup.hx'
s = io.open(p, encoding='utf-8').read()
if 'UpdateAllSortingGroups' not in s:
    s = s.replace('''    public function new() {
        super();
    }''', '''    public function new() {
        super();
    }

    // PORT-NOTE: \u8865\u5168 UnityEngine.Rendering.SortingGroup.UpdateAllSortingGroups\uff08\u6e32\u67d3\u5c42\u672a\u5b9e\u73b0\uff0c\u7a7a\u5b9e\u73b0\uff09\u3002
    public static function UpdateAllSortingGroups():Void {}''')
    io.open(p, 'w', encoding='utf-8', newline='').write(s)
    print('SortingGroup ok')

# 4) TalkController: characterTemplate.gameObject -> characterTemplate
p = 'source/mvz2/talk/TalkController.hx'
s = io.open(p, encoding='utf-8').read()
old = '        characterTemplate.gameObject.SetActive(false);'
new = '        // PORT-NOTE: C# \u4e2d characterTemplate \u662f GameObject\uff0c\u79fb\u690d\u5c42\u76f4\u63a5\u8c03 SetActive\u3002\n        characterTemplate.SetActive(false);'
assert old in s, 'talkctrl'
s = s.replace(old, new)
io.open(p, 'w', encoding='utf-8', newline='').write(s)
print('TalkController ok')

# 5) ModelManager Vector2.Scale arg
p = 'source/mvz2/models/ModelManager.hx'
s = io.open(p, encoding='utf-8').read()
old = '            var offset = new Vector3(Vector2.Scale(pivot / pixelsPerUnit, scale).x, Vector2.Scale(pivot / pixelsPerUnit, scale).y, 0);'
new = ('            // PORT-NOTE: C# \u4e2d scale \u662f Vector3 \u4e0e Vector2 \u76f8\u4e58\uff08\u9690\u5f0f\u8f6c\u6362\uff09\uff0c\u79fb\u690d\u5c42\u663e\u5f0f\u53d6 xy\u3002\n'
       '            var scale2 = new Vector2(scale.x, scale.y);\n'
       '            var offset = new Vector3(Vector2.Scale(pivot / pixelsPerUnit, scale2).x, Vector2.Scale(pivot / pixelsPerUnit, scale2).y, 0);')
assert old in s, 'modelmanager scale'
s = s.replace(old, new)
io.open(p, 'w', encoding='utf-8', newline='').write(s)
print('ModelManager scale ok')

# 6) OptionsDialogController: LogicGameExt using
p = 'source/mvz2/options/OptionsDialogController.hx'
s = io.open(p, encoding='utf-8').read()
if 'using mvz2logic.games.LogicGameExt' not in s:
    lines = s.split('\n')
    idxs = [i for i, l in enumerate(lines) if l.strip().startswith('import ') or l.strip().startswith('using ')]
    lines.insert(idxs[-1] + 1, 'using mvz2logic.games.LogicGameExt;  // EXTUSING')
    io.open(p, 'w', encoding='utf-8', newline='').write('\n'.join(lines))
    print('OptionsDialogController using ok')
