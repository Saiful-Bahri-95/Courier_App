import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:store_app/provider/user_provider.dart';

class HeaderWidget extends ConsumerWidget {
  const HeaderWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final width = MediaQuery.of(context).size.width;
    final user = ref.watch(userProvider);

    return SizedBox(
      width: width,
      height: 180,
      child: Stack(
        children: [
          /// Background Banner
          Container(
            width: width,
            height: 130,
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF786DF5), Color(0xFFA79EFF)],
              ),
            ),
          ),

          /// Gradient Overlay
          Container(
            width: width,
            height: 150,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                // ignore: deprecated_member_use
                colors: [Colors.black.withOpacity(0.35), Colors.transparent],
              ),
            ),
          ),

          /// Search Bar
          Positioned(
            left: 16,
            right: 16,
            bottom: 30,
            top: 100,
            child: Material(
              elevation: 6,
              borderRadius: BorderRadius.circular(20),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Cari Apapun Disini',
                  hintStyle: TextStyle(color: Colors.grey.shade600),
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.camera_alt_outlined),
                    onPressed: () {},
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
          ),

          /// Header User Info
          Positioned(
            top: 40,
            left: 20,
            right: 20,
            child: Row(
              children: [
                /// Avatar + Name
                Row(
                  children: [
                    _UserAvatar(user: user),
                    const SizedBox(width: 12),
                    _UserGreeting(user: user),
                  ],
                ),

                const Spacer(),

                _ActionIcon(icon: Icons.notifications_none, onTap: () {}),
                const SizedBox(width: 12),
                _ActionIcon(icon: Icons.chat_bubble_outline, onTap: () {}),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _UserAvatar extends StatelessWidget {
  // ignore: prefer_typing_uninitialized_variables
  final user;

  const _UserAvatar({required this.user});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(2), // border thickness
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.teal, // border color
      ),
      child: CircleAvatar(
        radius: 22,
        backgroundColor: Colors.white,
        backgroundImage:
            (user != null && user.avatar != null && user.avatar!.isNotEmpty)
            ? NetworkImage(
                '${user.avatar}?v=${DateTime.now().millisecondsSinceEpoch}',
              )
            : const AssetImage('assets/images/banner2.png') as ImageProvider,
      ),
    );
  }
}

class _UserGreeting extends StatelessWidget {
  // ignore: prefer_typing_uninitialized_variables
  final user;

  const _UserGreeting({required this.user});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          user != null ? 'Hi, ${user.fullname}' : 'Hi!',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 1),
        const Text(
          'Good to see you again!',
          style: TextStyle(color: Colors.white70, fontSize: 12),
        ),
      ],
    );
  }
}

/// Reusable Icon Button
class _ActionIcon extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _ActionIcon({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      // ignore: deprecated_member_use
      color: Colors.white.withOpacity(0.9),
      borderRadius: BorderRadius.circular(20),
      elevation: 4,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: SizedBox(
          width: 40,
          height: 40,
          child: Icon(icon, color: Colors.black87, size: 22),
        ),
      ),
    );
  }
}
