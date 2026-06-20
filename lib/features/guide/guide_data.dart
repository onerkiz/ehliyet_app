// Sürücü Rehberi — statik referans içeriği (tamamen offline).
//
// NOT: Yaş/şart gibi bilgiler özet niteliğindedir; resmi/güncel şartlar için
// MEB ve EGM (Emniyet Genel Müdürlüğü) kaynaklarını esas alın.

/// 81 il plaka kodu.
const List<List<String>> kPlates = [
  ['01', 'Adana'], ['02', 'Adıyaman'], ['03', 'Afyonkarahisar'], ['04', 'Ağrı'],
  ['05', 'Amasya'], ['06', 'Ankara'], ['07', 'Antalya'], ['08', 'Artvin'],
  ['09', 'Aydın'], ['10', 'Balıkesir'], ['11', 'Bilecik'], ['12', 'Bingöl'],
  ['13', 'Bitlis'], ['14', 'Bolu'], ['15', 'Burdur'], ['16', 'Bursa'],
  ['17', 'Çanakkale'], ['18', 'Çankırı'], ['19', 'Çorum'], ['20', 'Denizli'],
  ['21', 'Diyarbakır'], ['22', 'Edirne'], ['23', 'Elazığ'], ['24', 'Erzincan'],
  ['25', 'Erzurum'], ['26', 'Eskişehir'], ['27', 'Gaziantep'], ['28', 'Giresun'],
  ['29', 'Gümüşhane'], ['30', 'Hakkari'], ['31', 'Hatay'], ['32', 'Isparta'],
  ['33', 'Mersin'], ['34', 'İstanbul'], ['35', 'İzmir'], ['36', 'Kars'],
  ['37', 'Kastamonu'], ['38', 'Kayseri'], ['39', 'Kırklareli'], ['40', 'Kırşehir'],
  ['41', 'Kocaeli'], ['42', 'Konya'], ['43', 'Kütahya'], ['44', 'Malatya'],
  ['45', 'Manisa'], ['46', 'Kahramanmaraş'], ['47', 'Mardin'], ['48', 'Muğla'],
  ['49', 'Muş'], ['50', 'Nevşehir'], ['51', 'Niğde'], ['52', 'Ordu'],
  ['53', 'Rize'], ['54', 'Sakarya'], ['55', 'Samsun'], ['56', 'Siirt'],
  ['57', 'Sinop'], ['58', 'Sivas'], ['59', 'Tekirdağ'], ['60', 'Tokat'],
  ['61', 'Trabzon'], ['62', 'Tunceli'], ['63', 'Şanlıurfa'], ['64', 'Uşak'],
  ['65', 'Van'], ['66', 'Yozgat'], ['67', 'Zonguldak'], ['68', 'Aksaray'],
  ['69', 'Bayburt'], ['70', 'Karaman'], ['71', 'Kırıkkale'], ['72', 'Batman'],
  ['73', 'Şırnak'], ['74', 'Bartın'], ['75', 'Ardahan'], ['76', 'Iğdır'],
  ['77', 'Yalova'], ['78', 'Karabük'], ['79', 'Kilis'], ['80', 'Osmaniye'],
  ['81', 'Düzce'],
];

/// Ehliyet sınıfı: [kod, kısa açıklama, asgari yaş].
const List<List<String>> kLicenseClasses = [
  ['M', 'Moped / motorlu bisiklet', '16'],
  ['A1', '125 cm³ / 11 kW\'a kadar motosiklet', '16'],
  ['A2', '35 kW\'a kadar motosiklet', '18'],
  ['A', 'Motosiklet (sınırsız)', '20*'],
  ['B1', 'Dört tekerlekli motosiklet', '16'],
  ['B', 'Otomobil / kamyonet (≤3500 kg, en çok 8+1)', '18'],
  ['BE', 'B sınıfı + ağır römork', '18'],
  ['C1', '3500–7500 kg arası kamyon', '18'],
  ['C', '3500 kg üzeri kamyon', '21**'],
  ['D1', 'En çok 16+1 koltuklu minibüs', '21'],
  ['D', 'Otobüs', '24**'],
  ['F', 'Lastik tekerlekli traktör', '18'],
  ['G', 'İş makinesi', '18'],
];

/// Sınav/ehliyet alma süreci adımları: [başlık, açıklama].
const List<List<String>> kExamSteps = [
  [
    'Sürücü kursuna kayıt',
    'Nüfus cüzdanı, sağlık raporu, öğrenim belgesi ve fotoğrafla kursa kaydol.'
  ],
  [
    'Teorik eğitim',
    'Trafik, ilk yardım, motor ve trafik adabı derslerini (örgün/uzaktan) tamamla.'
  ],
  [
    'e-Sınav (yazılı)',
    '50 soru, 45 dakika. Geçmek için en az 35 doğru (70 puan) gerekir.'
  ],
  [
    'Direksiyon eğitimi',
    'Yazılıyı geçince araçta uygulamalı direksiyon derslerini al.'
  ],
  [
    'Direksiyon (uygulama) sınavı',
    'Akan trafikte/parkurda sürüş becerin değerlendirilir.'
  ],
  [
    'Sürücü belgesi',
    'Sertifikanı alıp randevuyla sürücü belgeni (ehliyetini) teslim al.'
  ],
];

/// Direksiyon sınavı ipuçları (checklist).
const List<String> kDrivingTips = [
  'Araca biner binmez koltuk, ayna ve direksiyon ayarını yap.',
  'Emniyet kemerini tak; yolcuların da taktığından emin ol.',
  'Hareket etmeden önce sinyal ver, aynaları ve kör noktayı kontrol et.',
  'Hız limitlerine ve takip mesafesine uy; ani fren/gazdan kaçın.',
  'Şerit değiştirirken sinyal + ayna + kör nokta sırasını uygula.',
  'Kavşak ve yaya geçitlerinde yavaşla, geçiş hakkına dikkat et.',
  'Park (paralel/dik) ve geri manevrada acele etme, kontrollü ol.',
  'Sakin ol, eğitmenin yönergelerini dikkatle dinle.',
];
