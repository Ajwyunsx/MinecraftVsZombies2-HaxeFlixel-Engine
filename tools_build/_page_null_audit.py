"""For each page prefab: list Awake-declaring components whose exported fields contain
a null reference (i.e. injection incomplete) — these are unsafe to dispatch Awake on.

Usage: cd HaxePort && python tools_build/_page_null_audit.py
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


def has_awake(haxe):
    p = cls2file.get(haxe.lower())
    if not p:
        return False
    return re.search(r'\bfunction Awake\b', open(p, encoding='utf-8').read()) is not None


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


for page, key in PAGES.items():
    d = json.load(open(os.path.join(DATA, key + '.json'), encoding='utf-8'))
    nodes = d['nodes']
    rows = []
    for i, n in enumerate(nodes):
        for c in n.get('components', []):
            haxe = c.get('haxe')
            if not haxe or not has_awake(haxe):
                continue
            nf = null_fields(c.get('fields'))
            if nf:
                rows.append((i, n['name'], haxe, nf))
    print('=== %s : %d Awake 组件有 null 引用' % (page, len(rows)))
    for r in rows:
        print('    node %d %s : %s -> %s' % r)
