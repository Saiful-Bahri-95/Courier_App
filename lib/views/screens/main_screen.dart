import 'package:flutter/material.dart';
import 'package:convex_bottom_bar/convex_bottom_bar.dart';

import 'package:store_app/views/screens/nav_screens/account_screen.dart';
import 'package:store_app/views/screens/nav_screens/history_screen.dart';
import 'package:store_app/views/screens/nav_screens/home_screen.dart';
import 'package:store_app/views/screens/nav_screens/send_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _pageIndex = 0;

  final List<Widget> _pages = [
    HomeScreen(),
    SendScreen(),
    HistoryScreen(),
    AccountScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        child: _pages[_pageIndex],
      ),

      /// ✅ CONVEX BOTTOM BAR (FamilyMart style)
      bottomNavigationBar: ConvexAppBar(
        style: TabStyle.reactCircle, // 🔥 efek ikon naik keluar
        height: 60,
        gradient: const LinearGradient(
          colors: [
            Color.fromARGB(255, 12, 210, 255),
            Color.fromARGB(255, 255, 255, 255),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        activeColor: Color(0xFF030F2F),
        color: const Color.fromARGB(255, 114, 75, 75),

        items: const [
          TabItem(icon: Icons.home_work, title: 'Home'),
          TabItem(icon: Icons.send_rounded, title: 'Send'),
          TabItem(icon: Icons.history_edu, title: 'History'),
          TabItem(icon: Icons.person_outline, title: 'Account'),
        ],

        initialActiveIndex: _pageIndex,
        onTap: (int index) {
          setState(() {
            _pageIndex = index;
          });
        },
      ),
    );
  }
}
