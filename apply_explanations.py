# -*- coding: utf-8 -*-
"""
Kendi ürettiğimiz açıklamaları questions.json'a işler.
Kullanım: python apply_explanations.py <batch.json>
  batch.json = { "es36": "açıklama...", "es53": "...", ... }
Sadece BOŞ explanation'ı doldurur (mevcut açıklamayı ezmez), yedek alır.
"""
import json, sys, os, time
ROOT=os.path.dirname(os.path.abspath(__file__))
QJSON=os.path.join(ROOT,"assets","data","questions.json")

def main():
    if len(sys.argv)<2:
        print("batch.json yolu gerekli"); return
    batch=json.load(open(sys.argv[1],encoding='utf-8'))
    qs=json.load(open(QJSON,encoding='utf-8'))
    byid={q['id']:q for q in qs}
    applied=0; skip_missing=0; skip_filled=0
    for qid,expl in batch.items():
        q=byid.get(qid)
        if not q: skip_missing+=1; continue
        if q.get('explanation'): skip_filled+=1; continue
        q['explanation']=expl.strip(); applied+=1
    bak=QJSON+".backup-"+time.strftime('%Y%m%d-%H%M%S')
    json.dump(qs,open(bak,'w',encoding='utf-8'),ensure_ascii=False,indent=2)
    json.dump(qs,open(QJSON,'w',encoding='utf-8'),ensure_ascii=False,indent=2)
    filled=sum(1 for q in qs if q.get('explanation'))
    print(f"Uygulanan: {applied} | atlanan(yok): {skip_missing} | atlanan(dolu): {skip_filled}")
    print(f"Toplam açıklamalı: {filled}/{len(qs)}")

if __name__=='__main__':
    main()
