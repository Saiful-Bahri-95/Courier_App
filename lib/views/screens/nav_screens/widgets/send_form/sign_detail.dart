import 'package:flutter/material.dart';
import 'package:signature/signature.dart';
import 'package:store_app/models/document_data.dart';
import 'package:store_app/views/screens/utils.dart';
import 'preview_document.dart';
import 'send_form_widgets.dart';

class SignDetail extends StatefulWidget {
  final DocumentData documentData;
  const SignDetail({super.key, required this.documentData});

  @override
  State<SignDetail> createState() => _SignDetailState();
}

class _SignDetailState extends State<SignDetail> {
  final _formKey = GlobalKey<FormState>();
  final signedNameCtrl = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  bool _hasSignature = false;

  final SignatureController _signatureController = SignatureController(
    penStrokeWidth: 3,
    penColor: Colors.black,
  );

  @override
  void initState() {
    super.initState();
    _signatureController.addListener(() {
      if (_signatureController.isNotEmpty && !_hasSignature) {
        setState(() => _hasSignature = true);
      }
    });
  }

  @override
  void dispose() {
    signedNameCtrl.dispose();
    _signatureController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: kNavyBlue,
      body: Column(
        children: [
          buildSendHeader(
            context,
            title: 'Send Document',
            subtitle: 'Tanda Tangan & Konfirmasi',
          ),
          buildWhiteFormContainer(
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildStepIndicator(current: 3, total: 3),
                    const SizedBox(height: 20),
                    buildSectionLabel('Tanggal Penerimaan'),
                    const SizedBox(height: 12),
                    _buildDatePicker(),
                    const SizedBox(height: 20),
                    buildSectionLabel('Data Penerima'),
                    const SizedBox(height: 12),
                    buildFormField(
                      label: 'Nama Penerima',
                      icon: Icons.person_rounded,
                      controller: signedNameCtrl,
                    ),
                    const SizedBox(height: 8),
                    buildSectionLabel('Tanda Tangan'),
                    const SizedBox(height: 12),
                    _buildSignaturePad(),
                    const SizedBox(height: 28),
                    buildBottomNavButtons(
                      context: context,
                      nextLabel: 'Preview',
                      nextIcon: Icons.preview_rounded,
                      onNext: _onSubmit,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _onSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_signatureController.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.warning_rounded, color: Colors.white),
              SizedBox(width: 8),
              Text('Tanda tangan wajib diisi'),
            ],
          ),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      return;
    }

    await Future.delayed(const Duration(milliseconds: 100));
    final signatureBytes = await _signatureController.toPngBytes();

    if (signatureBytes == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal memproses tanda tangan')),
      );
      return;
    }

    widget.documentData
      ..receivedDate = _selectedDate
      ..signedName = signedNameCtrl.text.trim()
      ..signature = signatureBytes;

    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            PreviewDocumentScreen(documentData: widget.documentData),
      ),
    );
  }

  Widget _buildDatePicker() {
    final DateTime today = DateTime.now();
    final List<DateTime> dates = List.generate(
      5,
      (i) => today.subtract(const Duration(days: 2)).add(Duration(days: i)),
    );

    const days = ['Min', 'Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab'];
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];

    return SizedBox(
      height: 88,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: dates.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final date = dates[index];
          final isSelected =
              date.day == _selectedDate.day &&
              date.month == _selectedDate.month &&
              date.year == _selectedDate.year;
          final isToday =
              date.day == today.day &&
              date.month == today.month &&
              date.year == today.year;

          return GestureDetector(
            onTap: () => setState(() => _selectedDate = date),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 64,
              decoration: BoxDecoration(
                color: isSelected ? kAccentBlue : kLightBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected
                      ? kAccentBlue
                      : isToday
                      ? kAccentBlue
                      : kBorderColor,
                  width: isToday && !isSelected ? 1.5 : 1,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    days[date.weekday % 7],
                    style: TextStyle(
                      fontSize: 11,
                      color: isSelected ? Colors.white70 : kTextMuted,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${date.day}',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.white : kTextDark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    months[date.month - 1],
                    style: TextStyle(
                      fontSize: 11,
                      color: isSelected ? Colors.white70 : kTextMuted,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSignaturePad() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 200,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: _hasSignature ? kAccentBlue : kBorderColor,
              width: _hasSignature ? 2 : 1,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(13),
            child: Stack(
              children: [
                Signature(
                  controller: _signatureController,
                  backgroundColor: kLightBg,
                ),
                if (!_hasSignature)
                  const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.draw_rounded, size: 32, color: kBorderColor),
                        SizedBox(height: 8),
                        Text(
                          'Tanda tangan di sini',
                          style: TextStyle(color: kTextMuted, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        TextButton.icon(
          onPressed: () {
            _signatureController.clear();
            setState(() => _hasSignature = false);
          },
          icon: const Icon(Icons.refresh_rounded, size: 16, color: kTextMuted),
          label: const Text(
            'Ulangi Tanda Tangan',
            style: TextStyle(color: kTextMuted, fontSize: 13),
          ),
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          ),
        ),
      ],
    );
  }
}
