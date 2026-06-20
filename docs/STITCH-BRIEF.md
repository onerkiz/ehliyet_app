# Stitch Brief — Ehliyet App (paste this whole thing into Stitch)

Design a clean, modern Turkish driving-license (ehliyet) exam-prep MOBILE app. It works fully offline, is free, and has no login or sign-up. Visual style: MODERN, MINIMAL, TRUSTWORTHY — lots of white space, simple, premium but with the seriousness of an official exam. Provide BOTH a light theme and a dark theme.

DESIGN SYSTEM
- Primary brand color (green): #16A34A. Use green as the ONLY accent color; everything else is neutral gray. No rainbow of colors.
- Semantic colors: success #16A34A, fail/error #DC2626, streak/fire #EA580C, warning #F59E0B.
- Light theme: background #F8FAFC, cards pure white, text #0F172A, secondary text #64748B.
- Dark theme: background #0B0F14, cards #161B22, text #E5E7EB, secondary text #94A3B8.
- Font: Plus Jakarta Sans (fallback Inter). Bold headings (700), body 400–500. Clear hierarchy: large bold title + smaller gray subtitle.
- Cards: 20px corner radius, very soft shadow, thin or no border.
- Primary button: solid green, 14px radius, 52px tall, bold label.
- Category/tool tiles: 16px radius, light tinted background (8–12% of the icon's color).
- Icons: outline (line) style, rounded.
- Generous spacing, 16–24px padding.
- Bottom navigation bar: 4 tabs, the selected tab is green.

SCREENS TO DESIGN

1) HOME ("Ana Sayfa")
Top bar: left title "Ehliyet Sınav 2026", right a settings (gear) icon. Then, top to bottom:
- Daily streak card: orange flame icon + bold "5 günlük seri 🔥", below it gray "En iyi: 12 gün". Faint orange tinted background.
- Big "Deneme Sınavı" card with a green gradient background and white text. Title "Deneme Sınavı", subtitle "50 soru · 45 dk · geçme 35 doğru", and a white solid button "Sınavı Başlat ▸".
- Section title "Ders Bazında Çalış", then a 2-column grid of 4 tiles: "Trafik ve Çevre" 🚦, "İlk Yardım" ⛑️, "Motor ve Araç Tekniği" 🔧, "Trafik Adabı" 🤝. Each tile: icon + subject name + "x soru". Light tinted background.
- A summary card "Son sınav: 42/50 (Geçti)" with a green check icon.
- Section title "Araçlar", then a list of rows (icon + title + subtitle + right chevron): "Çıkmış Sorular", "Zayıf Noktalarım", "Başarılarım", "Yanlışlarım", "Favorilerim".
- Bottom navigation with 4 tabs: "Ana Sayfa", "İşaretler", "Konular", "İstatistik".

2) EXAM ("Sınav") — most important
- Top bar: centered "Soru 12/50", right side a star (favorite) icon and a timer "12:34" with a clock icon (turns red in the last minute). A thin green progress bar sits directly under the top bar.
- Body: an optional centered traffic-sign image, below it the bold question text, then 4 answer options. Each option is a card: round A/B/C/D letter badge on the left + option text. The selected option has a green border + faint green background + a filled green letter badge.
- Bottom bar: left "back" and "question palette (grid)" icon buttons, right a wide green "Sonraki" button (on the last question it says "Sınavı Bitir").
- Clean, distraction-free, highly readable.

3) RESULT ("Sonuç")
- Large circular score gauge (e.g. 42/50) and a "Geçti" badge in green (red "Kaldı" if failed).
- Three small stat boxes: "Doğru" (green), "Yanlış" (red), "Boş" (gray).
- An outline button "Cevapları İncele" and a solid green button "Ana Sayfa".
- A subtle sense of celebration, not loud.

4) TRAFFIC SIGNS ("İşaretler")
- Top rounded search bar ("İşaret ara...").
- Filter chips by category (Tehlike, Yasak, Bilgi, etc.).
- A 3-column grid: each cell is a white card with the sign image + a small name below. Airy and clean.

5) TOPICS ("Konular")
- A list of topic cards: each card has a colored icon on the left + topic title + short description + right chevron.
- Tapping opens "Konu Detayı": title on top, then readable lesson content split into card sections with generous line spacing.

6) STATS ("İstatistik")
- A large circular chart showing overall success percentage.
- Summary boxes: total exams, average correct, best streak.
- A bar/line chart of recent exams and per-subject success bars. Simple, data-clear.

7) ACHIEVEMENTS ("Başarılarım")
- A grid of badges: earned ones are colorful and crisp, locked ones are faded/gray. Each badge shows its name and a progress bar. Total earned count at the top.

CONSTRAINTS
- Keep the Turkish text exactly as written above.
- Keep the brand green #16A34A fixed (it matches the app icon).
- Deliver both light and dark variants, both using the green accent.
