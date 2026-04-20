import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:store_app/models/document_data.dart';
import 'package:store_app/models/document_detail_model.dart';
import 'package:store_app/provider/user_provider.dart';
import 'package:store_app/services/cloudinary_service.dart';
import 'package:store_app/services/document_service.dart';
import 'package:store_app/services/manage_http_response.dart';
import 'package:store_app/views/screens/main_screen.dart';
import 'package:store_app/views/screens/nav_screens/widgets/send_form/sender_detail.dart';
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
    if (date == null) return '-';
    return DateFormat('EEEE, dd MMMM yyyy, HH:mm').format(date);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.documentData != null) {
      return _buildPreview(context, widget.documentData!);
    }

    return FutureBuilder<DocumentDetailModel>(
      future: DocumentService.getDocumentDetail(widget.documentId!),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: kNavyBlue,
            body: Center(child: CircularProgressIndicator(color: Colors.white)),
          );
        }
        if (snapshot.hasError) {
          return Scaffold(body: Center(child: Text(snapshot.error.toString())));
        }
        return _buildPreview(context, snapshot.data!.toDocumentData());
      },
    );
  }

  Widget _buildPreview(BuildContext context, DocumentData data) {
    final isViewMode = widget.documentId != null;

    return Scaffold(
      backgroundColor: kNavyBlue,
      body: Column(
        children: [
          _buildHeader(context, isViewMode),
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0xFFF8FAFC),
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSummaryCard(data),
                    const SizedBox(height: 14),
                    _buildSection(
                      title: 'Detail Pengirim',
                      icon: Icons.send_rounded,
                      gradient: const LinearGradient(
                        colors: [Color(0xFF1A3C8F), Color(0xFF2563EB)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      children: [
                        _infoRow('Perusahaan', data.senderCompany),
                        _infoRow('Nama', data.senderName),
                        _infoRow('Telepon', data.senderPhone),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildSection(
                      title: 'Detail Penerima',
                      icon: Icons.inbox_rounded,
                      gradient: const LinearGradient(
                        colors: [Color(0xFF059669), Color(0xFF10B981)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      children: [
                        _infoRow('Perusahaan', data.receiverCompany),
                        _infoRow('Nama', data.receiverName),
                        _infoRow('Telepon', data.receiverPhone),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildSection(
                      title: 'Informasi Dokumen',
                      icon: Icons.description_rounded,
                      gradient: const LinearGradient(
                        colors: [Color(0xFF7C3AED), Color(0xFF9F67FF)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      children: [
                        _infoRow('Jenis', data.documentType),
                        _descriptionBox(data.description),
                      ],
                    ),
                    if (data.receiverImage != null ||
                        data.receiverImageUrl != null) ...[
                      const SizedBox(height: 12),
                      _buildSection(
                        title: 'Foto Bukti Penerimaan',
                        icon: Icons.photo_camera_rounded,
                        gradient: const LinearGradient(
                          colors: [Color(0xFFD97706), Color(0xFFF59E0B)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        children: [_receiverImageWidget(data)],
                      ),
                    ],
                    const SizedBox(height: 12),
                    _buildSection(
                      title: 'Tanda Tangan',
                      icon: Icons.draw_rounded,
                      gradient: const LinearGradient(
                        colors: [Color(0xFFDB2777), Color(0xFFEC4899)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      children: [
                        _infoRow('Tanggal', _formatDateTime(data.receivedDate)),
                        _infoRow('Nama', data.signedName),
                        if (data.signature != null || data.signatureUrl != null)
                          _signatureWidget(data),
                      ],
                    ),
                    const SizedBox(height: 24),
                    _buildSubmitButton(context, data, isViewMode),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isViewMode) {
    final topPadding = MediaQuery.of(context).padding.top;
    return Container(
      color: kNavyBlue,
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: topPadding + 16,
        bottom: 20,
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.arrow_back_ios_new,
                color: Colors.white,
                size: 18,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Preview Dokumen',
                style: TextStyle(
                  fontSize: 22,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                isViewMode ? 'Detail pengiriman' : 'Periksa sebelum submit',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.white.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(DocumentData data) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              // ignore: deprecated_member_use
              color: kAccentBlue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.receipt_long_rounded,
              color: kAccentBlue,
              size: 28,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.senderCompany ?? '-',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: kTextDark,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '→ ${data.receiverCompany ?? '-'}',
                  style: const TextStyle(color: kTextMuted, fontSize: 13),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              // ignore: deprecated_member_use
              color: const Color(0xFF10B981).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              data.documentType ?? '-',
              style: const TextStyle(
                color: Color(0xFF059669),
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required Gradient gradient,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(gradient: gradient),
              child: Row(
                children: [
                  Icon(icon, color: Colors.white, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            // Content
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: children,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(color: kTextMuted, fontSize: 13),
            ),
          ),
          const Text(':', style: TextStyle(color: kTextMuted)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value ?? '-',
              style: const TextStyle(
                fontSize: 13,
                color: kTextDark,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _descriptionBox(String? description) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: kLightBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: kBorderColor),
      ),
      child: Text(
        description ?? '-',
        style: const TextStyle(fontSize: 13, color: kTextDark, height: 1.5),
      ),
    );
  }

  Widget _receiverImageWidget(DocumentData data) {
    if (data.receiverImage != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.file(
          data.receiverImage!,
          height: 200,
          width: double.infinity,
          fit: BoxFit.cover,
        ),
      );
    }
    if (data.receiverImageUrl != null && data.receiverImageUrl!.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.network(
          data.receiverImageUrl!,
          height: 200,
          width: double.infinity,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, progress) {
            if (progress == null) return child;
            return const SizedBox(
              height: 200,
              child: Center(child: CircularProgressIndicator()),
            );
          },
          errorBuilder: (_, __, ___) =>
              const Icon(Icons.broken_image, size: 40),
        ),
      );
    }
    return const Text('-');
  }

  Widget _signatureWidget(DocumentData data) {
    Widget content;

    if (data.signature != null) {
      content = Image.memory(data.signature!, fit: BoxFit.contain);
    } else if (data.signatureUrl != null && data.signatureUrl!.isNotEmpty) {
      content = Image.network(data.signatureUrl!, fit: BoxFit.contain);
    } else {
      return const SizedBox.shrink();
    }

    return Container(
      height: 140,
      width: double.infinity,
      margin: const EdgeInsets.only(top: 8),
      decoration: BoxDecoration(
        color: kLightBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: kBorderColor),
      ),
      child: ClipRRect(borderRadius: BorderRadius.circular(9), child: content),
    );
  }

  Widget _buildSubmitButton(
    BuildContext context,
    DocumentData data,
    bool isViewMode,
  ) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: isViewMode
            ? null
            : () async {
                final user = ref.read(userProvider);
                if (user == null) {
                  showSnackbar(context, 'User belum login');
                  return;
                }

                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (_) => const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  ),
                );

                try {
                  String? receiverImageUrl;
                  if (widget.documentData?.receiverImage != null) {
                    receiverImageUrl = await UploadService.uploadImageFile(
                      widget.documentData!.receiverImage!,
                      user.token,
                    );
                  }

                  String? signatureUrl;
                  if (widget.documentData?.signature != null) {
                    signatureUrl = await UploadService.uploadSignature(
                      widget.documentData!.signature!,
                      user.token,
                    );
                  }

                  await DocumentService.submit(
                    widget.documentData!,
                    receiverImageUrl,
                    signatureUrl,
                  );

                  // ignore: use_build_context_synchronously
                  Navigator.pop(context);
                  // ignore: use_build_context_synchronously
                  showSnackbar(context, 'Dokumen berhasil dikirim ✅');
                  // ignore: use_build_context_synchronously
                  Navigator.pushAndRemoveUntil(
                    // ignore: use_build_context_synchronously
                    context,
                    MaterialPageRoute(builder: (_) => const MainScreen()),
                    (route) => false,
                  );
                } catch (e) {
                  // ignore: use_build_context_synchronously
                  Navigator.pop(context);
                  // ignore: use_build_context_synchronously
                  showSnackbar(context, e.toString());
                }
              },
        style: ElevatedButton.styleFrom(
          backgroundColor: isViewMode ? kBorderColor : kAccentBlue,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isViewMode ? Icons.check_circle_rounded : Icons.send_rounded,
              color: Colors.white,
              size: 18,
            ),
            const SizedBox(width: 8),
            Text(
              isViewMode ? 'Dokumen Telah Dikirim' : 'Submit Dokumen',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
