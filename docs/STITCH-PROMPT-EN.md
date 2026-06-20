# Single Stitch Prompt (English) — paste this whole block into Stitch

---

Design a modern, clean, trustworthy mobile app UI for a **Turkish driving-license exam prep app** called "Ehliyet Sınav 2026". The app is offline, free, and ad-supported. Audience: 18–30 year-old exam candidates. The feeling should be professional and calm like an official e-exam, but modern and motivating — not boring.

**Design system (apply to every screen):**
- Font: "Plus Jakarta Sans" — geometric, friendly, modern.
- Brand color (primary): green `#16A34A`. Darker green `#15803D`. Light green tints `#DCFCE7` and `#F0FDF4`.
- Page background: light slate `#F8FAFC`. Cards: white `#FFFFFF` with a SOFT subtle shadow (e.g. 0 2px 8px rgba(15,23,42,0.06)) — never flat gray fills.
- Borders/dividers: `#E2E8F0`. Text primary: `#0F172A`. Text secondary: `#64748B`.
- Accents: amber `#F59E0B` (daily streak/warning), red `#DC2626` (wrong/fail), green `#16A34A` (correct/pass/success).
- Shapes: card radius 20px, button radius 14px, chips fully rounded. Generous white space, 16px page padding.
- Buttons: primary = filled green, white text, 52px tall, soft shadow. Secondary = white with green border and green text.
- Icons: consistent rounded/duotone style; green when active, slate-gray when inactive.
- Bottom navigation: 4 tabs (Ana Sayfa, İşaretler, Konular, İstatistik), white background, green active icon+label, thin top border. Leave ~50px empty space above the nav bar for a banner ad (do NOT design the ad).

**Generate these screens, all in Turkish text, all using the same design system above:**

1. **Home (Ana Sayfa):** Top app bar "Ehliyet Sınav 2026" (bold, left) + settings icon (right). Then, as cards on the light background: (a) a streak pill card with an amber flame icon, "5 günlük seri 🔥" and subtitle "En iyi: 12 gün"; (b) a prominent HERO card with a green gradient and white text — title "Deneme Sınavı", subtitle "50 soru · 45 dk · geçme 35 doğru", a white "Sınavı Başlat" button with a play icon, and a faint steering-wheel illustration in the corner; (c) section label "Ders Bazında Çalış" then a 2-column grid of category cards (Trafik, Motor, İlk Yardım, Trafik Adabı) each with a colored rounded icon chip, name, and "320 soru" caption; (d) a "Son sınav: 38/50 (Geçti)" strip, green-tinted with a check icon; (e) section label "Araçlar" then a vertical list of white rows ("Çıkmış Sorular", "Zayıf Noktalarım", "Başarılarım", "Yanlışlarım", "Favorilerim") each with a leading duotone icon, title, one-line subtitle, and a chevron.

2. **Quiz question (Sınav):** Top: thin green progress bar + "Soru 12 / 50" centered, a circular countdown timer "23:14" on the right, a bookmark icon to favorite. Body: large readable question text, optional question image in a rounded card, then 4 answer options as full-width rounded cards — default white with border, selected = green border + light green fill, correct = green with check, wrong = red with x. Bottom: large primary "Sonraki" button. Calm, focused, distraction-free.

3. **Result (Sonuç):** Hero circular progress ring showing the score percentage (green if passed / red if failed) with "38/50" big in the center and "Geçti! 🎉" below, plus a short motivational line. Then stat chips in a row (Doğru, Yanlış, Boş) with colored numbers. Then primary button "Yanlışları İncele", secondary "Tekrar Dene", and a small "Ana Sayfa" text button.

4. **Traffic signs (İşaretler):** Top search bar "İşaret ara..." and horizontal category chips (Tehlike, Yasak, Zorunluluk, Bilgi) green when selected. Body: a responsive grid of white sign cards, each with the sign image on top and its name below in small semibold text, soft shadow.

5. **Topics (Konular):** A vertical list of topic cards, each with a leading colored duotone icon, topic title (semibold), one-line description, and a thin green progress bar with "4/10 konu".

6. **Statistics (İstatistik):** Top row of 2–3 summary stat cards (Çözülen Soru, Başarı %, Günlük Seri) — big number, small label, small icon, subtle colored background. Below: a green line/area chart of exam scores over time and a donut chart of correct vs wrong answers. Then a "Başarılarım" row of achievement medals (locked ones grayed out). Clean data-viz, green accents, lots of white space.

Style overall: minimal, premium, lots of white space, soft shadows, rounded corners, "Plus Jakarta Sans" font, green `#16A34A` brand color. No purple. Material 3 friendly.
