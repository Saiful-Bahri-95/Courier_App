import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:store_app/config/globar_variable.dart';
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'] ?? 'Gagal kirim OTP')),
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
                    'Forgot Password? 🔐',
                    style: GoogleFonts.poppins(
                      fontSize: 23,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Enter your email to receive an OTP code',
                    style: GoogleFonts.lato(color: Colors.white70),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),
                  Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      'Email',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 5),
                  TextFormField(
                    onChanged: (value) => email = value,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      hintText: 'Enter your email',
                      hintStyle: GoogleFonts.poppins(fontSize: 14),
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
                        sendOtp();
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
