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

# Wikipedia Commons URL pattern
# https://upload.wikimedia.org/wikipedia/commons/thumb/X/XX/Turkey_road_sign_CODE.svg/120px-Turkey_road_sign_CODE.svg.png

def get_wiki_image_url(code):
    """Wikipedia Commons'dan resim URL'sini olustur"""
    # Kod formatini duzelt: T-1a -> T-1a, TT-1 -> TT-1
    sign_name = f"Turkey_road_sign_{code}.svg"

    # Wikipedia API ile gercek URL'yi al
    api_url = f"https://commons.wikimedia.org/w/api.php?action=query&titles=File:{sign_name}&prop=imageinfo&iiprop=url&format=json"

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
                            # Thumbnail URL olustur (200px)
                            thumb_url = url.replace('/commons/', '/commons/thumb/')
                            thumb_url = f"{thumb_url}/200px-{sign_name.replace('.svg', '.svg.png')}"
                            return thumb_url
    except Exception as e:
        pass
    return None

def download_image(code, url, extension='png'):
    """Resmi indir"""
    local_filename = f"{code.lower().replace('-', '_')}.{extension}"
    local_path = os.path.join(output_dir, local_filename)

    # Zaten varsa atla
    if os.path.exists(local_path) and os.path.getsize(local_path) > 1000:
        return local_filename

    try:
        headers = {'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36'}
        req = urllib.request.Request(url, headers=headers)
        with urllib.request.urlopen(req, timeout=15) as response:
            content = response.read()
            if len(content) > 500:  # En az 500 byte olmali
                with open(local_path, 'wb') as f:
                    f.write(content)
                return local_filename
    except Exception as e:
        pass
    return None

# JSON'dan kodlari oku
with open(json_path, 'r', encoding='utf-8') as f:
    data = json.load(f)

# Tum kodlari topla
all_codes = []
for category, signs in data.items():
    for sign in signs:
        all_codes.append(sign['code'])

print(f"Toplam {len(all_codes)} isaret bulundu")
print("Wikipedia Commons'dan resimler indiriliyor...\n")

downloaded = {}
failed = []

for i, code in enumerate(all_codes):
    print(f"[{i+1}/{len(all_codes)}] {code}...", end=" ")

    # Wikipedia URL'sini al
    url = get_wiki_image_url(code)

    if url:
        result = download_image(code, url)
        if result:
            downloaded[code] = result
            print("[OK]")
        else:
            failed.append(code)
            print("[DOWNLOAD FAILED]")
    else:
        failed.append(code)
        print("[URL NOT FOUND]")

    time.sleep(0.3)  # Rate limiting

print(f"\n{'='*50}")
print(f"Indirilen: {len(downloaded)}")
print(f"Basarisiz: {len(failed)}")

if failed:
    print(f"\nBasarisiz kodlar: {failed[:20]}...")  # Ilk 20

# JSON'u guncelle
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
