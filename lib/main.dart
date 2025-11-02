import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'providers/auth_provider.dart';
import 'providers/schedule_provider.dart'; // menambahkan import untuk ScheduleProvider
import 'providers/attendance_history_provider.dart'; // menambahkan import untuk AttendanceHistoryProvider
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Supabase.initialize(
    url: 'https://stsukntjvdvmjeimfunp.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InN0c3VrbnRqdmR2bWplaW1mdW5wIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjE4MzEyMDQsImV4cCI6MjA3NzQwNzIwNH0.t9llt1DCORI9KdU8yIx2gPn5J_NN8JOLonhdmWfcgbI',
  );
  
  final prefs = await SharedPreferences.getInstance();
  runApp(MyApp(prefs: prefs));
}

class MyApp extends StatelessWidget {
  final SharedPreferences prefs;

  const MyApp({super.key, required this.prefs});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider(prefs),
        ),
        ChangeNotifierProvider(
          create: (_) => ScheduleProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => AttendanceHistoryProvider(),
        ),
      ],
      child: MaterialApp(
        title: 'TrustMedis Presensi',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF003366)),
          useMaterial3: true,
          scaffoldBackgroundColor: Colors.white,
        ),
        home: Consumer<AuthProvider>(
          builder: (context, authProvider, _) {
            if (authProvider.isLoggedIn) {
              return const HomeScreen();
            } else {
              return const LoginScreen();
            }
          },
        ),
      ),
    );
  }
}
