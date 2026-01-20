import 'package:flutter/material.dart';
import 'package:store_app/views/screens/nav_screens/widgets/send_form/receive_detail.dart';

class SendScreen extends StatefulWidget {
  const SendScreen({super.key});

  @override
  State<SendScreen> createState() => _SendScreenState();
}

class _SendScreenState extends State<SendScreen> {
  final _formKey = GlobalKey<FormState>();

  String? selectedDocumentType;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 31, 207, 247),
      // backgroundColor: Color(0xFFD25353),
      body: Column(
        children: [
          SizedBox(height: 30),
          Padding(
            padding: const EdgeInsets.only(left: 20, top: 20),
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
          SizedBox(height: 24),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Color.fromARGB(255, 240, 245, 250),
                borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                boxShadow: [
                  BoxShadow(
                    // ignore: deprecated_member_use
                    color: Colors.black12,
                    blurRadius: 10,
                    offset: Offset(0, -5),
                  ),
                ],
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 20, top: 10),
                child: Form(
                  key: _formKey,
                  child: Column(children: [_buildFormCard()]),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Detail Pengirim",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 16),
          _buildInputField(label: "Nama Perusahaan", icon: Icons.business),
          _buildInputField(label: "Nama Pengirim", icon: Icons.person),
          _buildInputField(
            label: "Nomor Telepon",
            icon: Icons.phone,
            keyboardType: TextInputType.phone,
          ),
          SizedBox(height: 16),
          Text(
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
          const SizedBox(height: 20),
          _buildSubmitButton(),
        ],
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          filled: true,
          fillColor: const Color(0xFFF8FAFC),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: Colors.grey),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Colors.black, width: 2),
          ),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
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
            borderSide: BorderSide(color: Colors.grey),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Colors.black, width: 2),
          ),
        ),
        initialValue: selectedDocumentType,
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
      maxLines: 3,
      decoration: InputDecoration(
        labelText: "Perihal / Desc",
        prefixIcon: const Icon(Icons.notes_sharp),
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.grey),
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
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ReceiverDetailScreen()),
        );
        // if (_formKey.currentState!.validate()) {
        //   // Jika form valid, lanjut ke halaman kedua
        //   Navigator.push(
        //     context,
        //     MaterialPageRoute(
        //       builder: (context) => const ReceiverDetailScreen(),
        //     ),
        //   );
        // } else {
        //   // Jika form tidak valid, tampilkan pesan
        //   ScaffoldMessenger.of(context).showSnackBar(
        //     const SnackBar(
        //       content: Text("Mohon lengkapi semua data terlebih dahulu"),
        //       backgroundColor: Colors.red,
        //     ),
        //   );
        // }
      },
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(double.infinity, 54),
        backgroundColor: const Color(0xFF2563EB),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
