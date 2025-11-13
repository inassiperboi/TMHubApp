import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/attendance_history_provider.dart';

class AttendanceHistoryScreen extends StatefulWidget {
  const AttendanceHistoryScreen({super.key});

  @override
  State<AttendanceHistoryScreen> createState() =>
      _AttendanceHistoryScreenState();
}

class _AttendanceHistoryScreenState extends State<AttendanceHistoryScreen> {
  String? _selectedMonth;
  String? _selectedYear;
  List<String> _availableMonths = [];
  List<String> _availableYears = [];

  @override
  void initState() {
    super.initState();
    _loadAttendance();
  }

  Future<void> _loadAttendance() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');
    if (userId != null) {
      await Provider.of<AttendanceHistoryProvider>(context, listen: false)
          .fetchAttendanceHistory(userId);
      _updateAvailableFilters();
    }
  }

  void _updateAvailableFilters() {
    final provider = Provider.of<AttendanceHistoryProvider>(context, listen: false);
    final Set<String> months = {};
    final Set<String> years = {};

    for (var record in provider.filteredAttendance) {
      final tanggal = DateTime.parse(record['tanggal']);
      months.add(_monthName(tanggal.month));
      years.add(tanggal.year.toString());
    }

    setState(() {
      _availableMonths = months.toList()..sort((a, b) => _monthNumber(a).compareTo(_monthNumber(b)));
      _availableYears = years.toList()..sort((a, b) => b.compareTo(a));
    });
  }

  List<Map<String, dynamic>> _getFilteredRecords(List<Map<String, dynamic>> records) {
    if (_selectedMonth == null && _selectedYear == null) {
      return records;
    }

    return records.where((record) {
      final tanggal = DateTime.parse(record['tanggal']);
      final monthMatch = _selectedMonth == null || _monthName(tanggal.month) == _selectedMonth;
      final yearMatch = _selectedYear == null || tanggal.year.toString() == _selectedYear;
      return monthMatch && yearMatch;
    }).toList();
  }

  Map<String, List<Map<String, dynamic>>> _groupByMonthYear(
      List<Map<String, dynamic>> records) {
    final grouped = <String, List<Map<String, dynamic>>>{};
    for (var record in records) {
      final tanggal = DateTime.parse(record['tanggal']);
      final key =
          '${_monthName(tanggal.month)} ${tanggal.year.toString()}';
      grouped.putIfAbsent(key, () => []).add(record);
    }

    // Urut dari terbaru ke lama
    final sortedKeys = grouped.keys.toList()
      ..sort((a, b) {
        final partsA = a.split(' ');
        final partsB = b.split(' ');
        final yearA = int.parse(partsA[1]);
        final yearB = int.parse(partsB[1]);
        final monthA = _monthNumber(partsA[0]);
        final monthB = _monthNumber(partsB[0]);
        if (yearA != yearB) return yearB.compareTo(yearA);
        return monthB.compareTo(monthA);
      });

    return {for (var key in sortedKeys) key: grouped[key]!};
  }

  static int _monthNumber(String monthName) {
    const months = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember'
    ];
    return months.indexOf(monthName) + 1;
  }

  static String _monthName(int month) {
    const months = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember'
    ];
    return months[month - 1];
  }

  void _resetFilter() {
    setState(() {
      _selectedMonth = null;
      _selectedYear = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E4471),  // #1E4471 - Biru tua
        title: const Text(
          "Riwayat Absensi",
          style: TextStyle(
            color: Colors.white,  // #FFFFFF - Putih
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final screenWidth = constraints.maxWidth;
          final screenHeight = constraints.maxHeight;
          final isSmallScreen = screenWidth < 600; // Misalnya, tablet atau lebih besar

          // Responsif padding dan ukuran
          final horizontalPadding = screenWidth * 0.05; // 5% dari lebar layar
          final verticalPadding = 16.0;
          final fontSizeTitle = screenWidth * 0.04; // 4% dari lebar layar
          final fontSizeSubtitle = screenWidth * 0.035;
          final iconSize = screenWidth * 0.06;

          return Container(
            width: double.infinity,
            height: double.infinity, // Pastikan fullscreen
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFE3F2FD), Color(0xFFBBDEFB)],  // #E3F2FD ke #BBDEFB
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: SafeArea(
              child: RefreshIndicator(
                onRefresh: _loadAttendance,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: verticalPadding),
                  child: Consumer<AttendanceHistoryProvider>(
                    builder: (context, provider, _) {
                      if (provider.isLoading) {
                        return SizedBox(
                          height: screenHeight * 0.8, // Responsif tinggi
                          child: const Center(child: CircularProgressIndicator()),
                        );
                      }

                      final filteredRecords = _getFilteredRecords(provider.filteredAttendance);
                      final groupedData = _groupByMonthYear(filteredRecords);

                      int hadirCount = 0;
                      int izinCount = 0;
                      int tidakHadirCount = 0;

                      for (var record in filteredRecords) {
                        final status = record['status']?.toString().toLowerCase() ?? '';
                        if (status.contains('hadir telah disetujui')) {
                          hadirCount++;
                        } else if (status.contains('ijin disetujui')) {
                          izinCount++;
                        } else if (status.contains('hadir tidak disetujui') ||
                            status.contains('ijin ditolak')) {
                          tidakHadirCount++;
                        }
                      }

                      return Column(
                        children: [
                          // Filter Section
                          Container(
                            padding: EdgeInsets.all(screenWidth * 0.03), // Responsif padding
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.2),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.filter_list, color: const Color(0xFF1E4471), size: iconSize),
                                    SizedBox(width: screenWidth * 0.02),
                                    Text(
                                      "Filter",
                                      style: TextStyle(
                                        fontSize: fontSizeTitle,
                                        fontWeight: FontWeight.bold,
                                        color: const Color(0xFF1E4471),
                                      ),
                                    ),
                                    const Spacer(),
                                    if (_selectedMonth != null || _selectedYear != null)
                                      TextButton(
                                        onPressed: _resetFilter,
                                        child: Text(
                                          "Reset",
                                          style: TextStyle(color: const Color(0xFF1E4471), fontSize: fontSizeSubtitle),
                                        ),
                                      ),
                                  ],
                                ),
                                SizedBox(height: screenHeight * 0.02),
                                Row(
                                  children: [
                                    // Filter Bulan
                                    Expanded(
                                      child: Container(
                                        padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.03),
                                        decoration: BoxDecoration(
                                          border: Border.all(color: Colors.grey[300]!),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: DropdownButtonHideUnderline(
                                          child: DropdownButton<String>(
                                            isExpanded: true,
                                            value: _selectedMonth,
                                            hint: Text("Pilih Bulan", style: TextStyle(fontSize: fontSizeSubtitle)),
                                            items: [
                                              const DropdownMenuItem(
                                                value: null,
                                                child: Text("Semua Bulan"),
                                              ),
                                              ..._availableMonths.map((month) {
                                                return DropdownMenuItem(
                                                  value: month,
                                                  child: Text(month, style: TextStyle(fontSize: fontSizeSubtitle)),
                                                );
                                              }).toList(),
                                            ],
                                            onChanged: (value) {
                                              setState(() {
                                                _selectedMonth = value;
                                              });
                                            },
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: screenWidth * 0.03),
                                    // Filter Tahun
                                    Expanded(
                                      child: Container(
                                        padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.03),
                                        decoration: BoxDecoration(
                                          border: Border.all(color: Colors.grey[300]!),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: DropdownButtonHideUnderline(
                                          child: DropdownButton<String>(
                                            isExpanded: true,
                                            value: _selectedYear,
                                            hint: Text("Pilih Tahun", style: TextStyle(fontSize: fontSizeSubtitle)),
                                            items: [
                                              const DropdownMenuItem(
                                                value: null,
                                                child: Text("Semua Tahun"),
                                              ),
                                              ..._availableYears.map((year) {
                                                return DropdownMenuItem(
                                                  value: year,
                                                  child: Text(year, style: TextStyle(fontSize: fontSizeSubtitle)),
                                                );
                                              }).toList(),
                                            ],
                                            onChanged: (value) {
                                              setState(() {
                                                _selectedYear = value;
                                              });
                                            },
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: screenHeight * 0.02),

                          // Statistik
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _buildStatCard("Hadir", hadirCount, const Color(0xFF2AB77A), screenWidth, screenHeight),
                              _buildStatCard("Izin", izinCount, const Color(0xFFFFE16A), screenWidth, screenHeight),
                              _buildStatCard("Tidak Hadir", tidakHadirCount, const Color(0xFFEB5757), screenWidth, screenHeight),
                            ],
                          ),
                          SizedBox(height: screenHeight * 0.02),

                          // List data
                          if (groupedData.isEmpty)
                            SizedBox(
                              height: screenHeight * 0.4,
                              child: Center(
                                child: Padding(
                                  padding: EdgeInsets.all(screenWidth * 0.08),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.search_off,
                                        size: iconSize * 1.5,
                                        color: Colors.grey[400],
                                      ),
                                      SizedBox(height: screenHeight * 0.02),
                                      Text(
                                        "Tidak ada data",
                                        style: TextStyle(
                                          fontSize: fontSizeTitle,
                                          color: Colors.black54,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            )
                          else
                            for (var entry in groupedData.entries)
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    entry.key,
                                    style: TextStyle(
                                      fontSize: fontSizeTitle,
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xFF1E4471),
                                    ),
                                  ),
                                  SizedBox(height: screenHeight * 0.01),
                                  Column(
                                    children: entry.value.map((record) {
                                      final status = record['status']?.toString() ?? '';
                                      final keterangan = record['keterangan']?.toString() ?? 'Karyawan bekerja hari ini';
                                      
                                      Color iconColor;
                                      IconData icon;
                                      Color statusTextColor;
                                      
                                      if (status.toLowerCase().contains('hadir telah disetujui')) {
                                        iconColor = const Color(0xFF2AB77A);
                                        icon = Icons.check_circle;
                                        statusTextColor = const Color(0xFF2AB77A);
                                      } else if (status.toLowerCase().contains('ijin disetujui')) {
                                        iconColor = const Color(0xFFFFA500);
                                        icon = Icons.event_note;
                                        statusTextColor = const Color(0xFFFFA500);
                                      } else {
                                        iconColor = const Color(0xFFEB5757);
                                        icon = Icons.cancel;
                                        statusTextColor = const Color(0xFFEB5757);
                                      }

                                      return Container(
                                        margin: EdgeInsets.only(bottom: screenHeight * 0.015),
                                        padding: EdgeInsets.all(screenWidth * 0.035),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(12),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.blueAccent.withOpacity(0.1),
                                              blurRadius: 6,
                                              spreadRadius: 1,
                                              offset: const Offset(0, 3),
                                            ),
                                          ],
                                        ),
                                        child: Row(
                                          children: [
                                            Container(
                                              padding: EdgeInsets.all(screenWidth * 0.02),
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              child: Icon(
                                                icon,
                                                color: iconColor,
                                                size: iconSize,
                                              ),
                                            ),
                                            SizedBox(width: screenWidth * 0.03),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    record['tanggal'],
                                                    style: TextStyle(
                                                      fontSize: fontSizeSubtitle,
                                                      fontWeight: FontWeight.bold,
                                                      color: Colors.black87,
                                                    ),
                                                  ),
                                                  SizedBox(height: screenHeight * 0.005),
                                                  Text(
                                                    'Keterangan: $keterangan',
                                                    style: TextStyle(
                                                      color: Colors.grey[700],
                                                      fontSize: fontSizeSubtitle * 0.9,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            SizedBox(width: screenWidth * 0.02),
                                            Text(
                                              status,
                                              style: TextStyle(
                                                color: statusTextColor,
                                                fontSize: fontSizeSubtitle * 0.9,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                  SizedBox(height: screenHeight * 0.03),
                                ],
                              ),
                          
                          // Footer
                          SizedBox(height: screenHeight * 0.04),
                          Center(
                            child: Text(
                              '© 2025 AttendEase - Sistem Presensi trustmedis',
                              style: TextStyle(color: Colors.black54, fontSize: fontSizeSubtitle * 0.8),
                            ),
                          ),
                          SizedBox(height: screenHeight * 0.02),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatCard(String title, int count, Color color, double screenWidth, double screenHeight) {
    return Expanded(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.01),
        padding: EdgeInsets.all(screenWidth * 0.03),
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(
              count.toString(),
              style: TextStyle(
                fontSize: screenWidth * 0.05, // Responsif ukuran angka
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            SizedBox(height: screenHeight * 0.005),
            Text(
              title,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w500,
                fontSize: screenWidth * 0.035,
              ),
            ),
          ],
        ),
      ),
    );
  }
}