import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AttendanceHistoryProvider extends ChangeNotifier {
  final supabase = Supabase.instance.client;
  
  List<Map<String, dynamic>> _attendanceHistory = [];
  bool _isLoading = false;
  String? _errorMessage;
  
  String? _selectedMonth; // Format: "2025-11" (YYYY-MM)

  List<Map<String, dynamic>> get attendanceHistory => _attendanceHistory;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get selectedMonth => _selectedMonth;

  Future<void> fetchAttendanceHistory(String userId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      print('[v0] Fetching attendance history for userId: $userId');
      
      final response = await supabase
          .from('detail_schedule')
          .select()
          .eq('id_user', int.parse(userId))
          .order('tanggal', ascending: false);

      print('[v0] Attendance history response: $response');

      _attendanceHistory = List<Map<String, dynamic>>.from(response);
      _errorMessage = null;
    } catch (e) {
      print('[v0] Error fetching attendance history: ${e.toString()}');
      _errorMessage = 'Gagal memuat riwayat absensi: ${e.toString()}';
      _attendanceHistory = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void selectMonth(String monthYear) {
    if (_selectedMonth == monthYear) {
      _selectedMonth = null; // Deselect jika klik 2x
    } else {
      _selectedMonth = monthYear;
    }
    notifyListeners();
  }

  Map<String, List<Map<String, dynamic>>> get groupedAttendanceByMonth {
    final grouped = <String, List<Map<String, dynamic>>>{};
    
    for (var record in _attendanceHistory) {
      final tanggal = record['tanggal'] as String?;
      if (tanggal != null) {
        try {
          final date = DateTime.parse(tanggal);
          final monthYear = '${date.year}-${date.month.toString().padLeft(2, '0')}';
          
          if (!grouped.containsKey(monthYear)) {
            grouped[monthYear] = [];
          }
          grouped[monthYear]!.add(record);
        } catch (e) {
          print('[v0] Error parsing date: $tanggal');
        }
      }
    }
    
    return grouped;
  }

  List<String> get sortedMonths {
    final months = groupedAttendanceByMonth.keys.toList();
    months.sort((a, b) => b.compareTo(a));
    return months;
  }

  List<Map<String, dynamic>> get filteredAttendance {
    if (_selectedMonth == null) {
      return _attendanceHistory;
    }
    
    return _attendanceHistory.where((record) {
      final tanggal = record['tanggal'] as String?;
      if (tanggal == null) return false;
      
      try {
        final date = DateTime.parse(tanggal);
        final monthYear = '${date.year}-${date.month.toString().padLeft(2, '0')}';
        return monthYear == _selectedMonth;
      } catch (e) {
        return false;
      }
    }).toList();
  }
}
