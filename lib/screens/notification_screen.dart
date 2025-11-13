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
      final provider =
          Provider.of<NotificationProvider>(context, listen: false);
      provider.initializeNotificationListener();
      provider.fetchGeneralNotifications();
    });
  }

  @override
  Widget build(BuildContext context) {
    final notificationProvider = Provider.of<NotificationProvider>(context);
    final notifications = notificationProvider.generalNotifications;

    final size = MediaQuery.of(context).size;
    final isTablet = size.width > 600;
    final isSmallPhone = size.width < 350;
    final horizontalPadding = isTablet ? 24.0 : isSmallPhone ? 12.0 : 16.0;
    final verticalPadding = isTablet ? 20.0 : isSmallPhone ? 8.0 : 12.0;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Notifikasi',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: isTablet ? 24 : isSmallPhone ? 18 : 20,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF1E4471),
        foregroundColor: Colors.white,
        elevation: 4,
        shadowColor: Colors.black26,
      ),
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFE3F2FD), Color(0xFFBBDEFB)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: horizontalPadding,
              vertical: verticalPadding,
            ),
            child: notifications.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Belum ada notifikasi',
                          style: TextStyle(
                            fontSize: isTablet ? 20 : isSmallPhone ? 14 : 16,
                            color: Colors.black54,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          '© 2025 AttendEase - Sistem Presensi trustmedis',
                          style: TextStyle(color: Colors.black54, fontSize: 12),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: () async {
                      await notificationProvider.fetchGeneralNotifications();
                    },
                    child: ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      padding: EdgeInsets.only(top: isTablet ? 20 : 12),
                      itemCount: notifications.length + 1, // Tambah 1 untuk footer
                      itemBuilder: (context, index) {
                        if (index == notifications.length) {
                          // Item terakhir: Footer copyright
                          return Padding(
                            padding: EdgeInsets.only(top: isTablet ? 20 : 12, bottom: isTablet ? 20 : 12),
                            child: const Center(
                              child: Text(
                                '© 2025 AttendEase - Sistem Presensi trustmedis',
                                style: TextStyle(color: Colors.black54, fontSize: 12),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          );
                        }
                        final notif = notifications[index];
                        final judul = notif['judul'] ?? 'Tanpa Judul';
                        final keterangan = notif['keterangan'] ?? '-';
                        final createdAt = notif['created_at'] ?? '';

                        return Container(
                          margin: EdgeInsets.only(bottom: isTablet ? 20 : 12),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(
                                isTablet ? 20 : isSmallPhone ? 10 : 14),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.blueAccent.withOpacity(0.1),
                                blurRadius: isTablet ? 10 : 6,
                                spreadRadius: 1,
                                offset: const Offset(0, 3),
                              ),
                            ],
                            gradient: LinearGradient(
                              colors: [
                                Colors.white.withOpacity(0.95),
                                Colors.white.withOpacity(0.85),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(isTablet ? 20 : 14),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  judul,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize:
                                        isTablet ? 20 : isSmallPhone ? 14 : 16,
                                    color: const Color(0xFF1E4471),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  keterangan,
                                  style: TextStyle(
                                    fontSize:
                                        isTablet ? 16 : isSmallPhone ? 12 : 14,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Align(
                                  alignment: Alignment.bottomRight,
                                  child: Text(
                                    createdAt.toString(),
                                    style: TextStyle(
                                      fontSize:
                                          isTablet ? 14 : isSmallPhone ? 10 : 12,
                                      color: Colors.grey[600],
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
          ),
        ),
      ),
    );
  }
}