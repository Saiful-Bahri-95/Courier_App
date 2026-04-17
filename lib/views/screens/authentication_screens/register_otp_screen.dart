import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:store_app/controllers/auth_controller.dart';

class RegisterOtpScreen extends StatefulWidget {
  final String email;
  final String fullname;
  final String password;

  const RegisterOtpScreen({
    super.key,
    required this.email,
    required this.fullname,
    required this.password,
  });

  @override
  State<RegisterOtpScreen> createState() => _RegisterOtpScreenState();
}

class _RegisterOtpScreenState extends State<RegisterOtpScreen> {
  final _formKey = GlobalKey<FormState>();
  final AuthController _authController = AuthController();
  String otp = '';
  bool _isLoading = false;

  Future<void> verifyOtp() async {
    setState(() => _isLoading = true);

    await _authController.verifyRegisterOtp(
      context: context,
      email: widget.email,
      fullname: widget.fullname,
      password: widget.password,
      otp: otp,
    );

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
                  Image.asset(
                    'assets/images/banner2.png',
                    width: 150,
                    height: 150,
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Verify Your Email 📧',
                    style: GoogleFonts.poppins(
                      fontSize: 23,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'OTP code has been sent to\n${widget.email}',
                    style: GoogleFonts.lato(color: Colors.white70),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),
                  Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      'OTP Code',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 5),
                  TextFormField(
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                    onChanged: (value) => otp = value,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'OTP wajib diisi';
                      }
                      if (value.length < 6) return 'OTP harus 6 digit';
                      return null;
                    },
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      hintText: 'Enter 6-digit OTP',
                      hintStyle: GoogleFonts.poppins(fontSize: 14),
                      counterText: '',
                      prefixIcon: const Icon(
                        Icons.lock_outline,
                        color: Colors.grey,
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
                        verifyOtp();
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
                                'Verify & Create Account',
                                style: GoogleFonts.lato(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Resend OTP
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context); // kembali ke register
                    },
                    child: Text(
                      'Didn\'t receive OTP? Go back',
                      style: GoogleFonts.poppins(
                        color: const Color.fromARGB(255, 255, 0, 0),
                        fontWeight: FontWeight.w600,
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
