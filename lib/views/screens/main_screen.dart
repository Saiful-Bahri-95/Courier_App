import 'package:flutter/material.dart';
import 'package:convex_bottom_bar/convex_bottom_bar.dart';

import 'package:store_app/views/screens/nav_screens/account_screen.dart';
import 'package:store_app/views/screens/nav_screens/history_screen.dart';
import 'package:store_app/views/screens/nav_screens/home_screen.dart';
import 'package:store_app/views/screens/nav_screens/send_screen.dart';
import 'package:store_app/views/screens/utils.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _pageIndex = 0;

  final List<Widget> _pages = [
    const HomeScreen(),
    const SendScreen(),
    const HistoryScreen(),
    AccountScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        switchInCurve: Curves.easeOut,
        switchOutCurve: Curves.easeIn,
        child: KeyedSubtree(
          key: ValueKey<int>(_pageIndex),
          child: _pages[_pageIndex],
        ),
      ),

      bottomNavigationBar: ConvexAppBar(
        style: TabStyle.reactCircle,
        height: 58,
        backgroundColor: kNavyBlue,
        activeColor: Colors.white,
        color: Colors.white54,
        elevation: 12,
        curveSize: 80,
        top: -24,

        items: const [
          TabItem(icon: Icons.home_rounded, title: 'Home'),
          TabItem(icon: Icons.send_rounded, title: 'Send'),
          TabItem(icon: Icons.history_rounded, title: 'History'),
          TabItem(icon: Icons.person_rounded, title: 'Account'),
        ],

        initialActiveIndex: _pageIndex,
        onTap: (int index) => setState(() => _pageIndex = index),
      ),
    );
  }
}
