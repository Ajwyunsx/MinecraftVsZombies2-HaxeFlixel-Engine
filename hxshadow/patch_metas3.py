import io

# 1) AudioSample: attribute access + out container
p = 'source/mvz2/metas/AudioSample.hx'
s = io.open(p, encoding='utf-8').read()
s = s.replace('        var pathAttr = node.Attributes.getAt("path");',
              '        var pathAttr = node.Attributes["path"]; // PORT-NOTE: shim \u7684 XmlAttributeCollection \u63d0\u4f9b @:arrayAccess\u3002')
s = s.replace('        var weightAttribute = node.Attributes.getAt("weight");',
              '        var weightAttribute = node.Attributes["weight"];')
old = '''            var floatValue = ParseHelper.TryParseFloat(weightAttribute.Value);
            if (floatValue != null) {
                weight = floatValue;
            }'''
new = '''            // PORT-NOTE: C# \u7684 out \u53c2\u6570\u5728 Haxe \u4e2d\u7528 OutFloat \u5bb9\u5668\u3002
            var floatRef:mvz2logic.OutFloat = {value: 0};
            if (ParseHelper.TryParseFloat(weightAttribute.Value, floatRef)) {
                weight = floatRef.value;
            }'''
if old in s:
    s = s.replace(old, new)
io.open(p, 'w', encoding='utf-8', newline='').write(s)
print('AudioSample ok')

# 2) SoundMeta: int range
p = 'source/mvz2/metas/SoundMeta.hx'
s = io.open(p, encoding='utf-8').read()
old = '        return samples[Random.Range(0, samples.length)];'
new = '        // PORT-NOTE: C# Random.Range(int,int) \u8fd4\u56de int\uff1b\u79fb\u690d\u5c42\u7528 RangeInt \u5bf9\u5e94\u6574\u6570\u91cd\u8f7d\u3002\n        return samples[Random.RangeInt(0, samples.length)];'
assert old in s, 'soundmeta'
s = s.replace(old, new)
io.open(p, 'w', encoding='utf-8', newline='').write(s)
print('SoundMeta ok')

# 3) SerializableParticleSystem: add missing Emitting case
p = 'source/mvz2/models/SerializableParticleSystem.hx'
s = io.open(p, encoding='utf-8').read()
old = '''			case ParticleState.Stopped:'''
new = '''			case ParticleState.Emitting:
				// PORT-NOTE: C# switch \u4e0d\u5f3a\u5236\u7a77\u4e3e\uff0c\u6b64\u5206\u652f\u5728 C# \u4e2d\u4e3a\u7a7a\uff08\u65e0\u64cd\u4f5c\uff09\uff1bHaxe \u9700\u8981\u663e\u5f0f\u5217\u51fa\u3002
			case ParticleState.Stopped:'''
assert old in s, 'particle'
s = s.replace(old, new, 1)
io.open(p, 'w', encoding='utf-8', newline='').write(s)
print('SerializableParticleSystem ok')
