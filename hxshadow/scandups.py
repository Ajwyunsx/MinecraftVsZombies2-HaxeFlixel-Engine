import io, os, re, sys, collections

CLS = re.compile(r'(?m)^[ \t]*(?:(?:public|private|final|extern)\s+)*(class|interface)\s+([A-Z]\w*)')
FN = re.compile(r'(?m)^[ \t]*(?:(?:public|private|static|override|inline|dynamic|extern)\s+)*function\s+([a-zA-Z_]\w*)')


def main(roots):
    tot = 0
    for root in roots:
        for dp, dn, fn in os.walk(root):
            for f in fn:
                if not f.endswith('.hx'):
                    continue
                p = os.path.join(dp, f)
                s = io.open(p, encoding='utf-8', errors='replace').read()
                lines = s.split('\n')
                # split by top-level class starts
                starts = [(m.start(), m.group(1)) for m in re.finditer(r'(?m)^(?:class|interface|abstract|enum abstract)\s+([A-Z]\w*)', s)]
                if not starts:
                    continue
                bounds = [(starts[i][0], starts[i + 1][0] if i + 1 < len(starts) else len(s)) for i in range(len(starts))]
                for (a, b) in bounds:
                    body = s[a:b]
                    names = FN.findall(body)
                    c = collections.Counter(names)
                    dups = [k for k, v in c.items() if v > 1]
                    if dups:
                        tot += len(dups)
                        print('%s : %s' % (p.replace(os.sep, '/'), dups))
    print('total duplicate fields', tot)


main(sys.argv[1:] or ['source'])
