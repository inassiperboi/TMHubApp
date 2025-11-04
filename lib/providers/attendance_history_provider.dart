import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AttendanceHistoryProvider extends ChangeNotifier {
  final supabase = Supabase.instance.client;
  
  List<Map<String, dynamic>> _attendanceHistory = [];
  bool _isLoading = false;
  String? _errorMessage;
  
  int? _selectedMonth;
  int? _selectedYear;

  List<Map<String, dynamic>> get attendanceHistory => _attendanceHistory;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int? get selectedMonth => _selectedMonth;
  int? get selectedYear => _selectedYear;

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

  void setFilterMonth(int? month) {
    _selectedMonth = month;
    notifyListeners();
  }

  void setFilterYear(int? year) {
    _selectedYear = year;
    notifyListeners();
  }

  List<int> get availableYears {
    final years = <int>{};
    for (var record in _attendanceHistory) {
      final tanggal = record['tanggal'] as String?;
      if (tanggal != null) {
        try {
          final date = DateTime.parse(tanggal);
          years.add(date.year);
        } catch (e) {
          // ignore
        }
      }
    }
    return years.toList()..sort((a, b) => b.compareTo(a));
  }

  List<int> get availableMonths {
    final months = <int>{};
    for (var record in _attendanceHistory) {
      final tanggal = record['tanggal'] as String?;
      if (tanggal != null) {
        try {
          final date = DateTime.parse(tanggal);
          if (_selectedYear == null || date.year == _selectedYear) {
            months.add(date.month);
          }
        } catch (e) {
          // ignore
        }
      }
    }
    return months.toList()..sort((a, b) => b.compareTo(a));
  }

  List<Map<String, dynamic>> get filteredAttendance {
    if (_selectedMonth == null && _selectedYear == null) {
      return _attendanceHistory;
    }
    
    return _attendanceHistory.where((record) {
      final tanggal = record['tanggal'] as String?;
      if (tanggal == null) return false;
      
      try {
        final date = DateTime.parse(tanggal);
        
        bool matchYear = _selectedYear == null || date.year == _selectedYear;
        bool matchMonth = _selectedMonth == null || date.month == _selectedMonth;
        
        return matchYear && matchMonth;
      } catch (e) {
        return false;
      }
    }).toList();
  }

  void resetFilters() {
    _selectedMonth = null;
    _selectedYear = null;
    notifyListeners();
  }
}
