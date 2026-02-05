import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:store_app/models/document_data.dart';
import 'package:store_app/models/document_detail_model.dart';
import 'package:store_app/services/document_service.dart';
import 'package:store_app/services/manage_http_response.dart';

class BottomSheetPreviewDocument extends StatelessWidget {
  final String documentId;
  final ScrollController scrollController;

  const BottomSheetPreviewDocument({
    super.key,
    required this.documentId,
    required this.scrollController,
  });

  String _formatDateTime(DateTime? date) {
    if (date == null) return "-";
    return DateFormat('EEEE, dd MMM y').format(date);
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
                    "Info Pengiriman",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            SizedBox(height: 8),

            const Divider(height: 5, color: Colors.black),

            /// ================= CONTENT =================
            Expanded(
              child: SingleChildScrollView(
                controller: scrollController,
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Detail Pengirim",
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Spacer(),

                        Text(
                          _formatDateTime(data.receivedDate),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Color.fromARGB(255, 120, 119, 119),
                          ),
                        ),
                        SizedBox(width: 5),
                      ],
                    ),

                    SizedBox(height: 16),

                    /// ===== DETAIL PENGIRIM =====
                    _gradientInfoCard(
                      title: data.senderCompany ?? "-",
                      subtitle: "From ${data.senderName}",
                      phone: data.senderPhone,
                      imagePath: 'assets/icons/Office.png',
                      gradient: const LinearGradient(
                        colors: [Color(0xFF5F77F5), Color(0xFF37458F)],
                      ),
                    ),

                    const SizedBox(height: 16),
                    Text(
                      "Detail Penerima",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 16),

                    /// ===== DETAIL PENERIMA =====
                    _gradientInfoCard(
                      title: data.receiverCompany ?? "-",
                      subtitle: "To ${data.receiverName}",
                      phone: data.receiverPhone,
                      imagePath: 'assets/icons/penerima.png',
                      gradient: const LinearGradient(
                        colors: [Color(0xFF3BB54A), Color(0xFF1F7A33)],
                      ),
                    ),

                    const SizedBox(height: 16),

                    /// ===== KETERANGAN =====
                    Text(
                      "Keterangan",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),

                    _descriptionCard(
                      description: data.description ?? "-",
                      documentType: data.documentType,
                      signedName: data.signedName,
                      onTapBuktiFoto: () {
                        _showBuktiFoto(context, data);
                      },
                    ),

                    const SizedBox(height: 24),

                    /// ===== BUKTI FOTO =====
                    Row(
                      children: [
                        /// DELETE
                        SizedBox(
                          width: 110,
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              backgroundColor: const Color(0xFFEAF3E5),
                              side: BorderSide.none,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),

                            onPressed: () async {
                              final confirm = await _showDeleteConfirmation(
                                context,
                              );

                              if (confirm == true) {
                                await DocumentService.deleteDocument(
                                  documentId,
                                );

                                // 🔥 INI YANG WAJIB
                                Navigator.pop(
                                  context,
                                  true,
                                ); // TUTUP BOTTOMSHEET + KIRIM RESULT
                              }
                            },

                            child: const Text(
                              "Delete",
                              style: TextStyle(
                                color: Color.fromARGB(255, 255, 0, 0),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(width: 16),

                        /// SHARE
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF5FA53A),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            onPressed: () {},
                            child: const Text(
                              "Share",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

Widget _gradientInfoCard({
  required String title,
  required String subtitle,
  required String? phone,
  required Gradient gradient,
  required String imagePath,
}) {
  return Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      gradient: gradient,
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(
          // ignore: deprecated_member_use
          color: Colors.black.withOpacity(0.9),
          blurRadius: 5,
          offset: const Offset(4, 4),
        ),
      ],
    ),
    child: Row(
      children: [
        /// TEXT
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Text(subtitle, style: const TextStyle(color: Colors.white)),
              const SizedBox(height: 6),
              Row(
                children: [
                  Icon(Icons.phone_in_talk, size: 16, color: Colors.white),
                  SizedBox(width: 5),
                  Text(
                    phone ?? "-",
                    style: const TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ],
          ),
        ),

        /// ILLUSTRATION PLACEHOLDER
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(16)),
          child: Transform.scale(
            scale: 1.7,
            child: Image.asset(imagePath, fit: BoxFit.contain),
          ),
        ),
      ],
    ),
  );
}

