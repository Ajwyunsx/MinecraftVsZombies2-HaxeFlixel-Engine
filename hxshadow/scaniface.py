import io, os, re, sys

PKGRE = re.compile(r'(?m)^package\s+([\w\.]*)\s*;')
CLS = re.compile(r'(?m)^[ \t]*(?:public |private |final )*class\s+([A-Z]\w*)\s*([^\n{]*)\{')
IFACE = re.compile(r'(?m)^[ \t]*(?:public |private )*interface\s+([A-Z]\w*)')
PROP = re.compile(r'(?m)^[ \t]*var\s+([A-Z]\w*)\s*\(\s*get\s*,\s*never\s*\)')


def build_ifaces(roots):
    props = {}
    paths = {}
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
                for im in IFACE.finditer(s):
                    name = im.group(1)
                    end = s.find('\nclass ', im.end())
                    body = s[im.start():]
                    d = 0
                    started = False
                    for i, ch in enumerate(body):
                        if ch == '{':
                            d += 1
                            started = True
                        elif ch == '}':
                            d -= 1
                            if started and d == 0:
                                body = body[:i]
                                break
                    pr = set(PROP.findall(body))
                    key = name
                    props.setdefault(key, set()).update(pr)
                    paths.setdefault(key, set()).add('%s.%s' % (pkg, name) if pkg else name)
    return props, paths


def main(roots, ifaceroots):
    props, paths = build_ifaces(ifaceroots)
    for root in roots:
        for dp, dn, fn in os.walk(root):
            for f in fn:
                if not f.endswith('.hx'):
                    continue
                p = os.path.join(dp, f)
                s = io.open(p, encoding='utf-8', errors='replace').read()
                for m in CLS.finditer(s):
                    rest = m.group(2)
                    im = re.search(r'implements\s+([\w\.\,\s]+)', rest)
                    if not im:
                        continue
                    names = [x.strip().split('.')[-1] for x in im.group(1).split(',') if x.strip()]
                    wanted = set()
                    for n in names:
                        if n in props:
                            wanted |= props[n]
                    if not wanted:
                        continue
                    # class body
                    body = s[m.start():]
                    d = 0
                    started = False
                    for i, ch in enumerate(body):
                        if ch == '{':
                            d += 1
                            started = True
                        elif ch == '}':
                            d -= 1
                            if started and d == 0:
                                body = body[:i]
                                break
                    bad = []
                    for w in sorted(wanted):
                        if re.search(r'(?m)^[ \t]*(?:override\s+)?public var ' + w + r'\s*\(\s*default\s*,', body):
                            bad.append(w)
                        elif re.search(r'(?m)^[ \t]*(?:override\s+)?public var ' + w + r'\s*:\s*[^;]+;', body):
                            bad.append(w)
                    if bad:
                        print('%s : class %s implements %s needs property(ies): %s' % (p.replace(os.sep, '/'), m.group(1), names, bad))


main(sys.argv[1:8], sys.argv[8:] or ['source/mvz2logic', 'source/pvzengine', 'source/mvz2'])
