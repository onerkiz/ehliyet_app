import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

/// Günlük çalışma hatırlatıcısı — tamamen yerel (sunucu/FCM yok).
class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final _plugin = FlutterLocalNotificationsPlugin();
  static const _dailyId = 1001;
  bool _ready = false;

  Future<void> _ensureInit() async {
    if (_ready || kIsWeb) return;
    tzdata.initializeTimeZones();
    try {
      tz.setLocalLocation(tz.getLocation('Europe/Istanbul'));
    } catch (_) {/* varsayılan UTC kalır */}
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    await _plugin.initialize(const InitializationSettings(android: android));
    _ready = true;
  }

  /// Android 13+ bildirim iznini ister. İzin verilirse true.
  Future<bool> requestPermission() async {
    if (kIsWeb) return false;
    await _ensureInit();
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    final granted = await android?.requestNotificationsPermission();
    return granted ?? true;
  }

  Future<void> scheduleDaily(int hour, int minute) async {
    if (kIsWeb) return;
    await _ensureInit();
    await _plugin.cancel(_dailyId);
    final now = tz.TZDateTime.now(tz.local);
    var when =
        tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (!when.isAfter(now)) when = when.add(const Duration(days: 1));
    await _plugin.zonedSchedule(
      _dailyId,
      'Ehliyet çalışma zamanı 📚',
      'Bugünkü serini bozma! Birkaç soru çöz.',
      when,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_reminder',
          'Günlük Hatırlatıcı',
          channelDescription: 'Her gün çalışma hatırlatması',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<void> cancelDaily() async {
    if (kIsWeb) return;
    await _ensureInit();
    await _plugin.cancel(_dailyId);
  }
}
