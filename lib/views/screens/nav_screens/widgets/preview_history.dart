import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:store_app/models/document_data.dart';
import 'package:store_app/models/document_detail_model.dart';
import 'package:store_app/provider/user_provider.dart';
import 'package:store_app/services/document_service.dart';
import 'package:store_app/services/pdf_service.dart';

class BottomSheetPreviewDocument extends ConsumerWidget {
  final String documentId;
  final ScrollController scrollController;

  const BottomSheetPreviewDocument({
    super.key,
    required this.documentId,
    required this.scrollController,
  });

  String _formatDateTime(DateTime? date) {
    if (date == null) return "-";
    return DateFormat('EEEE, dd MMMM y - HH:mm').format(date);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider); // ← ambil user
    return FutureBuilder<DocumentDetailModel>(
      future: DocumentService.getDocumentDetail(documentId),
      builder: (context, snapshot) {
        // Loading
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.all(40),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        // Error
        if (snapshot.hasError) {
          final err = snapshot.error.toString();
          final isNetworkError =
              err.contains('SocketException') ||
              err.contains('Failed host lookup');
          return Padding(
            padding: const EdgeInsets.all(24),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isNetworkError ? Icons.wifi_off : Icons.error_outline,
                    size: 48,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    isNetworkError
                        ? 'Tidak dapat terhubung ke server.'
                        : 'Terjadi kesalahan. Coba lagi.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.red),
                  ),
                ],
              ),
            ),
          );
        }

        final data = snapshot.data!.toDocumentData();

        return Column(
          children: [
            // ===== HEADER =====
            const SizedBox(height: 8),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade400,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 12),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                "Info Pengiriman",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 8),
            const Divider(height: 5, color: Colors.black),

            // ===== CONTENT =====
            Expanded(
              child: SingleChildScrollView(
                controller: scrollController,
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Detail Pengirim",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          _formatDateTime(data.receivedDate),
                          textAlign: TextAlign.right,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Color.fromARGB(255, 120, 119, 119),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
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
                    const Text(
                      "Detail Penerima",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
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
                    const Text(
                      "Keterangan",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _descriptionCard(
                      description: data.description ?? "-",
                      documentType: data.documentType,
                      signedName: data.signedName,
                      onTapBuktiFoto: () => _showBuktiFoto(context, data),
                    ),
                    const SizedBox(height: 24),

                    // Tombol Delete & Share
                    Row(
                      children: [
                        // Delete
                        SizedBox(
                          width: 110,
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              backgroundColor: const Color(0xFFFFEBEB),
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
                                // ignore: use_build_context_synchronously
                                Navigator.pop(context, true);
                              }
                            },
                            child: const Text(
                              "Delete",
                              style: TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),

                        // ✅ SHARE - AKTIF
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF5FA53A),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            onPressed: () async {
                              showDialog(
                                context: context,
                                barrierDismissible: false,
                                builder: (_) => const Center(
                                  child: CircularProgressIndicator(),
                                ),
                              );
                              await PdfService.generateAndShare(
                                context,
                                data,
                                user?.fullname ?? '-',
                              );
                              // ignore: use_build_context_synchronously
                              Navigator.pop(context);
                            },
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

// ===== FLUTTER WIDGET HELPERS =====

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
          color: Colors.black.withOpacity(0.25),
          blurRadius: 8,
          offset: const Offset(4, 4),
        ),
      ],
    ),
    child: Row(
      children: [
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
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 6),
              Text(
                subtitle,
                style: const TextStyle(color: Colors.white),
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(
                    Icons.phone_in_talk,
                    size: 16,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 5),
                  Flexible(
                    child: Text(
                      phone ?? "-",
                      style: const TextStyle(color: Colors.white),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
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
      Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF00B4B0), Color(0xFF007E7C)],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              // ignore: deprecated_member_use
              color: Colors.black.withOpacity(0.25),
              blurRadius: 8,
              offset: const Offset(4, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              constraints: const BoxConstraints(minHeight: 80),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Description :\n$description',
                style: const TextStyle(fontSize: 14),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(
                  Icons.description_rounded,
                  size: 18,
                  color: Colors.white,
                ),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    documentType ?? "-",
                    style: const TextStyle(color: Colors.white),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(
                  Icons.person_pin_outlined,
                  size: 16,
                  color: Colors.white,
                ),
                const SizedBox(width: 5),
                Flexible(
                  child: Text(
                    signedName ?? "-",
                    style: const TextStyle(color: Colors.white),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      const SizedBox(height: 8),
      InkWell(
        onTap: onTapBuktiFoto,
        borderRadius: BorderRadius.circular(8),
        child: const Padding(
          padding: EdgeInsets.symmetric(vertical: 4, horizontal: 2),
          child: Row(
            children: [
              Icon(Icons.remove_red_eye, size: 20),
              SizedBox(width: 6),
              Text(
                "Bukti Foto",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
            ],
          ),
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
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Container(color: Colors.black, child: _previewImage(data)),
            ),
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
                  const Icon(
                    Icons.warning_amber_rounded,
                    size: 48,
                    color: Colors.red,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    "Hapus Dokumen?",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Tindakan ini tidak dapat dibatalkan.",
                    style: TextStyle(color: Colors.grey, fontSize: 13),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: isDeleting
                              ? null
                              : () => Navigator.pop(context, false),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
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
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: isDeleting
                              ? null
                              : () async {
                                  setState(() => isDeleting = true);
                                  Navigator.pop(context, true);
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
