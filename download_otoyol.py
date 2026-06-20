import urllib.request
import os
import json
import ssl

# SSL sertifika dogrulamasini atla
ssl._create_default_https_context = ssl._create_unverified_context

output_dir = r"C:\Users\orhan nerkiz\Desktop\Ehliyet\assets\images\signs"
json_path = r"C:\Users\orhan nerkiz\Desktop\Ehliyet\assets\data\traffic_signs.json"

os.makedirs(output_dir, exist_ok=True)

# Wikipedia'da denenecek alternatif isimler
# Turk otoyol isaretleri icin cesitli isimlendirmeler
otoyol_alternatives = {
    'OY-1': [
        'Turkey_road_sign_Oy-1',
        'Turkey_road_sign_OY-1',
        'Turkey_motorway_sign_1',
        'Turkey_road_sign_D-1',
        'Turkey_road_sign_M-1',
        'Zeichen_330_-_Autobahn,_StVO_1992',  # Alman otoyol isareti (benzer)
    ],
    'OY-2': ['Turkey_road_sign_Oy-2', 'Turkey_road_sign_OY-2', 'Turkey_motorway_sign_2'],
    'OY-3': ['Turkey_road_sign_Oy-3', 'Turkey_road_sign_OY-3', 'Turkey_motorway_sign_3'],
    'OY-4': ['Turkey_road_sign_Oy-4', 'Turkey_road_sign_OY-4', 'Turkey_motorway_sign_4'],
    'OY-5': ['Turkey_road_sign_Oy-5', 'Turkey_road_sign_OY-5', 'Turkey_motorway_sign_5'],
    'OY-6': ['Turkey_road_sign_Oy-6', 'Turkey_road_sign_OY-6', 'Turkey_motorway_sign_6'],
    'OY-7': ['Turkey_road_sign_Oy-7', 'Turkey_road_sign_OY-7', 'Turkey_motorway_sign_7'],
    'OY-8': ['Turkey_road_sign_Oy-8', 'Turkey_road_sign_OY-8', 'Turkey_motorway_sign_8'],
    'OY-9': ['Turkey_road_sign_Oy-9', 'Turkey_road_sign_OY-9', 'Turkey_motorway_sign_9'],
}

def get_wiki_image_url(sign_name):
    """Wikipedia Commons'dan resim URL'sini al"""
    # SVG dene
    for ext in ['.svg', '.png', '.jpg']:
        api_url = f"https://commons.wikimedia.org/w/api.php?action=query&titles=File:{sign_name}{ext}&prop=imageinfo&iiprop=url&format=json"

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
                                if ext == '.svg':
                                    thumb_url = url.replace('/commons/', '/commons/thumb/')
                                    thumb_url = f"{thumb_url}/200px-{sign_name}{ext}.png"
                                    return thumb_url
                                else:
                                    return url
        except Exception:
            pass
    return None

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
        print(f"    Indirme hatasi: {e}")
    return False

print("Otoyol isaretleri icin Wikipedia'da arama yapiliyor...")
print(f"Toplam {len(otoyol_alternatives)} isaret icin deneniyor\n")

downloaded = {}
failed = []

for code, alternatives in otoyol_alternatives.items():
    local_filename = f"{code.lower().replace('-', '_')}.png"
    local_path = os.path.join(output_dir, local_filename)

    # Zaten varsa atla
    if os.path.exists(local_path) and os.path.getsize(local_path) > 1000:
        print(f"{code}: [ZATEN VAR]")
        downloaded[code] = local_filename
        continue

    print(f"{code}:", end=" ")
    found = False

    for alt_name in alternatives:
        url = get_wiki_image_url(alt_name)
        if url:
            print(f"\n  Deneniyor: {alt_name}...", end=" ")
            if download_image(url, local_path):
                downloaded[code] = local_filename
                print(f"[OK]")
                found = True
                break
            else:
                print(f"[INDIRME BASARISIZ]")

    if not found:
        failed.append(code)
        print(f"[BULUNAMADI]")

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
