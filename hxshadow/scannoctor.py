import io, os, re, sys

PKGRE = re.compile(r'(?m)^package\s+([\w\.]*)\s*;')
CLSDEF = re.compile(r'(?m)^[ \t]*(?:public |private |final |extern )*class\s+([A-Z]\w*)')


def class_bodies(s):
    out = []
    for m in CLSDEF.finditer(s):
        i = s.find('{', m.end())
        if i < 0:
            continue
        d = 0
        j = i
        while j < len(s):
            if s[j] == '{':
                d += 1
            elif s[j] == '}':
                d -= 1
                if d == 0:
                    break
            j += 1
        out.append((m.group(1), m.start(), s[i:j]))
    return out


def main(roots, scan_all=False):
    bodies = {}
    for root in roots:
        for dp, dn, fn in os.walk(root):
            for f in fn:
                if not f.endswith('.hx'):
                    continue
                p = os.path.join(dp, f)
                s = io.open(p, encoding='utf-8', errors='replace').read()
                m = PKGRE.search(s)
                pkg = m.group(1) if m else ''
                mod = f[:-3]
                for name, off, body in class_bodies(s):
                    fqn = (pkg + '.' + name) if pkg else name
                    hasnew = re.search(r'(?m)^[ \t]*(?:public |private |static |override |inline |dynamic )*function\s+new\s*\(', body) is not None
                    ext = re.search(r'extends\s+([\w\.]+)', s[off:off + 200])
                    bodies[fqn] = dict(path=p, name=name, line=s[:off].count('\n') + 1, hasnew=hasnew,
                                       mod=mod, pkg=pkg, ext=ext.group(1) if ext else None, body=body, fqn=fqn)
    # who instantiates / extends
    used = {}
    for fqn, d in bodies.items():
        p = d['path']
        s = io.open(p, encoding='utf-8', errors='replace').read()
        for other, dd in bodies.items():
            n = dd['name']
            if re.search(r'\bnew\s+(?:[\w\.]*\.)?' + n + r'\s*\(', s) or re.search(r'\bextends\s+(?:[\w\.]*\.)?' + n + r'\b', s):
                used.setdefault(other, set()).add(p)
    # also search the whole tree for `new X(`
    allsrc = {}
    for root in ['source']:
        for dp, dn, fn in os.walk(root):
            for f in fn:
                if f.endswith('.hx'):
                    pp = os.path.join(dp, f)
                    allsrc[pp] = io.open(pp, encoding='utf-8', errors='replace').read()
    for fqn, d in sorted(bodies.items()):
        if d['hasnew'] and not scan_all:
            continue
        n = d['name']
        if len(n) < 4:
            continue
        hits = [p for p, s in allsrc.items() if re.search(r'\bnew\s+(?:[\w\.]+\.)?' + n + r'\s*\(', s) or re.search(r'\bextends\s+(?:[\w\.]+\.)?' + n + r'\b', s)]
        if hits and not d['hasnew']:
            print('%s:%d class %s (no constructor) used in %d file(s): %s' % (
                d['path'].replace(os.sep, '/'), d['line'], n, len(hits), [h.replace(os.sep, '/') for h in hits[:3]]))


main(sys.argv[1:8] if len(sys.argv) > 8 else sys.argv[1:])
