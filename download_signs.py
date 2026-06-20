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

# Izmir Park sitesinden bilinen URL'ler
base_url = "https://izmirparksurucukursu.com/wp-content/uploads/2021/02/"

# Bilinen resim URL pattern'leri
known_images = {
    # Tehlike Uyari Isaretleri
    "T-1a": "t1a-150x113-1.jpg",
    "T-1b": "t1b.jpg",
    "T-2a": "t2a-150x132-1.png",
    "T-2b": "sola-tehlikeli-devamli-virajlar-levhasi-0773-300x225.jpg",
    "T-3a": "t3a-150x112-1.png",
    "T-3b": "t3b-150x150-1.jpg",
    "T-4a": "t4a.jpg",
    "T-4b": "t4b.jpg",
    "T-4c": "t4c.jpg",
    "T-5": "t5.jpg",
    "T-6": "t6.jpg",
    "T-7": "t7.jpg",
    "T-8": "t8.jpg",
    "T-9": "t9.jpg",
    "T-10": "t10.jpg",
    "T-11": "t11.jpg",
    "T-12": "t12.jpg",
    "T-13": "t13.jpg",
    "T-14a": "t14a.jpg",
    "T-14b": "t14b.jpg",
    "T-15": "t15.jpg",
    "T-16": "t16.jpg",
    "T-17": "t17.jpg",
    "T-18": "t18.jpg",
    "T-19": "t19.jpg",
    "T-20": "t20.jpg",
    "T-21": "t21.jpg",
    "T-22a": "t22a.jpg",
    "T-22b": "t22b.jpg",
    "T-22c": "t22c.jpg",
    "T-22d": "t22d.jpg",
    "T-22e": "t22e.jpg",
    "T-23a": "t23a.jpg",
    "T-23b": "t23b.jpg",
    "T-24": "t24.jpg",
    "T-25": "t25.jpg",
    "T-26": "t26.jpg",
    "T-27a": "t27a.jpg",
    "T-27b": "t27b.jpg",
    "T-28a": "t28a.jpg",
    "T-28b": "t28b.jpg",
    "T-29a": "t29a.jpg",
    "T-29b": "t29b.jpg",
    "T-30a": "t30a.jpg",
    "T-30b": "t30b.jpg",
    "T-31a": "t31a.jpg",
    "T-31b": "t31b.jpg",
    "T-32": "t32.jpg",
    "T-33a": "t33a.jpg",
    "T-33b": "t33b.jpg",
    "T-33c": "t33c.jpg",
    "T-33d": "t33d.jpg",
    "T-33e": "t33e.jpg",
    "T-33f": "t33f.jpg",
    "T-34a": "t34a.jpg",
    "T-34b": "t34b.jpg",
    "T-35": "t35.jpg",
    "T-36": "t36.jpg",
    "T-37": "t37.jpg",
    "T-38": "t38.jpg",
    "T-39": "t39.jpg",
    # Trafik Tanzim Isaretleri
    "TT-1": "tt1-150x113-1.jpg",
    "TT-2": "tt2-150x113-1.jpg",
    "TT-3": "tt3-150x113-1.jpg",
    "TT-4": "tt4.jpg",
    "TT-5": "tt5.jpg",
    "TT-6": "tt6.jpg",
    "TT-7": "tt7.jpg",
    "TT-8": "tt8.jpg",
    "TT-9": "tt9.jpg",
    "TT-10a": "tt10a.jpg",
    "TT-10b": "tt10b.jpg",
    "TT-11": "tt11.jpg",
    "TT-12": "tt12.jpg",
    "TT-13": "tt13.jpg",
    "TT-14": "tt14.jpg",
    "TT-15": "tt15.jpg",
    "TT-16a": "tt16a.jpg",
    "TT-16b": "tt16b.jpg",
    "TT-17": "tt17.jpg",
    "TT-18": "tt18.jpg",
    "TT-19": "tt19.jpg",
    "TT-20": "tt20.jpg",
    "TT-21": "tt21.jpg",
    "TT-22": "tt22.jpg",
    "TT-23": "tt23.jpg",
    "TT-24": "tt24.jpg",
    "TT-25": "tt25.jpg",
    "TT-26a": "tt26a.jpg",
    "TT-26b": "tt26b.jpg",
    "TT-26c": "tt26c.jpg",
    "TT-27": "tt27.jpg",
    "TT-28": "tt28.jpg",
    "TT-29a": "tt29a.jpg",
    "TT-29b": "tt29b.jpg",
    "TT-30": "tt30.jpg",
    "TT-31": "tt31.jpg",
    "TT-32": "tt32.jpg",
    "TT-33a": "tt33a.jpg",
    "TT-33b": "tt33b.jpg",
    "TT-34a": "tt34a.jpg",
    "TT-34b": "tt34b.jpg",
    "TT-35a": "tt35a.jpg",
    "TT-35b": "tt35b.jpg",
    "TT-35c": "tt35c.jpg",
    "TT-35d": "tt35d.jpg",
    "TT-35e": "tt35e.jpg",
    "TT-35f": "tt35f.jpg",
    "TT-35g": "tt35g.jpg",
    "TT-35h": "tt35h.jpg",
    "TT-36a": "tt36a.jpg",
    "TT-36b": "tt36b.jpg",
    "TT-36c": "tt36c.jpg",
    "TT-37": "tt37.jpg",
    "TT-38a": "tt38a.jpg",
    "TT-38b": "tt38b.jpg",
    "TT-39a": "tt39a.jpg",
    "TT-39b": "tt39b.jpg",
    "TT-40a": "tt40a.jpg",
    "TT-40b": "tt40b.jpg",
    "TT-41a": "tt41a.jpg",
    "TT-41b": "tt41b.jpg",
    "TT-42a": "tt42a.jpg",
    "TT-42b": "tt42b.jpg",
    "TT-43": "tt43.jpg",
    "TT-44a": "tt44a.jpg",
    "TT-44b": "tt44b.jpg",
    "TT-45a": "tt45a.jpg",
    "TT-45b": "tt45b.jpg",
    # Bilgi Isaretleri
    "B-14a": "b14a.jpg",
    "B-14b": "b14b.jpg",
    "B-15": "b15.jpg",
    "B-16a": "b16a.jpg",
    "B-16b": "b16b.jpg",
    "B-17": "b17.jpg",
    "B-18": "b18.jpg",
    "B-19": "b19.jpg",
    "B-20": "b20.jpg",
    "B-21": "b21.jpg",
    "B-22": "b22.jpg",
    "B-23": "b23.jpg",
    "B-24": "b24.jpg",
    "B-25": "b25.jpg",
    "B-26": "b26.jpg",
    "B-27": "b27.jpg",
    "B-28": "b28.jpg",
    "B-29": "b29.jpg",
    "B-30": "b30.jpg",
    "B-31": "b31.jpg",
    "B-32": "b32.jpg",
    "B-33": "b33.jpg",
    "B-34": "b34.jpg",
    "B-35": "b35.jpg",
    "B-36": "b36.jpg",
    "B-37": "b37.jpg",
    "B-38": "b38.jpg",
    "B-39": "b39.jpg",
    "B-40": "b40.jpg",
    "B-41": "b41.jpg",
    "B-42": "b42.jpg",
    "B-43": "b43.jpg",
    "B-44": "b44.jpg",
    "B-45a": "b45a.jpg",
    "B-45b": "b45b.jpg",
    "B-45c": "b45c.jpg",
    "B-45d": "b45d.jpg",
    "B-46": "b46.jpg",
    "B-47": "b47.jpg",
    # Park Isaretleri
    "P-1": "p1.jpg",
    "P-2": "p2.jpg",
    "P-3a": "p3a.jpg",
    "P-3b": "p3b.jpg",
    "P-3c": "p3c.jpg",
    "P-3d": "p3d.jpg",
    "P-3e": "p3e.jpg",
    "P-3f": "p3f.jpg",
}

def download_image(code, filename):
    """Resmi indir"""
    url = base_url + filename
    local_filename = f"{code.lower().replace('-', '_')}.jpg"
    local_path = os.path.join(output_dir, local_filename)

    try:
        headers = {'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36'}
        req = urllib.request.Request(url, headers=headers)
        with urllib.request.urlopen(req, timeout=10) as response:
            with open(local_path, 'wb') as f:
                f.write(response.read())
        return local_filename
    except Exception as e:
        return None

# Resimleri indir
print("Trafik isareti resimleri indiriliyor...")
downloaded = {}
failed = []

for code, filename in known_images.items():
    result = download_image(code, filename)
    if result:
        downloaded[code] = result
        print(f"  [OK] {code}")
    else:
        failed.append(code)
        print(f"  [--] {code}")
    time.sleep(0.2)  # Rate limiting

print(f"\nIndirilen: {len(downloaded)}, Basarisiz: {len(failed)}")

# JSON'u guncelle
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

print(f"JSON guncellendi: {updated} isaret")
