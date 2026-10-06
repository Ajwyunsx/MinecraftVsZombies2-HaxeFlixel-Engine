import json, os, re

SRC = 'source'
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

pages = {
    'Splash': 'Init/Splash', 'Titlescreen': 'Init/Titlescreen', 'Mainmenu': 'Mainmenu/Mainmenu',
    'Note': 'Note', 'Map': 'Map/Map', 'Almanac': 'Almanac/Almanac', 'Store': 'Store/Store',
    'Archive': 'Archive/Archive', 'Addons': 'Addons/Addons', 'MusicRoom': 'MusicRoom/MusicRoom',
    'Arcade': 'Arcade/Arcade', 'ChapterTransition': 'ChapterTransition', 'Credits': 'Mainmenu/Credits',
    'AchievementHint': 'UI/AchievementHint',
}

for page, key in pages.items():
    f = 'assets/scene_prefabs/Prefabs/%s.json' % key
    d = json.load(open(f, encoding='utf-8'))
    hits = []
    for i, n in enumerate(d['nodes']):
        for c in n.get('components', []):
            haxe = c.get('haxe')
            if not haxe:
                continue
            p = cls2file.get(haxe.lower())
            if not p:
                continue
            t = open(p, encoding='utf-8').read()
            if re.search(r'\bfunction Awake\b', t):
                hits.append((i, n['name'], haxe, p))
    print('==', page, len(hits))
    for h in hits:
        print('   ', h[0], h[1], h[2], '|', h[3])
