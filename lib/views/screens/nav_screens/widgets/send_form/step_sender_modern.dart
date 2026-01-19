import 'package:flutter/material.dart';
import 'modern_input.dart';
import 'modern_date_picker.dart';

class StepSenderModern extends StatelessWidget {
  const StepSenderModern({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: const [
        ModernInput(hint: 'Kepada / To', icon: Icons.person_outline),
        ModernInput(
          hint: 'Alamat / Address',
          icon: Icons.location_on_outlined,
          maxLines: 2,
        ),
        ModernInput(hint: 'Dari / From', icon: Icons.business_outlined),
        ModernInput(
          hint: 'Telepon / Phone',
          icon: Icons.phone_outlined,
          keyboardType: TextInputType.phone,
        ),
        ModernDatePicker(
          hint: 'Tanggal Kirim',
          icon: Icons.calendar_today_outlined,
        ),
      ],
    );
  }
}
