import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:store_app/globar_variable.dart';
import 'package:http/http.dart' as http;
import 'package:store_app/models/user.dart';
import 'package:store_app/provider/user_provider.dart';
import 'package:store_app/services/auth_secure_storage.dart';
import 'package:store_app/views/screens/authentication_screens/login_screen.dart';
import 'package:store_app/views/screens/main_screen.dart';

import '../services/manage_http_response.dart';

final providerContainer = ProviderContainer();

class AuthController {
  Future<void> signUpUser({
    required BuildContext context,
    required String email,
    required String fullname,
    required String password,
  }) async {
    try {
      http.Response response = await http.post(
        Uri.parse('$uri/api/signup'),
        headers: const {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode({
          'fullname': fullname,
          'email': email,
          'password': password,
        }),
      );

      manageHttpResponse(
        response: response,
        // ignore: use_build_context_synchronously
        context: context,
        onSuccess: () {
          showSnackbar(context, 'Account has been created');
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const LoginScreen()),
          );
        },
      );
    } catch (e) {
      // ignore: use_build_context_synchronously
      showSnackbar(context, 'Server error');
    }
  }

  //signin user function
  Future<void> signInUser({
    required context,
    required WidgetRef ref,
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$uri/api/signin'),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      manageHttpResponse(
        response: response,
        // ignore: use_build_context_synchronously
        context: context,
        onSuccess: () async {
          final data = jsonDecode(response.body);

          // 🔥 1. Buat object User dari response
          final user = User.fromMap(data);

          // 🔐 2. Simpan token & user ke SecureStorage
          await AuthSecureStorage.saveToken(user.token);
          await AuthSecureStorage.saveUser(user);

          // 🌍 3. Simpan user ke Riverpod (global state)
          ref.read(userProvider.notifier).setUser(user);

          // 🚀 4. Pindah ke MainScreen
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const MainScreen()),
            (route) => false,
          );

          showSnackbar(context, 'Login successful');
        },
      );
    } catch (e) {
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

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Logged out successfully')));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Error during logout')));
    }
  }
}
