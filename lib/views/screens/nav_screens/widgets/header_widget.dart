import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:store_app/provider/user_provider.dart';
import 'package:store_app/views/screens/utils.dart';

class HeaderWidget extends ConsumerWidget {
  const HeaderWidget({super.key});

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Selamat Pagi';
    if (hour < 15) return 'Selamat Siang';
    if (hour < 18) return 'Selamat Sore';
    return 'Selamat Malam';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final topPadding = MediaQuery.of(context).padding.top;
    final user = ref.watch(userProvider);

    return Container(
      color: kNavyBlue,
      padding: EdgeInsets.only(top: topPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Top bar: avatar + greeting + actions ──
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
            child: Row(
              children: [
                // Avatar
                Container(
                  padding: const EdgeInsets.all(2.5),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    // ignore: deprecated_member_use
                    color: Colors.white.withOpacity(0.25),
                  ),
                  child: CircleAvatar(
                    radius: 22,
                    backgroundColor: Colors.white,
                    backgroundImage:
                        (user != null &&
                            user.avatar != null &&
                            user.avatar!.isNotEmpty)
                        ? NetworkImage(
                                '${user.avatar}?v=${DateTime.now().millisecondsSinceEpoch}',
                              )
                              as ImageProvider
                        : const AssetImage('assets/images/banner2.png'),
                  ),
                ),
                const SizedBox(width: 12),

                // Greeting
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getGreeting(),
                        style: TextStyle(
                          fontSize: 12,
                          // ignore: deprecated_member_use
                          color: Colors.white.withOpacity(0.65),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 1),
                      Text(
                        user != null ? user.fullname : 'Pengguna',
                        style: const TextStyle(
                          fontSize: 17,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.2,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),

                // Action icons
                _ActionIcon(icon: Icons.notifications_rounded, onTap: () {}),
                const SizedBox(width: 10),
                _ActionIcon(icon: Icons.chat_bubble_rounded, onTap: () {}),
              ],
            ),
          ),

          // ── Search bar ──
          Container(
            margin: const EdgeInsets.fromLTRB(20, 0, 20, 0),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  // ignore: deprecated_member_use
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                const Icon(Icons.search_rounded, color: kTextMuted, size: 20),
                const SizedBox(width: 10),
                const Expanded(
                  child: TextField(
                    style: TextStyle(fontSize: 14, color: kTextDark),
                    decoration: InputDecoration(
                      hintText: 'Cari dokumen...',
                      hintStyle: TextStyle(color: kBorderColor, fontSize: 14),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
                Container(
                  width: 1,
                  height: 22,
                  color: kBorderColor,
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                ),
                GestureDetector(
                  onTap: () {},
                  child: const Icon(
                    Icons.document_scanner_rounded,
                    color: kAccentBlue,
                    size: 20,
                  ),
                ),
              ],
            ),
          ),

          // ── Bottom curve spacer ──
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class _ActionIcon extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _ActionIcon({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          // ignore: deprecated_member_use
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }
}
