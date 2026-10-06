import io

# 1) Mathf.Clamp (int overload) -> ClampInt in Animation*Setter
for p in ('source/mvz2/models/AnimationImageSetter.hx', 'source/mvz2/models/AnimationSpriteSetter.hx'):
    s = io.open(p, encoding='utf-8').read()
    if 'Mathf.Clamp(' in s:
        s = s.replace('Mathf.Clamp(', 'Mathf.ClampInt(')
        io.open(p, 'w', encoding='utf-8', newline='').write(s)
        print('%s ClampInt ok' % p)

# 2) ParticleSystem.MainModule.startSpeedMultiplier
p = 'source/unity/ParticleSystem.hx'
s = io.open(p, encoding='utf-8').read()
if 'startSpeedMultiplier' not in s:
    s = s.replace('class MainModule {', '''class MainModule {
	// PORT-NOTE: \u8865\u5168 startSpeedMultiplier\uff08\u7c92\u5b50\u6a21\u62df\u7531 Flixel \u5b9e\u73b0\uff0c\u6b64\u5904\u4ec5\u4fdd\u7559\u6570\u503c\uff09\u3002
	public var startSpeedMultiplier:Float = 1;''')
    io.open(p, 'w', encoding='utf-8', newline='').write(s)
    print('MainModule +startSpeedMultiplier')
