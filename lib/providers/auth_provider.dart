import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';

class AuthProvider extends ChangeNotifier {
  final SharedPreferences prefs;
  final supabase = Supabase.instance.client;
  
  String? _token;
  String? _email;
  String? _userId;
  String? _userName;
  String? _userAddress;
  String? _userPhone;
  String? _userEmployeeId;
  String? _userPosition; // menambahkan field untuk jabatan
  String? _userBankAccount; // tambah field nomor rekening
  bool _isLoading = false;
  String? _errorMessage;

  AuthProvider(this.prefs) {
    _loadFromPrefs();
  }

  // Getters
  bool get isLoggedIn => _token != null;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get email => _email;
  String? get userId => _userId;
  String? get userName => _userName;
  String? get userAddress => _userAddress;
  String? get userPhone => _userPhone;
  String? get userEmployeeId => _userEmployeeId;
  String? get userPosition => _userPosition; // getter untuk jabatan
  String? get userBankAccount => _userBankAccount; // getter untuk nomor rekening

  void _loadFromPrefs() {
    _token = prefs.getString('token');
    _email = prefs.getString('email');
    _userId = prefs.getString('userId');
    _userName = prefs.getString('userName');
    _userAddress = prefs.getString('userAddress');
    _userPhone = prefs.getString('userPhone');
    _userEmployeeId = prefs.getString('userEmployeeId');
    _userPosition = prefs.getString('userPosition'); // load jabatan dari SharedPreferences
    _userBankAccount = prefs.getString('userBankAccount'); // load nomor rekening
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      if (email.isEmpty || password.isEmpty) {
        _errorMessage = 'Email dan password tidak boleh kosong';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      print('[v0] Attempting login with email: $email');
      
      final response = await supabase
          .from('user')
          .select()
          .eq('email', email);

      print('[v0] Query response: $response');

      if (response.isEmpty) {
        _errorMessage = 'Email tidak ditemukan';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      final user = response[0];

      if (user['password'] != password) {
        _errorMessage = 'Password salah';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Login berhasil - simpan data user
      _token = 'token_${user['id_user']}_${DateTime.now().millisecondsSinceEpoch}';
      _email = user['email'];
      _userId = user['id_user'].toString();
      _userName = user['nama_user'];
      _userAddress = user['alamat'];
      _userPhone = user['no_telp'].toString();
      _userEmployeeId = user['no_karyawan'];
      _userPosition = user['jabatan']; // ambil jabatan dari database
      _userBankAccount = user['no_rekening']; // ambil nomor rekening dari database

      // Simpan ke local storage
      await prefs.setString('token', _token!);
      await prefs.setString('email', _email!);
      await prefs.setString('userId', _userId!);
      await prefs.setString('userName', _userName ?? '');
      await prefs.setString('userAddress', _userAddress ?? '');
      await prefs.setString('userPhone', _userPhone ?? '');
      await prefs.setString('userEmployeeId', _userEmployeeId ?? '');
      await prefs.setString('userPosition', _userPosition ?? ''); // simpan jabatan ke SharedPreferences
      await prefs.setString('userBankAccount', _userBankAccount ?? ''); // simpan nomor rekening

      print('[v0] Login successful for user: $_email');

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      print('[v0] Login error: ${e.toString()}');
      _errorMessage = 'Terjadi kesalahan: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    _token = null;
    _email = null;
    _userId = null;
    _userName = null;
    _userAddress = null;
    _userPhone = null;
    _userEmployeeId = null;
    _userPosition = null; // clear jabatan saat logout
    _userBankAccount = null; // clear nomor rekening
    _errorMessage = null;
    
    await prefs.remove('token');
    await prefs.remove('email');
    await prefs.remove('userId');
    await prefs.remove('userName');
    await prefs.remove('userAddress');
    await prefs.remove('userPhone');
    await prefs.remove('userEmployeeId');
    await prefs.remove('userPosition'); // hapus jabatan dari SharedPreferences
    await prefs.remove('userBankAccount'); // hapus nomor rekening
    
    notifyListeners();
  }
}
