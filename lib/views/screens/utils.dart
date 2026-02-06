import 'package:flutter/material.dart';

class AppGradients {
  static const sender = LinearGradient(
    colors: [Color(0xFF5F77F5), Color(0xFF37458F)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const receiver = LinearGradient(
    colors: [Color(0xFF3BB54A), Color(0xFF1F7A33)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const document = LinearGradient(
    colors: [Color(0xFF00B4B0), Color(0xFF007E7C)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const signature = LinearGradient(
    colors: [Color(0xFF232526), Color(0xFF414345)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
