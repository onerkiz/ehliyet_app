import fitz  # PyMuPDF
import os
import json

pdf_path = r"C:\Users\orhan nerkiz\Desktop\Ehliyet\assets\data\kgm_trafik_isaretleri.pdf"
output_dir = r"C:\Users\orhan nerkiz\Desktop\Ehliyet\assets\images\signs"
json_path = r"C:\Users\orhan nerkiz\Desktop\Ehliyet\assets\data\traffic_signs.json"

os.makedirs(output_dir, exist_ok=True)

# Eksik isaretler
missing_codes = [
    'T-28a', 'T-28b', 'T-29a', 'T-29b', 'T-30a', 'T-30b', 'T-31a', 'T-31b',
    'T-33c', 'T-33d', 'T-33e', 'T-34a', 'T-34b',
    'TT-29a', 'TT-33a', 'TT-41a', 'TT-41b',
    'B-1a', 'B-1b', 'B-1c', 'B-1d', 'B-5a', 'B-5d', 'B-6', 'B-13a', 'B-13b', 'B-16a', 'B-49a', 'B-50a',
    'OY-1', 'OY-2', 'OY-3', 'OY-4', 'OY-5', 'OY-6', 'OY-7', 'OY-8', 'OY-9'
]

print(f"PDF aciliyor: {pdf_path}")
doc = fitz.open(pdf_path)
print(f"Toplam sayfa: {len(doc)}")

# PDF'den tum resimleri cikar
print("\nResimler cikariliyor...")
extracted_images = []

for page_num in range(len(doc)):
    page = doc[page_num]
    images = page.get_images()

    for img_index, img in enumerate(images):
        xref = img[0]
        base_image = doc.extract_image(xref)

        if base_image:
            image_bytes = base_image["image"]
            image_ext = base_image["ext"]

            # Boyut kontrolu (cok kucuk resimleri atla)
            if len(image_bytes) > 1000:
                extracted_images.append({
                    'page': page_num + 1,
                    'index': img_index,
                    'xref': xref,
                    'ext': image_ext,
                    'size': len(image_bytes),
                    'bytes': image_bytes
                })

doc.close()

print(f"\nToplam {len(extracted_images)} resim bulundu")

# Ilk 50 resmi kaydet (inceleme icin)
print("\nIlk 50 resim kaydediliyor (inceleme icin)...")
for i, img in enumerate(extracted_images[:50]):
    filename = f"kgm_page{img['page']}_img{img['index']}.{img['ext']}"
    filepath = os.path.join(output_dir, filename)
    with open(filepath, 'wb') as f:
        f.write(img['bytes'])
    print(f"  {filename} ({img['size']} bytes)")

print(f"\nKaydedilen: {min(50, len(extracted_images))} resim")
print(f"Konum: {output_dir}")

# Sayfa listesi
print("\nSayfa basina resim sayilari:")
page_counts = {}
for img in extracted_images:
    p = img['page']
    page_counts[p] = page_counts.get(p, 0) + 1

for p in sorted(page_counts.keys())[:20]:
    print(f"  Sayfa {p}: {page_counts[p]} resim")
