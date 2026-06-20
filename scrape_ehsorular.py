# -*- coding: utf-8 -*-
"""
ehliyetsorular.com (WordPress AYS Quiz) çıkmış soru scraper -> questions.json (3. kaynak)

- post-sitemap'teki ~194 quiz post'u (2019-2026, eski sınavlar dahil)
- her soru: <div class="step" data-question-id> + ays_quiz_question metni + 4 şık
  (ays_answer_correct value="1" -> doğru), doğru cevap HTML'de açık
- GÖRSEL ÇEKİLMEZ: görselli soru / görsel-şıklı soru ATLANIR (sadece metin sorular)
- per-soru kategori yok -> anahtar-kelime sınıflandırıcı (yoksa default trafik)
- açıklama boş; mevcut questions.json ile normalize-metin dedup'ı; yedekli
"""
import urllib.request, ssl, re, json, sys, time, os, unicodedata, tempfile, html as htmllib
sys.stdout.reconfigure(encoding='utf-8')
ssl._create_default_https_context = ssl._create_unverified_context
BASE="https://ehliyetsorular.com"
H={'User-Agent':'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36','Accept-Language':'tr-TR,tr;q=0.9'}
ROOT=os.path.dirname(os.path.abspath(__file__))
QJSON=os.path.join(ROOT,"assets","data","questions.json")
CACHE=os.path.join(tempfile.gettempdir(),"ehsorular_pages_cache")
os.makedirs(CACHE,exist_ok=True)

def get(u,t=25,retry=1):
    for k in range(retry+1):
        try:
            with urllib.request.urlopen(urllib.request.Request(u,headers=H),timeout=t) as r:
                return r.read().decode('utf-8','ignore')
        except Exception:
            if k==retry: raise
            time.sleep(2)

def cached(u,throttle=0.6):
    key=re.sub(r'\W+','_',u)[-120:]+".html"; p=os.path.join(CACHE,key)
    if os.path.exists(p): return open(p,encoding='utf-8').read()
    t=get(u); open(p,'w',encoding='utf-8').write(t); time.sleep(throttle); return t

def clean(s):
    s=re.sub(r'<[^>]+>',' ',s)
    return re.sub(r'\s+',' ',htmllib.unescape(s)).strip()

def norm(s):
    s=unicodedata.normalize('NFKD',s.lower())
    return re.sub(r'[^a-z0-9çğıöşü ]','',s).strip()

# yüksek-isabetli anahtar kelimeler
IY=['ilk yardım','ilkyardım','kanama','yaralı','suni solunum','suni teneffüs','kalp masaj','turnike','kazazede',
    'nabız','bilinci kapalı','bilinci açık','şok pozisyon','heimlich','rentek','koma pozisyon','atardamar',
    'toplardamar','zehirlenme','yanık','kırık','çıkık','burkulma','dış kalp','solunum yolu','boğulma','sara nöbet',
    'bayılma','omurga','sedye taşı','turnike','pansuman','holger','şah damar','kalp durmas','soluk yolu']
MOTOR=['motorun','yağ basınc','radyatör','debriyaj','buji','marş motor','rölanti','supap','silindir','antifriz',
    'alternatör','distribütör','karbüratör','şanzıman','triger','enjektör','balata','amortisör','egzoz',
    'yakıt sistem','soğutma sistem','ikaz lamba','hararet','akünün','vites','far ','fren ','lastik','rot balans',
    'gösterge panel','şarj sistem','devir daim','kompresyon','soğutma suyu','motor yağ','akü','far ayar','rulman']
ADAP=['trafik adabı','hoşgörü','öfke','empati','nezaket','agresif','sürücü davran','sabır','trafik kültür',
    'saygı','bencil','olumlu davran','stres','kızgınlık','psikolojik','iletişim','teşekkür','yaya hakkı']

