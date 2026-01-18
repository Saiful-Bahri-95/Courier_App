import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class EditProfileScreen extends StatelessWidget {
  const EditProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF8B0000),
      body: Column(
        children: [
          /// APP BAR
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Text(
                    'Edit profile',
                    style: GoogleFonts.getFont(
                      'Poppins',
                      fontSize: 20,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),

          /// CONTENT
          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
              ),
              child: Column(
                children: [
                  /// PROFILE IMAGE
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      const CircleAvatar(
                        radius: 50,
                        backgroundImage: AssetImage(
                          'assets/images/banner2.png',
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.camera_alt, size: 18),
                      ),
                    ],
                  ),

                  const SizedBox(height: 30),

                  _ProfileField(label: 'Username', value: 'Ava Michel'),
                  _ProfileField(label: 'Email', value: 'avamichel@gmail.com'),
                  _ProfileField(label: 'Phone Number', value: '+256-6847839'),
                  _ProfileField(label: 'Date of birth', value: '10/12/2000'),

                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      // Simpan perubahan profil
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF8B0000),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 80,
                        vertical: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: Text(
                      'Save Changes',
                      style: GoogleFonts.getFont(
                        'Poppins',
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileField extends StatelessWidget {
  final String label;
  final String value;

  const _ProfileField({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: TextEditingController(text: value),
          decoration: const InputDecoration(border: InputBorder.none),
        ),
        const Divider(height: 1),
        const SizedBox(height: 14),
      ],
    );
  }
}
