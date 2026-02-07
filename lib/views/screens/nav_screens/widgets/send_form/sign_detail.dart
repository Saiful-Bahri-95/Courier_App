import 'package:flutter/material.dart';
import 'package:signature/signature.dart';
import 'package:store_app/models/document_data.dart';

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

  String _getDayName(DateTime date) {
    const days = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    return days[date.weekday % 7];
  }

  String _getDayMonth(DateTime date) {
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
    return months[date.month - 1];
  }

  final SignatureController _signatureController = SignatureController(
    penStrokeWidth: 3,
    penColor: Colors.black,
  );

  @override
  void dispose() {
    signedNameCtrl.dispose();
    _signatureController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFA79EFF),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 20, top: 50, bottom: 15),
            child: Row(
              children: [
                Text(
                  'Send Document',
                  style: TextStyle(
                    fontSize: 25,
                    color: Color(0xFF030F2F),
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.01,
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(top: 20),
              child: Form(
                key: _formKey,
                child: Column(children: [_buildFormCard()]),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormCard() {
    return Container(
      height: MediaQuery.of(context).size.height,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: Colors.black.withOpacity(0.7),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Tanda Tangan & Penerima",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildTimelineDatePicker(),
          const SizedBox(height: 25),
          _buildInput(
            label: "Nama Penerima",
            icon: Icons.person,
            controller: signedNameCtrl,
          ),
          const SizedBox(height: 2),
          _buildSignaturePad(),

          _buildFloatingBottomButton(),
        ],
      ),
    );
  }

  Widget _buildSignaturePad() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Tanda Tangan Penerima",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 10),
        Container(
          height: 220,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Signature(
            controller: _signatureController,
            backgroundColor: const Color(0xFFF8FAFC),
          ),
        ),
        const SizedBox(height: 5),
        Row(
          children: [
            TextButton.icon(
              onPressed: () => _signatureController.clear(),
              icon: const Icon(Icons.refresh),
              label: const Text("Ulangi Tanda Tangan"),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInput({
    required String label,
    required IconData icon,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          filled: true,
          fillColor: const Color(0xFFF8FAFC),

          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Colors.grey),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Colors.black, width: 2),
          ),
        ),
        validator: (value) =>
            value == null || value.isEmpty ? "$label wajib diisi" : null,
      ),
    );
  }

  Widget _buildFloatingBottomButton() {
    return SafeArea(
      child: Row(
        children: [
          // Back
          Expanded(
            child: OutlinedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(0, 54),
                side: const BorderSide(color: Color(0xFFCBD5E1)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text(
                "Back",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
          ),

          const SizedBox(width: 12),

          // Next
          Expanded(
            child: ElevatedButton(
              onPressed: () async {
                debugPrint("SUBMIT BUTTON PRESSED");
                if (!_formKey.currentState!.validate()) return;

                // 🔥 VALIDASI SIGNATURE DULU
                if (_signatureController.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Tanda tangan wajib diisi")),
                  );
                  return;
                }

                await Future.delayed(const Duration(milliseconds: 100));

                // BARU convert ke PNG
                final signatureBytes = await _signatureController.toPngBytes();

                if (signatureBytes == null) {
                  // ignore: use_build_context_synchronously
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Gagal memproses tanda tangan"),
                    ),
                  );
                  return;
                }
                // Pindah ke preview screen
                widget.documentData
                  ..receivedDate = _selectedDate
                  ..signedName = signedNameCtrl.text
                  ..signature = signatureBytes;

                Navigator.push(
                  // ignore: use_build_context_synchronously
                  context,
                  MaterialPageRoute(
                    builder: (_) => PreviewDocumentScreen(
                      documentData: widget.documentData,
                    ),
                  ),
                );
              },

              style: ElevatedButton.styleFrom(
                minimumSize: const Size(0, 54),
                backgroundColor: const Color(0xFF2563EB),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: const Text(
                "Submit",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineDatePicker() {
    final DateTime today = DateTime.now();
    final List<DateTime> dates = List.generate(
      5,
      (index) =>
          //DateTime(
          // today.year,
          // today.month,
          today.subtract(const Duration(days: 2)).add(Duration(days: index)),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        SizedBox(
          height: 90,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: dates.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final date = dates[index];
              final isSelected =
                  date.day == _selectedDate.day &&
                  date.month == _selectedDate.month &&
                  date.year == _selectedDate.year;

              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedDate = date;
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  width: 68,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFF2563EB)
                        : const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFF2563EB)
                          : Colors.grey.shade300,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              // ignore: deprecated_member_use
                              color: Colors.blue.withOpacity(0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 6),
                            ),
                          ]
                        : [],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _getDayName(date),
                        style: TextStyle(
                          fontSize: 12,
                          color: isSelected ? Colors.white : Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        date.day.toString(),
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: isSelected ? Colors.white : Colors.black,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _getDayMonth(date),
                        style: TextStyle(
                          fontSize: 12,
                          color: isSelected ? Colors.white : Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
