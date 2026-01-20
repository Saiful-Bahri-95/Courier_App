import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
      // backgroundColor: Color.fromARGB(255, 31, 207, 247),
      backgroundColor: Color(0xFFD25353),
      body: Column(
        children: [
          SizedBox(height: 30),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Text(
                  'Send Document',
                  style: GoogleFonts.getFont(
                    'Poppins',
                    fontSize: 25,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
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
                color: Color.fromARGB(255, 67, 221, 255),
                borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 20, top: 10),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(),
                      const SizedBox(height: 20),
                      _buildFormCard(),
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

  Widget _buildHeader() {
    return Text(
      "Detail Pengiriman",
      style: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: Color(0xFF1E293B),
      ),
      textAlign: TextAlign.left,
    );
  }

  Widget _buildFormCard() {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 20, 10, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildInputField(
            label: "Nama Perusahaan",
            hint: "Masukkan PT",
            icon: Icons.business,
          ),
          _buildInputField(
            label: "Nama Penerima / UP",
            hint: "Masukkan UP",
            icon: Icons.person,
          ),
          _buildInputField(
            label: "Nomor Telepon",
            hint: "Masukkan nomor telepon",
            icon: Icons.phone,
            keyboardType: TextInputType.phone,
          ),
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
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: Icon(icon),
          filled: true,
          fillColor: const Color(0xFFF8FAFC),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: Colors.black, width: 1),
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
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: Colors.black, width: 1),
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
        hintText: "Masukan Perihal / Desc",
        prefixIcon: const Icon(Icons.notes_sharp),
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.black, width: 1),
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return ElevatedButton(
      onPressed: () {
        if (_formKey.currentState!.validate()) {
          // Jika form valid, lanjut ke halaman kedua
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ReceiverDetailScreen(),
            ),
          );
        } else {
          // Jika form tidak valid, tampilkan pesan
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Mohon lengkapi semua data terlebih dahulu"),
              backgroundColor: Colors.red,
            ),
          );
        }
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
