import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/notifications/notification_service.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/providers/providers.dart';
import '../../shared/widgets/app_card.dart';

/// Profil sekmesi: kullanıcı özeti + ayarlar (görünüm, hatırlatıcı, veri, hakkında).
/// İleride profil/hesap özellikleri buraya eklenecek.
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(themeModeProvider);
    final notifier = ref.read(themeModeProvider.notifier);
    final ttsAuto = ref.watch(ttsAutoReadProvider);
    final progress = ref.watch(progressRepositoryProvider);
    final examCount = progress.allResults().length;
    final streak = progress.currentStreak();

    return Scaffold(
      appBar: AppBar(title: const Text('Profil')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          _ProfileHeader(examCount: examCount, streak: streak),
          const SizedBox(height: 20),
          const _SectionHeader('Görünüm'),
          AppCard(
            padding: EdgeInsets.zero,
            child: RadioGroup<ThemeMode>(
              groupValue: mode,
              onChanged: (m) {
                if (m != null) notifier.set(m);
              },
              child: const Column(
                children: [
                  RadioListTile<ThemeMode>(
                    value: ThemeMode.system,
                    title: Text('Sistem'),
                  ),
                  RadioListTile<ThemeMode>(
                    value: ThemeMode.light,
                    title: Text('Açık'),
                  ),
                  RadioListTile<ThemeMode>(
                    value: ThemeMode.dark,
                    title: Text('Koyu'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          const _SectionHeader('Dinleyerek Çalış'),
          AppCard(
            padding: EdgeInsets.zero,
            child: SwitchListTile(
              secondary: const Icon(Icons.headphones_outlined),
              title: const Text('Soruları sesli oku'),
              subtitle: const Text(
                  'Her soru ve açıklama otomatik sesli okunur (cihaz sesi)'),
              value: ttsAuto,
              onChanged: (v) => ref.read(ttsAutoReadProvider.notifier).set(v),
            ),
          ),
          const SizedBox(height: 20),
          const _SectionHeader('Hatırlatıcı'),
          const AppCard(
            padding: EdgeInsets.zero,
            child: _ReminderSection(),
          ),
          const SizedBox(height: 20),
          const _SectionHeader('Veri'),
          AppCard(
            padding: EdgeInsets.zero,
            child: ListTile(
              leading: const Icon(Icons.delete_outline),
              title: const Text('İlerlemeyi sıfırla'),
              subtitle: const Text('Sonuçlar, yanlışlar ve favoriler silinir'),
              onTap: () => _resetData(context, ref),
            ),
          ),
          const SizedBox(height: 20),
          const _SectionHeader('Hakkında'),
          AppCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.mail_outline),
                  title: const Text('Soru / Hata Bildir'),
                  subtitle: const Text('Yanlış soru veya öneri için yaz'),
                  onTap: _reportIssue,
                ),
                const _VersionTile(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _reportIssue() async {
    final uri = Uri(
      scheme: 'mailto',
      path: 'blografcom@gmail.com',
      query:
          'subject=${Uri.encodeComponent('Ehliyet Uygulaması - Geri Bildirim')}',
    );
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Future<void> _resetData(BuildContext context, WidgetRef ref) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('İlerlemeyi sıfırla'),
        content: const Text(
            'Tüm sınav sonuçların, yanlışların ve favorilerin silinecek. Emin misin?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(c, false),
              child: const Text('Vazgeç')),
          FilledButton(
              onPressed: () => Navigator.pop(c, true),
              child: const Text('Sıfırla')),
        ],
      ),
    );
    if (ok != true) return;
    await Hive.box('results').clear();
    await Hive.box('answers').clear();
    await Hive.box('favorites').clear();
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('İlerleme sıfırlandı')),
      );
    }
  }
}

/// Profil başlığı — avatar + isim + mini istatistik. (Hesap özelliği ileride.)
class _ProfileHeader extends StatelessWidget {
  final int examCount;
  final int streak;
  const _ProfileHeader({required this.examCount, required this.streak});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(18),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: const BoxDecoration(
              color: AppColors.greenSoft,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.person, color: AppColors.primary, size: 32),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Profilim',
                    style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 4),
                Text(
                  '$examCount sınav · $streak günlük seri',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Uygulama sürümünü pubspec'ten otomatik okur.
class _VersionTile extends StatelessWidget {
  const _VersionTile();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<PackageInfo>(
      future: PackageInfo.fromPlatform(),
      builder: (context, snap) {
        final v = snap.hasData
            ? '${snap.data!.version} (${snap.data!.buildNumber})'
            : '…';
        return AboutListTile(
          icon: const Icon(Icons.info_outline),
          applicationName: 'Ehliyet Sınav 2026',
          applicationVersion: v,
          child: const Text(
            'MEB e-sınav formatına uygun, çevrimdışı ehliyet hazırlık uygulaması.',
          ),
        );
      },
    );
  }
}

/// Günlük çalışma hatırlatıcısı ayarı (aç/kapa + saat seçimi).
class _ReminderSection extends ConsumerStatefulWidget {
  const _ReminderSection();

  @override
  ConsumerState<_ReminderSection> createState() => _ReminderSectionState();
}

class _ReminderSectionState extends ConsumerState<_ReminderSection> {
  late bool _enabled;
  late TimeOfDay _time;

  @override
  void initState() {
    super.initState();
    final repo = ref.read(progressRepositoryProvider);
    _enabled = repo.reminderEnabled();
    _time = TimeOfDay(hour: repo.reminderHour(), minute: repo.reminderMinute());
  }

  Future<void> _toggle(bool value) async {
    final repo = ref.read(progressRepositoryProvider);
    if (value) {
      final granted = await NotificationService.instance.requestPermission();
      if (!granted) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text('Bildirim izni verilmedi.')));
        }
        return;
      }
      await NotificationService.instance
          .scheduleDaily(_time.hour, _time.minute);
    } else {
      await NotificationService.instance.cancelDaily();
    }
    await repo.setReminder(value, _time.hour, _time.minute);
    if (mounted) setState(() => _enabled = value);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(context: context, initialTime: _time);
    if (picked == null) return;
    final repo = ref.read(progressRepositoryProvider);
    await repo.setReminder(_enabled, picked.hour, picked.minute);
    if (_enabled) {
      await NotificationService.instance
          .scheduleDaily(picked.hour, picked.minute);
    }
    if (mounted) setState(() => _time = picked);
  }

  @override
  Widget build(BuildContext context) {
    final hh = _time.hour.toString().padLeft(2, '0');
    final mm = _time.minute.toString().padLeft(2, '0');
    return Column(
      children: [
        SwitchListTile(
          secondary: const Icon(Icons.notifications_active_outlined),
          title: const Text('Günlük çalışma hatırlatıcısı'),
          subtitle: const Text('Her gün seni çalışmaya çağırır'),
          value: _enabled,
          onChanged: _toggle,
        ),
        ListTile(
          enabled: _enabled,
          leading: const Icon(Icons.access_time),
          title: const Text('Hatırlatma saati'),
          trailing: Text('$hh:$mm',
              style: const TextStyle(fontWeight: FontWeight.w600)),
          onTap: _enabled ? _pickTime : null,
        ),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 0, 4, 10),
      child: Text(
        title,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }
}
