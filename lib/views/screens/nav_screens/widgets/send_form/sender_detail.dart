import 'package:flutter/material.dart';
import 'package:store_app/models/document_data.dart';
import 'package:store_app/views/screens/nav_screens/widgets/send_form/receive_detail.dart';
import 'package:store_app/views/screens/utils.dart';
import 'send_form_widgets.dart';

class SenderDetail extends StatefulWidget {
  final DocumentData documentData;
  final bool isDraft;
  const SenderDetail({
    super.key,
    required this.documentData,
    this.isDraft = false,
  });

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
      resizeToAvoidBottomInset: true,
      backgroundColor: kNavyBlue,
      body: Column(
        children: [
          buildSendHeader(
            context,
            title: 'Send Document',
            subtitle: 'Detail Pengirim',
          ),
          buildWhiteFormContainer(
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildStepIndicator(current: 1, total: 3),
                    const SizedBox(height: 20),
                    buildSectionLabel('Informasi Perusahaan'),
                    const SizedBox(height: 12),
                    buildFormField(
                      label: 'Nama Perusahaan',
                      icon: Icons.business_rounded,
                      controller: companyCtrl,
                      readOnly: true,
                    ),
                    buildFormField(
                      label: 'Nomor Telepon',
                      icon: Icons.phone_rounded,
                      controller: phoneCtrl,
                      keyboardType: TextInputType.phone,
                      readOnly: true,
                    ),
                    buildFormField(
                      label: 'Nama Pengirim',
                      icon: Icons.person_rounded,
                      controller: senderCtrl,
                    ),
                    const SizedBox(height: 8),
                    buildSectionLabel('Informasi Dokumen'),
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
        ],
      ),
    );
  }

  Widget _buildDropdown() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: DropdownButtonFormField<String>(
        initialValue: selectedDocumentType,
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
                builder: (_) => ReceiverDetailScreen(
                  documentData: widget.documentData,
                  isDraft: widget.isDraft,
                ),
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
