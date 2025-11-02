import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ScheduleProvider extends ChangeNotifier {
  final supabase = Supabase.instance.client;
  
  List<Map<String, dynamic>> _schedules = [];
  String? _selectedScheduleId;
  String? _selectedScheduleDate;
  String? _selectedScheduleDay;
  String? _attendanceStatus;
  bool _isLoading = false;
  String? _errorMessage;
  bool _hasSubmittedToday = false; // track if user already submitted today

  // Getters
  List<Map<String, dynamic>> get schedules => _schedules;
  String? get selectedScheduleId => _selectedScheduleId;
  String? get selectedScheduleDate => _selectedScheduleDate;
  String? get selectedScheduleDay => _selectedScheduleDay;
  String? get attendanceStatus => _attendanceStatus;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasSubmittedToday => _hasSubmittedToday; // getter for submission status

  // Fetch semua jadwal
  Future<void> fetchSchedules() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      print('[v0] Fetching schedules from database');
      
      final response = await supabase
          .from('schedule')
          .select()
          .order('tanggal', ascending: false);

      print('[v0] Schedules fetched: $response');
      
      _schedules = List<Map<String, dynamic>>.from(response);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      print('[v0] Error fetching schedules: ${e.toString()}');
      _errorMessage = 'Gagal mengambil jadwal: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
    }
  }

  // Fetch jadwal hari ini dengan retry logic
  Future<void> fetchTodaySchedule() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final today = DateTime.now();
      final formattedDate = "${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}";
      
      print('[v0] Fetching today schedule for date: $formattedDate');
      
      final response = await supabase
          .from('schedule')
          .select('id_schedule, tanggal, nama_hari')
          .eq('tanggal', formattedDate)
          .limit(1);

      print('[v0] Today schedule response: $response, Length: ${(response as List).length}');

      if (response.isNotEmpty) {
        final schedule = response[0];
        
        print('[v0] Full schedule data: $schedule');
        print('[v0] id_schedule value: ${schedule['id_schedule']}, type: ${schedule['id_schedule'].runtimeType}');
        
        final scheduleUuid = schedule['id_schedule'];
        
        if (scheduleUuid == null) {
          _selectedScheduleId = null;
          _errorMessage = 'ID jadwal tidak valid di database. Silakan hubungi admin.';
          print('[v0] ERROR: id_schedule is null in database');
        } else {
          _selectedScheduleId = scheduleUuid.toString();
          _selectedScheduleDate = schedule['tanggal'] ?? formattedDate;
          _selectedScheduleDay = schedule['nama_hari'] ?? _getDayName(today);
          print('[v0] Successfully set Schedule ID: $_selectedScheduleId');
        }
      } else {
        print('[v0] No schedule found for today');
        _selectedScheduleDate = formattedDate;
        _selectedScheduleDay = _getDayName(today);
        _selectedScheduleId = null;
        _errorMessage = 'Jadwal untuk hari ini tidak ditemukan.';
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      print('[v0] Error fetching today schedule: ${e.toString()}');
      _errorMessage = 'Error: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
    }
  }

  String _getDayName(DateTime date) {
    const days = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'];
    return days[date.weekday - 1];
  }

  Future<void> checkAttendanceStatus(String userId) async {
    try {
      print('[v0] Checking attendance status for user: $userId, Schedule ID: $_selectedScheduleId');
      
      if (_selectedScheduleId == null) {
        print('[v0] No schedule ID available, setting status to Belum Absen');
        _attendanceStatus = 'Belum Absen';
        _hasSubmittedToday = false;
        notifyListeners();
        return;
      }

      final response = await supabase
          .from('detail_schedule')
          .select('status')
          .eq('id_user', userId)
          .eq('id_schedule', _selectedScheduleId!)
          .limit(1);

      print('[v0] Attendance check response: $response');

      if (response.isEmpty) {
        _attendanceStatus = 'Belum Absen';
        _hasSubmittedToday = false;
      } else {
        _attendanceStatus = response[0]['status'] ?? 'Belum Absen';
        _hasSubmittedToday = true; // mark as submitted if record exists
      }

      notifyListeners();
    } catch (e) {
      print('[v0] Error checking attendance: ${e.toString()}');
      _attendanceStatus = 'Belum Absen';
      _hasSubmittedToday = false;
      notifyListeners();
    }
  }

  Future<bool> submitAttendance({
    required String userId,
    required String userName,
    required String status,
    String? keterangan, // add keterangan parameter
  }) async {
    try {
      print('[v0] Submitting attendance - Status: $status, User: $userName, UserID: $userId');
      print('[v0] Selected Schedule ID: $_selectedScheduleId (type: ${_selectedScheduleId.runtimeType})');

      if (_hasSubmittedToday) {
        _errorMessage = 'Anda sudah melakukan absensi hari ini. Silakan coba besok.';
        print('[v0] Error: User already submitted today');
        notifyListeners();
        return false;
      }

      if (_selectedScheduleId == null || _selectedScheduleId!.isEmpty) {
        _errorMessage = 'Jadwal untuk hari ini tidak ditemukan. Silakan hubungi admin atau coba kembali nanti.';
        print('[v0] Error: Schedule ID is null or empty');
        notifyListeners();
        return false;
      }

      final userIdInt = int.tryParse(userId) ?? 0;
      final scheduleIdInt = int.tryParse(_selectedScheduleId!) ?? 0;

      print('[v0] Attempting to submit with schedule ID: $scheduleIdInt (int), user ID: $userIdInt (int)');

      final existingResponse = await supabase
          .from('detail_schedule')
          .select()
          .eq('id_user', userIdInt)
          .eq('id_schedule', scheduleIdInt);

      if (existingResponse.isNotEmpty) {
        print('[v0] Updating existing attendance record');
        
        await supabase
            .from('detail_schedule')
            .update({
              'status': status,
              'tanggal': _selectedScheduleDate,
              'keterangan': keterangan ?? '', // update keterangan field
            })
            .eq('id_user', userIdInt)
            .eq('id_schedule', scheduleIdInt);
      } else {
        print('[v0] Creating new attendance record');
        
        await supabase
            .from('detail_schedule')
            .insert({
              'id_user': userIdInt,
              'nama_user': userName,
              'id_schedule': scheduleIdInt,
              'status': status,
              'tanggal': _selectedScheduleDate,
              'keterangan': keterangan ?? '', // add keterangan on insert
              'created_at': DateTime.now().toIso8601String(),
            });
      }

      _attendanceStatus = status;
      _hasSubmittedToday = true; // mark as submitted
      _errorMessage = null;
      notifyListeners();
      print('[v0] Attendance submitted successfully');
      return true;
    } catch (e) {
      print('[v0] Error submitting attendance: ${e.toString()}');
      _errorMessage = 'Gagal menyimpan absensi: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
