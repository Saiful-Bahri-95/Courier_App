import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:store_app/controllers/auth_controller.dart';
import 'package:store_app/views/screens/nav_screens/widgets/edit_profile_screen.dart';

class AccountScreen extends ConsumerWidget {
  AccountScreen({super.key});

  final AuthController _authController = AuthController();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      // backgroundColor: const Color(0xFF8B0000),
      backgroundColor: const Color.fromARGB(255, 31, 207, 247),
      body: Column(
        children: [
          const SizedBox(height: 30),

          /// HEADER
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Text(
                  'Settings',
                  style: GoogleFonts.getFont(
                    'Poppins',
                    fontSize: 25,
                    color: Color(0xFF030F2F),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          /// PROFILE INFO
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 28,
                  backgroundImage: AssetImage('assets/images/banner2.png'),
                ),
                const SizedBox(width: 14),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ava Michel',
                      style: GoogleFonts.getFont(
                        'Poppins',
                        fontSize: 18,
                        color: Color(0xFF030F2F),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'avamichel@gmail.com',
                      style: GoogleFonts.getFont(
                        'Poppins',
                        fontSize: 13,
                        color: Color(0xFF030F2F),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 28),

          /// CONTENT
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
              ),
              child: Column(
                children: [
                  _SettingItem(
                    icon: Icons.person_outline,
                    title: 'Edit Profile',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const EditProfileScreen(),
                        ),
                      );
                    },
                  ),
                  _SettingItem(
                    icon: Icons.notifications_none,
                    title: 'Notification',
                    onTap: () {},
                  ),
                  _SettingItem(
                    icon: Icons.settings_outlined,
                    title: 'Others',
                    onTap: () {},
                  ),
                  _SettingItem(icon: Icons.help_outline, title: 'Help'),
                  _SettingItem(
                    icon: Icons.logout,
                    title: 'Logout',
                    onTap: () async {
                      await _authController.signOutUser(
                        context: context,
                        ref: ref,
                      );
                    },
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

class _SettingItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback? onTap;

  const _SettingItem({required this.icon, required this.title, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          leading: Icon(icon, color: Colors.black87, size: 30),
          title: Text(
            title,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          trailing: const Icon(Icons.chevron_right),
          onTap: onTap,
        ),
        const Divider(height: 1),
      ],
    );
  }
}
