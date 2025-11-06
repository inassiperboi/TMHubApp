import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final orientation = MediaQuery.of(context).orientation;
    final isLandscape = orientation == Orientation.landscape;
    final isTablet = screenSize.width > 600;
    final isSmallPhone = screenSize.width < 350;
    final isMediumPhone = screenSize.width >= 350 && screenSize.width <= 600;
    
    // Dynamic padding based on screen width
    final horizontalPadding = isSmallPhone ? 12.0 : isMediumPhone ? 16.0 : isTablet ? 24.0 : 20.0;
    final verticalPadding = isSmallPhone ? 8.0 : isMediumPhone ? 10.0 : isTablet ? 16.0 : 12.0;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Profil Saya',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: isTablet ? 24 : isMediumPhone ? 20 : 18,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF1E4471), // #1E4471
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
        child: Consumer<AuthProvider>(
          builder: (context, authProvider, _) {
            return SafeArea(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: horizontalPadding,
                          vertical: verticalPadding,
                        ),
                        child: Column(
                          children: [
                            SizedBox(height: isLandscape ? 8 : (isTablet ? 20 : 10)),

                            _buildProfileAvatar(
                              context: context,
                              authProvider: authProvider,
                              isTablet: isTablet,
                              isSmallPhone: isSmallPhone,
                              isMediumPhone: isMediumPhone,
                              isLandscape: isLandscape,
                            ),

                            SizedBox(height: isLandscape ? 12 : (isTablet ? 25 : 15)),

                            _buildInfoCard(
                              context: context,
                              authProvider: authProvider,
                              isTablet: isTablet,
                              isSmallPhone: isSmallPhone,
                              isMediumPhone: isMediumPhone,
                              isLandscape: isLandscape,
                            ),

                            SizedBox(height: isLandscape ? 12 : (isTablet ? 25 : 20)),

                            _buildLogoutButton(
                              context: context,
                              authProvider: authProvider,
                              isTablet: isTablet,
                              isSmallPhone: isSmallPhone,
                              isMediumPhone: isMediumPhone,
                              isLandscape: isLandscape,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: isTablet ? 15 : 10),
                      child: Text(
                        '© 2025 AttendEase - Sistem Absensi Digital',
                        style: TextStyle(
                          color: Colors.black54,
                          fontSize: isSmallPhone ? 10 : isMediumPhone ? 12 : isTablet ? 14 : 11,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildProfileAvatar({
    required BuildContext context,
    required AuthProvider authProvider,
    required bool isTablet,
    required bool isSmallPhone,
    required bool isMediumPhone,
    required bool isLandscape,
  }) {
    double avatarRadius;
    double containerSize;
    double fontSize;

    if (isSmallPhone) {
      avatarRadius = 45;
      containerSize = 100;
      fontSize = 24;
    } else if (isMediumPhone) {
      avatarRadius = 55;
      containerSize = 120;
      fontSize = 28;
    } else if (isTablet) {
      avatarRadius = 70;
      containerSize = 160;
      fontSize = 40;
    } else {
      avatarRadius = 60;
      containerSize = 130;
      fontSize = 30;
    }

    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.blueAccent.withOpacity(0.3),
            blurRadius: isTablet ? 20 : 15,
            spreadRadius: isTablet ? 4 : 3,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: containerSize,
            height: containerSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  Colors.blueAccent.withOpacity(0.2),
                  Colors.blueAccent.withOpacity(0.1),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          CircleAvatar(
            radius: avatarRadius,
            backgroundColor: Colors.blueAccent,
            child: Text(
              authProvider.userName != null && authProvider.userName!.isNotEmpty
                  ? authProvider.userName![0].toUpperCase()
                  : '-',
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required BuildContext context,
    required AuthProvider authProvider,
    required bool isTablet,
    required bool isSmallPhone,
    required bool isMediumPhone,
    required bool isLandscape,
  }) {
    final borderRadius = isSmallPhone ? 15.0 : isMediumPhone ? 18.0 : isTablet ? 25.0 : 20.0;
    final padding = isSmallPhone ? 16.0 : isMediumPhone ? 18.0 : isTablet ? 25.0 : 20.0;
    final spacing = isSmallPhone ? 8.0 : isMediumPhone ? 10.0 : isTablet ? 14.0 : 10.0;

    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(borderRadius)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(borderRadius),
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
          padding: EdgeInsets.all(padding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(isSmallPhone ? 8 : isMediumPhone ? 10 : isTablet ? 12 : 8),
                    decoration: BoxDecoration(
                      color: Colors.blueAccent.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(isSmallPhone ? 12 : isTablet ? 16 : 12),
                    ),
                    child: Icon(
                      Icons.person_outline_rounded,
                      color: Colors.blueAccent,
                      size: isSmallPhone ? 20 : isMediumPhone ? 22 : isTablet ? 28 : 24,
                    ),
                  ),
                  SizedBox(width: isSmallPhone ? 10 : isMediumPhone ? 12 : isTablet ? 15 : 12),
                  Expanded(
                    child: Text(
                      'Informasi Pribadi',
                      style: TextStyle(
                        fontSize: isSmallPhone ? 16 : isMediumPhone ? 18 : isTablet ? 22 : 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.blueAccent,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              SizedBox(height: isSmallPhone ? 12 : isMediumPhone ? 14 : isTablet ? 20 : 15),

              // Info rows
              _buildInfoRow(
                context: context,
                icon: Icons.person_rounded,
                label: 'Nama',
                value: authProvider.userName ?? '-',
                isSmallPhone: isSmallPhone,
                isMediumPhone: isMediumPhone,
                isTablet: isTablet,
              ),
              SizedBox(height: spacing),
              _buildInfoRow(
                context: context,
                icon: Icons.work_rounded,
                label: 'Jabatan',
                value: authProvider.userPosition ?? '-',
                isSmallPhone: isSmallPhone,
                isMediumPhone: isMediumPhone,
                isTablet: isTablet,
              ),
              SizedBox(height: spacing),
              _buildInfoRow(
                context: context,
                icon: Icons.email_rounded,
                label: 'Email',
                value: authProvider.email ?? '-',
                isSmallPhone: isSmallPhone,
                isMediumPhone: isMediumPhone,
                isTablet: isTablet,
              ),
              SizedBox(height: spacing),
              _buildInfoRow(
                context: context,
                icon: Icons.phone_rounded,
                label: 'No. Telepon',
                value: authProvider.userPhone ?? '-',
                isSmallPhone: isSmallPhone,
                isMediumPhone: isMediumPhone,
                isTablet: isTablet,
              ),
              SizedBox(height: spacing),
              _buildInfoRow(
                context: context,
                icon: Icons.location_on_rounded,
                label: 'Alamat',
                value: authProvider.userAddress ?? '-',
                isSmallPhone: isSmallPhone,
                isMediumPhone: isMediumPhone,
                isTablet: isTablet,
              ),
              SizedBox(height: spacing),
              _buildInfoRow(
                context: context,
                icon: Icons.account_balance_rounded,
                label: 'No. Rekening',
                value: authProvider.userBankAccount ?? '-',
                isSmallPhone: isSmallPhone,
                isMediumPhone: isMediumPhone,
                isTablet: isTablet,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required BuildContext context,
    required IconData icon,
    required String label,
    required String value,
    required bool isSmallPhone,
    required bool isMediumPhone,
    required bool isTablet,
  }) {
    final iconSize = (isSmallPhone ? 14 : isMediumPhone ? 16 : isTablet ? 20 : 18).toDouble();
    final fontSize = (isSmallPhone ? 12 : isMediumPhone ? 13 : isTablet ? 16 : 14).toDouble();
    final containerPadding = isSmallPhone ? 6.0 : isMediumPhone ? 7.0 : isTablet ? 8.0 : 6.0;
    final rowPadding = isSmallPhone ? 8.0 : isMediumPhone ? 10.0 : isTablet ? 12.0 : 8.0;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: rowPadding, vertical: rowPadding * 0.75),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.5),
        borderRadius: BorderRadius.circular(isSmallPhone ? 10 : isMediumPhone ? 11 : isTablet ? 12 : 10),
        border: Border.all(
          color: Colors.blueAccent.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(containerPadding),
            decoration: BoxDecoration(
              color: Colors.blueAccent.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: iconSize, color: Colors.blueAccent),
          ),
          SizedBox(width: isSmallPhone ? 10 : isMediumPhone ? 12 : isTablet ? 15 : 12),
          Expanded(
            flex: 2,
            child: Text(
              '$label:',
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(width: 8),
          Expanded(
            flex: 3,
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: TextStyle(
                fontSize: fontSize,
                color: Colors.black87,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogoutButton({
    required BuildContext context,
    required AuthProvider authProvider,
    required bool isTablet,
    required bool isSmallPhone,
    required bool isMediumPhone,
    required bool isLandscape,
  }) {
    final buttonHeight = isSmallPhone ? 45.0 : isMediumPhone ? 48.0 : isTablet ? 60.0 : 50.0;
    final fontSize = isSmallPhone ? 14.0 : isMediumPhone ? 15.0 : isTablet ? 18.0 : 16.0;
    final iconSize = isSmallPhone ? 18.0 : isMediumPhone ? 20.0 : isTablet ? 24.0 : 20.0;
    final borderRadius = isSmallPhone ? 10.0 : isMediumPhone ? 12.0 : isTablet ? 16.0 : 12.0;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.redAccent.withOpacity(0.3),
            blurRadius: 8,
            spreadRadius: 1,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        height: buttonHeight,
        child: ElevatedButton.icon(
          icon: Icon(Icons.logout_rounded, color: Colors.white, size: iconSize),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.redAccent,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(borderRadius)),
            elevation: 0,
          ),
          onPressed: () => _showLogoutDialog(context, authProvider, isTablet, isSmallPhone, isMediumPhone),
          label: Text(
            'Logout',
            style: TextStyle(
              fontSize: fontSize,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog(
    BuildContext context,
    AuthProvider authProvider,
    bool isTablet,
    bool isSmallPhone,
    bool isMediumPhone,
  ) {
    final borderRadius = isSmallPhone ? 20.0 : isMediumPhone ? 22.0 : isTablet ? 25.0 : 20.0;
    final padding = isSmallPhone ? 20.0 : isMediumPhone ? 22.0 : isTablet ? 30.0 : 24.0;
    final iconSize = isSmallPhone ? 28.0 : isMediumPhone ? 32.0 : isTablet ? 40.0 : 32.0;
    final titleFontSize = isSmallPhone ? 18.0 : isMediumPhone ? 20.0 : isTablet ? 24.0 : 20.0;
    final buttonFontSize = isSmallPhone ? 13.0 : isMediumPhone ? 14.0 : isTablet ? 16.0 : 14.0;
    final buttonRadius = isSmallPhone ? 10.0 : isMediumPhone ? 12.0 : isTablet ? 16.0 : 12.0;
    final buttonPadding = isSmallPhone ? 12.0 : isMediumPhone ? 14.0 : isTablet ? 16.0 : 12.0;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(borderRadius)),
          elevation: 10,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(borderRadius),
              gradient: const LinearGradient(
                colors: [Colors.white, Color(0xFFE3F2FD)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Padding(
              padding: EdgeInsets.all(padding),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: EdgeInsets.all(isSmallPhone ? 14 : isMediumPhone ? 16 : isTablet ? 20 : 16),
                    decoration: BoxDecoration(
                      color: Colors.redAccent.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.logout_rounded, color: Colors.redAccent, size: iconSize),
                  ),
                  SizedBox(height: isSmallPhone ? 16 : isMediumPhone ? 18 : isTablet ? 25 : 20),
                  Text(
                    'Konfirmasi Logout',
                    style: TextStyle(
                      fontSize: titleFontSize,
                      fontWeight: FontWeight.bold,
                      color: Colors.redAccent,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: isSmallPhone ? 10 : isMediumPhone ? 12 : isTablet ? 15 : 12),
                  Text(
                    'Apakah Anda yakin ingin logout dari akun Anda?',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: isSmallPhone ? 13 : isMediumPhone ? 14 : isTablet ? 16 : 14,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: isSmallPhone ? 20 : isMediumPhone ? 22 : isTablet ? 30 : 24),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.grey,
                            side: const BorderSide(color: Colors.grey),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(buttonRadius)),
                            padding: EdgeInsets.symmetric(vertical: buttonPadding),
                          ),
                          child: Text(
                            'Batal',
                            style: TextStyle(fontWeight: FontWeight.w600, fontSize: buttonFontSize),
                          ),
                        ),
                      ),
                      SizedBox(width: isSmallPhone ? 10 : isMediumPhone ? 12 : isTablet ? 15 : 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            authProvider.logout();
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Berhasil Logout',
                                  style: TextStyle(fontSize: buttonFontSize),
                                ),
                                backgroundColor: Colors.redAccent,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.all(Radius.circular(buttonRadius)),
                                ),
                                margin: EdgeInsets.symmetric(
                                  horizontal: isSmallPhone ? 16 : isMediumPhone ? 20 : isTablet ? 100 : 20,
                                  vertical: isSmallPhone ? 8 : isMediumPhone ? 10 : isTablet ? 20 : 10,
                                ),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.redAccent,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(buttonRadius)),
                            padding: EdgeInsets.symmetric(vertical: buttonPadding),
                          ),
                          child: Text(
                            'Logout',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: buttonFontSize,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
