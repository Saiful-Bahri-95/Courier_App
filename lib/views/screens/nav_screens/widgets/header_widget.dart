import 'package:flutter/material.dart';

class HeaderWidget extends StatelessWidget {
  const HeaderWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

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
                colors: [
                  // ignore: deprecated_member_use
                  Colors.black.withOpacity(0.35),
                  Colors.transparent,
                ],
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
                  hintText: 'Cari produk favoritmu...',
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

          /// Action Icons
          Positioned(
            top: 40,
            left: 20,
            right: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    /// Foto Profil
                    const CircleAvatar(
                      radius: 22,
                      backgroundImage: AssetImage(
                        'assets/images/banner2.png', // ganti sesuai aset Anda
                      ),
                      backgroundColor: Colors.white,
                    ),

                    const SizedBox(width: 12),

                    /// Text Greeting
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Hi, Saiful Bahri',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 1),
                        Text(
                          'Good to see you again!',
                          style: TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                      ],
                    ),
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
          child: Icon(icon, color: Colors.black87),
        ),
      ),
    );
  }
}
