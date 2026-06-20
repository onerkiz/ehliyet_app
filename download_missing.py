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

# Eksik isaretler ve alternatif Wikipedia isimleri
missing_codes = [
    'T-28a', 'T-28b', 'T-29a', 'T-29b', 'T-30a', 'T-30b', 'T-31a', 'T-31b',
    'T-33c', 'T-33d', 'T-33e', 'T-34a', 'T-34b',
    'TT-29a', 'TT-33a', 'TT-41a', 'TT-41b',
    'B-1a', 'B-1b', 'B-1c', 'B-1d', 'B-5a', 'B-5d', 'B-6', 'B-13a', 'B-13b', 'B-16a', 'B-49a', 'B-50a',
    'OY-1', 'OY-2', 'OY-3', 'OY-4', 'OY-5', 'OY-6', 'OY-7', 'OY-8', 'OY-9'
]

# Wikipedia alternatif isimlendirmeler
alt_names = {
    # Otoyol isaretleri
    'OY-1': ['Turkey_road_sign_M-101', 'Turkey_motorway_sign_1', 'Motorway_sign_Turkey_1'],
    'OY-2': ['Turkey_road_sign_M-102', 'Turkey_motorway_sign_2'],
    'OY-3': ['Turkey_road_sign_M-103', 'Turkey_motorway_sign_3'],
    'OY-4': ['Turkey_road_sign_M-104', 'Turkey_motorway_sign_4'],
    'OY-5': ['Turkey_road_sign_M-105', 'Turkey_motorway_sign_5'],
    'OY-6': ['Turkey_road_sign_M-106', 'Turkey_motorway_sign_6'],
    'OY-7': ['Turkey_road_sign_M-107', 'Turkey_motorway_sign_7'],
    'OY-8': ['Turkey_road_sign_M-108', 'Turkey_motorway_sign_8'],
    'OY-9': ['Turkey_road_sign_M-109', 'Turkey_motorway_sign_9'],
    # B isaretleri
    'B-1a': ['Turkey_road_sign_B-1a', 'Turkey_road_sign_B-1_a'],
    'B-1b': ['Turkey_road_sign_B-1b', 'Turkey_road_sign_B-1_b'],
    'B-1c': ['Turkey_road_sign_B-1c', 'Turkey_road_sign_B-1_c'],
    'B-1d': ['Turkey_road_sign_B-1d', 'Turkey_road_sign_B-1_d'],
}

def get_wiki_image_url(sign_name):
    """Wikipedia Commons'dan resim URL'sini al"""
    api_url = f"https://commons.wikimedia.org/w/api.php?action=query&titles=File:{sign_name}.svg&prop=imageinfo&iiprop=url&format=json"

    try:
        headers = {'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36'}
        req = urllib.request.Request(api_url, headers=headers)
        with urllib.request.urlopen(req, timeout=10) as response:
            data = json.loads(response.read().decode())
            pages = data.get('query', {}).get('pages', {})
            for page_id, page_data in pages.items():
                if page_id != '-1':
                    imageinfo = page_data.get('imageinfo', [])
                    if imageinfo:
                        url = imageinfo[0].get('url', '')
                        if url:
                            thumb_url = url.replace('/commons/', '/commons/thumb/')
                            thumb_url = f"{thumb_url}/200px-{sign_name}.svg.png"
                            return thumb_url
    except Exception:
        pass
    return None

def download_image(code, url):
    """Resmi indir"""
    local_filename = f"{code.lower().replace('-', '_')}.png"
    local_path = os.path.join(output_dir, local_filename)

    try:
        headers = {'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36'}
        req = urllib.request.Request(url, headers=headers)
        with urllib.request.urlopen(req, timeout=15) as response:
            content = response.read()
            if len(content) > 500:
                with open(local_path, 'wb') as f:
                    f.write(content)
                return local_filename
    except Exception:
        pass
    return None

print("Eksik isaretler icin alternatif kaynaklar deneniyor...")
print(f"Toplam {len(missing_codes)} eksik isaret\n")

downloaded = {}
still_missing = []

for code in missing_codes:
    print(f"{code}...", end=" ")

    # Dosya zaten varsa atla
    local_filename = f"{code.lower().replace('-', '_')}.png"
    local_path = os.path.join(output_dir, local_filename)
    if os.path.exists(local_path) and os.path.getsize(local_path) > 1000:
        print("[ZATEN VAR]")
        downloaded[code] = local_filename
        continue

    found = False

    # Alternatif isimleri dene
    if code in alt_names:
        for alt_name in alt_names[code]:
            url = get_wiki_image_url(alt_name)
            if url:
                result = download_image(code, url)
                if result:
                    downloaded[code] = result
                    print(f"[OK - {alt_name}]")
                    found = True
                    break

    # Standart ismi tekrar dene
    if not found:
        standard_name = f"Turkey_road_sign_{code}"
        url = get_wiki_image_url(standard_name)
        if url:
            result = download_image(code, url)
            if result:
                downloaded[code] = result
                print("[OK]")
                found = True

    if not found:
        still_missing.append(code)
        print("[BULUNAMADI]")

    time.sleep(0.3)

print(f"\n{'='*50}")
print(f"Bu turda indirilen: {len(downloaded)}")
print(f"Hala eksik: {len(still_missing)}")

if still_missing:
    print(f"\nHala eksik kodlar: {still_missing}")

# JSON'u guncelle
if downloaded:
    with open(json_path, 'r', encoding='utf-8') as f:
        data = json.load(f)

    updated = 0
    for category, signs in data.items():
        for sign in signs:
            code = sign['code']
            if code in downloaded:
                sign['imageUrl'] = f"assets/images/signs/{downloaded[code]}"
                updated += 1

    with open(json_path, 'w', encoding='utf-8') as f:
        json.dump(data, f, ensure_ascii=False, indent=2)

    print(f"\nJSON guncellendi: {updated} isaret")
