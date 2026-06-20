# -*- coding: utf-8 -*-
"""
ehliyet-soru.com çıkmış soru scraper -> assets/data/questions.json

- sitemap'teki tüm /test/ sayfalarını gezer, global data-question-id ile tekilleştirir
- soru görsellerini VE görsel-şıkları assets/images/q/ altına indirir, lokal asset yoluna çevirir
- görsel-şıklarda options[i] = "assets/images/q/N.webp" (UI asset/network ayırt eder)
- açıklama (explanation) KOPYALANMAZ (telif): boş bırakılır
- mevcut questions.json ile birleştirir (yedek alarak)
- sayfalar diske cache'lenir -> yeniden çalıştırma offline + anında
"""
import urllib.request, ssl, re, json, base64, sys, time, os, unicodedata, tempfile
sys.stdout.reconfigure(encoding='utf-8')
ssl._create_default_https_context = ssl._create_unverified_context

BASE = "https://ehliyet-soru.com"
H = {'User-Agent':'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
     'Accept-Language':'tr-TR,tr;q=0.9'}
ROOT = os.path.dirname(os.path.abspath(__file__))
IMG_DIR = os.path.join(ROOT, "assets", "images", "q")
QJSON = os.path.join(ROOT, "assets", "data", "questions.json")
CACHE = os.path.join(tempfile.gettempdir(), "ehliyet_pages_cache")
os.makedirs(IMG_DIR, exist_ok=True)
os.makedirs(CACHE, exist_ok=True)
LET = {'A':0,'B':1,'C':2,'D':3}

def get(u, t=25, retry=1):
    for k in range(retry+1):
        try:
            req = urllib.request.Request(u, headers=H)
            with urllib.request.urlopen(req, timeout=t) as r:
                return r.read()
        except Exception:
            if k == retry: raise
            time.sleep(2)

def gettext(u, **kw):
    return get(u, **kw).decode('utf-8','ignore')

def cached_page(u):
    key = re.sub(r'\W+', '_', u)[-120:] + ".html"
    p = os.path.join(CACHE, key)
    if os.path.exists(p):
        return open(p, encoding='utf-8').read()
    txt = gettext(u)
    open(p, 'w', encoding='utf-8').write(txt)
    time.sleep(1.2)   # sadece cache miss'te yavaşla
    return txt

def clean(s):
    return re.sub(r'\s+', ' ', re.sub(r'<[^>]+>', '', s)).strip()

def norm(s):
    s = unicodedata.normalize('NFKD', s.lower())
    return re.sub(r'[^a-z0-9çğıöşü ]', '', s).strip()

def map_cat(t):
    t = t.lower()
    if 'adab' in t: return 'trafik_adabi'
    if 'lk yard' in t: return 'ilk_yardim'
    if 'motor' in t or 'tekn' in t: return 'motor'
    return 'trafik'

def download_img(src):
    """'/images/q/749.webp' -> 'assets/images/q/749.webp' (indirir, varsa atlar)"""
    if not src: return None
    name = re.sub(r'[^A-Za-z0-9._-]', '_', os.path.basename(src.split('?')[0]))
    dest = os.path.join(IMG_DIR, name)
    if not os.path.exists(dest):
        url = src if src.startswith('http') else BASE + src
        try:
            open(dest, 'wb').write(get(url, t=30))
            time.sleep(0.2)
        except Exception as e:
            print(f"    img FAIL {src}: {e}", flush=True)
            return None
    return f"assets/images/q/{name}"

def parse_options(card):
    """Her şık için ('text', metin) veya ('img', src). Hiçbiri yoksa None."""
    res = {}
    for part in re.split(r'(?=data-option="[A-D]")', card):
        m = re.match(r'data-option="([A-D])"', part)
        if not m: continue
        letter = m.group(1)
        oc = re.search(r'<div class="option-content">(.*?)</div>', part, re.S)
        if oc:
            txt = clean(oc.group(1))
            if txt:
                res[letter] = ('text', txt); continue
            img = re.search(r'<img[^>]+src="([^"]+)"', oc.group(1))
            if img:
                res[letter] = ('img', img.group(1)); continue
        img = re.search(r'<img[^>]+src="([^"]+)"', part)
        res[letter] = ('img', img.group(1)) if img else ('text', '')
    if not all(l in res for l in 'ABCD'):
        return None
    return [res[l] for l in 'ABCD']

