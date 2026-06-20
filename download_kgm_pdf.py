import urllib.request
import ssl
import os

# SSL sertifika dogrulamasini atla
ssl._create_default_https_context = ssl._create_unverified_context

pdf_url = "https://www.kgm.gov.tr/SiteCollectionDocuments/KGMdocuments/Trafik/IsaretlerElKitabi/KarayoluTrafikIsaretlemeStandartlari1.pdf"
output_path = r"C:\Users\orhan nerkiz\Desktop\Ehliyet\assets\data\kgm_trafik_isaretleri.pdf"

os.makedirs(os.path.dirname(output_path), exist_ok=True)

print("KGM PDF indiriliyor...")
print(f"URL: {pdf_url}")

try:
    headers = {'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36'}
    req = urllib.request.Request(pdf_url, headers=headers)

    with urllib.request.urlopen(req, timeout=60) as response:
        content = response.read()
        with open(output_path, 'wb') as f:
            f.write(content)

        print(f"\nBasarili! Dosya boyutu: {len(content) / (1024*1024):.2f} MB")
        print(f"Kaydedildi: {output_path}")
except Exception as e:
    print(f"Hata: {e}")
