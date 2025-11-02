import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/attendance_history_provider.dart';

class AttendanceMonthDetailScreen extends StatefulWidget {
  final String monthYear;

  const AttendanceMonthDetailScreen({
    super.key,
    required this.monthYear,
  });

  @override
  State<AttendanceMonthDetailScreen> createState() =>
      _AttendanceMonthDetailScreenState();
}

class _AttendanceMonthDetailScreenState
    extends State<AttendanceMonthDetailScreen> {
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
    final monthDetails =
        historyProvider.groupedAttendanceByMonth[widget.monthYear] ?? [];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _formatMonthYear(widget.monthYear),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFE3F2FD), Color(0xFFBBDEFB)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: monthDetails.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.calendar_today_outlined,
                        size: 64, color: Colors.grey[400]),
                    const SizedBox(height: 16),
                    Text(
                      'Tidak ada absensi di bulan ini',
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
                    Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: Row(
                        children: [
                          Expanded(
                            child: _buildStatCard(
                              'Total Hari',
                              monthDetails.length.toString(),
                              Color(0xFF2196F3),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildStatCard(
                              'Hadir',
                              monthDetails
                                  .where((d) =>
                                      d['status']?.toLowerCase() == 'hadir')
                                  .length
                                  .toString(),
                              Color(0xFF2BB673),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildStatCard(
                              'Ijin',
                              monthDetails
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
                      child: ListView.builder(
                        physics: const BouncingScrollPhysics(),
                        itemCount: monthDetails.length,
                        itemBuilder: (context, index) {
                          final data = monthDetails[index];
                          final tanggal = data['tanggal'] as String?;
                          final status = data['status'] as String? ?? '-';
                          final keterangan = data['keterangan'] as String?;

                          DateTime? parsedDate;
                          String displayDate =
                              tanggal ?? 'Tanggal tidak tersedia';
                          if (tanggal != null) {
                            try {
                              parsedDate = DateTime.parse(tanggal);
                              displayDate = DateFormat(
                                      'EEEE, dd MMM yyyy', 'id_ID')
                                  .format(parsedDate);
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
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              displayDate,
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: Color(0xFF0f172a),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 12, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: statusColor.withOpacity(0.15),
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(statusIcon,
                                                size: 16, color: statusColor),
                                            const SizedBox(width: 6),
                                            Text(
                                              status,
                                              style: TextStyle(
                                                color: statusColor,
                                                fontWeight: FontWeight.w700,
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
                                      padding: const EdgeInsets.only(top: 12),
                                      child: Container(
                                        width: double.infinity,
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: Colors.grey[100],
                                          borderRadius:
                                              BorderRadius.circular(8),
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
                  ],
                ),
              ),
      ),
    );
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
}
