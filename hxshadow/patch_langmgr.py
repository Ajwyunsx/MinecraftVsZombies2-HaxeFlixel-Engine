import io

p = 'source/mvz2/localization/LanguageManager.hx'
s = io.open(p, encoding='utf-8').read()
old = '''    public function ToString():String {
        return GetKey();
    }
}'''
new = '''    public function ToString():String {
        return GetKey();
    }
    // PORT-NOTE: C# \u8986\u5199 Object.GetHashCode\uff08\u57fa\u7c7b\u4e3a\u9ed8\u8ba4\u5b9e\u73b0\uff09\uff1bHaxe \u4fa7\u4fdd\u7559\u540c\u540d\u65b9\u6cd5\u4f9b\u8c03\u7528\u70b9\u4e0e\u5b50\u7c7b super \u8c03\u7528\u3002
    public function GetHashCode():Int {
        return StringTools.hashCode(GetKey());
    }
}'''
assert old in s, 'base'
s = s.replace(old, new, 1)
old2 = '        return (path + (isDirectory ? "1" : "0")).hashCode();'
new2 = ('        // PORT-NOTE: C# \u4e3a HashCode.Combine(path, isDirectory)\uff1bHaxe \u7528\u5b57\u7b26\u4e32\u54c8\u5e0c\u66ff\u4ee3\u3002\n'
        '        return StringTools.hashCode(path + (isDirectory ? "1" : "0"));')
assert old2 in s, 'ext'
s = s.replace(old2, new2)
io.open(p, 'w', encoding='utf-8', newline='').write(s)
print('ok')
