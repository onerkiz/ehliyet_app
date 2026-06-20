# -*- coding: utf-8 -*-
"""ehliyetim.net'ten 0-byte (bozuk) soru/sik gorsellerini yeniden indirir.
Eslesme: S3 dosya adi == bizim yerel dosya adi. Indirme: get-temp-url?filename=<yil/ay/dosya>.
"""
import urllib.request, ssl, re, json, os, time, datetime, tempfile, sys
sys.stdout.reconfigure(encoding='utf-8')
ssl._create_default_https_context = ssl._create_unverified_context
BASE = 'https://ehliyetim.net'
H = {'User-Agent': 'Mozilla/5.0 (Linux; Android 13) Chrome/120 Mobile Safari/537.36',
     'Accept-Language': 'tr-TR', 'Referer': 'https://ehliyetim.net/'}
ROOT = os.path.dirname(os.path.abspath(__file__))
QDIR = os.path.join(ROOT, 'assets', 'images', 'q')
CACHE = os.path.join(tempfile.gettempdir(), 'ehliyetim_pages_cache')
os.makedirs(CACHE, exist_ok=True)
MONTHS = ['ocak','subat','mart','nisan','mayis','haziran','temmuz','agustos','eylul','ekim','kasim','aralik']

# --- ihtiyac: 0-byte referansli gorsellerin basename'leri ---
qs = json.load(open(os.path.join(ROOT,'assets','data','questions.json'), encoding='utf-8'))
need = {}  # basename -> local path
for q in qs:
    refs = []
    if q.get('imageUrl'): refs.append(q['imageUrl'])
    refs += [str(o) for o in q.get('options',[]) if str(o).startswith('assets/')]
    for r in refs:
        if os.path.exists(r) and os.path.getsize(r)==0:
            need[os.path.basename(r)] = r
print('Ihtiyac duyulan 0-byte gorsel:', len(need), flush=True)

def get(u, t=25):
    return urllib.request.urlopen(urllib.request.Request(u, headers=H), timeout=t).read()

def cached(u):
    key = re.sub(r'\W+','_',u)[-120:]+'.html'
    p = os.path.join(CACHE, key)
    if os.path.exists(p):
        t = open(p, encoding='utf-8').read()
        return None if t=='__404__' else t
    try:
        t = get(u).decode('utf-8','ignore')
    except urllib.error.HTTPError as e:
        if e.code==404:
            open(p,'w',encoding='utf-8').write('__404__'); time.sleep(0.5); return None
        return None
    except Exception:
        return None
    open(p,'w',encoding='utf-8').write(t); time.sleep(0.6); return t

S3RE = re.compile(r'https?://ehliyetim\.s3[^"\\\s]+?/uploads/([^"\\\s]+?\.webp)')

def download(path_after_uploads, dest):
    url = f'{BASE}/api/v1/mobile/get-temp-url?filename={path_after_uploads}'
    try:
        d = get(url, t=30)
        if d[:4]==b'RIFF' and d[8:12]==b'WEBP' and len(d)>100:
            open(dest,'wb').write(d); return True
    except Exception:
        pass
    return False

# --- sayfa listesi: once kategori, sonra gunluk ---
pages = [f'{BASE}/test-coz/{s}' for s in
         ['trafik-ve-cevre-bilgisi','motor-ve-arac-teknigi','ilk-yardim-bilgisi',
          'trafik-adabi','cikmis-ehliyet-sinav-sorulari','animasyonlu-ehliyet-sinav-sorulari']]
d0 = datetime.date(2024,10,1); d1 = datetime.date(2026,5,27); d = d0
while d <= d1:
    pages.append(f'{BASE}/gunluk-ehliyet-sinav-sorulari/{d.day}-{MONTHS[d.month-1]}-{d.year}-ehliyet-sinav-sorulari')
    d += datetime.timedelta(days=1)

found = 0; done = set()
for i, u in enumerate(pages, 1):
    if len(done) >= len(need): break
    html = cached(u)
    if not html: continue
    raw = html.replace('\\/', '/')
    for path in set(S3RE.findall(raw)):
        base = os.path.basename(path)
        if base in need and base not in done:
            if download(path, need[base]):
                done.add(base); found += 1
                print(f'  [{found}/{len(need)}] {base}', flush=True)
    if i % 50 == 0:
        print(f'... {i} sayfa, bulunan {found}/{len(need)}', flush=True)

print(f'BITTI. Kurtarilan: {found}/{len(need)}', flush=True)
miss = [b for b in need if b not in done]
print('Bulunamayan:', len(miss))
for b in miss[:20]: print('  -', b)