Widget _descriptionCard({
  required String description,
  required String? documentType,
  required String? signedName,
  required VoidCallback onTapBuktiFoto,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      /// MAIN CARD (SEJAJAR DENGAN PENGIRIM & PENERIMA)
      Container(
        width: double.infinity,
        // ✅ ikut parent
        padding: const EdgeInsets.only(
          left: 30,
          right: 30,
          top: 20,
          bottom: 10,
        ),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF00B4B0), Color(0xFF007E7C)],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              // ignore: deprecated_member_use
              color: Colors.black.withOpacity(0.9),
              blurRadius: 5,
              offset: const Offset(4, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// DESC BOX (PUTIH)
            Container(
              width: double.infinity, // ✅ penuh
              constraints: const BoxConstraints(minHeight: 120),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Description : \n$description',
                style: const TextStyle(fontSize: 14),
              ),
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                Icon(Icons.description_rounded, size: 18, color: Colors.white),
                const SizedBox(width: 4),
                Text(
                  documentType ?? "-",
                  style: const TextStyle(color: Colors.white),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.person_pin_outlined, size: 16, color: Colors.white),
                const SizedBox(width: 5),
                Text(
                  signedName ?? "-",
                  style: const TextStyle(color: Colors.white),
                ),
              ],
            ),
          ],
        ),
      ),

      const SizedBox(height: 8),

      /// BUKTI FOTO LABEL
      InkWell(
        onTap: onTapBuktiFoto,

        child: Row(
          children: const [
            Icon(Icons.remove_red_eye, size: 20),
            SizedBox(width: 6),
            Text(
              "Bukti Foto",
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    ],
  );
}

void _showBuktiFoto(BuildContext context, DocumentData data) {
  showDialog(
    context: context,
    builder: (_) {
      return Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(16),
        child: Stack(
          children: [
            /// IMAGE PREVIEW
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Container(color: Colors.black, child: _previewImage(data)),
            ),

            /// CLOSE BUTTON
            Positioned(
              top: 8,
              right: 8,
              child: InkWell(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    // ignore: deprecated_member_use
                    color: Colors.black.withOpacity(0.6),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close, color: Colors.white, size: 20),
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}

Widget _previewImage(DocumentData data) {
  // 🔥 VIEW MODE (URL)
  if (data.receiverImageUrl != null &&
      data.receiverImageUrl!.trim().isNotEmpty) {
    return Image.network(
      data.receiverImageUrl!,
      fit: BoxFit.contain,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return const Center(child: CircularProgressIndicator());
      },
      errorBuilder: (_, __, ___) =>
          const Center(child: Icon(Icons.broken_image, color: Colors.white)),
    );
  }

  // CREATE MODE (FILE)
  if (data.receiverImage != null) {
    return Image.file(data.receiverImage!, fit: BoxFit.contain);
  }

  return const Center(
    child: Text("Tidak ada foto", style: TextStyle(color: Colors.white)),
  );
}

Future<bool?> _showDeleteConfirmation(BuildContext context) {
  return showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      bool isDeleting = false;

      return StatefulBuilder(
        builder: (context, setState) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "Hapus Dokumen?",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: isDeleting
                              ? null
                              : () => Navigator.pop(context, false),
                          child: const Text(
                            "Batal",
                            style: TextStyle(color: Colors.black),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                          ),
                          onPressed: isDeleting
                              ? null
                              : () async {
                                  setState(() => isDeleting = true);
                                  Navigator.pop(
                                    context,
                                    true,
                                  ); // ✅ hanya return true
                                },
                          child: isDeleting
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text(
                                  "Hapus",
                                  style: TextStyle(color: Colors.white),
                                ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}
