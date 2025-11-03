import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/notification_provider.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final notificationProvider =
          Provider.of<NotificationProvider>(context, listen: false);
      notificationProvider.initializeNotificationListener();
      notificationProvider.fetchTodayNotifications();
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width > 600;
    final isSmallPhone = screenSize.width < 350;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Notifikasi',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: isTablet ? 24 : 20,
          ),
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
        child: Consumer<NotificationProvider>(
          builder: (context, notificationProvider, _) {
            if (notificationProvider.newScheduleNotifications.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.notifications_off_outlined,
                      size: isTablet ? 100 : 80,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Tidak ada notifikasi',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: isTablet ? 20 : 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: isTablet ? 10 : 5),
                    Text(
                      'Notifikasi jadwal baru akan muncul di sini',
                      style: TextStyle(
                        color: Colors.grey[500],
                        fontSize: isTablet ? 16 : 14,
                      ),
                    ),
                  ],
                ),
              );
            }

            return Column(
              children: [
                // Header with badge count
                Container(
                  padding: EdgeInsets.all(isTablet ? 20 : 16),
                  color: Colors.white.withOpacity(0.7),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(isTablet ? 12 : 10),
                            decoration: BoxDecoration(
                              color: Colors.blueAccent.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.notifications_active,
                              color: Colors.blueAccent,
                              size: isTablet ? 28 : 24,
                            ),
                          ),
                          SizedBox(width: isTablet ? 15 : 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Jadwal Baru',
                                style: TextStyle(
                                  fontSize: isTablet ? 18 : 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blueAccent,
                                ),
                              ),
                              Text(
                                '${notificationProvider.notificationCount} notifikasi',
                                style: TextStyle(
                                  fontSize: isTablet ? 14 : 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      if (notificationProvider.hasNotifications)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.redAccent,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            notificationProvider.notificationCount.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                // Notification list
                Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.all(isTablet ? 20 : 16),
                    itemCount:
                        notificationProvider.newScheduleNotifications.length,
                    itemBuilder: (context, index) {
                      final notification =
                          notificationProvider.newScheduleNotifications[index];
                      final isRead = notification['isRead'] ?? false;

                      return Container(
                        margin: EdgeInsets.only(bottom: isTablet ? 16 : 12),
                        decoration: BoxDecoration(
                          color: isRead
                              ? Colors.white.withOpacity(0.8)
                              : Colors.white,
                          border: Border.all(
                            color: isRead
                                ? Colors.grey[300]!
                                : Colors.blueAccent,
                            width: isRead ? 1 : 2,
                          ),
                          borderRadius: BorderRadius.circular(
                            isTablet ? 20 : 16,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(isTablet ? 20 : 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Top row: icon and title
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: EdgeInsets.all(isTablet ? 12 : 10),
                                    decoration: BoxDecoration(
                                      color: Colors.greenAccent.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(
                                      Icons.calendar_today_outlined,
                                      color: Colors.green[700],
                                      size: isTablet ? 24 : 20,
                                    ),
                                  ),
                                  SizedBox(width: isTablet ? 15 : 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Jadwal Baru',
                                          style: TextStyle(
                                            fontWeight: isRead
                                                ? FontWeight.normal
                                                : FontWeight.bold,
                                            fontSize: isTablet ? 18 : 16,
                                            color: isRead
                                                ? Colors.black87
                                                : Colors.blueAccent,
                                          ),
                                        ),
                                        SizedBox(
                                            height: isTablet ? 6 : 4),
                                        Text(
                                          'Admin telah membuat jadwal baru',
                                          style: TextStyle(
                                            fontSize: isTablet ? 14 : 12,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: isTablet ? 16 : 12),

                              // Schedule details
                              Container(
                                padding: EdgeInsets.all(isTablet ? 16 : 12),
                                decoration: BoxDecoration(
                                  color: Colors.blue[50],
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Colors.blueAccent.withOpacity(0.2),
                                    width: 1,
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildDetailRow(
                                      context,
                                      Icons.calendar_month_outlined,
                                      'Tanggal',
                                      notification['tanggal'] ?? '-',
                                      isTablet,
                                    ),
                                    SizedBox(height: isTablet ? 12 : 8),
                                    _buildDetailRow(
                                      context,
                                      Icons.today_outlined,
                                      'Hari',
                                      notification['nama_hari'] ?? '-',
                                      isTablet,
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: isTablet ? 16 : 12),

                              // Time and actions
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    _formatTime(
                                        notification['notificationTime']),
                                    style: TextStyle(
                                      fontSize: isTablet ? 13 : 12,
                                      color: Colors.grey[500],
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      if (!isRead)
                                        ElevatedButton.icon(
                                          onPressed: () {
                                            notificationProvider
                                                .markAsRead(index);
                                          },
                                          icon: const Icon(Icons.done, size: 16),
                                          label: Text(
                                            'Tandai dibaca',
                                            style: TextStyle(
                                              fontSize: isTablet ? 12 : 11,
                                            ),
                                          ),
                                          style:
                                              ElevatedButton.styleFrom(
                                            backgroundColor: Colors.blueAccent,
                                            foregroundColor: Colors.white,
                                            padding: EdgeInsets.symmetric(
                                              horizontal: isTablet ? 12 : 8,
                                              vertical: isTablet ? 8 : 6,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                          ),
                                        ),
                                      SizedBox(width: isTablet ? 12 : 8),
                                      ElevatedButton.icon(
                                        onPressed: () {
                                          notificationProvider
                                              .removeNotification(index);
                                        },
                                        icon: const Icon(Icons.delete, size: 16),
                                        label: Text(
                                          'Hapus',
                                          style: TextStyle(
                                            fontSize: isTablet ? 12 : 11,
                                          ),
                                        ),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.red[400],
                                          foregroundColor: Colors.white,
                                          padding: EdgeInsets.symmetric(
                                            horizontal: isTablet ? 12 : 8,
                                            vertical: isTablet ? 8 : 6,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // Clear all button
                if (notificationProvider.hasNotifications)
                  Container(
                    padding: EdgeInsets.all(isTablet ? 20 : 16),
                    child: SizedBox(
                      width: double.infinity,
                      height: isTablet ? 56 : 48,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.clear_all),
                        onPressed: () {
                          notificationProvider.clearAllNotifications();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Semua notifikasi telah dihapus',
                                style:
                                    TextStyle(fontSize: isTablet ? 14 : 12),
                              ),
                              backgroundColor: Colors.blueAccent,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        label: Text(
                          'Hapus Semua Notifikasi',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: isTablet ? 16 : 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, IconData icon, String label,
      String value, bool isTablet) {
    return Row(
      children: [
        Icon(
          icon,
          size: isTablet ? 18 : 16,
          color: Colors.blueAccent,
        ),
        SizedBox(width: isTablet ? 12 : 8),
        Text(
          '$label:',
          style: TextStyle(
            fontSize: isTablet ? 14 : 12,
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
        SizedBox(width: isTablet ? 12 : 8),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: isTablet ? 14 : 12,
              fontWeight: FontWeight.w500,
              color: Colors.blueAccent,
            ),
          ),
        ),
      ],
    );
  }

  String _formatTime(DateTime? dateTime) {
    if (dateTime == null) return '-';
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Baru saja';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} menit lalu';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} jam lalu';
    } else {
      return '${difference.inDays} hari lalu';
    }
  }
}
