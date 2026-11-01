import copy, re
from docx import Document
from docx.oxml.ns import qn
from docx.oxml import OxmlElement

W14 = 'http://schemas.microsoft.com/office/word/2010/wordml'

class Ctx: pass
C = Ctx()

def init(path):
    C.doc = Document(path)
    C.ps = C.doc.paragraphs
    xml = C.doc.element.body.xml
    ids = [int(x,16) for x in re.findall(r'w14:paraId="([0-9A-Fa-f]{8})"', xml)]
    C.next_id = max(ids)+1 if ids else 1
    C.nid_used = 0

def new_id():
    v = format(C.next_id, '08X'); C.next_id += 1; return v

def _strip_children(p):
    for el in list(p):
        if el.tag != qn('w:pPr'):
            p.remove(el)

def _base_run(tmpl_p):
    for r in tmpl_p.findall(qn('w:r')):
        if ''.join(t.text or '' for t in r.iter(qn('w:t'))).strip():
            return copy.deepcopy(r)
    rs = tmpl_p.findall(qn('w:r'))
    return copy.deepcopy(rs[0]) if rs else OxmlElement('w:r')

def _set_bold(rpr, on):
    for tag in ('w:b','w:bCs'):
        for e in rpr.findall(qn(tag)): rpr.remove(e)
    if on:
        pos = 0
        for i,ch in enumerate(rpr):
            if ch.tag in (qn('w:rStyle'), qn('w:rFonts')): pos = i+1
        for tag in ('w:bCs','w:b'):
            e = OxmlElement(tag); e.set(qn('w:val'),'1'); rpr.insert(pos, e)

def mk(tmpl, segs, page_break=False):
    """tmpl: Paragraph; segs: str or list of (text, bold|None)"""
    if isinstance(segs, str): segs = [(segs, None)]
    p = copy.deepcopy(tmpl._p)
    base = _base_run(p)
    _strip_children(p)
    first = True
    for text, bold in segs:
        r = copy.deepcopy(base)
        rpr = r.find(qn('w:rPr'))
        for ch in list(r):
            if ch.tag != qn('w:rPr'): r.remove(ch)
        if bold is not None:
            if rpr is None:
                rpr = OxmlElement('w:rPr'); r.insert(0, rpr)
            _set_bold(rpr, bold)
        if first and page_break:
            br = OxmlElement('w:br'); br.set(qn('w:type'),'page'); r.append(br)
        first = False
        t = OxmlElement('w:t'); t.set(qn('xml:space'),'preserve'); t.text = text; r.append(t)
        p.append(r)
    if p.get(qn('w14:paraId')) is not None:
        p.set(qn('w14:paraId'), new_id())
    return p

def set_text(par, text):
    p = par._p
    runs = p.findall(qn('w:r'))
    keep = None
    for r in runs:
        if r.find(qn('w:t')) is not None: keep = r; break
    assert keep is not None
    for r in runs:
        if r is not keep: p.remove(r)
    for h in p.findall(qn('w:hyperlink')): p.remove(h)
    for t in keep.findall(qn('w:t')): keep.remove(t)
    t = OxmlElement('w:t'); t.set(qn('xml:space'),'preserve'); t.text = text; keep.append(t)

def md_segs(text):
    text = text.replace('`','')
    text = re.sub(r'(?<!\*)\*(?!\*)([^*\n]+?)(?<!\*)\*(?!\*)', r'\1', text)
    parts = text.split('**')
    return [(s, True if i%2==1 else None) for i,s in enumerate(parts) if s != '']

