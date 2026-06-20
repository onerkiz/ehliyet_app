import fitz  # PyMuPDF
import os

output_dir = r"C:\Users\orhan nerkiz\Desktop\Ehliyet\assets\images\signs"
os.makedirs(output_dir, exist_ok=True)

# PDF dosyaları
pdf_files = [
    r"C:\Users\orhan nerkiz\Downloads\duseyisaretleme.pdf",
    r"C:\Users\orhan nerkiz\Downloads\Pano.pdf"
]

# Yüksek çözünürlük için zoom faktörü
zoom = 3.0
mat = fitz.Matrix(zoom, zoom)

for pdf_path in pdf_files:
    if not os.path.exists(pdf_path):
        print(f"Dosya bulunamadı: {pdf_path}")
        continue

    pdf_name = os.path.splitext(os.path.basename(pdf_path))[0]
    doc = fitz.open(pdf_path)

    print(f"\n{pdf_name}.pdf açıldı: {doc.page_count} sayfa")

    for page_num in range(doc.page_count):
        page = doc[page_num]
        pix = page.get_pixmap(matrix=mat)

        image_filename = f"{pdf_name}_page_{page_num + 1}.png"
        image_path = os.path.join(output_dir, image_filename)
        pix.save(image_path)

        print(f"  Sayfa {page_num + 1} kaydedildi: {image_filename} ({pix.width}x{pix.height})")

    doc.close()

print(f"\n{'='*50}")
print(f"Tüm sayfalar kaydedildi: {output_dir}")
print(f"{'='*50}")
