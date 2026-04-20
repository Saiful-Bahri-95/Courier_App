import 'package:flutter/material.dart';
import 'package:store_app/models/document_data.dart';
import 'package:store_app/views/screens/nav_screens/widgets/send_form/receive_detail.dart';

// ========================
// SHARED THEME CONSTANTS
// ========================
const kNavyBlue = Color(0xFF1A3C8F);
const kAccentBlue = Color(0xFF2563EB);
const kLightBg = Color(0xFFF1F5F9);
const kTextDark = Color(0xFF1E293B);
const kTextMuted = Color(0xFF64748B);
const kBorderColor = Color(0xFFCBD5E1);

class SenderDetail extends StatefulWidget {
  final DocumentData documentData;
  const SenderDetail({super.key, required this.documentData});

  @override
  State<SenderDetail> createState() => _SenderDetailState();
}

class _SenderDetailState extends State<SenderDetail> {
  final _formKey = GlobalKey<FormState>();
  final companyCtrl = TextEditingController();
  final senderCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final descCtrl = TextEditingController();
  String? selectedDocumentType;

  @override
  void initState() {
    super.initState();
    companyCtrl.text = 'PT KGI Sekuritas Indonesia';
    phoneCtrl.text = '021-2505337';
  }

  @override
  void dispose() {
    companyCtrl.dispose();
    senderCtrl.dispose();
    phoneCtrl.dispose();
    descCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 8, 11, 18),
      body: Column(
        children: [
          _buildHeader(context, 'Detail Pengirim', step: 1),
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
                      _stepIndicator(current: 1, total: 3),
                      const SizedBox(height: 20),
                      _sectionLabel('Informasi Perusahaan'),
                      const SizedBox(height: 12),
                      _buildField(
                        label: 'Nama Perusahaan',
                        icon: Icons.business_rounded,
                        controller: companyCtrl,
                        readOnly: true,
                      ),
                      _buildField(
                        label: 'Nomor Telepon',
                        icon: Icons.phone_rounded,
                        controller: phoneCtrl,
                        keyboardType: TextInputType.phone,
                        readOnly: true,
                      ),
                      _buildField(
                        label: 'Nama Pengirim',
                        icon: Icons.person_rounded,
                        controller: senderCtrl,
                      ),
                      const SizedBox(height: 8),
                      _sectionLabel('Informasi Dokumen'),
                      const SizedBox(height: 12),
                      _buildDropdown(),
                      _buildNoteField(),
                      const SizedBox(height: 28),
                      _buildNextButton(),
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

  Widget _buildHeader(BuildContext context, String title, {required int step}) {
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
                  letterSpacing: 0.3,
                ),
              ),
              Text(
                title,
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

  Widget _buildField({
    required String label,
    required IconData icon,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    bool readOnly = false,
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
          labelStyle: TextStyle(
            color: readOnly ? kTextMuted : kTextMuted,
            fontSize: 13,
          ),
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
            borderSide: BorderSide(
              color: readOnly ? kBorderColor : kBorderColor,
              width: 1,
            ),
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
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return '$label wajib diisi';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildDropdown() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: DropdownButtonFormField<String>(
        value: selectedDocumentType,
        decoration: InputDecoration(
          labelText: 'Jenis Dokumen',
          labelStyle: const TextStyle(color: kTextMuted, fontSize: 13),
          prefixIcon: const Icon(
            Icons.description_rounded,
            size: 20,
            color: kAccentBlue,
          ),
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
        items: const [
          DropdownMenuItem(value: 'Document', child: Text('Document')),
          DropdownMenuItem(value: 'Invoice', child: Text('Invoice')),
          DropdownMenuItem(value: 'BG/Cheque', child: Text('BG/Cheque')),
          DropdownMenuItem(value: 'Cash', child: Text('Cash')),
          DropdownMenuItem(value: 'Others', child: Text('Others')),
        ],
        onChanged: (value) => setState(() => selectedDocumentType = value),
        validator: (value) => value == null ? 'Pilih jenis dokumen' : null,
      ),
    );
  }

  Widget _buildNoteField() {
    return TextFormField(
      controller: descCtrl,
      keyboardType: TextInputType.multiline,
      maxLines: 4,
      minLines: 3,
      style: const TextStyle(fontSize: 14, color: kTextDark),
      decoration: InputDecoration(
        labelText: 'Perihal / Deskripsi',
        alignLabelWithHint: true,
        labelStyle: const TextStyle(color: kTextMuted, fontSize: 13),
        prefixIcon: const Padding(
          padding: EdgeInsets.only(bottom: 48),
          child: Icon(Icons.notes_rounded, size: 20, color: kAccentBlue),
        ),
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
      ),
    );
  }

  Widget _buildNextButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: () {
          if (_formKey.currentState!.validate()) {
            widget.documentData
              ..senderCompany = companyCtrl.text.trim()
              ..senderName = senderCtrl.text.trim()
              ..senderPhone = phoneCtrl.text.trim()
              ..documentType = selectedDocumentType
              ..description = descCtrl.text.trim();

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    ReceiverDetailScreen(documentData: widget.documentData),
              ),
            );
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: kAccentBlue,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 0,
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Selanjutnya',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(width: 8),
            Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 18),
          ],
        ),
      ),
    );
  }
}
