import io

# ---------- OptionsManager ----------
p = 'source/mvz2/options/OptionsManager.hx'
s = io.open(p, encoding='utf-8').read()
old = '''    // PORT-NOTE: C# \u7684 out \u53c2\u6570\u5728 Haxe \u4e2d\u6539\u4e3a\u8fd4\u56de\u503c\uff08\u627e\u4e0d\u5230\u65f6\u8fd4\u56de null\uff09\u3002
    public function TryGetOptionBool(id:NamespaceID):Null<Bool> return options.TryGetOptionBool(id);
    public function TryGetOptionInt(id:NamespaceID):Null<Int> return options.TryGetOptionInt(id);
    public function TryGetOptionFloat(id:NamespaceID):Null<Float> return options.TryGetOptionFloat(id);
    public function TryGetOptionString(id:NamespaceID):Null<String> return options.TryGetOptionString(id);
    public function TryGetOptionID(id:NamespaceID):Null<NamespaceID> return options.TryGetOptionID(id);'''
new = '''    // PORT-NOTE: IGlobalOptions \u5b9a\u4e49\u4e3a out \u53c2\u6570\uff0cHaxe \u7edf\u4e00\u7528 tools.Ref<T> \u5bb9\u5668\u5b9e\u73b0\u3002
    public function TryGetOptionBool(id:NamespaceID, value:Ref<Bool>):Bool {
        var v = options.TryGetOptionBool(id);
        if (v == null) return false;
        value.value = v;
        return true;
    }
    public function TryGetOptionInt(id:NamespaceID, value:Ref<Int>):Bool {
        var v = options.TryGetOptionInt(id);
        if (v == null) return false;
        value.value = v;
        return true;
    }
    public function TryGetOptionFloat(id:NamespaceID, value:Ref<Float>):Bool {
        var v = options.TryGetOptionFloat(id);
        if (v == null) return false;
        value.value = v;
        return true;
    }
    public function TryGetOptionString(id:NamespaceID, value:Ref<String>):Bool {
        var v = options.TryGetOptionString(id);
        if (v == null) return false;
        value.value = v;
        return true;
    }
    public function TryGetOptionID(id:NamespaceID, value:Ref<Null<NamespaceID>>):Bool {
        var v = options.TryGetOptionID(id);
        if (v == null) return false;
        value.value = v;
        return true;
    }'''
assert old in s, 'optmgr tryget'
s = s.replace(old, new)
old2 = '''    public function GetOptionBool(id:NamespaceID):Bool {
        var value = TryGetOptionBool(id);
        return value != null ? value : GetDefaultOptionValueBool(id);
    }
    public function GetOptionInt(id:NamespaceID):Int {
        var value = TryGetOptionInt(id);
        return value != null ? value : GetDefaultOptionValueInt(id);
    }
    public function GetOptionFloat(id:NamespaceID):Float {
        var value = TryGetOptionFloat(id);
        return value != null ? value : GetDefaultOptionValueFloat(id);
    }
    public function GetOptionString(id:NamespaceID):String {
        var value = TryGetOptionString(id);
        return value != null ? value : GetDefaultOptionValueString(id);
    }
    public function GetOptionID(id:NamespaceID):Null<NamespaceID> {
        var value = TryGetOptionID(id);
        return value != null ? value : GetDefaultOptionValueID(id);
    }'''
new2 = '''    public function GetOptionBool(id:NamespaceID):Bool {
        var ref:Ref<Bool> = new Ref<Bool>(false);
        return TryGetOptionBool(id, ref) ? ref.value : GetDefaultOptionValueBool(id);
    }
    public function GetOptionInt(id:NamespaceID):Int {
        var ref:Ref<Int> = new Ref<Int>(0);
        return TryGetOptionInt(id, ref) ? ref.value : GetDefaultOptionValueInt(id);
    }
    public function GetOptionFloat(id:NamespaceID):Float {
        var ref:Ref<Float> = new Ref<Float>(0);
        return TryGetOptionFloat(id, ref) ? ref.value : GetDefaultOptionValueFloat(id);
    }
    public function GetOptionString(id:NamespaceID):String {
        var ref:Ref<String> = new Ref<String>(null);
        return TryGetOptionString(id, ref) ? ref.value : GetDefaultOptionValueString(id);
    }
    public function GetOptionID(id:NamespaceID):Null<NamespaceID> {
        var ref:Ref<Null<NamespaceID>> = new Ref<Null<NamespaceID>>(null);
        return TryGetOptionID(id, ref) ? ref.value : GetDefaultOptionValueID(id);
    }'''
