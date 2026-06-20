# -*- coding: utf-8 -*-
"""
ehliyetim.net çıkmış soru scraper -> assets/data/questions.json (ek kaynak)

- günlük sayfalar (~554) tarih üreterek + test-coz havuzları
- __NEXT_DATA__ JSON: questions[] / answers[] (isCorrect boolean)
- soru & şık görselleri (S3) assets/images/q/ altına iner, lokal asset yoluna çevrilir
- açıklama KOPYALANMAZ (telif): boş
- mevcut questions.json ile normalize-metin dedup'ı ile birleştirir (yedek alarak)
- sayfalar diske cache'lenir
"""
import urllib.request, ssl, re, json, sys, time, os, unicodedata, tempfile, html as htmllib, datetime
sys.stdout.reconfigure(encoding='utf-8')
ssl._create_default_https_context = ssl._create_unverified_context

BASE="https://ehliyetim.net"
H={'User-Agent':'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36','Accept-Language':'tr-TR,tr;q=0.9'}
ROOT=os.path.dirname(os.path.abspath(__file__))
IMG_DIR=os.path.join(ROOT,"assets","images","q")
QJSON=os.path.join(ROOT,"assets","data","questions.json")
CACHE=os.path.join(tempfile.gettempdir(),"ehliyetim_pages_cache")
os.makedirs(IMG_DIR,exist_ok=True); os.makedirs(CACHE,exist_ok=True)
MONTHS=['ocak','subat','mart','nisan','mayis','haziran','temmuz','agustos','eylul','ekim','kasim','aralik']

def get(u,t=25,retry=1):
    for k in range(retry+1):
        try:
            req=urllib.request.Request(u,headers=H)
            with urllib.request.urlopen(req,timeout=t) as r: return r.read()
        except urllib.error.HTTPError as e:
            if e.code==404: raise
            if k==retry: raise
            time.sleep(2)
        except Exception:
            if k==retry: raise
            time.sleep(2)

def gettext(u,**kw): return get(u,**kw).decode('utf-8','ignore')

def cached(u, throttle=0.8):
    key=re.sub(r'\W+','_',u)[-120:]+".html"
    p=os.path.join(CACHE,key)
    if os.path.exists(p):
        t=open(p,encoding='utf-8').read()
        return None if t=="__404__" else t
    try:
        t=gettext(u)
    except urllib.error.HTTPError as e:
        if e.code==404:
            open(p,'w',encoding='utf-8').write("__404__"); time.sleep(throttle); return None
        raise
    open(p,'w',encoding='utf-8').write(t); time.sleep(throttle); return t

def clean(s):
    s=re.sub(r'<img[^>]*>',' ',s); s=re.sub(r'<[^>]+>',' ',s)
    return re.sub(r'\s+',' ',htmllib.unescape(s)).strip()

def imgsrcs(s): return re.findall(r'<img[^>]+src="([^"]+)"', s)

def norm(s):
    s=unicodedata.normalize('NFKD',s.lower())
    return re.sub(r'[^a-z0-9çğıöşü ]','',s).strip()

def map_cat(t):
    t=(t or '').lower()
    if 'adab' in t: return 'trafik_adabi'
    if 'lk yard' in t or 'ilk yard' in t: return 'ilk_yardim'
    if 'motor' in t or 'tekn' in t: return 'motor'
    return 'trafik'

def s3_filename(src):
    """S3 url veya get-temp-url ref'inden API filename'i çıkar."""
    if 'get-temp-url' in src:
        m=re.search(r'filename=([^&"\']+)', src); return m.group(1) if m else None
    if '/uploads/' in src:
        return src.split('/uploads/',1)[1].split('?')[0]
    return None

def download_img(src):
    """ehliyetim S3 görseli -> get-temp-url API üzerinden indir (S3 direkt 403)."""
    if not src: return None
    fn=s3_filename(src)
    if fn:
        url=f"{BASE}/api/v1/mobile/get-temp-url?filename={fn}"
        name=os.path.basename(fn)
    else:
        url=src if src.startswith('http') else BASE+src
        name=os.path.basename(src.split('?')[0])
    name=re.sub(r'[^A-Za-z0-9._-]','_',name)
    if '.' not in name: name+=".webp"
    dest=os.path.join(IMG_DIR,name)
    if not os.path.exists(dest):
        try:
            open(dest,'wb').write(get(url, t=30)); time.sleep(0.12)
        except Exception as e:
            print("    img FAIL",src,e,flush=True); return None
    return f"assets/images/q/{name}"

def nextdata(html):
    m=re.search(r'<script id="__NEXT_DATA__" type="application/json">(.*?)</script>', html, re.S)
    return json.loads(m.group(1)) if m else None

def find_questions(o):
    if isinstance(o,list) and o and isinstance(o[0],dict) and 'answers' in o[0] and 'question' in o[0]:
        return o
    if isinstance(o,dict):
        for v in o.values():
            r=find_questions(v)
            if r: return r
    elif isinstance(o,list):
        for v in o:
            if isinstance(v,(dict,list)):
                r=find_questions(v)
                if r: return r
    return None

