import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class NotificationProvider extends ChangeNotifier {
  final supabase = Supabase.instance.client;

  List<Map<String, dynamic>> _generalNotifications = [];
  bool _isListening = false;
  StreamSubscription? _streamSubscription;

  // Getters
  List<Map<String, dynamic>> get generalNotifications => _generalNotifications;
  bool get hasNotifications => _generalNotifications.isNotEmpty;
  int get notificationCount => _generalNotifications.length;

  void initializeNotificationListener() {
    if (_isListening) return;

    _isListening = true;
    print('[v1] Notification listener started (polling every 10 seconds)');

    // Polling setiap 10 detik
    _streamSubscription = Stream.periodic(const Duration(seconds: 10)).listen((_) async {
      await fetchGeneralNotifications();
    });
  }

  Future<void> fetchGeneralNotifications() async {
    try {
      print('[v1] Fetching general notifications...');
      final response = await supabase
          .from('notifikasi')
          .select()
          .order('created_at', ascending: false)
          .limit(50);

      if (response.isNotEmpty) {
        final notifications = List<Map<String, dynamic>>.from(response);
        _generalNotifications = notifications
            .map((notif) => {
                  ...notif,
                  'isRead': notif['isRead'] ?? false,
                  'notificationTime': DateTime.now(),
                  'type': 'general',
                })
            .toList();
        notifyListeners();
      }
    } catch (e) {
      print('[v1] Error fetching general notifications: $e');
    }
  }

  void markAsRead(int index) {
    if (index >= 0 && index < _generalNotifications.length) {
      _generalNotifications[index]['isRead'] = true;
      notifyListeners();
    }
  }

  void removeNotification(int index) {
    if (index >= 0 && index < _generalNotifications.length) {
      _generalNotifications.removeAt(index);
      notifyListeners();
    }
  }

  void clearAllNotifications() {
    _generalNotifications.clear();
    notifyListeners();
  }

  @override
  void dispose() {
    _streamSubscription?.cancel();
    _isListening = false;
    super.dispose();
  }
}
