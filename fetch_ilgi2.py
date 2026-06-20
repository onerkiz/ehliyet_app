import urllib.request
import ssl
import re
import os

# SSL sertifika dogrulamasini atla
ssl._create_default_https_context = ssl._create_unverified_context

output_dir = r"C:\Users\orhan nerkiz\Desktop\Ehliyet\assets\images\signs"
os.makedirs(output_dir, exist_ok=True)

headers = {
    'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
    'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8',
    'Accept-Language': 'tr-TR,tr;q=0.9,en-US;q=0.8,en;q=0.7',
}

url = "https://www.ilgitrafik.com/trafik-levhalari-isaretleri-tabelalari/"

print(f"Sayfa indiriliyor: {url}")

try:
    req = urllib.request.Request(url, headers=headers)
    with urllib.request.urlopen(req, timeout=30) as response:
        content = response.read().decode('utf-8', errors='ignore')

        # Resim URL'lerini bul
        img_urls = re.findall(r'https?://[^"\s<>\']+\.(?:jpg|jpeg|png|gif|webp)', content, re.IGNORECASE)

        # Benzersiz URL'ler
        unique_urls = list(set(img_urls))
        print(f"\nBulunan benzersiz resim URL'leri: {len(unique_urls)} adet\n")

        # Trafik levhasi resimlerini filtrele
        levha_urls = [u for u in unique_urls if any(kw in u.lower() for kw in
            ['levha', 'isaret', 't-', 'tt-', 'b-', 'oy-', 'tehlike', 'bilgi', 'tanzim', 'trafik', 'product'])]

        print(f"Trafik levhalariyla ilgili resimler: {len(levha_urls)} adet\n")

        # Ilk 50 URL'yi goster
        for i, img_url in enumerate(levha_urls[:50]):
            print(f"{i+1}. {img_url}")

        # Tum URL'leri dosyaya kaydet
        with open(r"C:\Users\orhan nerkiz\Desktop\Ehliyet\ilgi_urls.txt", 'w', encoding='utf-8') as f:
            f.write(f"Toplam: {len(unique_urls)} URL\n")
            f.write(f"Levha ilgili: {len(levha_urls)} URL\n\n")
            for url in sorted(unique_urls):
                f.write(url + '\n')

        print(f"\nTum URL'ler kaydedildi: ilgi_urls.txt")

except Exception as e:
    print(f"Hata: {e}")

# Sitemap'ten urun sayfalarini al
print("\n" + "="*60)
print("SITEMAP'TEN URUN SAYFALARI")
print("="*60)

try:
    sitemap_url = "https://www.ilgitrafik.com/sitemap-product-1.xml"
    req = urllib.request.Request(sitemap_url, headers=headers)
    with urllib.request.urlopen(req, timeout=15) as response:
        content = response.read().decode('utf-8', errors='ignore')

        # URL'leri bul
        urls = re.findall(r'<loc><!\[CDATA\[(https?://[^\]]+)\]\]></loc>', content)
        if not urls:
            urls = re.findall(r'<loc>(https?://[^<]+)</loc>', content)

        # Levha ile ilgili URL'leri filtrele
        levha_product_urls = [u for u in urls if any(kw in u.lower() for kw in
            ['levha', 'isaret', 'tehlike', 'bilgi', 'tanzim', 'otoyol'])]

        print(f"\nUrun sayfalari ({len(urls)} toplam, {len(levha_product_urls)} levha):\n")

        for url in levha_product_urls[:30]:
            print(f"  {url}")

except Exception as e:
    print(f"Sitemap hatasi: {e}")
