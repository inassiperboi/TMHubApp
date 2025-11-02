import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Mendapatkan ukuran layar
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width > 600;
    final isSmallPhone = screenSize.width < 350;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Profil Saya',
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
        child: Consumer<AuthProvider>(
          builder: (context, authProvider, _) {
            return SafeArea(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: isSmallPhone ? 12 : 20,
                    vertical: isSmallPhone ? 8 : 12, // Diperkecil dari 12:20
                  ),
                  child: Column(
                    children: [
                      SizedBox(height: isTablet ? 20 : 10), // Diperkecil dari 40:20

                      // FOTO PROFIL RESPONSIF DENGAN INISIAL NAMA
                      Container(
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
                              width: isTablet ? 160 : isSmallPhone ? 110 : 130,
                              height: isTablet ? 160 : isSmallPhone ? 110 : 130,
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
                            // CircleAvatar dengan inisial nama
                            CircleAvatar(
                              radius: isTablet ? 70 : isSmallPhone ? 50 : 60,
                              backgroundColor: Colors.blueAccent,
                              child: Text(
                                // Mengambil huruf pertama dari nama, jika tidak ada tampilkan '-'
                                authProvider.userName != null && authProvider.userName!.isNotEmpty
                                    ? authProvider.userName![0].toUpperCase()
                                    : '-',
                                style: TextStyle(
                                  fontSize: isTablet ? 40 : 30,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: isTablet ? 25 : 15), // Diperkecil dari 35:25

                      // INFORMASI PENGGUNA RESPONSIF
                      Card(
                        elevation: 8,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                              isTablet ? 25 : isSmallPhone ? 15 : 20),
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(
                                isTablet ? 25 : isSmallPhone ? 15 : 20),
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
                            padding: EdgeInsets.all(isTablet ? 25 : 20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // HEADER CARD
                                Row(
                                  children: [
                                    Container(
                                      padding: EdgeInsets.all(isTablet ? 12 : 8),
                                      decoration: BoxDecoration(
                                        color: Colors.blueAccent.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(
                                            isTablet ? 16 : 12),
                                      ),
                                      child: Icon(
                                        Icons.person_outline_rounded,
                                        color: Colors.blueAccent,
                                        size: isTablet ? 28 : 24,
                                      ),
                                    ),
                                    SizedBox(width: isTablet ? 15 : 12),
                                    Text(
                                      'Informasi Pribadi',
                                      style: TextStyle(
                                        fontSize: isTablet ? 22 : 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blueAccent,
                                      ),
                                    ),
                                  ],
                                ),
                                
                                SizedBox(height: isTablet ? 20 : 15), // Diperkecil dari 25:20
                                
                                // LIST INFORMASI RESPONSIF
                                _buildInfoRow(
                                  context: context,
                                  icon: Icons.person_rounded,
                                  label: 'Nama',
                                  value: authProvider.userName ?? '-',
                                ),
                                SizedBox(height: isTablet ? 14 : 10), // Diperkecil
                                _buildInfoRow(
                                  context: context,
                                  icon: Icons.work_rounded,
                                  label: 'Jabatan',
                                  value: authProvider.userPosition ?? '-',
                                ),
                                SizedBox(height: isTablet ? 14 : 10), // Diperkecil
                                _buildInfoRow(
                                  context: context,
                                  icon: Icons.email_rounded,
                                  label: 'Email',
                                  value: authProvider.email ?? '-',
                                ),
                                SizedBox(height: isTablet ? 14 : 10), // Diperkecil
                                _buildInfoRow(
                                  context: context,
                                  icon: Icons.phone_rounded,
                                  label: 'No. Telepon',
                                  value: authProvider.userPhone ?? '-',
                                ),
                                SizedBox(height: isTablet ? 14 : 10), // Diperkecil
                                _buildInfoRow(
                                  context: context,
                                  icon: Icons.location_on_rounded,
                                  label: 'Alamat',
                                  value: authProvider.userAddress ?? '-',
                                ),
                                SizedBox(height: isTablet ? 14 : 10), // Diperkecil
                                _buildInfoRow(
                                  context: context,
                                  icon: Icons.account_balance_rounded,
                                  label: 'No. Rekening',
                                  value: authProvider.userBankAccount ?? '-',
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: isTablet ? 25 : 20), // Diperkecil dari 35:30

                      // TOMBOL LOGOUT RESPONSIF
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(
                              isTablet ? 16 : isSmallPhone ? 10 : 12),
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
                          height: isTablet ? 60 : isSmallPhone ? 45 : 50,
                          child: ElevatedButton.icon(
                            icon: Icon(
                              Icons.logout_rounded, 
                              color: Colors.white,
                              size: isTablet ? 24 : 20,
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.redAccent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                    isTablet ? 16 : isSmallPhone ? 10 : 12),
                              ),
                              elevation: 0,
                            ),
                            onPressed: () => _showLogoutDialog(context, authProvider),
                            label: Text(
                              'Logout',
                              style: TextStyle(
                                fontSize: isTablet ? 18 : isSmallPhone ? 14 : 16,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: isTablet ? 30 : 20), // Diperkecil dari 40:30

                      // FOOTER INFO RESPONSIF
                      Container(
                        padding: EdgeInsets.symmetric(vertical: isTablet ? 15 : 10), // Diperkecil
                        child: Text(
                          '© 2025 AttendEase - Sistem Absensi Digital',
                          style: TextStyle(
                            color: Colors.black54, 
                            fontSize: isTablet ? 14 : isSmallPhone ? 10 : 12,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required BuildContext context,
    required IconData icon,
    required String label,
    required String value,
  }) {
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width > 600;
    final isSmallPhone = screenSize.width < 350;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isTablet ? 12 : 8,
        vertical: isTablet ? 10 : 6,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.5),
        borderRadius: BorderRadius.circular(isTablet ? 12 : 10),
        border: Border.all(
          color: Colors.blueAccent.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(isTablet ? 8 : 6),
            decoration: BoxDecoration(
              color: Colors.blueAccent.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: isTablet ? 20 : isSmallPhone ? 14 : 18,
              color: Colors.blueAccent,
            ),
          ),
          SizedBox(width: isTablet ? 15 : 12),
          Expanded(
            flex: 2,
            child: Text(
              '$label:',
              style: TextStyle(
                fontSize: isTablet ? 16 : isSmallPhone ? 12 : 14,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: TextStyle(
                fontSize: isTablet ? 16 : isSmallPhone ? 12 : 14,
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

  void _showLogoutDialog(BuildContext context, AuthProvider authProvider) {
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width > 600;
    final isSmallPhone = screenSize.width < 350;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(isTablet ? 25 : 20),
          ),
          elevation: 10,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(isTablet ? 25 : 20),
              gradient: const LinearGradient(
                colors: [Colors.white, Color(0xFFE3F2FD)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Padding(
              padding: EdgeInsets.all(isTablet ? 30 : 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ICON PERINGATAN
                  Container(
                    padding: EdgeInsets.all(isTablet ? 20 : 16),
                    decoration: BoxDecoration(
                      color: Colors.redAccent.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.logout_rounded,
                      color: Colors.redAccent,
                      size: isTablet ? 40 : 32,
                    ),
                  ),
                  
                  SizedBox(height: isTablet ? 25 : 20),
                  
                  // TITLE
                  Text(
                    'Konfirmasi Logout',
                    style: TextStyle(
                      fontSize: isTablet ? 24 : 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.redAccent,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  
                  SizedBox(height: isTablet ? 15 : 12),
                  
                  // SUBTITLE
                  Text(
                    'Apakah Anda yakin ingin logout dari akun Anda?',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: isTablet ? 16 : 14,
                      color: Colors.black87,
                    ),
                  ),
                  
                  SizedBox(height: isTablet ? 30 : 24),
                  
                  // TOMBOL AKSI RESPONSIF
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.grey,
                            side: const BorderSide(color: Colors.grey),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                  isTablet ? 16 : 12),
                            ),
                            padding: EdgeInsets.symmetric(
                                vertical: isTablet ? 16 : 12),
                          ),
                          child: Text(
                            'Batal',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: isTablet ? 16 : 14,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: isTablet ? 15 : 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            authProvider.logout();
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Berhasil Logout',
                                  style: TextStyle(
                                    fontSize: isTablet ? 16 : 14,
                                  ),
                                ),
                                backgroundColor: Colors.redAccent,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(isTablet ? 16 : 10),
                                  ),
                                ),
                                margin: EdgeInsets.symmetric(
                                  horizontal: isTablet ? 100 : 20,
                                  vertical: isTablet ? 20 : 10,
                                ),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.redAccent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                  isTablet ? 16 : 12),
                            ),
                            padding: EdgeInsets.symmetric(
                                vertical: isTablet ? 16 : 12),
                          ),
                          child: Text(
                            'Logout',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: isTablet ? 16 : 14,
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
