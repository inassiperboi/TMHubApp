import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/attendance_history_provider.dart';
import 'attendance_month_detail_screen.dart';

class AttendanceHistoryScreen extends StatefulWidget {
  const AttendanceHistoryScreen({super.key});

  @override
  State<AttendanceHistoryScreen> createState() =>
      _AttendanceHistoryScreenState();
}

class _AttendanceHistoryScreenState extends State<AttendanceHistoryScreen> {
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

  String _formatMonthYear(String monthYear) {
    try {
      final parts = monthYear.split('-');
      final year = int.parse(parts[0]);
      final month = int.parse(parts[1]);
      final date = DateTime(year, month);
      return DateFormat('MMMM yyyy', 'id_ID').format(date);
    } catch (e) {
      return monthYear;
    }
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
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        const SizedBox(height: 10),
                        Expanded(
                          child: GridView.builder(
                            physics: const BouncingScrollPhysics(),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                              childAspectRatio: 1.1,
                            ),
                            itemCount: historyProvider.sortedMonths.length,
                            itemBuilder: (context, index) {
                              final monthYear =
                                  historyProvider.sortedMonths[index];
                              final recordCount = historyProvider
                                      .groupedAttendanceByMonth[monthYear]
                                      ?.length ??
                                  0;

                              return GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          AttendanceMonthDetailScreen(
                                        monthYear: monthYear,
                                      ),
                                    ),
                                  );
                                },
                                child: Card(
                                  elevation: 8,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20),
                                      gradient: LinearGradient(
                                        colors: [
                                          Color(0xFF2196F3).withOpacity(0.8),
                                          Color(0xFF1976D2).withOpacity(0.9),
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(20),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.calendar_month,
                                            size: 40,
                                            color: Colors.white,
                                          ),
                                          const SizedBox(height: 12),
                                          Text(
                                            _formatMonthYear(monthYear),
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                          const SizedBox(height: 8),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 6,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.white30,
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child: Text(
                                              '$recordCount hari',
                                              style: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
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