# ---- tables
def _cell_set(tc, text, sz, bold=None):
    ps_ = tc.findall(qn('w:p'))
    for extra in ps_[1:]: tc.remove(extra)
    p = ps_[0]
    base = _base_run(p)
    _strip_children(p)
    r = copy.deepcopy(base)
    for ch in list(r):
        if ch.tag != qn('w:rPr'): r.remove(ch)
    rpr = r.find(qn('w:rPr'))
    if rpr is None:
        rpr = OxmlElement('w:rPr'); r.insert(0, rpr)
    for tag in ('w:sz','w:szCs'):
        e = rpr.find(qn(tag))
        if e is None:
            e = OxmlElement(tag); rpr.append(e)
        e.set(qn('w:val'), str(sz))
    if bold is not None: _set_bold(rpr, bold)
    t = OxmlElement('w:t'); t.set(qn('xml:space'),'preserve'); t.text = text; r.append(t)
    p.append(r)
    ppr = p.find(qn('w:pPr'))
    if ppr is not None:
        prp = ppr.find(qn('w:rPr'))
        if prp is not None:
            for tag in ('w:sz','w:szCs'):
                e = prp.find(qn(tag))
                if e is not None: e.set(qn('w:val'), str(sz))
    if p.get(qn('w14:paraId')) is not None:
        p.set(qn('w14:paraId'), new_id())

def mk_table(tmpl_tbl, header, rows, widths, sz=20):
    tbl = copy.deepcopy(tmpl_tbl)
    pr = tbl.find(qn('w:tblPr'))
    fl = pr.find(qn('w:tblpPr'))
    if fl is not None: pr.remove(fl)
    tw = pr.find(qn('w:tblW')); tw.set(qn('w:w'), str(sum(widths))); tw.set(qn('w:type'),'dxa')
    grid = tbl.find(qn('w:tblGrid'))
    for ch in list(grid): grid.remove(ch)
    for w in widths:
        g = OxmlElement('w:gridCol'); g.set(qn('w:w'), str(w)); grid.append(g)
    trs = tbl.findall(qn('w:tr'))
    head_t, body_t = trs[0], trs[1]
    for tr in trs: tbl.remove(tr)
    def row(tmpl_tr, tc_idx, vals, bold):
        tr = copy.deepcopy(tmpl_tr)
        tcs = tr.findall(qn('w:tc'))
        tmpl_tc = tcs[tc_idx]
        for tc in tcs: tr.remove(tc)
        for v,w in zip(vals, widths):
            tc = copy.deepcopy(tmpl_tc)
            tcpr = tc.find(qn('w:tcPr'))
            if tcpr is not None:
                tcw = tcpr.find(qn('w:tcW'))
                if tcw is not None: tcw.set(qn('w:w'), str(w)); tcw.set(qn('w:type'),'dxa')
                gs = tcpr.find(qn('w:gridSpan'))
                if gs is not None: tcpr.remove(gs)
            _cell_set(tc, v, sz, bold)
            tr.append(tc)
        return tr
    tbl.append(row(head_t, 0, header, True))
    for r_ in rows: tbl.append(row(body_t, 1, r_, False))
    return tbl


def _keep_next(p):
    ppr = p.find(qn('w:pPr'))
    if ppr is None:
        ppr = OxmlElement('w:pPr'); p.insert(0, ppr)
    if ppr.find(qn('w:keepNext')) is None:
        pos = 1 if (len(ppr) and ppr[0].tag == qn('w:pStyle')) else 0
        ppr.insert(pos, OxmlElement('w:keepNext'))

def finish_table(tbl):
    trs = tbl.findall(qn('w:tr'))
    for k,tr in enumerate(trs):
        trpr = tr.find(qn('w:trPr'))
        if trpr is None:
            trpr = OxmlElement('w:trPr'); tr.insert(0, trpr)
        if trpr.find(qn('w:cantSplit')) is None:
            trpr.insert(0, OxmlElement('w:cantSplit'))
        if k == 0 and trpr.find(qn('w:tblHeader')) is None:
            trpr.append(OxmlElement('w:tblHeader'))
        if k <= 1:
            for p in tr.iter(qn('w:p')): _keep_next(p)
    return tbl
