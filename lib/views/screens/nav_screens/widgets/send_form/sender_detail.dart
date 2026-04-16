import 'package:flutter/material.dart';
import 'package:store_app/models/document_data.dart';
import 'package:store_app/views/screens/nav_screens/widgets/send_form/receive_detail.dart';

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
  void dispose() {
    companyCtrl.dispose();
    senderCtrl.dispose();
    phoneCtrl.dispose();
    descCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;

    return Scaffold(
      resizeToAvoidBottomInset: true, // ✅ tombol tidak tertutup keyboard
      backgroundColor: const Color(0xFFA79EFF),
      body: Column(
        children: [
          // ✅ Header responsif
          Padding(
            padding: EdgeInsets.only(
              left: 20,
              top: topPadding + 20,
              bottom: 15,
            ),
            child: Row(
              children: [
                const Text(
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

          // ✅ Container putih mengisi sisa layar, scroll di dalamnya
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 30,
                    offset: Offset(0, 10),
                  ),
                ],
              ),
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  // ✅ scroll di dalam container, bukan di luar
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Detail Pengirim",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildInputField(
                        label: "Nama Perusahaan",
                        icon: Icons.business,
                        controller: companyCtrl,
                      ),
                      _buildInputField(
                        label: "Nama Pengirim",
                        icon: Icons.person,
                        controller: senderCtrl,
                      ),
                      _buildInputField(
                        label: "Nomor Telepon",
                        icon: Icons.phone,
                        keyboardType: TextInputType.phone,
                        controller: phoneCtrl,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        "Jenis & Deskripsi Dokumen",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildDropdown(),
                      _buildNoteField(),
                      const SizedBox(height: 24),
                      _buildSubmitButton(), // ✅ tidak pakai Spacer
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

  Widget _buildInputField({
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
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Colors.red),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Colors.red, width: 2),
          ),
        ),
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return "$label wajib diisi";
          }
          return null;
        },
      ),
    );
  }

  Widget _buildDropdown() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          labelText: "Jenis Dokumen",
          prefixIcon: const Icon(Icons.description),
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
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Colors.red),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Colors.red, width: 2),
          ),
        ),
        value: selectedDocumentType,
        items: const [
          DropdownMenuItem(value: "Document", child: Text("Document")),
          DropdownMenuItem(value: "Invoice", child: Text("Invoice")),
          DropdownMenuItem(value: "BG / Cheque", child: Text("BG / Cheque")),
          DropdownMenuItem(value: "Cash", child: Text("Cash")),
          DropdownMenuItem(value: "Others", child: Text("Others")),
        ],
        onChanged: (value) {
          setState(() {
            selectedDocumentType = value;
          });
        },
        validator: (value) => value == null ? "Pilih jenis dokumen" : null,
      ),
    );
  }

  Widget _buildNoteField() {
    return TextFormField(
      controller: descCtrl,
      keyboardType: TextInputType.multiline,
      maxLines: 5,
      minLines: 3,
      decoration: InputDecoration(
        labelText: "Perihal / Desc",
        prefixIcon: const Icon(Icons.notes_sharp),
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
    );
  }

  Widget _buildSubmitButton() {
    return ElevatedButton(
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
              builder: (context) =>
                  ReceiverDetailScreen(documentData: widget.documentData),
            ),
          );
        }
      },
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(double.infinity, 54),
        backgroundColor: const Color(0xFF2563EB),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 2,
      ),
      child: const Text(
        "Next",
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }
}
