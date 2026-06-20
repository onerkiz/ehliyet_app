import urllib.request
import ssl
import re
import json
import os

# SSL sertifika dogrulamasini atla
ssl._create_default_https_context = ssl._create_unverified_context

output_dir = r"C:\Users\orhan nerkiz\Desktop\Ehliyet\assets\images\signs"
os.makedirs(output_dir, exist_ok=True)

# Farkli URL'leri dene
urls_to_try = [
    "https://www.ilgitrafik.com/trafik-levhalari-isaretleri-tabelalari/",
    "https://www.ilgitrafik.com/wp-json/wp/v2/posts",  # WordPress API
    "https://www.ilgitrafik.com/wp-json/wp/v2/pages",
    "https://www.ilgitrafik.com/sitemap.xml",
    "https://www.ilgitrafik.com/sitemap_index.xml",
]

headers = {
    'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
    'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8',
    'Accept-Language': 'tr-TR,tr;q=0.9,en-US;q=0.8,en;q=0.7',
}

for url in urls_to_try:
    print(f"\n{'='*60}")
    print(f"Deneniyor: {url}")
    print('='*60)

    try:
        req = urllib.request.Request(url, headers=headers)
        with urllib.request.urlopen(req, timeout=15) as response:
            content = response.read().decode('utf-8', errors='ignore')

            # Resim URL'lerini bul
            img_urls = re.findall(r'https?://[^"\s<>]+\.(?:jpg|jpeg|png|gif|webp)', content, re.IGNORECASE)

            if img_urls:
                print(f"\nBulunan resim URL'leri ({len(img_urls)} adet):")
                # Sadece ilk 20'yi goster
                for i, img_url in enumerate(set(img_urls)[:20]):
                    print(f"  {i+1}. {img_url}")

            # Trafik levhasi ile ilgili kelimeleri ara
            keywords = ['levha', 'isaret', 'trafik', 'tehlike', 'bilgi', 'otoyol', 'tanzim']
            for kw in keywords:
                count = content.lower().count(kw)
                if count > 0:
                    print(f"  '{kw}' kelimesi: {count} kez")

            # Icerik uzunlugu
            print(f"\nIcerik uzunlugu: {len(content)} karakter")

            # Ilk 500 karakteri goster
            print(f"\nIlk 500 karakter:")
            print(content[:500])

    except Exception as e:
        print(f"Hata: {e}")

# Sitemap'ten URL'leri cikar
print("\n\n" + "="*60)
print("SITEMAP ANALIZI")
print("="*60)

try:
    sitemap_url = "https://www.ilgitrafik.com/sitemap.xml"
    req = urllib.request.Request(sitemap_url, headers=headers)
    with urllib.request.urlopen(req, timeout=15) as response:
        content = response.read().decode('utf-8', errors='ignore')

        # URL'leri bul
        urls = re.findall(r'<loc>(https?://[^<]+)</loc>', content)

        # Trafik levhalariyla ilgili URL'leri filtrele
        levha_urls = [u for u in urls if any(kw in u.lower() for kw in ['levha', 'isaret', 'trafik', 'tehlike', 'bilgi', 'tanzim', 'otoyol'])]

        print(f"\nTrafik levhalariyla ilgili URL'ler ({len(levha_urls)} adet):")
        for url in levha_urls[:30]:
            print(f"  {url}")

except Exception as e:
    print(f"Sitemap hatasi: {e}")
