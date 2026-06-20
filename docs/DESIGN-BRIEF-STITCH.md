# Tasarım Brief — Stitch için (Ehliyet Sınav İnternetsiz 2026)

> Hedef hissi: **Modern, temiz, güven veren** (resmî e-sınav havası ama sönük değil).
> Marka rengi: **Yeşil** (mevcut ikonla uyumlu) — modernize edilmiş palet. **Mor YOK.**
> Platform: Mobil (Flutter, Material 3). Dil: Türkçe. Tamamen offline.

---

## 0. Stitch'e nasıl verilir
Stitch tek seferde 1 ekran üretir. Önce aşağıdaki **"Design System"** bloğunu ver, sonra her ekran için ilgili prompt'u sırayla yapıştır. Her prompt'un başına şu cümleyi ekle:
> "Use this exact design system for every screen:" + (Design System bloğu)

---

## 1. DESIGN SYSTEM (her prompt'un başına koy)

**App:** Turkish driving-license exam prep app ("Ehliyet Sınav"). Offline, free, ad-supported. Audience: 18–30, exam candidates. Tone: trustworthy, modern, calm, motivating.

**Color palette (light):**
- Primary (brand green): `#16A34A`
- Primary dark (pressed/headings accent): `#15803D`
- Primary tint (backgrounds, selected states): `#F0FDF4` and `#DCFCE7`
- Page background: `#F8FAFC` (very light slate)
- Card surface: `#FFFFFF`
- Border / divider: `#E2E8F0`
- Text primary: `#0F172A` (slate-900)
- Text secondary: `#64748B` (slate-500)
- Warning / streak: `#F59E0B` (amber)
- Error / wrong / fail: `#DC2626` (red)
- Success / correct / pass: `#16A34A` (green)

**Color palette (dark) — opsiyonel:**
- Background `#0B1220`, surface `#111827`, border `#1F2937`, text `#F1F5F9`, secondary text `#94A3B8`, primary green stays `#22C55E`.

**Typography:** Font family **"Plus Jakarta Sans"** (headings, bold/semibold) + body in same family. Modern, geometric, friendly. Sizes: H1 28/bold, H2 20/semibold, title 16/semibold, body 14/regular, caption 12/medium.

**Shape & spacing:** Generous white space. Card radius **20px**, button radius **14px**, chips/pills **full rounded**. Page padding 16px. Card padding 16–20px.

**Elevation:** Soft, subtle shadows (not flat, not heavy). e.g. `0 2px 8px rgba(15,23,42,0.06)`. Cards have white background + soft shadow, NOT gray fill.

**Components:**
- Primary button: filled green, white text, 52px tall, radius 14, subtle shadow.
- Secondary button: white bg, green border + green text.
- Card: white, soft shadow, 20px radius, clear title + secondary subtitle.
- Icons: rounded/duotone style, green when active, slate-400 when inactive. Consistent across the app (no mixing of filled/outline randomly).
- Progress: rounded bars and ring/donut charts in green.
- Bottom navigation: 4 tabs, white bg, green active icon+label, slate inactive. A thin top border. **(Note: a banner ad sits directly above the nav bar — leave 50px space for it; do not design the ad.)**

**Genel kural:** Boş gri kartlardan kaç. Her kartın net bir başlığı, ikonu ve nefes alan boşluğu olsun. Tek bir görsel dil — grid kartları, liste kartları ve istatistik kartları aynı sistemden gelsin.

---

## 2. EKRAN PROMPT'LARI

