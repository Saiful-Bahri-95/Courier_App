import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:store_app/config/globar_variable.dart';
import 'package:store_app/services/manage_http_response.dart';
import 'otp_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();

  // Palet warna konsisten dengan LoginScreen & RegisterScreen
  static const Color _primaryColor = Color(0xFF0A68FF);
  static const Color _primaryDark = Color(0xFF225BCE);
  static const Color _textDark = Color(0xFF030F2F);
  static const Color _textMuted = Color(0xFF6B7280);
  static const Color _fieldFill = Color(0xFFF3F4F6);
  static const Color _fieldBorder = Color(0xFFE5E7EB);

  String email = '';
  bool _isLoading = false;

  Future<void> sendOtp() async {
    setState(() => _isLoading = true);

    try {
      final res = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/api/forgot-password'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );

      final data = jsonDecode(res.body);

      if (res.statusCode == 200) {
        Navigator.push(
          // ignore: use_build_context_synchronously
          context,
          MaterialPageRoute(builder: (context) => OtpScreen(email: email)),
        );
      } else {
        // ignore: use_build_context_synchronously
        showSnackbar(context, data['message'] ?? 'Failed to send OTP');
      }
    } catch (e) {
      // ignore: use_build_context_synchronously
      showSnackbar(context, 'Gagal terhubung ke server');
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: _textDark),
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
                  Container(
                    width: 300,
                    height: 150,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(2),
                    ),
                    padding: const EdgeInsets.all(4),
                    child: Image.asset(
                      'assets/icons/app_icon_foreground.png',
                      width: 300,
                      height: 150,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Forgot Password? 🔐',
                    style: GoogleFonts.poppins(
                      fontSize: 23,
                      color: _textDark,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Enter your email to receive an OTP code',
                    style: GoogleFonts.lato(color: _textMuted),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),
                  Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      'Email',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        color: _textDark,
                      ),
                    ),
                  ),
                  const SizedBox(height: 5),
                  TextFormField(
                    onChanged: (value) => email = value,
                    keyboardType: TextInputType.emailAddress,
                    style: GoogleFonts.poppins(fontSize: 14, color: _textDark),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: _fieldFill,
                      hintText: 'Enter your email',
                      hintStyle: GoogleFonts.poppins(
                        fontSize: 14,
                        color: _textMuted,
                      ),
                      prefixIcon: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Image.asset(
                          'assets/icons/email.png',
                          width: 20,
                          height: 20,
                        ),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: const BorderSide(color: _fieldBorder),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: const BorderSide(color: _fieldBorder),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: const BorderSide(
                          color: _primaryColor,
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  InkWell(
                    onTap: () {
                      if (_formKey.currentState!.validate()) {
                        sendOtp();
                      }
                    },
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      width: 355,
                      height: 60,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        gradient: const LinearGradient(
                          colors: [_primaryDark, _primaryColor],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: _primaryColor.withValues(alpha: 0.25),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Center(
                        child: _isLoading
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : Text(
                                'Send OTP',
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
