import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:store_app/models/document_data.dart';
import 'package:intl/intl.dart';
import 'package:store_app/models/document_detail_model.dart';
import 'package:store_app/provider/user_provider.dart';
import 'package:store_app/services/cloudinary_service.dart';
import 'package:store_app/services/document_service.dart';
import 'package:store_app/services/manage_http_response.dart';
import 'package:store_app/views/screens/main_screen.dart';
import 'package:store_app/views/screens/utils.dart';

class PreviewDocumentScreen extends ConsumerStatefulWidget {
  final DocumentData? documentData;
  final String? documentId;

  const PreviewDocumentScreen({
    super.key,
    required this.documentData,
    this.documentId,
  });

  @override
  ConsumerState<PreviewDocumentScreen> createState() =>
      _PreviewDocumentScreenState();
}

class _PreviewDocumentScreenState extends ConsumerState<PreviewDocumentScreen> {
  String _formatDateTime(DateTime? date) {
    if (date == null) return "-";
    return DateFormat('EEEE, d/MM/y, HH:mm:ss').format(date);
  }

  @override
  Widget build(BuildContext context) {
    // MODE CREATE / PREVIEW
    if (widget.documentData != null) {
      return _buildPreview(context, widget.documentData!);
    }

    // MODE VIEW / DETAIL (FETCH API)
    return FutureBuilder<DocumentDetailModel>(
      future: DocumentService.getDocumentDetail(widget.documentId!),
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
      appBar: AppBar(
        title: Text(
          'Preview Document',
          style: TextStyle(
            fontSize: 25,
            color: Color(0xFF030F2F),
            fontWeight: FontWeight.w500,
            letterSpacing: 0.01,
          ),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _section("Detail Pengirim", [
              _item("Perusahaan", data.senderCompany),
              _item("Nama Pengirim", data.senderName),
              _item("Telepon", data.senderPhone),
            ], gradient: AppGradients.sender),

            _section("Detail Penerima", [
              _item("Perusahaan", data.receiverCompany),
              _item("Nama", data.receiverName),
              _item("Telepon", data.receiverPhone),
            ], gradient: AppGradients.sender),

            _section("Dokumen", [
              _item("Jenis Dokumen", data.documentType),
              Container(
                width: double.infinity, // ✅ penuh
                constraints: const BoxConstraints(minHeight: 120),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Description :\n${data.description ?? "-"}',
                  style: const TextStyle(fontSize: 14),
                ),
              ),
            ], gradient: AppGradients.document),

            if (data.receiverImage != null || data.receiverImageUrl != null)
              _section("Foto Penerima", [
                _receiverImagePreview(data),
              ], gradient: AppGradients.document),

            _section("Tanda Tangan", [
              _item("Tanggal", _formatDateTime(data.receivedDate)),
              _item("Nama", data.signedName),
            ], gradient: AppGradients.document),

            if (data.signature != null || data.signatureUrl != null)
              _section("Preview Tanda Tangan", [
                _signaturePreview(data),
              ], gradient: AppGradients.document),

            const SizedBox(height: 10),
            _submitButton(context), // ruang buat tombol bawah
          ],
        ),
      ),

      // 🔥 PINDAHKAN SUBMIT KE SINI
    );
  }

  // ===== UI Helpers =====
  Widget _section(
    String title,
    List<Widget> children, {
    required Gradient gradient,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: Colors.black.withOpacity(0.9),
            blurRadius: 5,
            offset: const Offset(4, 4),
          ),
        ],
      ),
      child: Card(
        color: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white, // 🔥
                ),
              ),
              const SizedBox(height: 12),
              ...children,
            ],
          ),
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
          SizedBox(
            width: 120,
            child: Text(label, style: const TextStyle(color: Colors.white70)),
          ),
          const SizedBox(
            width: 10,
            child: Text(":", style: TextStyle(color: Colors.white54)),
          ),
          Expanded(
            child: Text(
              value ?? "-",
              style: const TextStyle(fontSize: 15, color: Colors.white),
            ),
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

        child: Image.file(
          data.receiverImage!,
          height: 200,
          width: double.infinity,
          fit: BoxFit.cover,
        ),
      );
    }

    // MODE VIEW → pakai URL
    if (data.receiverImageUrl != null && data.receiverImageUrl!.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.network(
          data.receiverImageUrl!,
          height: 200,
          width: double.infinity,
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
    final isViewMode = widget.documentId != null;

    return SizedBox(
      height: 55,
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isViewMode
            ? null
            : () async {
                // 🔥 AMBIL USER DARI RIVERPOD
                final user = ref.read(userProvider);

                if (user == null) {
                  showSnackbar(context, 'User belum login');
                  return;
                }

                final token = user.token;

                // 🔒 loading
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (_) =>
                      const Center(child: CircularProgressIndicator()),
                );

                try {
                  // 1️⃣ Upload receiver image
                  String? receiverImageUrl;
                  if (widget.documentData?.receiverImage != null) {
                    receiverImageUrl = await UploadService.uploadImageFile(
                      widget.documentData!.receiverImage!,
                      token,
                    );
                  }

                  // 2️⃣ Upload signature
                  String? signatureUrl;
                  if (widget.documentData?.signature != null) {
                    signatureUrl = await UploadService.uploadSignature(
                      widget.documentData!.signature!,
                      token,
                    );
                  }

                  // 3️⃣ Submit ke backend
                  await DocumentService.submit(
                    widget.documentData!,
                    receiverImageUrl,
                    signatureUrl,
                  );

                  Navigator.pop(context); // 🔥 tutup loading

                  showSnackbar(context, 'Dokumen berhasil dikirim');

                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const MainScreen()),
                    (route) => false,
                  );
                } catch (e) {
                  Navigator.pop(context); // 🔥 WAJIB tutup loading saat error
                  showSnackbar(context, e.toString());
                }
              },
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.all(Colors.blueAccent),
        ),
        child: Text(
          isViewMode ? "Dokumen Dikirim" : "Submit Dokumen",
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
