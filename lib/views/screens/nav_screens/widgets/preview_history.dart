import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:store_app/models/document_data.dart';
import 'package:store_app/models/document_detail_model.dart';
import 'package:store_app/services/document_service.dart';

class BottomSheetPreviewDocument extends StatelessWidget {
  final String documentId;

  const BottomSheetPreviewDocument({super.key, required this.documentId});

  String _formatDateTime(DateTime? date) {
    if (date == null) return "-";
    return DateFormat('EEEE, d/MM/y, HH:mm:ss').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentDetailModel>(
      future: DocumentService.getDocumentDetail(documentId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.all(40),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return Padding(
            padding: const EdgeInsets.all(24),
            child: Center(child: Text(snapshot.error.toString())),
          );
        }

        final data = snapshot.data!.toDocumentData();

        return Column(
          children: [
            /// ================= HEADER =================
            const SizedBox(height: 8),

            /// 🔹 Swipe Indicator
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade400,
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            const SizedBox(height: 12),

            /// 🔹 Title + Close Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Preview Dokumen",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            SizedBox(height: 8),

            const Divider(height: 2),

            /// ================= CONTENT =================
            Expanded(
              child: SingleChildScrollView(
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

                    if (data.receiverImage != null ||
                        data.receiverImageUrl != null)
                      _section("Foto Penerima", [_receiverImagePreview(data)]),

                    _section("Tanda Tangan", [
                      _item("Tanggal", _formatDateTime(data.receivedDate)),
                      _item("Nama", data.signedName),
                    ]),

                    if (data.signature != null || data.signatureUrl != null)
                      _section("Preview Tanda Tangan", [
                        _signaturePreview(data),
                      ]),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // ================= HELPERS =================

  static Widget _section(String title, List<Widget> children) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }

  static Widget _item(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 120, child: Text(label)),
          const SizedBox(width: 8, child: Text(":")),
          Expanded(child: Text(value ?? "-")),
        ],
      ),
    );
  }

  static Widget _receiverImagePreview(DocumentData data) {
    if (data.receiverImage != null) {
      return Image.file(data.receiverImage!, height: 200, fit: BoxFit.cover);
    }

    if (data.receiverImageUrl != null && data.receiverImageUrl!.isNotEmpty) {
      return Image.network(
        data.receiverImageUrl!,
        height: 200,
        fit: BoxFit.cover,
      );
    }

    return const Text("-");
  }

  static Widget _signaturePreview(DocumentData data) {
    if (data.signature != null) {
      return Image.memory(data.signature!, height: 150);
    }

    if (data.signatureUrl != null && data.signatureUrl!.isNotEmpty) {
      return Image.network(data.signatureUrl!, height: 150);
    }

    return const Text("-");
  }
}
