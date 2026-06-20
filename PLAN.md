# ehliyet_app — Faz 1 Teknik Plan

E-sınav gerçek formatı: **50 soru / 45 dk / geçme 35 doğru.** 4 ders: Trafik, İlk Yardım, Motor/Araç Tekniği, Trafik Adabı.
MEB soru dağılımı (50 soru): Trafik 23, İlk Yardım 12, Motor 9, Trafik Adabı 6.

## Stack
- State: flutter_riverpod
- Router: go_router
- Kalıcılık: hive_flutter (adapter'sız, map tabanlı)
- Grafik: fl_chart
- Faz 1'de reklam/IAP/login KAPALI. Tamamen offline (google_fonts kullanılmıyor — offline garantisi için sistem fontu).

## Klasör yapısı (lib/)
- core/{theme,router,constants}
- data/{models,repositories}
- features/{home,exam,practice,result,review,topics,signs,stats,settings}
- shared/{providers,widgets}

## Veri modelleri (gerçek JSON'a göre)
- Question: id, text, options[4], correctAnswer(int 0-3), explanation?, category, year?, imageUrl?(314), videoUrl?(boş)
- Topic: id, title, description, category, order, contents[] ; TopicContent: id, title, content, type, order
- TrafficSign: code, name, description, imageUrl, category (5 kategori, 229 işaret)
- ExamResult (Hive): dateEpoch, category?, total, correct, wrong, blank, durationSec, passed, answers[]
- AnsweredItem: questionId, category, selected?, isCorrect

## Ekranlar / rotalar
/, /exam, /result, /practice/:category, /topics, /topics/:id, /signs, /wrong, /favorites, /stats, /settings

## Faz 1 sırası
1. İskelet (main+tema+router) 2. Veri katmanı 3. Ana ekran 4. Deneme sınavı 5. Sonuç+inceleme
6. Kategori pratiği 7. İşaretler+konular 8. İstatistik+yanlışlarım/favoriler+ayarlar 9. flutter analyze

## Faz 1 dışı (sonra)
Az reklam + premium (IAP), bildirim, animasyonlu/video sorular, Google login + blograf backend, online yarışma.
