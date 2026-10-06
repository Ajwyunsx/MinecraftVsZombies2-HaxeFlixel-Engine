"""Decisive audit: for each page prefab, find Awake-declaring components whose exported
record has null reference fields AND whose Awake body textually uses those field names.
Those are the components that would segfault in release if Awake were dispatched.

Usage: cd HaxePort && python tools_build/_page_awake_nullrisk.py
"""
import json
import os
import re

SRC = 'source'
DATA = 'assets/scene_prefabs/Prefabs'

cls2file = {}
for root, dirs, files in os.walk(SRC):
    for f in files:
        if not f.endswith('.hx'):
            continue
        p = os.path.join(root, f)
        rel = os.path.relpath(p, SRC).replace(os.sep, '/')[:-3]
        parts = rel.split('/')
        pkg = '.'.join(parts[:-1])
        full = (pkg + '.' + parts[-1]) if pkg else parts[-1]
        cls2file[full.lower()] = p

PAGES = {
    'Splash': 'Init/Splash', 'Titlescreen': 'Init/Titlescreen', 'Mainmenu': 'Mainmenu/Mainmenu',
    'Note': 'Note', 'Map': 'Map/Map', 'Almanac': 'Almanac/Almanac', 'Store': 'Store/Store',
    'Archive': 'Archive/Archive', 'Addons': 'Addons/Addons', 'MusicRoom': 'MusicRoom/MusicRoom',
    'Arcade': 'Arcade/Arcade', 'ChapterTransition': 'ChapterTransition', 'Credits': 'Mainmenu/Credits',
    'AchievementHint': 'UI/AchievementHint', 'DebugConsole': 'Level/UI/DebugConsole',
    'InputNameDialog': 'UI/Dialogs/InputNameDialog', 'DeleteUserDialog': 'UI/Dialogs/DeleteUserDialog',
}


def awake_body(haxe):
    p = cls2file.get(haxe.lower())
    if not p:
        return None
    t = open(p, encoding='utf-8').read()
    m = re.search(r'\bfunction Awake\(\):Void\s*\{', t)
    if not m:
        return None
    i = m.end()
    depth = 1
    while i < len(t) and depth > 0:
        if t[i] == '{':
            depth += 1
        elif t[i] == '}':
            depth -= 1
        i += 1
    return t[m.end():i - 1]


def null_fields(fields):
    out = []
    for k, v in (fields or {}).items():
        if k == 'enabled':
            continue
        if v is None:
            out.append(k)
        elif isinstance(v, list):
            for i, e in enumerate(v):
                if e is None:
                    out.append('%s[%d]' % (k, i))
    return out


print('### 危险：Awake 正文用到「导出数据里为 null」的字段（release 下会直接访问违例）')
for page, key in PAGES.items():
    d = json.load(open(os.path.join(DATA, key + '.json'), encoding='utf-8'))
    for i, n in enumerate(d['nodes']):
        for c in n.get('components', []):
            haxe = c.get('haxe')
            if not haxe:
                continue
            body = awake_body(haxe)
            if body is None:
                continue
            nf = null_fields(c.get('fields'))
            used = [f for f in nf if re.search(r'\b' + re.escape(f.split('[')[0]) + r'\b', body)]
            if used:
                lines = [l.strip() for l in body.split('\n') if any(re.search(r'\b' + re.escape(u.split('[')[0]) + r'\b', l) for u in used)]
                print('  %-14s node %-4d %-22s %-46s nulls=%s' % (page, i, n['name'], haxe, used))
                for l in lines[:4]:
                    print('        | ' + l)

print()
print('### 安全：Awake 正文未用到 null 字段（null 只被 null 判断/间接使用）')
for page, key in PAGES.items():
    d = json.load(open(os.path.join(DATA, key + '.json'), encoding='utf-8'))
    for i, n in enumerate(d['nodes']):
        for c in n.get('components', []):
            haxe = c.get('haxe')
            if not haxe:
                continue
            body = awake_body(haxe)
            if body is None:
                continue
            nf = null_fields(c.get('fields'))
            if not nf:
                continue
            used = [f for f in nf if re.search(r'\b' + re.escape(f.split('[')[0]) + r'\b', body)]
            if not used:
                print('  %-14s node %-4d %-22s %-46s nulls=%s' % (page, i, n['name'], haxe, nf))
