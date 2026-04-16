import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flutter/material.dart';
import 'package:store_app/config/globar_variable.dart';
import 'package:http/http.dart' as http;
import 'package:store_app/models/user.dart';
import 'package:store_app/provider/user_provider.dart';
import 'package:store_app/services/auth_secure_storage.dart';
import 'package:store_app/views/screens/authentication_screens/login_screen.dart';
import 'package:store_app/views/screens/authentication_screens/register_otp_screen.dart';
import 'package:store_app/views/screens/main_screen.dart';

import '../services/manage_http_response.dart';

class AuthController {
  //signup user function
  // Future<void> signUpUser({
  //   required BuildContext context,
  //   required String email,
  //   required String fullname,
  //   required String password,
  // }) async {
  //   try {
  //     http.Response response = await http.post(
  //       Uri.parse('${ApiConfig.baseUrl}/api/signup'),
  //       headers: const {'Content-Type': 'application/json; charset=UTF-8'},
  //       body: jsonEncode({
  //         'fullname': fullname,
  //         'email': email,
  //         'password': password,
  //       }),
  //     );

  //     manageHttpResponse(
  //       response: response,
  //       // ignore: use_build_context_synchronously
  //       context: context,
  //       onSuccess: () {
  //         showSnackbar(context, 'Account has been created');
  //         Navigator.pushReplacement(
  //           context,
  //           MaterialPageRoute(builder: (_) => const LoginScreen()),
  //         );
  //       },
  //     );
  //   } catch (e) {
  //     // ignore: use_build_context_synchronously
  //     showSnackbar(context, 'Server error');
  //   }
  // }

  //signin user function
  Future<void> signInUser({
    required context,
    required WidgetRef ref,
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/api/signin'),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      // ❌ JANGAN parse dulu
      if (response.statusCode != 200) {
        final error = jsonDecode(response.body);
        showSnackbar(context, error['message'] ?? 'Login failed');
        return;
      }

      // ✅ BARU parse jika sukses
      final data = jsonDecode(response.body);
      final user = User.fromMap(data);

      await AuthSecureStorage.saveToken(user.token);
      await AuthSecureStorage.saveUser(user);

      ref.read(userProvider.notifier).setUser(user);

      Navigator.pushAndRemoveUntil(
        // ignore: use_build_context_synchronously
        context,
        MaterialPageRoute(builder: (_) => const MainScreen()),
        (route) => false,
      );

      showSnackbar(context, 'Login successful');
    } catch (e) {
      //print("LOGIN ERROR: $e");
      showSnackbar(context, 'Unexpected error occurred');
    }
  }

  // ========================
  // SEND REGISTER OTP
  // ========================
  Future<void> sendRegisterOtp({
    required BuildContext context,
    required String email,
    required String fullname,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/api/send-register-otp'),
        headers: const {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode({'email': email}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        Navigator.push(
          // ignore: use_build_context_synchronously
          context,
          MaterialPageRoute(
            builder: (_) => RegisterOtpScreen(
              email: email,
              fullname: fullname,
              password: password,
            ),
          ),
        );
      } else {
        // ignore: use_build_context_synchronously
        showSnackbar(context, data['message'] ?? 'Gagal kirim OTP');
      }
    } catch (e) {
      // ignore: use_build_context_synchronously
      showSnackbar(context, 'Server error');
    }
  }

  // ========================
  // VERIFY REGISTER OTP + BUAT AKUN
  // ========================
  Future<void> verifyRegisterOtp({
    required BuildContext context,
    required String email,
    required String fullname,
    required String password,
    required String otp,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/api/verify-register-otp'),
        headers: const {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode({
          'email': email,
          'fullname': fullname,
          'password': password,
          'otp': otp,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 201) {
        // ignore: use_build_context_synchronously
        showSnackbar(context, 'Akun berhasil dibuat! Silakan login.');
        Navigator.pushAndRemoveUntil(
          // ignore: use_build_context_synchronously
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
        );
      } else {
        // ignore: use_build_context_synchronously
        showSnackbar(context, data['message'] ?? 'OTP salah');
      }
    } catch (e) {
      // ignore: use_build_context_synchronously
      showSnackbar(context, 'Server error');
    }
  }

  // LOGOUT BERSIH
  Future<void> signOutUser({required context, required WidgetRef ref}) async {
    try {
      // 🔐 1. Hapus data auth dari SecureStorage
      await AuthSecureStorage.clearAuthData();

      // 🌍 2. Reset user global state
      ref.read(userProvider.notifier).signOut();

      // 🚀 3. Kembali ke LoginScreen (clear navigation stack)
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );

      showSnackbar(context, 'Logged out successfully');
    } catch (e) {
      showSnackbar(context, 'Error during logout');
    }
  }

  Future<void> updateProfile({
    required context,
    required WidgetRef ref,
    required String fullname,
    String? avatar,
  }) async {
    try {
      final user = ref.read(userProvider);
      if (user == null) return;

      final response = await http.patch(
        Uri.parse('${ApiConfig.baseUrl}/api/user/profile'), // ⬅️ FIX PATH
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${user.token}',
        },
        body: jsonEncode({'fullname': fullname, 'avatar': avatar}),
      );

      if (response.statusCode == 200) {
        final updatedUser = User.fromMap(jsonDecode(response.body));

        // 🔥 update state
        ref.read(userProvider.notifier).setUser(updatedUser);
        await AuthSecureStorage.saveUser(updatedUser);

        showSnackbar(context, 'Profile updated');
        Navigator.pop(context); // ⬅️ SEKARANG PASTI BALIK
      } else {
        showSnackbar(context, 'Failed to update profile');
      }
    } catch (e) {
      showSnackbar(context, 'Update failed');
    }
  }
}
