import 'package:flutter/material.dart';
import 'package:store_app/views/screens/utils.dart';

// ================================================
// SHARED WIDGETS untuk send_form flow
// Dipakai oleh: sender_detail, receive_detail,
//               sign_detail, preview_document
// ================================================

/// Header biru navy di bagian atas setiap halaman send form
Widget buildSendHeader(
  BuildContext context, {
  required String title,
  required String subtitle,
}) {
  final topPadding = MediaQuery.of(context).padding.top;
  return Container(
    color: kNavyBlue,
    padding: EdgeInsets.only(
      left: 20,
      right: 20,
      top: topPadding + 16,
      bottom: 20,
    ),
    child: Row(
      children: [
        if (Navigator.canPop(context))
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                // ignore: deprecated_member_use
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.arrow_back_ios_new,
                color: Colors.white,
                size: 18,
              ),
            ),
          ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 22,
                color: Colors.white,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.3,
              ),
            ),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 13,
                // ignore: deprecated_member_use
                color: Colors.white.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

/// Progress bar step indicator (misal: step 1 dari 3)
Widget buildStepIndicator({required int current, required int total}) {
  return Row(
    children: List.generate(total, (index) {
      final isActive = index + 1 == current;
      final isDone = index + 1 < current;
      return Expanded(
        child: Row(
          children: [
            Expanded(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                height: 4,
                decoration: BoxDecoration(
                  color: isActive || isDone ? kAccentBlue : kBorderColor,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            if (index < total - 1) const SizedBox(width: 6),
          ],
        ),
      );
    }),
  );
}

/// Label seksi dengan garis biru di kiri
Widget buildSectionLabel(String label) {
  return Row(
    children: [
      Container(
        width: 4,
        height: 18,
        decoration: BoxDecoration(
          color: kAccentBlue,
          borderRadius: BorderRadius.circular(4),
        ),
      ),
      const SizedBox(width: 8),
      Text(
        label,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: kTextDark,
          letterSpacing: 0.2,
        ),
      ),
    ],
  );
}

/// Input field standar yang dipakai di semua halaman send form
Widget buildFormField({
  required String label,
  required IconData icon,
  required TextEditingController controller,
  TextInputType keyboardType = TextInputType.text,
  bool readOnly = false,
  String? Function(String?)? validator,
}) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 14),
    child: TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      readOnly: readOnly,
      style: const TextStyle(fontSize: 14, color: kTextDark),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: kTextMuted, fontSize: 13),
        prefixIcon: Icon(
          icon,
          size: 20,
          color: readOnly ? kTextMuted : kAccentBlue,
        ),
        suffixIcon: readOnly
            ? const Icon(Icons.lock_outline, size: 16, color: kTextMuted)
            : null,
        filled: true,
        fillColor: readOnly ? const Color(0xFFF5F5F5) : kLightBg,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: kBorderColor, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: kAccentBlue, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 1.5),
        ),
      ),
      validator:
          validator ??
          (value) {
            if (value == null || value.trim().isEmpty) {
              return '$label wajib diisi';
            }
            return null;
          },
    ),
  );
}

/// Tombol navigasi bawah (Kembali + Selanjutnya/Submit)
Widget buildBottomNavButtons({
  required BuildContext context,
  required String nextLabel,
  required IconData nextIcon,
  required VoidCallback onNext,
}) {
  return Row(
    children: [
      Expanded(
        child: OutlinedButton(
          onPressed: () => Navigator.pop(context),
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(0, 52),
            side: const BorderSide(color: kBorderColor),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          child: const Text(
            'Kembali',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: kTextDark,
            ),
          ),
        ),
      ),
      const SizedBox(width: 12),
      Expanded(
        child: ElevatedButton(
          onPressed: onNext,
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(0, 52),
            backgroundColor: kAccentBlue,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            elevation: 0,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                nextLabel,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 6),
              Icon(nextIcon, color: Colors.white, size: 18),
            ],
          ),
        ),
      ),
    ],
  );
}

/// Container putih rounded di bawah header — dipakai di semua halaman
Widget buildWhiteFormContainer({required Widget child}) {
  return Expanded(
    child: Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: child,
    ),
  );
}
