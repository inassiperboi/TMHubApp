import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/schedule_provider.dart';
import '../providers/location_provider.dart';
import 'attendance_history_screen.dart';
import 'profile_screen.dart';
import 'notification_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  bool _dataInitialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeData();
    });
  }

  void _initializeData() async {
    await Future.delayed(const Duration(milliseconds: 500));

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final scheduleProvider = Provider.of<ScheduleProvider>(context, listen: false);
    final locationProvider = Provider.of<LocationProvider>(context, listen: false);

    print('[v0] Home Screen Init - UserID: ${authProvider.userId}, UserName: ${authProvider.userName}');

    if (authProvider.userId == null || authProvider.userName == null) {
      print('[v0] ERROR: User data incomplete - UserID: ${authProvider.userId}, UserName: ${authProvider.userName}');
      setState(() => _dataInitialized = true);
      return;
    }

    // 🧭 Inilah baris penting agar lokasi langsung diperbarui
    await locationProvider.getCurrentLocation();

    await scheduleProvider.fetchTodaySchedule();
    await scheduleProvider.checkAttendanceStatus(authProvider.userId!);

    setState(() => _dataInitialized = true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildBody(),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBottomNav() {
    return BottomNavigationBar(
      currentIndex: _selectedIndex,
      onTap: (index) => setState(() => _selectedIndex = index),
      backgroundColor: const Color(0xFF1E4471),
      selectedItemColor: Colors.white,
      unselectedItemColor: Colors.white70,
      type: BottomNavigationBarType.fixed,
      items: const [
        BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined), label: 'Home'),
        BottomNavigationBarItem(
            icon: Icon(Icons.history_outlined), label: 'Riwayat'),
        BottomNavigationBarItem(
            icon: Icon(Icons.notifications_outlined), label: 'Notifikasi'),
        BottomNavigationBarItem(
            icon: Icon(Icons.person_outline), label: 'Profil'),
      ],
    );
  }

  Widget _buildBody() {
    switch (_selectedIndex) {
      case 0:
        return const _HomeContent();
      case 1:
        return const AttendanceHistoryScreen();
      case 2:
        return const NotificationScreen();
      case 3:
        return const ProfileScreen();
      default:
        return const _HomeContent();
    }
  }
}

class _HomeContent extends StatelessWidget {
  const _HomeContent();

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final scheduleProvider = Provider.of<ScheduleProvider>(context);
    final locationProvider = Provider.of<LocationProvider>(context);
    
    final selectedDate = scheduleProvider.selectedScheduleDate ?? 'Tanggal tidak tersedia';
    final selectedDay = scheduleProvider.selectedScheduleDay ?? 'Hari tidak tersedia';
    final attendanceStatus = scheduleProvider.attendanceStatus ?? 'Belum Absen';
    final hasSubmittedToday = scheduleProvider.hasSubmittedToday;

