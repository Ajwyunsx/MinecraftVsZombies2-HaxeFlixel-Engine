"""List, per page prefab, the components that a "UI + page controller" Awake dispatch rule
would hit, together with their Awake body (for null-safety review).

Usage: cd HaxePort && python tools_build/_page_awake_candidates.py [Page ...]
"""
import json
import os
import re
import sys

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


def main():
    want = sys.argv[1:] or list(PAGES)
    for page in want:
        key = PAGES[page]
        d = json.load(open(os.path.join(DATA, key + '.json'), encoding='utf-8'))
        nodes = d['nodes']
        print('===== %s (%s)' % (page, key))
        seen = set()
        for i, n in enumerate(nodes):
            for c in n.get('components', []):
                haxe = c.get('haxe')
                if not haxe or haxe in seen:
                    continue
                if not (haxe.startswith('mvz2.ui.') or 'Controller' in haxe):
                    continue
                body = awake_body(haxe)
                if body is None:
                    continue
                seen.add(haxe)
                nf = null_fields(c.get('fields'))
                print('--- node %d %s : %s   nulls=%s' % (i, n['name'], haxe, nf))
                print('    ' + body.strip().replace('\n', '\n    '))


main()