def classify(text, slug=""):
    s=text.lower(); sl=slug.lower()
    if 'adap' in sl: return 'trafik_adabi'
    if 'ilk-yardim' in sl or 'ilkyardim' in sl: return 'ilk_yardim'
    if 'motor' in sl or 'arac-teknik' in sl: return 'motor'
    if any(k in s for k in ADAP): return 'trafik_adabi'
    if any(k in s for k in IY): return 'ilk_yardim'
    if any(k in s for k in MOTOR): return 'motor'
    return 'trafik'

def parse(html, year, slug=""):
    out=[]
    steps=re.split(r'<div class="step\b', html)
    for st in steps:
        mid=re.search(r'data-question-id="(\d+)"', st)
        if not mid: continue
        # sadece bu soruya ait kısmı al (sonraki step'e kadar zaten split etti)
        qm=re.search(r'<div class="ays_quiz_question">(.*?)</div>', st, re.S)
        if not qm: continue
        # görselli soru gövdesi -> atla
        if '<img' in qm.group(1): continue
        qtext=re.sub(r'^\s*\d+\)\s*','',clean(qm.group(1)))
        if not qtext: continue
        opts=[]; correct=0; bad=False
        for i,(corr,lab) in enumerate(re.findall(r'name="ays_answer_correct\[\]" value="([01])".*?<label[^>]*>(.*?)</label>', st, re.S)):
            if '<img' in lab: bad=True; break          # görsel-şık -> atla
            t=re.sub(r'^\s*[A-D]\)\s*','',clean(lab))
            if not t: bad=True; break
            opts.append(t)
            if corr=='1': correct=i
        if bad or len(opts)!=4: continue
        out.append({
            "id":"eh"+mid.group(1),
            "text":qtext,"options":opts,"correctAnswer":correct,
            "explanation":"","category":classify(qtext,slug),
            "year":year,"imageUrl":None,"videoUrl":None,
        })
    return out

def post_urls():
    urls=set()
    idx=get(BASE+"/sitemap.xml")
    for s in re.findall(r'<loc>([^<]+\.xml)</loc>', idx):
        if 'post-sitemap' not in s: continue
        try:
            for l in re.findall(r'<loc>([^<]+)</loc>', get(s)):
                if not l.endswith('.xml'): urls.add(l)
        except Exception: pass
    return sorted(urls)

def main():
    posts=post_urls()
    print(f"Post sayısı: {len(posts)}",flush=True)
    bank={}; seen={}; total=0
    for i,u in enumerate(posts,1):
        try: html=cached(u)
        except Exception as e:
            print(f"  [{i}] HATA {u}: {e}",flush=True); continue
        ym=re.search(r'(20\d\d)', u); year=int(ym.group(1)) if ym else 2025
        slug=u.rstrip('/').split('/')[-1]
        qs=parse(html, year, slug)
        total+=len(qs)
        for q in qs:
            nt=norm(q['text'])
            if not nt or nt in seen or q['id'] in bank: continue
            seen[nt]=q['id']; bank[q['id']]=q
        if i%40==0 or i==len(posts):
            print(f"  [{i}/{len(posts)}] tekil: {len(bank)}",flush=True)

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
        if norm(q['text']) in exist_text: continue
        merged.append(q); exist_text.add(norm(q['text'])); added+=1
    json.dump(merged,open(QJSON,'w',encoding='utf-8'),ensure_ascii=False,indent=2)
    cats={c:sum(1 for q in merged if q['category']==c) for c in ['ilk_yardim','trafik','motor','trafik_adabi']}
    print("\n=== ÖZET ===",flush=True)
    print(f"Post: {len(posts)} | ehsorular tekil: {len(scraped)} | görülen: {total}",flush=True)
    print(f"Mevcut: {len(existing)} + NET-YENİ: {added} => TOPLAM: {len(merged)}",flush=True)
    print(f"Kategori: {cats}",flush=True)

if __name__=='__main__':
    main()
