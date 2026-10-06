import io, os, re

SEP = os.sep
KINDS = ('enum abstract', 'abstract', 'class', 'interface', 'enum', 'typedef')


def read(p):
    return io.open(p, encoding='utf-8').read()


def write(p, s):
    d = os.path.dirname(p)
    if d and not os.path.exists(d):
        os.makedirs(d, exist_ok=True)
    io.open(p, 'w', encoding='utf-8', newline='').write(s)


def _strip_mods(t):
    while True:
        m = re.match(r'^(?:public|private|final|extern|inline|override|dynamic)\s+', t)
        if m:
            t = t[m.end():]
            continue
        m = re.match(r'^@:[\w\(\)\.\[\]\'"]+\s*', t)
        if m:
            t = t[m.end():]
            continue
        return t


def scan_defs(path):
    """yield (name, line_number) of top-level type definitions in a file"""
    s = read(path)
    res = []
    for i, line in enumerate(s.split('\n'), 1):
        t = _strip_mods(line.strip())
        for kw in KINDS:
            if t.startswith(kw + ' ') or t.startswith(kw + '\t'):
                rest = t[len(kw):].strip()
                name = re.match(r'([A-Za-z_]\w*)', rest)
                if name and name.group(1)[0].isupper():
                    res.append((name.group(1), i))
                break
    return res


def build_index(root='source'):
    """fqn -> [paths];  '#Name' -> [paths]"""
    idx = {}
    for dp, dn, fn in os.walk(root):
        for f in fn:
            if not f.endswith('.hx'):
                continue
            p = os.path.join(dp, f)
            s = io.open(p, encoding='utf-8', errors='replace').read()
            m = re.search(r'(?m)^package\s+([\w\.]*)\s*;', s)
            pkg = m.group(1) if m else ''
            mod = f[:-3]
            for name, ln in scan_defs(p):
                fqn = (pkg + '.' + (name if name == mod else mod + '.' + name)) if pkg else (name if name == mod else mod + '.' + name)
                idx.setdefault(fqn, []).append(p)
                idx.setdefault('#' + name, []).append(p)
    return idx


def module_of(path_of_def, name, root='source'):
    s = read(path_of_def)
    m = re.search(r'(?m)^package\s+([\w\.]*)\s*;', s)
    pkg = m.group(1) if m else ''
    mod = os.path.basename(path_of_def)[:-3]
    if mod == name:
        return (pkg + '.' + name) if pkg else name
    return (pkg + '.' + mod + '.' + name) if pkg else (mod + '.' + name)
