import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:store_app/controllers/auth_controller.dart';

import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final AuthController _authController = AuthController();

  late String email;
  late String fullname;
  late String password;

  bool _isLoading = false;

  registerUser() async {
    setState(() => _isLoading = true);

    await _authController
        .signUpUser(
          context: context,
          email: email,
          fullname: fullname,
          password: password,
        )
        .whenComplete(() {
          setState(() => _isLoading = false);
        });
  }

  InputDecoration _inputDecoration({
    required String hintText,
    required String iconPath,
  }) {
    return InputDecoration(
      filled: true,
      fillColor: Colors.white,
      hintText: hintText,
      hintStyle: GoogleFonts.poppins(fontSize: 14),

      prefixIcon: Padding(
        padding: const EdgeInsets.all(10),
        child: Image.asset(iconPath, width: 20, height: 20),
      ),

      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: const BorderSide(color: Color(0xFF0A68FF), width: 1.5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF030F2F),
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
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Join us and explore more features',
                    style: GoogleFonts.lato(color: Colors.white),
                  ),
                  const SizedBox(height: 20),

                  Image.asset(
                    'assets/images/banner2.png',
                    width: 150,
                    height: 150,
                  ),

                  const SizedBox(height: 20),

                  /// EMAIL
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
                    validator: (value) =>
                        value!.isEmpty ? 'Please enter your email' : null,
                    decoration: _inputDecoration(
                      hintText: 'Enter your email',
                      iconPath: 'assets/icons/email.png',
                    ),
                  ),

                  const SizedBox(height: 20),

                  /// FULL NAME
                  Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      'Full Name',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 5),
                  TextFormField(
                    onChanged: (value) => fullname = value,
                    validator: (value) =>
                        value!.isEmpty ? 'Please enter your full name' : null,
                    decoration: _inputDecoration(
                      hintText: 'Enter your full name',
                      iconPath: 'assets/icons/user.jpeg',
                    ),
                  ),

                  const SizedBox(height: 20),

                  /// PASSWORD
                  Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      'Password',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 5),
                  TextFormField(
                    obscureText: true,
                    onChanged: (value) => password = value,
                    validator: (value) =>
                        value!.isEmpty ? 'Please enter your password' : null,
                    decoration: _inputDecoration(
                      hintText: 'Enter your password',
                      iconPath: 'assets/icons/password.png',
                    ).copyWith(suffixIcon: const Icon(Icons.visibility)),
                  ),

                  const SizedBox(height: 30),

                  /// BUTTON
                  InkWell(
                    onTap: () {
                      if (_formKey.currentState!.validate()) {
                        registerUser();
                      }
                    },
                    child: Container(
                      width: 355,
                      height: 60,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        gradient: const LinearGradient(
                          colors: [Color(0xFF225BCE), Color(0xFF0A68FF)],
                        ),
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
                          color: Colors.white,
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const LoginScreen(),
                            ),
                          );
                        },
                        child: Text(
                          ' Sign In',
                          style: GoogleFonts.roboto(
                            color: const Color.fromARGB(255, 51, 121, 242),
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
