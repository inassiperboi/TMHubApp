import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class NotificationProvider extends ChangeNotifier {
  final supabase = Supabase.instance.client;

  List<Map<String, dynamic>> _newScheduleNotifications = [];
  bool _isListening = false;
  StreamSubscription? _streamSubscription;

  // Getters
  List<Map<String, dynamic>> get newScheduleNotifications =>
      _newScheduleNotifications;
  bool get hasNotifications => _newScheduleNotifications.isNotEmpty;
  int get notificationCount => _newScheduleNotifications.length;

  void initializeNotificationListener() {
    if (_isListening) return;

    _isListening = true;
    print('[v0] Initializing notification listener');

    _streamSubscription = Stream.periodic(Duration(seconds: 10)).listen((_) async {
      await _checkForNewSchedules();
    });

    print('[v0] Notification listener started (polling every 10 seconds)');
  }

  Future<void> _checkForNewSchedules() async {
    try {
      final today = DateTime.now();
      final formattedDate =
          "${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}";

      print('[v0] Checking for new schedules');

      final response = await supabase
          .from('schedule')
          .select()
          .eq('tanggal', formattedDate)
          .order('created_at', ascending: false);

      if (response.isNotEmpty) {
        final newSchedules = List<Map<String, dynamic>>.from(response);
        
        for (var schedule in newSchedules) {
          final exists = _newScheduleNotifications.any(
            (notif) => notif['id_schedule'] == schedule['id_schedule'],
          );

          if (!exists) {
            print('[v0] New schedule detected: ${schedule['id_schedule']}');
            _newScheduleNotifications.insert(0, {
              ...schedule,
              'notificationTime': DateTime.now(),
              'isRead': false,
            });
          }
        }

        notifyListeners();
      }
    } catch (e) {
      print('[v0] Error checking for new schedules: ${e.toString()}');
    }
  }

  // Tandai notifikasi sebagai sudah dibaca
  void markAsRead(int index) {
    if (index >= 0 && index < _newScheduleNotifications.length) {
      _newScheduleNotifications[index]['isRead'] = true;
      notifyListeners();
    }
  }

  // Hapus notifikasi
  void removeNotification(int index) {
    if (index >= 0 && index < _newScheduleNotifications.length) {
      _newScheduleNotifications.removeAt(index);
      notifyListeners();
    }
  }

  // Hapus semua notifikasi
  void clearAllNotifications() {
    _newScheduleNotifications.clear();
    notifyListeners();
  }

  // Fetch notifikasi dari database untuk jadwal yang dibuat hari ini
  Future<void> fetchTodayNotifications() async {
    try {
      final today = DateTime.now();
      final formattedDate =
          "${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}";

      print('[v0] Fetching today notifications for date: $formattedDate');

      final response = await supabase
          .from('schedule')
          .select()
          .eq('tanggal', formattedDate)
          .order('created_at', ascending: false);

      print('[v0] Today notifications fetched: $response');

      _newScheduleNotifications = List<Map<String, dynamic>>.from(response)
          .map((schedule) => {
                ...schedule,
                'notificationTime': DateTime.now(),
                'isRead': false,
              })
          .toList();

      notifyListeners();
    } catch (e) {
      print('[v0] Error fetching notifications: ${e.toString()}');
    }
  }

  @override
  void dispose() {
    _streamSubscription?.cancel();
    _isListening = false;
    super.dispose();
  }
}
