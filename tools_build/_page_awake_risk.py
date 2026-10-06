"""For every component present in the injected page trees, extract its Awake body and flag
references to things that are NOT available during MainGameScene.awakeAll()
(Global.*, MainManager.Instance via Main., manager singletons) — those would crash if dispatched.

Usage: cd HaxePort && python tools_build/_page_awake_risk.py
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

RISK = re.compile(r'\bGlobal\.|MainManager\.Instance|OptionsManager|ResourceManager|SaveManager|'
                  r'LanguageManager|LevelManager|SoundManager|MusicManager|InputManager|CursorManager')


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


seen = {}
for page, key in PAGES.items():
    d = json.load(open(os.path.join(DATA, key + '.json'), encoding='utf-8'))
    for i, n in enumerate(d['nodes']):
        for c in n.get('components', []):
            haxe = c.get('haxe')
            if not haxe or haxe in seen:
                continue
            body = awake_body(haxe)
            if body is None:
                continue
            seen[haxe] = (page, i, n['name'], body)

print('共 %d 个 Awake 组件（页面树去重）' % len(seen))
print()
print('### 依赖 Global./管理器（awakeAll 阶段不可用 → 会崩）')
for k, (page, i, name, body) in sorted(seen.items()):
    if RISK.search(body):
        hits = sorted(set(RISK.findall(body)))
        print('  %-46s %-14s node %-4d %-16s %s' % (k, page, i, name, hits))

print()
print('### mvz2.ui.* 且 Awake 无管理器依赖（可安全分发）')
for k, (page, i, name, body) in sorted(seen.items()):
    if k.startswith('mvz2.ui.') and not RISK.search(body):
        print('  %-46s %-14s node %-4d %s' % (k, page, i, name))
