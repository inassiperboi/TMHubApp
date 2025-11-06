import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class NotificationProvider extends ChangeNotifier {
  final supabase = Supabase.instance.client;

  List<Map<String, dynamic>> _newScheduleNotifications = [];
  List<Map<String, dynamic>> _generalNotifications = [];
  bool _isListening = false;
  StreamSubscription? _streamSubscription;

  // Getters
  List<Map<String, dynamic>> get newScheduleNotifications =>
      _newScheduleNotifications;
  List<Map<String, dynamic>> get generalNotifications => _generalNotifications;
  bool get hasNotifications =>
      _newScheduleNotifications.isNotEmpty || _generalNotifications.isNotEmpty;
  int get notificationCount =>
      _newScheduleNotifications.length + _generalNotifications.length;

  void initializeNotificationListener() {
    if (_isListening) return;

    _isListening = true;
    print('[v0] Initializing notification listener');

    _streamSubscription = Stream.periodic(Duration(seconds: 10)).listen((_) async {
      await _checkForNewSchedules();
      await _fetchGeneralNotifications();
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
              'type': 'schedule',
            });
          }
        }

        notifyListeners();
      }
    } catch (e) {
      print('[v0] Error checking for new schedules: ${e.toString()}');
    }
  }

  Future<void> _fetchGeneralNotifications() async {
    try {
      print('[v0] Fetching general notifications from notifikasi table');

      final response = await supabase
          .from('notifikasi')
          .select()
          .order('created_at', ascending: false)
          .limit(20);

      if (response.isNotEmpty) {
        final notifications = List<Map<String, dynamic>>.from(response);
        
        // Check for new notifications
        for (var notification in notifications) {
          final exists = _generalNotifications.any(
            (notif) => notif['id_notifikasi'] == notification['id_notifikasi'],
          );

          if (!exists) {
            print('[v0] New general notification detected: ${notification['id_notifikasi']}');
            _generalNotifications.insert(0, {
              ...notification,
              'notificationTime': DateTime.now(),
              'isRead': false,
              'type': 'general',
            });
          }
        }

        notifyListeners();
      }
    } catch (e) {
      print('[v0] Error fetching general notifications: ${e.toString()}');
    }
  }

  void markAsRead(int index) {
    if (index >= 0 && index < _newScheduleNotifications.length) {
      _newScheduleNotifications[index]['isRead'] = true;
      notifyListeners();
    }
  }

  void removeNotification(int index) {
    if (index >= 0 && index < _newScheduleNotifications.length) {
      _newScheduleNotifications.removeAt(index);
      notifyListeners();
    }
  }

  void removeGeneralNotification(int index) {
    if (index >= 0 && index < _generalNotifications.length) {
      _generalNotifications.removeAt(index);
      notifyListeners();
    }
  }

  void clearAllNotifications() {
    _newScheduleNotifications.clear();
    _generalNotifications.clear();
    notifyListeners();
  }

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
                'type': 'schedule',
              })
          .toList();

      await _fetchGeneralNotifications();

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
