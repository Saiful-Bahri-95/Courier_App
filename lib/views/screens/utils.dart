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

// ================================================
// APP COLOR CONSTANTS
// Dipindahkan dari sender_detail.dart agar bisa
// dipakai di semua file tanpa circular import
// ================================================

const kNavyBlue = Color(0xFF1A3C8F);
const kAccentBlue = Color(0xFF2563EB);
const kLightBg = Color(0xFFF1F5F9);
const kTextDark = Color(0xFF1E293B);
const kTextMuted = Color(0xFF64748B);
const kBorderColor = Color(0xFFCBD5E1);
