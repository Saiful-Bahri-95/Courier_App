import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'reset_password_screen.dart';

class OtpScreen extends StatefulWidget {
  final String email;
  const OtpScreen({super.key, required this.email});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final _formKey = GlobalKey<FormState>();

  // Palet warna konsisten
  static const Color _primaryColor = Color(0xFF0A68FF);
  static const Color _primaryDark = Color(0xFF225BCE);
  static const Color _textDark = Color(0xFF030F2F);
  static const Color _textMuted = Color(0xFF6B7280);
  static const Color _fieldFill = Color(0xFFF3F4F6);
  static const Color _fieldBorder = Color(0xFFE5E7EB);

  String otp = '';
  bool _isLoading = false;

  Future<void> verifyOtp() async {
    setState(() => _isLoading = true);

    try {
      // Kita cek OTP dengan mencoba reset password dummy
      // OTP akan diverifikasi di reset_password_screen
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              ResetPasswordScreen(email: widget.email, otp: otp),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Terjadi kesalahan')));
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
                    'Enter OTP Code 📩',
                    style: GoogleFonts.poppins(
                      fontSize: 23,
                      color: _textDark,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'OTP code has been sent to\n${widget.email}',
                    style: GoogleFonts.lato(color: _textMuted),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),
                  Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      'OTP Code',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        color: _textDark,
                      ),
                    ),
                  ),
                  const SizedBox(height: 5),
                  TextFormField(
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                    onChanged: (value) => otp = value,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: _textDark,
                      letterSpacing: 2,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter OTP code';
                      }
                      if (value.length < 6) {
                        return 'OTP must be 6 digits';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: _fieldFill,
                      hintText: 'Enter 6-digit OTP',
                      hintStyle: GoogleFonts.poppins(
                        fontSize: 14,
                        color: _textMuted,
                      ),
                      counterText: '',
                      prefixIcon: const Icon(
                        Icons.lock_outline,
                        color: _textMuted,
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
                        verifyOtp();
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
                                'Verify OTP',
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
