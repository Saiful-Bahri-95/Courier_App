import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'login_screen.dart';
import 'package:store_app/controllers/auth_controller.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final AuthController _authController = AuthController();

  // Palet warna konsisten dengan LoginScreen
  static const Color _primaryColor = Color(0xFF0A68FF);
  static const Color _primaryDark = Color(0xFF225BCE);
  static const Color _textDark = Color(0xFF030F2F);
  static const Color _textMuted = Color(0xFF6B7280);
  static const Color _fieldFill = Color(0xFFF3F4F6);
  static const Color _fieldBorder = Color(0xFFE5E7EB);

  String email = '';
  String password = '';
  String fullname = '';
  bool _isLoading = false;
  bool _obscure = true;

  // Kirim OTP dulu, bukan langsung register
  Future<void> sendOtp() async {
    setState(() => _isLoading = true);

    await _authController.sendRegisterOtp(
      context: context,
      email: email,
      fullname: fullname,
      password: password,
    );

    setState(() => _isLoading = false);
  }

  InputDecoration _inputDecoration({
    required String hintText,
    required String iconPath,
  }) {
    return InputDecoration(
      filled: true,
      fillColor: _fieldFill,
      hintText: hintText,
      hintStyle: GoogleFonts.poppins(fontSize: 14, color: _textMuted),
      prefixIcon: Padding(
        padding: const EdgeInsets.all(10),
        child: Image.asset(iconPath, width: 20, height: 20),
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
        borderSide: const BorderSide(color: _primaryColor, width: 1.5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(15),
        child: Center(
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Create Your Account 🚀',
                    style: GoogleFonts.poppins(
                      fontSize: 23,
                      color: _textDark,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Join us and explore more features',
                    style: GoogleFonts.lato(color: _textMuted),
                  ),
                  const SizedBox(height: 20),
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

                  Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      'Full Name',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        color: _textDark,
                      ),
                    ),
                  ),
                  const SizedBox(height: 5),
                  TextFormField(
                    onChanged: (value) => fullname = value,
                    style: GoogleFonts.poppins(fontSize: 14, color: _textDark),
                    validator: (value) =>
                        value!.isEmpty ? 'Nama lengkap wajib diisi' : null,
                    decoration: _inputDecoration(
                      hintText: 'Enter your full name',
                      iconPath: 'assets/icons/user.jpeg',
                    ),
                  ),

                  const SizedBox(height: 20),

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
                        return 'Email wajib diisi';
                      }
                      if (!RegExp(
                        r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                      ).hasMatch(value)) {
                        return 'Format email tidak valid';
                      }
                      return null;
                    },
                    decoration: _inputDecoration(
                      hintText: 'Enter your email',
                      iconPath: 'assets/icons/email.png',
                    ),
                  ),

                  const SizedBox(height: 20),

                  Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      'Password',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        color: _textDark,
                      ),
                    ),
                  ),
                  const SizedBox(height: 5),
                  TextFormField(
                    obscureText: _obscure,
                    onChanged: (value) => password = value,
                    style: GoogleFonts.poppins(fontSize: 14, color: _textDark),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Password wajib diisi';
                      }
                      if (value.length < 8) {
                        return 'Password minimal 8 karakter';
                      }
                      return null;
                    },
                    decoration:
                        _inputDecoration(
                          hintText: 'Enter your password',
                          iconPath: 'assets/icons/password.png',
                        ).copyWith(
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscure
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: _textMuted,
                            ),
                            onPressed: () =>
                                setState(() => _obscure = !_obscure),
                          ),
                        ),
                  ),

                  const SizedBox(height: 30),
                  InkWell(
                    onTap: () {
                      if (_formKey.currentState!.validate()) {
                        sendOtp(); // ← kirim OTP dulu
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
                            color: _primaryColor.withOpacity(0.25),
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
                                'Sign Up',
                                style: GoogleFonts.lato(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Already have an account?',
                        style: GoogleFonts.roboto(
                          fontWeight: FontWeight.bold,
                          color: _textDark,
                        ),
                      ),
                      InkWell(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const LoginScreen(),
                          ),
                        ),
                        child: Text(
                          ' Sign In',
                          style: GoogleFonts.roboto(
                            color: _primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
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
