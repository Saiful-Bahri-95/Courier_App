import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:store_app/config/globar_variable.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String email;
  final String otp;
  const ResetPasswordScreen({
    super.key,
    required this.email,
    required this.otp,
  });

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  String newPassword = '';
  String confirmPassword = '';
  bool _isLoading = false;
  bool _obscure1 = true;
  bool _obscure2 = true;

  Future<void> resetPassword() async {
    setState(() => _isLoading = true);

    try {
      final res = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/api/reset-password'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': widget.email,
          'otp': widget.otp,
          'newPassword': newPassword,
        }),
      );

      final data = jsonDecode(res.body);

      if (res.statusCode == 200) {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Password berhasil direset! Silakan login.'),
          ),
        );
        // Kembali ke login screen
        // ignore: use_build_context_synchronously
        Navigator.popUntil(context, (route) => route.isFirst);
      } else {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'] ?? 'Gagal reset password')),
        );
      }
    } catch (e) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal terhubung ke server')),
      );
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF030F2F),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Center(
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'New Password 🔑',
                    style: GoogleFonts.poppins(
                      fontSize: 23,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Create your new password',
                    style: GoogleFonts.lato(color: Colors.white70),
                  ),
                  const SizedBox(height: 40),
                  Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      'New Password',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 5),
                  TextFormField(
                    obscureText: _obscure1,
                    onChanged: (value) => newPassword = value,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Password wajib diisi';
                      }
                      if (value.length < 8) return 'Minimal 8 karakter';
                      return null;
                    },
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      hintText: 'Enter new password',
                      hintStyle: GoogleFonts.poppins(fontSize: 14),
                      prefixIcon: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Image.asset(
                          'assets/icons/password.png',
                          width: 20,
                          height: 20,
                        ),
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscure1 ? Icons.visibility : Icons.visibility_off,
                        ),
                        onPressed: () => setState(() => _obscure1 = !_obscure1),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: const BorderSide(
                          color: Color(0xFF0A68FF),
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      'Confirm Password',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 5),
                  TextFormField(
                    obscureText: _obscure2,
                    onChanged: (value) => confirmPassword = value,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Konfirmasi password wajib diisi';
                      }
                      if (value != newPassword) return 'Password tidak cocok';
                      return null;
                    },
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      hintText: 'Confirm new password',
                      hintStyle: GoogleFonts.poppins(fontSize: 14),
                      prefixIcon: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Image.asset(
                          'assets/icons/password.png',
                          width: 20,
                          height: 20,
                        ),
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscure2 ? Icons.visibility : Icons.visibility_off,
                        ),
                        onPressed: () => setState(() => _obscure2 = !_obscure2),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: const BorderSide(
                          color: Color(0xFF0A68FF),
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  InkWell(
                    onTap: () {
                      if (_formKey.currentState!.validate()) {
                        resetPassword();
                      }
                    },
                    child: Container(
                      width: 355,
                      height: 60,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        gradient: const LinearGradient(
                          colors: [
                            Color.fromARGB(255, 34, 91, 206),
                            Color.fromARGB(255, 10, 104, 255),
                          ],
                        ),
                      ),
                      child: Center(
                        child: _isLoading
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : Text(
                                'Reset Password',
                                style: GoogleFonts.lato(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