def parse(html, year):
    m = re.search(r"data-correct-answers='(\[.*?\])'", html)
    if not m: return []
    ans = [base64.b64decode(a).decode('utf-8','ignore') for a in json.loads(m.group(1))]
    out = []
    for card in re.split(r'<div class="card card-style p-3 qDiv">', html)[1:]:
        h2 = re.search(r'<h2[^>]*>(.*?)</h2>', card, re.S)
        qc = re.search(r'<div class="p-2 mb-4 qContent">(.*?)</div>\s*<div class="question"', card, re.S)
        qid = re.search(r'data-question-id="(\d+)"', card)
        qidx = re.search(r'data-question-index="(\d+)"', card)
        if not (h2 and qc and qid and qidx): continue
        qidx = int(qidx.group(1))
        if qidx >= len(ans): continue
        opts = parse_options(card)
        if not opts: continue
        opt_strings, opt_img_srcs, broken = [], {}, False
        for i, (kind, val) in enumerate(opts):
            if kind == 'img':
                opt_img_srcs[i] = val
                opt_strings.append(val)        # download fazında lokal yola çevrilir
            elif val:
                opt_strings.append(val)
            else:
                broken = True; break
        if broken: continue
        block = qc.group(1)
        img = re.search(r'<img[^>]+src="([^"]+)"', block)
        out.append({
            "id": "es" + qid.group(1),
            "text": clean(re.sub(r'<img[^>]+>', '', block)),
            "options": opt_strings,
            "correctAnswer": LET.get(ans[qidx], 0),
            "explanation": "",
            "category": map_cat(clean(h2.group(1))),
            "year": year,
            "_img_src": img.group(1) if img else None,
            "_opt_img_srcs": opt_img_srcs,
        })
    return out

def test_urls():
    urls = set()
    sm = gettext(BASE + "/sitemap.xml")
    for loc in re.findall(r'<loc>([^<]+)</loc>', sm):
        if loc.endswith('.xml'):
            try: urls.update(re.findall(r'<loc>([^<]+/test/[^<]+)</loc>', gettext(loc)))
            except Exception: pass
        elif '/test/' in loc:
            urls.add(loc)
    return sorted(urls)

def main():
    turls = test_urls()
    print(f"Toplam /test/ sayfası: {len(turls)}", flush=True)
    bank, seen_text, total_seen = {}, {}, 0
    for i, u in enumerate(turls, 1):
        ym = re.search(r'(20\d\d)', u)
        year = int(ym.group(1)) if ym else 2026
        try:
            qs = parse(cached_page(u), year)
        except Exception as e:
            print(f"  [{i}] HATA {u}: {e}", flush=True); continue
        total_seen += len(qs)
        new = 0
        for q in qs:
            nt = norm(q['text'])
            if not nt or nt in seen_text or q['id'] in bank: continue
            seen_text[nt] = q['id']; bank[q['id']] = q; new += 1
        if i % 20 == 0 or i == len(turls):
            print(f"  [{i}/{len(turls)}] tekil havuz: {len(bank)} (+{new})", flush=True)

    print("Görseller indiriliyor...", flush=True)
    img_q, img_opt = 0, 0
    for q in bank.values():
        src = q.pop('_img_src', None)
        q['imageUrl'] = download_img(src) if src else None
        if q['imageUrl']: img_q += 1
        q['videoUrl'] = None
        for idx, isrc in q.pop('_opt_img_srcs', {}).items():
            local = download_img(isrc)
            if local:
                q['options'][idx] = local; img_opt += 1

    scraped = list(bank.values())
    img_opt_q = sum(1 for q in scraped if any(o.startswith('assets/') for o in q['options']))

    existing = []
    if os.path.exists(QJSON):
        existing = json.load(open(QJSON, encoding='utf-8'))
        bak = QJSON + ".backup-" + time.strftime('%Y%m%d-%H%M%S')
        json.dump(existing, open(bak,'w',encoding='utf-8'), ensure_ascii=False, indent=2)
        print(f"Yedek: {bak}", flush=True)
    exist_text = {norm(q.get('text','')) for q in existing}
    merged = list(existing); added = 0
    for q in scraped:
        if norm(q['text']) in exist_text: continue
        merged.append(q); added += 1

    json.dump(merged, open(QJSON,'w',encoding='utf-8'), ensure_ascii=False, indent=2)
    cats = {c: sum(1 for q in merged if q['category']==c) for c in ['ilk_yardim','trafik','motor','trafik_adabi']}
    print("\n=== ÖZET ===", flush=True)
    print(f"Sayfa: {len(turls)} | görülen: {total_seen} | scrape tekil: {len(scraped)}", flush=True)
    print(f"Mevcut: {len(existing)} + eklenen: {added} => TOPLAM: {len(merged)}", flush=True)
    print(f"Soru görseli: {img_q} | görsel-şık adedi: {img_opt} ({img_opt_q} soruda)", flush=True)
    print(f"Kategori: {cats}", flush=True)
    print(f"Yazıldı: {QJSON}", flush=True)

if __name__ == '__main__':
    main()