    bool userDataComplete = auth.userId != null && auth.userName != null;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Absensi Hari Ini',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF1E4471),
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFE3F2FD), Color(0xFFBBDEFB)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: scheduleProvider.isLoading
            ? const Center(child: CircularProgressIndicator())
            : SafeArea(
                child: SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: MediaQuery.of(context).size.height -
                                 AppBar().preferredSize.height -
                                 MediaQuery.of(context).padding.top -
                                 MediaQuery.of(context).padding.bottom,
                    ),
                    child: IntrinsicHeight(
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          children: [
                      // CARD TANGGAL HARI INI
                      Card(
                        elevation: 6,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20)),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            children: [
                              const CircleAvatar(
                                radius: 30,
                                backgroundColor: Colors.blueAccent,
                                child: Icon(Icons.calendar_today,
                                    color: Colors.white, size: 28),
                              ),
                              const SizedBox(width: 20),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Tanggal Hari Ini',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.grey[800],
                                      ),
                                    ),
                                    Text(
                                      selectedDate,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        color: Colors.blueAccent,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      selectedDay,
                                      style: const TextStyle(
                                          fontSize: 15, color: Colors.black54),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 30),

                      // CARD STATUS LOKASI
                      Card(
                        elevation: 6,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20)),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.location_on,
                                    color: locationProvider.isWithinOfficeRadius
                                        ? Colors.green
                                        : Colors.redAccent,
                                    size: 24,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Status Lokasi',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.grey,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          locationProvider.isWithinOfficeRadius
                                              ? 'Anda berada di kantor'
                                              : 'Anda berada di luar kantor',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: locationProvider.isWithinOfficeRadius
                                                ? Colors.green
                                                : Colors.redAccent,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              if (locationProvider.distanceFromOffice != null)
                                Padding(
                                  padding: const EdgeInsets.only(top: 12.0),
                                  child: Text(
                                    'Jarak dari kantor: ${(locationProvider.distanceFromOffice! / 1000).toStringAsFixed(2)} km',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 30),

                      // CARD STATUS ABSENSI
                      Card(
                        color: Colors.white,
                        elevation: 6,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20)),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 30, horizontal: 20),
                          child: Column(
                            children: [
                              const Text(
                                'Status Absensi Kamu',
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                attendanceStatus,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: attendanceStatus == 'Belum Absen'
                                      ? Colors.redAccent
                                      : attendanceStatus == 'Hadir'
                                          ? Colors.green
                                          : Colors.orangeAccent,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 30),

                              // Tombol Hadir
                              SizedBox(
                                width: double.infinity,
                                height: 50,
                                child: ElevatedButton.icon(
                                  icon: const Icon(Icons.login,
                                      color: Colors.white),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: hasSubmittedToday
                                        ? Colors.grey
                                        : !locationProvider.isWithinOfficeRadius
                                            ? Colors.grey
                                            : Colors.green,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  onPressed: (hasSubmittedToday ||
                                          !locationProvider.isWithinOfficeRadius)
                                      ? null
                                      : () => _showHadirDialog(context, auth.userId,
                                          auth.userName, locationProvider),
                                  label: Text(
                                    hasSubmittedToday
                                        ? 'Sudah Absen Hari Ini'
                                        : !locationProvider.isWithinOfficeRadius
                                            ? 'Hadir (Di Luar Kantor)'
                                            : 'Hadir',
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 15),

                              // Tombol Ijin
                              SizedBox(
                                width: double.infinity,
                                height: 50,
                                child: ElevatedButton.icon(
                                  icon: const Icon(Icons.access_time_filled,
                                      color: Colors.white),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: hasSubmittedToday
                                        ? Colors.grey
                                        : Colors.orangeAccent,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  onPressed: hasSubmittedToday
                                      ? null
                                      : () => _showIjinDialog(context, auth.userId,
                                          auth.userName),
                                  label: Text(
                                    hasSubmittedToday
                                        ? 'Sudah Absen Hari Ini'
                                        : 'Ajukan Ijin',
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),

                              if (scheduleProvider.errorMessage != null)
                                Padding(
                                  padding: const EdgeInsets.only(top: 16.0),
                                  child: Text(
                                    scheduleProvider.errorMessage!,
                                    style: const TextStyle(
                                      color: Colors.redAccent,
                                      fontSize: 12,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),

                              if (locationProvider.locationError != null)
                                Padding(
                                  padding: const EdgeInsets.only(top: 12.0),
                                  child: Text(
                                    locationProvider.locationError!,
                                    style: const TextStyle(
                                      color: Colors.redAccent,
                                      fontSize: 12,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 30),

                      if (!userDataComplete)
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.red[100],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.redAccent),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.error_outline, color: Colors.red[700]),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Data pengguna tidak lengkap. Silakan login kembali.',
                                  style: TextStyle(
                                    color: Colors.red[700],
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                      const Spacer(),

                      const Text(
                        '© 2025 AttendEase - Sistem Presensi trustmedis',
                        style: TextStyle(color: Colors.black54, fontSize: 12),
                      ),

                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showHadirDialog(BuildContext context, String? userId, String? userName,
      LocationProvider locationProvider) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF4CAF50), Color(0xFF45a049)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(28.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.9),
                    ),
                    padding: const EdgeInsets.all(16),
                    child: const Icon(
                      Icons.check_circle,
                      color: Color(0xFF4CAF50),
                      size: 56,
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  const Text(
                    'Kehadiran Dicatat',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  
                  const Text(
                    'Anda telah berhasil mencatat kehadiran',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white70,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                        width: 1.5,
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.info_outline,
                              color: Colors.white,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              'Keterangan',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white70,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Karyawan bekerja hari ini',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on,
                              color: Colors.white,
                              size: 16,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Lokasi: ${(locationProvider.distanceFromOffice! / 1000).toStringAsFixed(2)} km dari kantor',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.white70,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),
                  
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF4CAF50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 8,
                      ),
                      onPressed: () async {
                        Navigator.pop(context);
                        await _submitAttendance(
                          context,
                          'Hadir',
                          userId,
                          userName,
                          'Karyawan bekerja hari ini',
                          locationProvider,
                        );
                      },
                      child: const Text(
                        'Konfirmasi Kehadiran',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(
                          color: Colors.white,
                          width: 2,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        'Batal',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showIjinDialog(BuildContext context, String? userId, String? userName) {
    final TextEditingController keteranganController = TextEditingController();
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFF9800), Color(0xFFFB8C00)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(28.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.9),
                    ),
                    padding: const EdgeInsets.all(16),
                    child: const Icon(
                      Icons.description_outlined,
                      color: Color(0xFFFF9800),
                      size: 56,
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  const Text(
                    'Ajukan Izin',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  
                  const Text(
                    'Jelaskan alasan atau keterangan izin Anda',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white70,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                        width: 1.5,
                      ),
                    ),
                    child: TextField(
                      controller: keteranganController,
                      minLines: 3,
                      maxLines: 5,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Contoh: Sakit, Keperluan Keluarga, Libur...',
                        hintStyle: TextStyle(
                          color: Colors.white.withOpacity(0.6),
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.all(16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFFFF9800),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 8,
                      ),
                      onPressed: () {
                        if (keteranganController.text.trim().isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Masukkan keterangan izin terlebih dahulu!'),
                              backgroundColor: Colors.redAccent,
                              duration: Duration(seconds: 2),
                            ),
                          );
                          return;
                        }
                        Navigator.pop(context);
                        _submitAttendance(
                          context,
                          'Ijin',
                          userId,
                          userName,
                          keteranganController.text.trim(),
                          null,
                        );
                      },
                      child: const Text(
                        'Ajukan Izin',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(
                          color: Colors.white,
                          width: 2,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        'Batal',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _submitAttendance(
    BuildContext context,
    String status,
    String? userId,
    String? userName,
    String keterangan,
    LocationProvider? locationProvider,
  ) async {
    if (userId == null || userName == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Data pengguna tidak lengkap! Silakan login kembali.'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    final scheduleProvider =
        Provider.of<ScheduleProvider>(context, listen: false);

    final success = await scheduleProvider.submitAttendance(
      userId: userId,
      userName: userName,
      status: status,
      keterangan: keterangan,
      latitude: locationProvider?.currentPosition?.latitude,
      longitude: locationProvider?.currentPosition?.longitude,
      distance: locationProvider?.distanceFromOffice,
    );

    if (success) {
      String message = status == 'Hadir'
          ? 'Absen masuk berhasil! Karyawan bekerja hari ini.'
          : 'Pengajuan izin berhasil!';
      
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Row(
              children: [
                Icon(
                  status == 'Hadir' ? Icons.check_circle : Icons.check,
                  color: status == 'Hadir' ? Colors.green : Colors.orangeAccent,
                  size: 28,
                ),
                const SizedBox(width: 8),
                const Text('Berhasil'),
              ],
            ),
            content: Text(message),
            actions: [
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
      
      Provider.of<ScheduleProvider>(context, listen: false)
          .checkAttendanceStatus(userId);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(scheduleProvider.errorMessage ?? 'Gagal menyimpan absensi!'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }
}