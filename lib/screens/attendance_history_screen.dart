import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/attendance_history_provider.dart';

class AttendanceHistoryScreen extends StatefulWidget {
  const AttendanceHistoryScreen({super.key});

  @override
  State<AttendanceHistoryScreen> createState() =>
      _AttendanceHistoryScreenState();
}

class _AttendanceHistoryScreenState extends State<AttendanceHistoryScreen> {
  String _formatMonthYear(String monthYear) {
    try {
      final parts = monthYear.split('-');
      final year = int.parse(parts[0]);
      final month = int.parse(parts[1]);
      final date = DateTime(year, month);
      return DateFormat('MMMM yyyy').format(date);
    } catch (e) {
      return monthYear;
    }
  }

  String _getMonthName(int month) {
    const months = ['Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'];
    return months[month - 1];
  }

  String _getDayName(int day) {
    const days = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'];
    return days[day % 7];
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadHistory();
    });
  }

  void _loadHistory() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final historyProvider =
        Provider.of<AttendanceHistoryProvider>(context, listen: false);

    if (authProvider.userId != null) {
      historyProvider.fetchAttendanceHistory(authProvider.userId!);
    }
  }

  Widget _buildStatCard(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection(AttendanceHistoryProvider historyProvider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Tahun',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    DropdownButton<int>(
                      isExpanded: true,
                      value: historyProvider.selectedYear,
                      hint: const Text('Pilih Tahun'),
                      items: [
                        const DropdownMenuItem<int>(
                          value: null,
                          child: Text('Semua Tahun'),
                        ),
                        ...historyProvider.availableYears.map((year) {
                          return DropdownMenuItem<int>(
                            value: year,
                            child: Text(year.toString()),
                          );
                        }).toList(),
                      ],
                      onChanged: (value) {
                        historyProvider.setFilterYear(value);
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Bulan',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    DropdownButton<int>(
                      isExpanded: true,
                      value: historyProvider.selectedMonth,
                      hint: const Text('Pilih Bulan'),
                      items: [
                        const DropdownMenuItem<int>(
                          value: null,
                          child: Text('Semua Bulan'),
                        ),
                        ...historyProvider.availableMonths.map((month) {
                          final monthName = _getMonthName(month);
                          return DropdownMenuItem<int>(
                            value: month,
                            child: Text(monthName),
                          );
                        }).toList(),
                      ],
                      onChanged: (value) {
                        historyProvider.setFilterMonth(value);
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: ElevatedButton.icon(
                  onPressed: () {
                    historyProvider.resetFilters();
                  },
                  icon: const Icon(Icons.refresh, size: 18),
                  label: const Text('Reset'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[300],
                    foregroundColor: Colors.grey[700],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final historyProvider = Provider.of<AttendanceHistoryProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Riwayat Absensi',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
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
        child: historyProvider.isLoading
            ? const Center(child: CircularProgressIndicator())
            : historyProvider.attendanceHistory.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.inbox_outlined,
                            size: 64, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text(
                          'Belum ada riwayat absensi',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  )
                : Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        _buildFilterSection(historyProvider),
                        const SizedBox(height: 16),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 20),
                          child: Row(
                            children: [
                              Expanded(
                                child: _buildStatCard(
                                  'Total Hari',
                                  historyProvider.filteredAttendance.length
                                      .toString(),
                                  Color(0xFF2196F3),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildStatCard(
                                  'Hadir',
                                  historyProvider.filteredAttendance
                                      .where((d) =>
                                          d['status']?.toLowerCase() ==
                                          'hadir')
                                      .length
                                      .toString(),
                                  Color(0xFF2BB673),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildStatCard(
                                  'Ijin',
                                  historyProvider.filteredAttendance
                                      .where((d) =>
                                          d['status']?.toLowerCase() == 'ijin')
                                      .length
                                      .toString(),
                                  Color(0xFFf59e0b),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: historyProvider.filteredAttendance.isEmpty
                              ? Center(
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.search_off,
                                          size: 64,
                                          color: Colors.grey[400]),
                                      const SizedBox(height: 16),
                                      Text(
                                        'Tidak ada data untuk filter ini',
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : ListView.builder(
                                  physics: const BouncingScrollPhysics(),
                                  itemCount:
                                      historyProvider.filteredAttendance.length,
                                  itemBuilder: (context, index) {
                                    final data = historyProvider
                                        .filteredAttendance[index];
                                    final tanggal = data['tanggal'] as String?;
                                    final status =
                                        data['status'] as String? ?? '-';
                                    final keterangan =
                                        data['keterangan'] as String?;

                                    DateTime? parsedDate;
                                    String displayDate =
                                        tanggal ?? 'Tanggal tidak tersedia';
                                    if (tanggal != null) {
                                      try {
                                        parsedDate = DateTime.parse(tanggal);
                                        final dayName = _getDayName(parsedDate.weekday);
                                        final monthName = _getMonthName(parsedDate.month);
                                        displayDate = '$dayName, ${parsedDate.day} $monthName ${parsedDate.year}';
                                      } catch (e) {
                                        displayDate = tanggal;
                                      }
                                    }

                                    Color statusColor = Colors.grey;
                                    IconData statusIcon = Icons.help_outline;
                                    if (status.toLowerCase() == 'hadir') {
                                      statusColor = const Color(0xFF2BB673);
                                      statusIcon = Icons.check_circle_outline;
                                    } else if (status.toLowerCase() == 'ijin') {
                                      statusColor = const Color(0xFFf59e0b);
                                      statusIcon = Icons.event_note_outlined;
                                    }

                                    return Card(
                                      margin: const EdgeInsets.only(bottom: 12),
                                      elevation: 4,
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(16),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(16),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        displayDate,
                                                        style: const TextStyle(
                                                          fontSize: 16,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color:
                                                              Color(0xFF0f172a),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                Container(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 12,
                                                      vertical: 6),
                                                  decoration: BoxDecoration(
                                                    color: statusColor
                                                        .withOpacity(0.15),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            12),
                                                  ),
                                                  child: Row(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      Icon(statusIcon,
                                                          size: 16,
                                                          color: statusColor),
                                                      const SizedBox(width: 6),
                                                      Text(
                                                        status,
                                                        style: TextStyle(
                                                          color: statusColor,
                                                          fontWeight:
                                                              FontWeight.w700,
                                                          fontSize: 12,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                            if (keterangan != null &&
                                                keterangan.isNotEmpty)
                                              Padding(
                                                padding:
                                                    const EdgeInsets.only(
                                                        top: 12),
                                                child: Container(
                                                  width: double.infinity,
                                                  padding:
                                                      const EdgeInsets.all(12),
                                                  decoration: BoxDecoration(
                                                    color: Colors.grey[100],
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
                                                  ),
                                                  child: Text(
                                                    'Keterangan: $keterangan',
                                                    style: TextStyle(
                                                      fontSize: 13,
                                                      color: Colors.grey[700],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                        ),
                        const SizedBox(height: 20),
                        if (historyProvider.errorMessage != null)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 10.0),
                            child: Text(
                              historyProvider.errorMessage!,
                              style: const TextStyle(
                                color: Colors.redAccent,
                                fontSize: 12,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        const Text(
                          '© 2025 AttendEase - Sistem Absensi Digital',
                          style: TextStyle(
                              color: Colors.black54, fontSize: 12),
                        ),
                        const SizedBox(height: 10),
                      ],
                    ),
                  ),
      ),
    );
  }
}
