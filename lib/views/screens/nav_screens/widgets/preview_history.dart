import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:store_app/models/document_data.dart';
import 'package:store_app/models/document_detail_model.dart';
import 'package:store_app/provider/user_provider.dart';
import 'package:store_app/services/document_service.dart';
import 'package:store_app/services/pdf_service.dart';
import 'package:store_app/views/screens/utils.dart';

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
    return DateFormat('dd MMM y · HH:mm').format(date);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);

    return FutureBuilder<DocumentDetailModel>(
      future: DocumentService.getDocumentDetail(documentId),
      builder: (context, snapshot) {
        // Loading
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.all(40),
            child: Center(child: CircularProgressIndicator(color: kAccentBlue)),
          );
        }

        // Error
        if (snapshot.hasError) {
          final err = snapshot.error.toString();
          final isNetworkError =
              err.contains('SocketException') ||
              err.contains('Failed host lookup');
          return Padding(
            padding: const EdgeInsets.all(32),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      // ignore: deprecated_member_use
                      color: Colors.red.withOpacity(0.08),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isNetworkError
                          ? Icons.wifi_off_rounded
                          : Icons.error_outline_rounded,
                      size: 40,
                      color: Colors.red.shade400,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    isNetworkError
                        ? 'Tidak dapat terhubung ke server.'
                        : 'Terjadi kesalahan. Coba lagi.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: kTextMuted, fontSize: 13),
                  ),
                ],
              ),
            ),
          );
        }

        final data = snapshot.data!.toDocumentData();

        return Column(
          children: [
            // ===== DRAG HANDLE =====
            const SizedBox(height: 10),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: kBorderColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 14),

            // ===== TITLE BAR =====
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      // ignore: deprecated_member_use
                      color: kAccentBlue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.receipt_long_rounded,
                      color: kAccentBlue,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      'Info Pengiriman',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: kTextDark,
                      ),
                    ),
                  ),
                  // Tanggal
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: kLightBg,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _formatDateTime(data.receivedDate),
                      style: const TextStyle(
                        fontSize: 11,
                        color: kTextMuted,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),
            const Divider(height: 1, color: kLightBg),

            // ===== SCROLLABLE CONTENT =====
            Expanded(
              child: SingleChildScrollView(
                controller: scrollController,
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Pengirim
                    _sectionLabel('Detail Pengirim'),
                    const SizedBox(height: 10),
                    _gradientInfoCard(
                      title: data.senderCompany ?? "-",
                      subtitle: data.senderName ?? "-",
                      subtitlePrefix: 'Dari',
                      phone: data.senderPhone,
                      imagePath: 'assets/icons/Office.png',
                      gradient: const LinearGradient(
                        colors: [Color(0xFF1A3C8F), Color(0xFF2563EB)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Penerima
                    _sectionLabel('Detail Penerima'),
                    const SizedBox(height: 10),
                    _gradientInfoCard(
                      title: data.receiverCompany ?? "-",
                      subtitle: data.receiverName ?? "-",
                      subtitlePrefix: 'Kepada',
                      phone: data.receiverPhone,
                      imagePath: 'assets/icons/penerima.png',
                      gradient: const LinearGradient(
                        colors: [Color(0xFF059669), Color(0xFF10B981)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Keterangan
                    _sectionLabel('Keterangan'),
                    const SizedBox(height: 10),
                    _descriptionCard(
                      description: data.description ?? "-",
                      documentType: data.documentType,
                      signedName: data.signedName,
                      onTapBuktiFoto: () => _showBuktiFoto(context, data),
                    ),

                    const SizedBox(height: 24),

                    // ── Action buttons ──
                    Row(
                      children: [
                        // Delete
                        OutlinedButton.icon(
                          onPressed: () async {
                            final confirm = await _showDeleteConfirmation(
                              context,
                            );
                            if (confirm == true) {
                              await DocumentService.deleteDocument(documentId);
                              // ignore: use_build_context_synchronously
                              Navigator.pop(context, true);
                            }
                          },
                          icon: const Icon(
                            Icons.delete_outline_rounded,
                            size: 16,
                            color: Colors.red,
                          ),
                          label: const Text(
                            'Hapus',
                            style: TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFFFFCDD2)),
                            backgroundColor: const Color(0xFFFFEBEB),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        ),

                        const SizedBox(width: 12),

                        // Share
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () async {
                              showDialog(
                                context: context,
                                barrierDismissible: false,
                                builder: (_) => const Center(
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                  ),
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
                            icon: const Icon(
                              Icons.share_rounded,
                              size: 16,
                              color: Colors.white,
                            ),
                            label: const Text(
                              'Share',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: kAccentBlue,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              elevation: 0,
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

// ===== SHARED HELPER WIDGETS =====

Widget _sectionLabel(String label) {
  return Row(
    children: [
      Container(
        width: 4,
        height: 16,
        decoration: BoxDecoration(
          color: kAccentBlue,
          borderRadius: BorderRadius.circular(4),
        ),
      ),
      const SizedBox(width: 8),
      Text(
        label,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: kTextMuted,
          letterSpacing: 0.4,
        ),
      ),
    ],
  );
}

Widget _gradientInfoCard({
  required String title,
  required String subtitle,
  required String subtitlePrefix,
  required String? phone,
  required Gradient gradient,
  required String imagePath,
}) {
  return Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      gradient: gradient,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          // ignore: deprecated_member_use
          color: Colors.black.withOpacity(0.15),
          blurRadius: 10,
          offset: const Offset(0, 5),
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
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.2,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 5),
              Row(
                children: [
                  const Icon(
                    Icons.person_rounded,
                    size: 13,
                    color: Colors.white70,
                  ),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      '$subtitlePrefix $subtitle',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 5),
              Row(
                children: [
                  const Icon(
                    Icons.phone_rounded,
                    size: 13,
                    color: Colors.white70,
                  ),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      phone ?? "-",
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            // ignore: deprecated_member_use
            color: Colors.white.withOpacity(0.12),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Transform.scale(
            scale: 1.5,
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
  return Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          // ignore: deprecated_member_use
          color: Colors.black.withOpacity(0.05),
          blurRadius: 8,
          offset: const Offset(0, 3),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header berwarna
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF00B4B0), Color(0xFF007E7C)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.info_outline_rounded,
                size: 16,
                color: Colors.white,
              ),
              const SizedBox(width: 8),
              const Text(
                'Keterangan Dokumen',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),

        // Body
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Description box
              Container(
                width: double.infinity,
                constraints: const BoxConstraints(minHeight: 60),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: kLightBg,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: kBorderColor),
                ),
                child: Text(
                  description,
                  style: const TextStyle(
                    fontSize: 13,
                    color: kTextDark,
                    height: 1.5,
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Jenis & TTD
              Row(
                children: [
                  _infoChip(
                    icon: Icons.description_rounded,
                    label: documentType ?? "-",
                    // ignore: deprecated_member_use
                    bgColor: kAccentBlue.withOpacity(0.08),
                    textColor: kAccentBlue,
                  ),
                  const SizedBox(width: 8),
                  _infoChip(
                    icon: Icons.draw_rounded,
                    label: signedName ?? "-",
                    // ignore: deprecated_member_use
                    bgColor: const Color(0xFF7C3AED).withOpacity(0.08),
                    textColor: const Color(0xFF7C3AED),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Bukti foto
              InkWell(
                onTap: onTapBuktiFoto,
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    // ignore: deprecated_member_use
                    color: const Color(0xFFD97706).withOpacity(0.08),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      // ignore: deprecated_member_use
                      color: const Color(0xFFD97706).withOpacity(0.2),
                    ),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.photo_camera_rounded,
                        size: 16,
                        color: Color(0xFFD97706),
                      ),
                      SizedBox(width: 6),
                      Text(
                        'Lihat Bukti Foto',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFFD97706),
                        ),
                      ),
                      SizedBox(width: 4),
                      Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 11,
                        color: Color(0xFFD97706),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

Widget _infoChip({
  required IconData icon,
  required String label,
  required Color bgColor,
  required Color textColor,
}) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    decoration: BoxDecoration(
      color: bgColor,
      borderRadius: BorderRadius.circular(8),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: textColor),
        const SizedBox(width: 5),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
        ),
      ],
    ),
  );
}

void _showBuktiFoto(BuildContext context, DocumentData data) {
  showDialog(
    context: context,
    builder: (_) => Dialog(
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
            child: GestureDetector(
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
    ),
  );
}

Widget _previewImage(DocumentData data) {
  if (data.receiverImageUrl != null &&
      data.receiverImageUrl!.trim().isNotEmpty) {
    return Image.network(
      data.receiverImageUrl!,
      fit: BoxFit.contain,
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
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
    child: Text('Tidak ada foto', style: TextStyle(color: Colors.white)),
  );
}

Future<bool?> _showDeleteConfirmation(BuildContext context) {
  return showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      bool isDeleting = false;
      return StatefulBuilder(
        builder: (context, setState) => Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    // ignore: deprecated_member_use
                    color: Colors.red.withOpacity(0.08),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.delete_forever_rounded,
                    size: 36,
                    color: Colors.red,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Hapus Dokumen?',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: kTextDark,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Tindakan ini tidak dapat dibatalkan.',
                  style: TextStyle(color: kTextMuted, fontSize: 13),
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
                          padding: const EdgeInsets.symmetric(vertical: 13),
                          side: const BorderSide(color: kBorderColor),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Batal',
                          style: TextStyle(
                            color: kTextDark,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          padding: const EdgeInsets.symmetric(vertical: 13),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        onPressed: isDeleting
                            ? null
                            : () {
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
                                'Hapus',
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
      );
    },
  );
}
