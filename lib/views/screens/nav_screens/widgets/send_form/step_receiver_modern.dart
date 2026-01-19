import 'package:flutter/material.dart';
import 'modern_input.dart';
import 'modern_date_picker.dart';
import 'modern_dropdown.dart';

class StepReceiverModern extends StatelessWidget {
  const StepReceiverModern({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        /// Quantity + Document Type
        Row(
          children: const [
            Expanded(
              child: ModernInput(
                hint: 'Quantity',
                icon: Icons.confirmation_number_outlined,
                keyboardType: TextInputType.number,
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: ModernDropdown(
                hint: 'Type',
                icon: Icons.article_outlined,
                items: ['Document', 'Invoice', 'Cheque', 'Others'],
              ),
            ),
          ],
        ),

        const ModernInput(
          hint: 'Perihal / Description',
          icon: Icons.description_outlined,
          maxLines: 3,
        ),
        const ModernInput(hint: 'Yang Memberi', icon: Icons.person_outline),
        const ModernInput(hint: 'Yang Menerima', icon: Icons.person_outline),
        const ModernDatePicker(
          hint: 'Tanggal Terima',
          icon: Icons.calendar_today_outlined,
        ),
      ],
    );
  }
}
