import json
import urllib.request
import urllib.parse

def get_wikipedia_image_url(code):
    """Wikipedia'dan trafik işareti resim URL'sini al"""
    # Kod formatını düzelt (T-1a -> T-1a, TT-1 -> TT-1)
    sign_name = f"Turkey_road_sign_{code}.svg"

    # Wikipedia API'sini kullan
    api_url = f"https://commons.wikimedia.org/w/api.php?action=query&titles=File:{urllib.parse.quote(sign_name)}&prop=imageinfo&iiprop=url&format=json"

    try:
        with urllib.request.urlopen(api_url, timeout=5) as response:
            data = json.loads(response.read().decode())
            pages = data.get('query', {}).get('pages', {})
            for page_id, page_data in pages.items():
                if page_id != '-1':
                    imageinfo = page_data.get('imageinfo', [])
                    if imageinfo:
                        url = imageinfo[0].get('url', '')
                        # SVG'yi PNG'ye dönüştür (thumb URL)
                        if url:
                            # Thumbnail URL oluştur
                            thumb_url = url.replace('/commons/', '/commons/thumb/')
                            thumb_url = f"{thumb_url}/120px-{sign_name.replace('.svg', '.svg.png')}"
                            return thumb_url
    except Exception as e:
        pass

    return None

# JSON dosyasını oku
json_path = r"C:\Users\orhan nerkiz\Desktop\Ehliyet\assets\data\traffic_signs.json"

with open(json_path, 'r', encoding='utf-8') as f:
    data = json.load(f)

# Her kategori için image URL'lerini ekle
total = 0
found = 0

for category, signs in data.items():
    print(f"\n{category}:")
    for sign in signs:
        code = sign['code']
        total += 1

        # URL'yi al
        image_url = get_wikipedia_image_url(code)

        if image_url:
            sign['imageUrl'] = image_url
            found += 1
            print(f"  [OK] {code}")
        else:
            print(f"  [--] {code} - bulunamadi")

# Güncellenmiş JSON'u kaydet
with open(json_path, 'w', encoding='utf-8') as f:
    json.dump(data, f, ensure_ascii=False, indent=2)

print(f"\n{'='*50}")
print(f"Toplam: {total}, Bulunan: {found}, Bulunamayan: {total - found}")
print(f"JSON güncellendi: {json_path}")
