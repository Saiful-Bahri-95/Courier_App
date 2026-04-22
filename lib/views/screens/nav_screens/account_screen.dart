import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:store_app/controllers/auth_controller.dart';
import 'package:store_app/provider/user_provider.dart';
import 'package:store_app/views/screens/nav_screens/widgets/edit_profile_screen.dart';
import 'package:store_app/views/screens/utils.dart';

class AccountScreen extends ConsumerWidget {
  AccountScreen({super.key});

  final AuthController _authController = AuthController();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);
    final topPadding = MediaQuery.of(context).padding.top;

    if (user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: kNavyBlue,
      body: Column(
        children: [
          // ===== HEADER =====
          Padding(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: topPadding + 20,
              bottom: 24,
            ),
            child: Row(
              children: [
                // Avatar
                Container(
                  padding: const EdgeInsets.all(2.5),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color.fromARGB(255, 255, 255, 255),
                  ),
                  child: CircleAvatar(
                    radius: 32,
                    backgroundColor: Colors.white,
                    backgroundImage:
                        (user.avatar != null && user.avatar!.isNotEmpty)
                        ? NetworkImage(user.avatar!) as ImageProvider
                        : const AssetImage('assets/images/banner2.png'),
                  ),
                ),
                const SizedBox(width: 16),
                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.fullname,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 0.2,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        user.email,
                        style: TextStyle(
                          fontSize: 13,
                          // ignore: deprecated_member_use
                          color: Colors.white.withOpacity(0.65),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                // Edit shortcut
                GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const EditProfileScreen(),
                    ),
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(9),
                    decoration: BoxDecoration(
                      // ignore: deprecated_member_use
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.edit_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ===== CONTENT =====
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Color(0xFFF8FAFC),
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 28, 20, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Section: Akun
                    _sectionLabel('Akun'),
                    const SizedBox(height: 10),
                    _settingsCard(
                      children: [
                        _SettingTile(
                          icon: Icons.person_rounded,
                          iconColor: kAccentBlue,
                          title: 'Edit Profile',
                          subtitle: 'Ubah nama dan foto profil',
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const EditProfileScreen(),
                            ),
                          ),
                        ),
                        _SettingTile(
                          icon: Icons.notifications_rounded,
                          iconColor: const Color(0xFF7C3AED),
                          title: 'Notifikasi',
                          subtitle: 'Pengaturan pemberitahuan',
                          onTap: () {},
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Section: Lainnya
                    _sectionLabel('Lainnya'),
                    const SizedBox(height: 10),
                    _settingsCard(
                      children: [
                        _SettingTile(
                          icon: Icons.settings_rounded,
                          iconColor: const Color(0xFF059669),
                          title: 'Pengaturan',
                          subtitle: 'Preferensi aplikasi',
                          onTap: () {},
                        ),
                        _SettingTile(
                          icon: Icons.help_rounded,
                          iconColor: const Color(0xFFD97706),
                          title: 'Tentang Aplikasi',
                          subtitle: 'Informasi versi dan pengembang',
                          onTap: () {},
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Logout button
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          await _authController.signOutUser(
                            context: context,
                            ref: ref,
                          );
                        },
                        icon: const Icon(
                          Icons.logout_rounded,
                          size: 18,
                          color: Colors.white,
                        ),
                        label: const Text(
                          'Logout',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFDC2626),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 0,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionLabel(String label) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 16,
          decoration: BoxDecoration(
            color: kAccentBlue,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: kTextMuted,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  Widget _settingsCard({required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: List.generate(children.length, (index) {
          return Column(
            children: [
              children[index],
              if (index < children.length - 1)
                const Divider(height: 1, indent: 60, endIndent: 16),
            ],
          );
        }),
      ),
    );
  }
}

class _SettingTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;

  const _SettingTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    this.subtitle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            // Icon box
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                // ignore: deprecated_member_use
                color: iconColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(11),
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 14),
            // Text
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: kTextDark,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      style: const TextStyle(fontSize: 12, color: kTextMuted),
                    ),
                  ],
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 14,
              color: kTextMuted,
            ),
          ],
        ),
      ),
    );
  }
}
