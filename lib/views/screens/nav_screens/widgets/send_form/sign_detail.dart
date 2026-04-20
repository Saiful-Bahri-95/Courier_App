import 'package:flutter/material.dart';
import 'package:signature/signature.dart';
import 'package:store_app/models/document_data.dart';
import 'package:store_app/views/screens/nav_screens/widgets/send_form/sender_detail.dart';
import 'preview_document.dart';

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
      backgroundColor: kNavyBlue,
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _stepIndicator(current: 3, total: 3),
                      const SizedBox(height: 20),
                      _sectionLabel('Tanggal Penerimaan'),
                      const SizedBox(height: 12),
                      _buildDatePicker(),
                      const SizedBox(height: 20),
                      _sectionLabel('Data Penerima'),
                      const SizedBox(height: 12),
                      _buildField(
                        label: 'Nama Penerima',
                        icon: Icons.person_rounded,
                        controller: signedNameCtrl,
                      ),
                      const SizedBox(height: 8),
                      _sectionLabel('Tanda Tangan'),
                      const SizedBox(height: 12),
                      _buildSignaturePad(),
                      const SizedBox(height: 28),
                      _buildBottomButtons(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
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
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
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
              const Text(
                'Send Document',
                style: TextStyle(
                  fontSize: 22,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Tanda Tangan & Konfirmasi',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.white.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _stepIndicator({required int current, required int total}) {
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

  Widget _sectionLabel(String label) {
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
                      ? kAccentBlue.withOpacity(0.3)
                      : kBorderColor,
                  width: isSelected ? 0 : 1,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: kAccentBlue.withOpacity(0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : [],
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

  Widget _buildField({
    required String label,
    required IconData icon,
    required TextEditingController controller,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: controller,
        style: const TextStyle(fontSize: 14, color: kTextDark),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: kTextMuted, fontSize: 13),
          prefixIcon: Icon(icon, size: 20, color: kAccentBlue),
          filled: true,
          fillColor: kLightBg,
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
        validator: (value) =>
            value == null || value.trim().isEmpty ? '$label wajib diisi' : null,
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
        Row(
          children: [
            TextButton.icon(
              onPressed: () {
                _signatureController.clear();
                setState(() => _hasSignature = false);
              },
              icon: const Icon(
                Icons.refresh_rounded,
                size: 16,
                color: kTextMuted,
              ),
              label: const Text(
                'Ulangi Tanda Tangan',
                style: TextStyle(color: kTextMuted, fontSize: 13),
              ),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBottomButtons() {
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
            onPressed: () async {
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
                // ignore: use_build_context_synchronously
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Gagal memproses tanda tangan')),
                );
                return;
              }

              widget.documentData
                ..receivedDate = _selectedDate
                ..signedName = signedNameCtrl.text.trim()
                ..signature = signatureBytes;

              Navigator.push(
                // ignore: use_build_context_synchronously
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      PreviewDocumentScreen(documentData: widget.documentData),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(0, 52),
              backgroundColor: kAccentBlue,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              elevation: 0,
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.preview_rounded, color: Colors.white, size: 18),
                SizedBox(width: 6),
                Text(
                  'Preview',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
