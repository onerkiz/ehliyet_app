import urllib.request
import os
import json
import ssl
import time

# SSL sertifika dogrulamasini atla
ssl._create_default_https_context = ssl._create_unverified_context

output_dir = r"C:\Users\orhan nerkiz\Desktop\Ehliyet\assets\images\signs"
json_path = r"C:\Users\orhan nerkiz\Desktop\Ehliyet\assets\data\traffic_signs.json"

os.makedirs(output_dir, exist_ok=True)

# IBB Trafik Cocuk URL pattern
base_url = "https://trafikcocuk.ibb.gov.tr/wp-content/uploads/2018/10/"

# Eksik isaretler ve IBB URL eslesmesi
ibb_mappings = {
    # Tehlike Uyari - tek resimde birden fazla isaret olabilir
    'T-28a': 'tehlike-uyari-isaretleri-28.png',
    'T-28b': 'tehlike-uyari-isaretleri-28.png',
    'T-29a': 'tehlike-uyari-isaretleri-29.png',
    'T-29b': 'tehlike-uyari-isaretleri-29.png',
    'T-30a': 'tehlike-uyari-isaretleri-30.png',
    'T-30b': 'tehlike-uyari-isaretleri-30.png',
    'T-31a': 'tehlike-uyari-isaretleri-31.png',
    'T-31b': 'tehlike-uyari-isaretleri-31.png',
    'T-33c': 'tehlike-uyari-isaretleri-33.png',
    'T-33d': 'tehlike-uyari-isaretleri-33.png',
    'T-33e': 'tehlike-uyari-isaretleri-33.png',
    'T-34a': 'tehlike-uyari-isaretleri-34.png',
    'T-34b': 'tehlike-uyari-isaretleri-34.png',
    # Trafik Tanzim
    'TT-29a': 'trafik-tanzim-isaretleri-29.png',
    'TT-33a': 'trafik-tanzim-isaretleri-33.png',
    'TT-41a': 'trafik-tanzim-isaretleri-41.png',
    'TT-41b': 'trafik-tanzim-isaretleri-41.png',
    # Bilgi isaretleri
    'B-1a': 'bilgi-isaretleri-01.png',
    'B-1b': 'bilgi-isaretleri-01.png',
    'B-1c': 'bilgi-isaretleri-01.png',
    'B-1d': 'bilgi-isaretleri-01.png',
    'B-5a': 'bilgi-isaretleri-05.png',
    'B-5d': 'bilgi-isaretleri-05.png',
    'B-6': 'bilgi-isaretleri-06.png',
    'B-13a': 'bilgi-isaretleri-13.png',
    'B-13b': 'bilgi-isaretleri-13.png',
    'B-16a': 'bilgi-isaretleri-16.png',
    'B-49a': 'bilgi-isaretleri-49.png',
    'B-50a': 'bilgi-isaretleri-50.png',
}

def download_image(url, local_path):
    """Resmi indir"""
    try:
        headers = {'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36'}
        req = urllib.request.Request(url, headers=headers)
        with urllib.request.urlopen(req, timeout=15) as response:
            content = response.read()
            if len(content) > 500:
                with open(local_path, 'wb') as f:
                    f.write(content)
                return True
    except Exception as e:
        print(f"    Hata: {e}")
    return False

print("IBB Trafik Cocuk sitesinden resimler indiriliyor...")
print(f"Toplam {len(ibb_mappings)} isaret icin deneniyor\n")

downloaded = {}
failed = []
downloaded_files = set()

for code, filename in ibb_mappings.items():
    local_filename = f"{code.lower().replace('-', '_')}.png"
    local_path = os.path.join(output_dir, local_filename)

    # Zaten varsa atla
    if os.path.exists(local_path) and os.path.getsize(local_path) > 1000:
        print(f"{code}: [ZATEN VAR]")
        downloaded[code] = local_filename
        continue

    print(f"{code}...", end=" ")

    # IBB URL'sinden indir
    url = base_url + filename

    # Ayni dosyayi daha once indirdiysek kopyala
    if filename in downloaded_files:
        # Daha onceki indirmeden kopyala
        for prev_code, prev_file in downloaded.items():
            if ibb_mappings.get(prev_code) == filename:
                prev_path = os.path.join(output_dir, prev_file)
                if os.path.exists(prev_path):
                    import shutil
                    shutil.copy(prev_path, local_path)
                    downloaded[code] = local_filename
                    print(f"[KOPYALANDI - {filename}]")
                    break
        continue

    if download_image(url, local_path):
        downloaded[code] = local_filename
        downloaded_files.add(filename)
        print(f"[OK - {filename}]")
    else:
        failed.append(code)
        print(f"[BASARISIZ]")

    time.sleep(0.3)

print(f"\n{'='*50}")
print(f"Indirilen: {len(downloaded)}")
print(f"Basarisiz: {len(failed)}")

if failed:
    print(f"Basarisiz: {failed}")

# JSON'u guncelle
if downloaded:
    with open(json_path, 'r', encoding='utf-8') as f:
        data = json.load(f)

    updated = 0
    for category, signs in data.items():
        for sign in signs:
            code = sign['code']
            if code in downloaded and not sign.get('imageUrl'):
                sign['imageUrl'] = f"assets/images/signs/{downloaded[code]}"
                updated += 1

    with open(json_path, 'w', encoding='utf-8') as f:
        json.dump(data, f, ensure_ascii=False, indent=2)

    print(f"\nJSON guncellendi: {updated} isaret")
