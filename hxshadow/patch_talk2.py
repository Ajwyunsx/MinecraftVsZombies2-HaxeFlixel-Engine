import io

# TalkMeta: XmlDocument is now an abstract with a static factory
p = 'source/mvz2/talkdata/TalkMeta.hx'
s = io.open(p, encoding='utf-8').read()
s = s.replace('        var xmlDoc = new XmlDocument();',
              '        // PORT-NOTE: shim \u7684 XmlDocument \u4e3a abstract\uff0c\u7528 XmlDocument.create() \u5de5\u5382\u521b\u5efa\u3002\n        var xmlDoc = XmlDocument.create();')
io.open(p, 'w', encoding='utf-8', newline='').write(s)
print('TalkMeta ok')

# TalkSentence: string overload of GetCharacterName -> GetCharacterNameByKey
p = 'source/mvz2/talkdata/TalkSentence.hx'
s = io.open(p, encoding='utf-8').read()
old = '            return main.ResourceManager.GetCharacterName(speakerName);'
new = ('            // PORT-NOTE: C# \u6709 GetCharacterName(string) \u91cd\u8f7d\uff0cHaxe \u65e0\u91cd\u8f7d\uff0c\u6309 key \u7684\u90a3\u4e2a\u91cd\u8f7d\u6539\u4e3a GetCharacterNameByKey\u3002\n'
       '            return main.ResourceManager.GetCharacterNameByKey(speakerName);')
assert old in s, 'sentence'
s = s.replace(old, new)
io.open(p, 'w', encoding='utf-8', newline='').write(s)
print('TalkSentence ok')
