import 'package:flutter/material.dart';
import 'package:store_app/models/document_data.dart';
import 'package:intl/intl.dart';
import 'package:store_app/models/document_detail_model.dart';
import 'package:store_app/services/cloudinary_service.dart';
import 'package:store_app/services/document_service.dart';
import 'package:store_app/services/manage_http_response.dart';
import 'package:store_app/views/screens/main_screen.dart';

class PreviewDocumentScreen extends StatelessWidget {
  final DocumentData? documentData;
  final String? documentId;

  const PreviewDocumentScreen({
    super.key,
    required this.documentData,
    this.documentId,
  });

  String _formatDateTime(DateTime? date) {
    if (date == null) return "-";
    return DateFormat('EEEE, d/MM/y, HH:mm:ss').format(date);
  }

  @override
  Widget build(BuildContext context) {
    // MODE CREATE / PREVIEW
    if (documentData != null) {
      return _buildPreview(context, documentData!);
    }

    // MODE VIEW / DETAIL (FETCH API)
    return FutureBuilder<DocumentDetailModel>(
      future: DocumentService.getDocumentDetail(documentId!),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(body: Center(child: Text(snapshot.error.toString())));
        }

        final detail = snapshot.data!;
        final mappedData = detail.toDocumentData();

        return _buildPreview(context, mappedData);
      },
    );
  }

  Widget _buildPreview(BuildContext context, DocumentData data) {
    return Scaffold(
      appBar: AppBar(title: const Text("Preview Dokumen")),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _section("Pengirim", [
              _item("Perusahaan", data.senderCompany),
              _item("Nama Pengirim", data.senderName),
              _item("Telepon", data.senderPhone),
            ]),

            _section("Dokumen", [
              _item("Jenis Dokumen", data.documentType),
              _item("Deskripsi", data.description),
            ]),

            _section("Penerima", [
              _item("Perusahaan", data.receiverCompany),
              _item("Nama", data.receiverName),
              _item("Telepon", data.receiverPhone),
            ]),

            if (data.receiverImage != null || data.receiverImageUrl != null)
              _section("Foto Penerima", [_receiverImagePreview(data)]),

            _section("Tanda Tangan", [
              _item("Tanggal", _formatDateTime(data.receivedDate)),
              _item("Nama", data.signedName),
            ]),

            if (data.signature != null || data.signatureUrl != null)
              _section("Preview Tanda Tangan", [_signaturePreview(data)]),

            const SizedBox(height: 100), // ruang buat tombol bawah
          ],
        ),
      ),

      // 🔥 PINDAHKAN SUBMIT KE SINI
      bottomNavigationBar: documentId == null ? _submitButton(context) : null,
    );
  }

  // ===== UI Helpers =====

  Widget _section(String title, List<Widget> children) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _item(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Label
          SizedBox(
            width: 120, // 🔥 bikin semua label sejajar
            child: Text(label, style: const TextStyle(color: Colors.black)),
          ),

          // Separator ( : atau = )
          const SizedBox(
            width: 10,
            child: Text(":", style: TextStyle(color: Colors.grey)),
          ),

          // Value
          Expanded(
            child: Text(value ?? "-", style: const TextStyle(fontSize: 15)),
          ),
        ],
      ),
    );
  }

  Widget _receiverImagePreview(DocumentData data) {
    // MODE CREATE → pakai File
    if (data.receiverImage != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.file(data.receiverImage!, height: 200, fit: BoxFit.cover),
      );
    }

    // MODE VIEW → pakai URL
    if (data.receiverImageUrl != null && data.receiverImageUrl!.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.network(
          data.receiverImageUrl!,
          height: 200,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return const SizedBox(
              height: 200,
              child: Center(child: CircularProgressIndicator()),
            );
          },
          errorBuilder: (_, __, ___) => const Icon(Icons.broken_image),
        ),
      );
    }

    return const Text('-');
  }

  Widget _signaturePreview(DocumentData data) {
    // MODE CREATE → Uint8List
    if (data.signature != null) {
      return Container(
        height: 150,
        decoration: BoxDecoration(border: Border.all(color: Colors.grey)),
        child: Image.memory(data.signature!),
      );
    }

    // MODE VIEW → URL
    if (data.signatureUrl != null && data.signatureUrl!.isNotEmpty) {
      return Container(
        height: 150,
        decoration: BoxDecoration(border: Border.all(color: Colors.grey)),
        child: Image.network(data.signatureUrl!, fit: BoxFit.contain),
      );
    }

    return const Text('-');
  }

  Widget _submitButton(context) {
    final isViewMode = documentId != null;
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: isViewMode
            ? null
            : () async {
                // 🔒 Tampilkan loading
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (_) =>
                      const Center(child: CircularProgressIndicator()),
                );

                try {
                  // 1️⃣ Upload receiver image
                  String? receiverImageUrl;
                  if (documentData?.receiverImage != null) {
                    receiverImageUrl = await CloudinaryService.uploadFile(
                      documentData!.receiverImage!,
                    );
                  }

                  // 2️⃣ Upload signature
                  String? signatureUrl;
                  if (documentData?.signature != null) {
                    signatureUrl = await CloudinaryService.uploadBytes(
                      documentData?.signature!,
                    );
                  }

                  // 3️⃣ Kirim data ke API
                  await DocumentService.submit(
                    documentData!,
                    receiverImageUrl,
                    signatureUrl,
                  );

                  showSnackbar(context, 'Dokumen berhasil dikirim');

                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const MainScreen()),
                    (route) => false,
                  );
                } catch (e) {
                  showSnackbar(context, e.toString());
                }
              },
        child: Text(isViewMode ? "Dokumen Dikirim" : "Submit Dokumen"),
      ),
    );
  }
}
