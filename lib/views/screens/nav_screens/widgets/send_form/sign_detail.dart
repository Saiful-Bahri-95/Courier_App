import 'package:flutter/material.dart';
import 'package:signature/signature.dart';

class SignDetail extends StatefulWidget {
  const SignDetail({super.key});

  @override
  State<SignDetail> createState() => _SignDetailState();
}

class _SignDetailState extends State<SignDetail> {
  final _formKey = GlobalKey<FormState>();

  final SignatureController _signatureController = SignatureController(
    penStrokeWidth: 3,
    penColor: Colors.black,
  );

  @override
  void dispose() {
    _signatureController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 31, 207, 247),
      body: Column(
        children: [
          // SizedBox(height: 30),
          Padding(
            padding: const EdgeInsets.only(left: 20, top: 50, bottom: 24),
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
          // SizedBox(height: 24),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(5),
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
                padding: const EdgeInsets.all(20),
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
          const Text(
            "Tanda Tangan  & Penerima",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildInput('Nama Penerima', Icons.person),
          const SizedBox(height: 16),
          _buildSignaturePad(),
          const SizedBox(height: 20),
          _buildFloatingBottomButton(),
        ],
      ),
    );
  }

  Widget _buildSignaturePad() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 180,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Signature(
            controller: _signatureController,
            backgroundColor: const Color(0xFFF8FAFC),
          ),
        ),
        const SizedBox(height: 10),
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

  Widget _buildInput(
    String label,
    IconData icon, {
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
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SignDetail()),
                );
                // if (_formKey.currentState!.validate()) {
                //   if (receiverImage == null) {
                //     ScaffoldMessenger.of(context).showSnackBar(
                //       const SnackBar(
                //         content: Text("Silakan ambil foto penerima"),
                //       ),
                //     );
                //     return;
                //   }

                //   // if (_signatureController.isEmpty) {
                //   //   ScaffoldMessenger.of(context).showSnackBar(
                //   //     const SnackBar(content: Text("Silakan isi tanda tangan")),
                //   //   );
                //   //   return;
                //   // }

                //   ScaffoldMessenger.of(context).showSnackBar(
                //     const SnackBar(
                //       content: Text("Data penerima berhasil disimpan"),
                //     ),
                //   );
                // }
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
                "Next",
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
}