assert old2 in s, 'optmgr get'
s = s.replace(old2, new2)
if 'import tools.Ref;' not in s:
    lines = s.split('\n')
    idxs = [i for i, l in enumerate(lines) if l.strip().startswith('import ')]
    lines.insert(idxs[-1] + 1, 'import tools.Ref;')
    s = '\n'.join(lines)
io.open(p, 'w', encoding='utf-8', newline='').write(s)
print('OptionsManager ok')

# ---------- OptionContext ----------
p = 'source/mvz2/options/OptionContext.hx'
s = io.open(p, encoding='utf-8').read()
old = '''    // PORT-NOTE: C# \u7684 out \u53c2\u6570\u5728 Haxe \u4e2d\u6539\u4e3a\u8fd4\u56de\u503c\uff08\u627e\u4e0d\u5230\u65f6\u8fd4\u56de null\uff09\u3002
    public function TryGetCachedOptionBool(id:NamespaceID):Null<Bool> {
        return cacheOptionBool.exists(id) ? cacheOptionBool.get(id) : null;
    }
    public function TryGetCachedOptionInt(id:NamespaceID):Null<Int> {
        return cacheOptionInt.exists(id) ? cacheOptionInt.get(id) : null;
    }
    public function TryGetCachedOptionFloat(id:NamespaceID):Null<Float> {
        return cacheOptionFloat.exists(id) ? cacheOptionFloat.get(id) : null;
    }
    public function TryGetCachedOptionString(id:NamespaceID):Null<String> {
        return cacheOptionString.exists(id) ? cacheOptionString.get(id) : null;
    }
    public function TryGetCachedOptionID(id:NamespaceID):Null<NamespaceID> {
        return cacheOptionID.exists(id) ? cacheOptionID.get(id) : null;
    }'''
new = '''    // PORT-NOTE: IOptionContext \u5b9a\u4e49\u4e3a out \u53c2\u6570\uff0cHaxe \u7edf\u4e00\u7528 tools.Ref<T> \u5bb9\u5668\u5b9e\u73b0\u3002
    public function TryGetCachedOptionBool(id:NamespaceID, value:Ref<Bool>):Bool {
        if (!cacheOptionBool.exists(id)) return false;
        value.value = cacheOptionBool.get(id);
        return true;
    }
    public function TryGetCachedOptionInt(id:NamespaceID, value:Ref<Int>):Bool {
        if (!cacheOptionInt.exists(id)) return false;
        value.value = cacheOptionInt.get(id);
        return true;
    }
    public function TryGetCachedOptionFloat(id:NamespaceID, value:Ref<Float>):Bool {
        if (!cacheOptionFloat.exists(id)) return false;
        value.value = cacheOptionFloat.get(id);
        return true;
    }
    public function TryGetCachedOptionString(id:NamespaceID, value:Ref<String>):Bool {
        if (!cacheOptionString.exists(id)) return false;
        value.value = cacheOptionString.get(id);
        return true;
    }
    public function TryGetCachedOptionID(id:NamespaceID, value:Ref<Null<NamespaceID>>):Bool {
        if (!cacheOptionID.exists(id)) return false;
        value.value = cacheOptionID.get(id);
        return true;
    }'''
assert old in s, 'optctx'
s = s.replace(old, new)
if 'import tools.Ref;' not in s:
    lines = s.split('\n')
    idxs = [i for i, l in enumerate(lines) if l.strip().startswith('import ')]
    lines.insert(idxs[-1] + 1, 'import tools.Ref;')
    s = '\n'.join(lines)
io.open(p, 'w', encoding='utf-8', newline='').write(s)
print('OptionContext ok')