### Ekran 1 — Ana Sayfa (Home)
> Design a mobile home screen for a Turkish driving-exam app. Top app bar: title "Ehliyet Sınav 2026" (left-aligned, bold) and a settings icon (right).
> Below, in order, as cards with soft shadows on a light `#F8FAFC` background:
> 1. **Streak banner** — a horizontal pill card with an amber flame icon, "5 günlük seri 🔥" bold, and a small subtitle "En iyi: 12 gün". Amber-tinted background.
> 2. **Hero "Deneme Sınavı" card** — the most prominent element: green gradient background, white text. Title "Deneme Sınavı", subtitle "50 soru · 45 dk · geçme 35 doğru", and a white "Sınavı Başlat" button with a play icon. Add a subtle steering-wheel or road illustration watermark in the corner.
> 3. Section label "Ders Bazında Çalış", then a **2-column grid of category cards** (e.g. Trafik, Motor, İlk Yardım, Trafik Adabı): each card has a colored rounded icon, category name (semibold), and "320 soru" caption. White cards, soft shadow, colored icon chip.
> 4. A **"Son sınav" result strip** — green-tinted if passed (check icon), red if failed: "Son sınav: 38/50 (Geçti)".
> 5. Section label "Araçlar", then a vertical list of tappable rows (white cards): "Çıkmış Sorular", "Zayıf Noktalarım", "Başarılarım", "Yanlışlarım", "Favorilerim" — each with a leading duotone icon, title, one-line subtitle, and a chevron.
> Bottom: 4-tab navigation (Ana Sayfa, İşaretler, Konular, İstatistik), green active state.
> Clean, modern, lots of white space, "Plus Jakarta Sans" font, green brand color `#16A34A`.

### Ekran 2 — Sınav / Soru ekranı (Exam question)
> Design a mobile quiz question screen for a driving-exam app. Top: a thin green progress bar + "Soru 12 / 50" centered, a circular countdown timer "23:14" on the right, and a bookmark/star icon to favorite the question.
> Body: the question text in large readable type (16–18). Optional question image in a rounded card. Below, **4 answer options** as full-width rounded cards (radius 14): default white with border; selected = green border + light green fill; after answering, correct = green with check, wrong = red with x.
> Bottom: a large primary "Sonraki" button. Calm, focused, distraction-free, generous spacing. Same design system.

### Ekran 3 — Sonuç ekranı (Result)
> Design an exam result screen. Hero at top: a large **circular progress ring** showing the score percentage, green if passed / red if failed, with "38/50" big in the center and "Geçti! 🎉" or "Kaldı" below. A short motivational line.
> Below: stat chips in a row (Doğru, Yanlış, Boş) with colored numbers. Then two buttons: primary "Yanlışları İncele", secondary "Tekrar Dene". Then a small "Ana Sayfa" text button. Celebratory but clean.

### Ekran 4 — Trafik İşaretleri (Signs)
> Design a traffic-signs browse screen. Top: a search bar (rounded, light) "İşaret ara...". Horizontal category chips (Tehlike, Yasak, Zorunluluk, Bilgi…), green when selected.
> Body: a **responsive grid of sign cards** — each white card shows the sign image centered on top and the sign name below in small semibold text. Soft shadow, 16px radius. Tapping opens a detail. Clean catalog feel.

### Ekran 5 — Konular (Topics)
> Design a "study topics" list screen. A vertical list of topic cards: each has a leading colored duotone icon, the topic title (semibold), a one-line description, and a small progress indicator (e.g. "4/10 konu" with a thin green progress bar). White cards, soft shadow, consistent spacing.

### Ekran 6 — İstatistik (Stats)
> Design a statistics/dashboard screen for an exam app. Top: 2–3 summary stat cards in a row (Çözülen Soru, Başarı %, Günlük Seri) — big number, small label, small icon, subtle colored background.
> Below: a **line/area chart** of exam scores over time (green), and a **donut chart** of correct vs wrong answers. Then a "Başarılarım" badges row (achievement medals, locked ones grayed). Clean data-viz, green accents, plenty of white space, "Plus Jakarta Sans".

---

## 3. Geliştiriciye not (Stitch çıktısı geldikten sonra Flutter tarafı)
- **Font offline olmalı:** "Plus Jakarta Sans"ı `assets/fonts/` altına `.ttf` olarak göm, `pubspec.yaml`'a ekle. `google_fonts` (runtime indirme) KULLANMA — offline garantisi bozulur.
- Stitch renk/şekil tokenlarını `app_theme.dart`'a taşı: `ColorScheme` + `cardTheme` (white + soft shadow) + `textTheme` (Plus Jakarta Sans).
- İşlevsellik aynı kalsın — bu sadece görsel katman. Rota/akış değişmiyor.
- Banner reklam alanı (alt nav üstü) korunsun; Stitch'e "orayı tasarlama, 50px boşluk bırak" dendi.