def parse_page(html, year):
    d=nextdata(html)
    if not d: return []
    qs=find_questions(d.get('props',{}).get('pageProps',{}))
    if not qs: return []
    out=[]
    for q in qs:
        qhtml=q.get('question','') or ''
        qtext=clean(qhtml)
        qimg=imgsrcs(qhtml)
        ans=q.get('answers',[])
        if len(ans)<2: continue
        opts=[]; opt_img={}; correct=0; ok=True
        for i,a in enumerate(ans):
            ah=a.get('answer','') or ''
            at=clean(ah); ai=imgsrcs(ah)
            if a.get('isCorrect'): correct=i
            if at: opts.append(at)
            elif ai: opt_img[i]=ai[0]; opts.append(ai[0])
            else: ok=False; break
        if not ok or len(opts)<2: continue
        if not qtext and not qimg: continue
        cat=map_cat((q.get('categoryNames') or [''])[0])
        out.append({
            "id":"em"+str(q.get('_id','')),
            "text":qtext,
            "options":opts,
            "correctAnswer":correct,
            "explanation":"",
            "category":cat,
            "year":year,
            "_img_src":qimg[0] if qimg else None,
            "_opt_img":opt_img,
        })
    return out

def daily_urls():
    start=datetime.date(2024,10,1); end=datetime.date(2026,5,27)
    d=start; urls=[]
    while d<=end:
        urls.append((f"{BASE}/gunluk-ehliyet-sinav-sorulari/{d.day}-{MONTHS[d.month-1]}-{d.year}-ehliyet-sinav-sorulari", d.year))
        d+=datetime.timedelta(days=1)
    return urls

def main():
    pages=daily_urls()
    extra=[("cikmis-ehliyet-sinav-sorulari",2026),("ehliyet-sinavi-50-soru-test",2026),
           ("ilk-yardim-bilgisi",2026),("motor-ve-arac-teknigi",2026),
           ("trafik-adabi",2026),("trafik-ve-cevre-bilgisi",2026),
           ("animasyonlu-ehliyet-sinav-sorulari",2026)]
    pages+=[(f"{BASE}/test-coz/{s}",y) for s,y in extra]
    print(f"Denenecek sayfa: {len(pages)}",flush=True)

    bank={}; seen_text={}; hit=0; miss=0; total_seen=0
    for i,(u,year) in enumerate(pages,1):
        try:
            html=cached(u)
        except Exception as e:
            print(f"  [{i}] HATA {u}: {e}",flush=True); continue
        if html is None: miss+=1; continue
        hit+=1
        for q in parse_page(html, year):
            nt=norm(q['text']) if q['text'] else q['id']
            total_seen+=1
            if nt in seen_text or q['id'] in bank: continue
            seen_text[nt]=q['id']; bank[q['id']]=q
        if i%80==0 or i==len(pages):
            print(f"  [{i}/{len(pages)}] hit:{hit} miss:{miss} tekil:{len(bank)}",flush=True)

    print(f"ehliyetim.net tekil (kendi içinde): {len(bank)} | görülen: {total_seen}",flush=True)

    print("Görseller indiriliyor (get-temp-url API)...",flush=True)
    qi=oi=0; drop=set()
    for q in bank.values():
        src=q.pop('_img_src',None)
        if src:
            loc=download_img(src)
            if loc: q['imageUrl']=loc; qi+=1
            else: q['imageUrl']=None; drop.add(q['id'])   # figür inemezse soru kullanılamaz
        else:
            q['imageUrl']=None
        q['videoUrl']=None
        for idx,isrc in q.pop('_opt_img',{}).items():
            loc=download_img(isrc)
            if loc: q['options'][idx]=loc; oi+=1
            else: drop.add(q['id'])                        # görsel-şık inemezse soru bozuk
    for k in drop: bank.pop(k,None)
    print(f"Görsel inemediği için düşen soru: {len(drop)}",flush=True)

    scraped=list(bank.values())
    existing=[]
    if os.path.exists(QJSON):
        existing=json.load(open(QJSON,encoding='utf-8'))
        bak=QJSON+".backup-"+time.strftime('%Y%m%d-%H%M%S')
        json.dump(existing,open(bak,'w',encoding='utf-8'),ensure_ascii=False,indent=2)
        print("Yedek:",bak,flush=True)
    exist_text={norm(q.get('text','')) for q in existing}
    merged=list(existing); added=0
    for q in scraped:
        if q['text'] and norm(q['text']) in exist_text: continue
        merged.append(q); added+=1
        if q['text']: exist_text.add(norm(q['text']))

    json.dump(merged,open(QJSON,'w',encoding='utf-8'),ensure_ascii=False,indent=2)
    cats={c:sum(1 for q in merged if q['category']==c) for c in ['ilk_yardim','trafik','motor','trafik_adabi']}
    print("\n=== ÖZET ===",flush=True)
    print(f"Sayfa hit:{hit} miss:{miss} | ehliyetim tekil: {len(scraped)}",flush=True)
    print(f"Mevcut: {len(existing)} + NET-YENİ: {added} => TOPLAM: {len(merged)}",flush=True)
    print(f"İnen soru görseli: {qi} | görsel-şık: {oi}",flush=True)
    print(f"Kategori: {cats}",flush=True)
    print(f"Yazıldı: {QJSON}",flush=True)

if __name__=='__main__':
    main()
