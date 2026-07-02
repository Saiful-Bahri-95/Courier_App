import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:store_app/models/document_data.dart';
import 'package:store_app/models/document_detail_model.dart';
import 'package:store_app/provider/user_provider.dart';
import 'package:store_app/services/document_service.dart';
import 'package:store_app/services/pdf_service.dart';
import 'package:store_app/views/screens/utils.dart';

// ─── Warna mengacu pada APP COLOR CONSTANTS di utils.dart ─────────────────────
// kNavyBlue    = Color(0xFF1A3C8F)
// kAccentBlue  = Color(0xFF2563EB)
// kLightBg     = Color(0xFFF1F5F9)
// kTextDark    = Color(0xFF1E293B)
// kTextMuted   = Color(0xFF64748B)
// kBorderColor = Color(0xFFCBD5E1)

// Turunan warna lokal
const _kNavyBg = Color(0xFFEBF0FB);
const _kAccentBg = Color(0xFFEFF4FF);
const _kGreenDark = Color(0xFF059669);
const _kGreenLight = Color(0xFF10B981);
const _kGreenIconBg = Color(0xFFD1FAE5);
const _kTealDark = Color(0xFF0F766E);
const _kTealLight = Color(0xFF0D9488);
const _kTealIconBg = Color(0xFFCCFBF1);
const _kRedBg = Color(0xFFFEF2F2);
const _kRedBorder = Color(0xFFFECACA);
const _kRedText = Color(0xFFB91C1C);

class BottomSheetPreviewDocument extends ConsumerWidget {
  final String documentId;
  final ScrollController scrollController;

  const BottomSheetPreviewDocument({
    super.key,
    required this.documentId,
    required this.scrollController,
  });

  String _formatDateTime(DateTime? date) {
    if (date == null) return '-';
    return DateFormat('dd MMM y · HH:mm').format(date);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);

    return FutureBuilder<DocumentDetailModel>(
      future: DocumentService.getDocumentDetail(documentId),
      builder: (context, snapshot) {
        // ── Loading ──────────────────────────────────────────────────────────
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.all(40),
            child: Center(child: CircularProgressIndicator(color: kAccentBlue)),
          );
        }

        // ── Error ────────────────────────────────────────────────────────────
        if (snapshot.hasError) {
          final err = snapshot.error.toString();
          final isNetwork =
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
                      color: Colors.red.withValues(alpha: 0.08),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isNetwork
                          ? Icons.wifi_off_rounded
                          : Icons.error_outline_rounded,
                      size: 40,
                      color: Colors.red.shade400,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    isNetwork
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
            // ── Drag handle ──────────────────────────────────────────────────
            const SizedBox(height: 12),
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: kBorderColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // ── Header ───────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: _kNavyBg,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.description_outlined,
                      size: 18,
                      color: kNavyBlue,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      'Info pengiriman',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: kTextDark,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: kLightBg,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: kBorderColor, width: 0.5),
                    ),
                    child: Text(
                      _formatDateTime(data.receivedDate),
                      style: const TextStyle(fontSize: 11, color: kTextMuted),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: kBorderColor),

            // ── Scrollable content ───────────────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                controller: scrollController,
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Pengirim
                    const _SectionLabel(label: 'Pengirim', color: kNavyBlue),
                    const SizedBox(height: 8),
                    _InfoCard(
                      companyIcon: Icons.business_outlined,
                      companyName: data.senderCompany ?? '-',
                      personLabel: 'Nama pengirim',
                      personName: data.senderName ?? '-',
                      phone: data.senderPhone,
                      gradient: const LinearGradient(
                        colors: [kNavyBlue, kAccentBlue],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      personIconBg: _kNavyBg,
                      personIconColor: kNavyBlue,
                    ),

                    const SizedBox(height: 16),

                    // Penerima
                    const _SectionLabel(label: 'Penerima', color: kAccentBlue),
                    const SizedBox(height: 8),
                    _InfoCard(
                      companyIcon: Icons.location_city_outlined,
                      companyName: data.receiverCompany ?? '-',
                      personLabel: 'Nama penerima',
                      personName: data.receiverName ?? '-',
                      phone: data.receiverPhone,
                      gradient: const LinearGradient(
                        colors: [_kGreenDark, _kGreenLight],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      personIconBg: _kGreenIconBg,
                      personIconColor: _kGreenDark,
                    ),

                    const SizedBox(height: 16),

                    // Keterangan
                    const _SectionLabel(label: 'Keterangan', color: _kTealDark),
                    const SizedBox(height: 8),
                    _KeteranganCard(
                      description: data.description ?? '-',
                      documentType: data.documentType,
                      signedName: data.signedName,
                      onTapBuktiFoto: () => _showBuktiFoto(context, data),
                    ),

                    const SizedBox(height: 24),

                    // Tombol aksi
                    Row(
                      children: [
                        _DeleteButton(
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
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _ShareButton(
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

// ─── Section label ─────────────────────────────────────────────────────────────
class _SectionLabel extends StatelessWidget {
  final String label;
  final Color color;

  const _SectionLabel({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 3,
          height: 13,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: kTextMuted,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }
}

// ─── Info card (pengirim / penerima) ───────────────────────────────────────────
class _InfoCard extends StatelessWidget {
  final IconData companyIcon;
  final String companyName;
  final String personLabel;
  final String personName;
  final String? phone;
  final LinearGradient gradient;
  final Color personIconBg;
  final Color personIconColor;

  const _InfoCard({
    required this.companyIcon,
    required this.companyName,
    required this.personLabel,
    required this.personName,
    required this.gradient,
    required this.personIconBg,
    required this.personIconColor,
    this.phone,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: kBorderColor, width: 0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          // ── Gradient header ──────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              gradient: gradient,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(companyIcon, size: 20, color: Colors.white),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    companyName,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),

          // ── Baris nama ───────────────────────────────────────────────────
          _InfoRow(
            iconBg: personIconBg,
            iconColor: personIconColor,
            icon: Icons.person_outline_rounded,
            label: personLabel,
            value: personName,
            isLast: false,
          ),

          // ── Baris telepon ────────────────────────────────────────────────
          _InfoRow(
            iconBg: kLightBg,
            iconColor: kTextMuted,
            icon: Icons.phone_outlined,
            label: 'Nomor telepon',
            value: phone ?? '-',
            isLast: true,
            valueMuted: phone == null || phone!.isEmpty,
          ),
        ],
      ),
    );
  }
}

// ─── Info row helper ───────────────────────────────────────────────────────────
class _InfoRow extends StatelessWidget {
  final Color iconBg;
  final Color iconColor;
  final IconData icon;
  final String label;
  final String value;
  final bool isLast;
  final bool valueMuted;

  const _InfoRow({
    required this.iconBg,
    required this.iconColor,
    required this.icon,
    required this.label,
    required this.value,
    required this.isLast,
    this.valueMuted = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
            child: Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: iconBg,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, size: 14, color: iconColor),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: kTextMuted,
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      value,
                      style: TextStyle(
                        fontSize: 13,
                        color: valueMuted ? kTextMuted : kTextDark,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (!isLast) const Divider(height: 1, color: Color(0xFFF1F5F9)),
        ],
      ),
    );
  }
}

// ─── Keterangan card ───────────────────────────────────────────────────────────
class _KeteranganCard extends StatelessWidget {
  final String description;
  final String? documentType;
  final String? signedName;
  final VoidCallback onTapBuktiFoto;

  const _KeteranganCard({
    required this.description,
    required this.documentType,
    required this.signedName,
    required this.onTapBuktiFoto,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: kBorderColor, width: 0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Gradient header teal ─────────────────────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [_kTealDark, _kTealLight],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.notes_outlined,
                    size: 20,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Keterangan dokumen',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),

          // ── Deskripsi — teks langsung, wrap, tanpa icon/label ───────────
          Container(
            width: double.infinity,
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Text(
              description,
              style: const TextStyle(
                fontSize: 13,
                color: kTextDark,
                height: 1.6,
              ),
              softWrap: true,
            ),
          ),
          const Divider(height: 1, color: kBorderColor),

          // ── Meta 2 kolom: jenis dokumen + nama penerima TTD ──────────────
          Container(
            color: Colors.white,
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Jenis dokumen
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(14, 10, 10, 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'JENIS DOKUMEN',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                              color: kTextMuted,
                              letterSpacing: 0.4,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: _kNavyBg,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.description_outlined,
                                  size: 12,
                                  color: kNavyBlue,
                                ),
                                const SizedBox(width: 4),
                                Flexible(
                                  child: Text(
                                    documentType ?? '-',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: kNavyBlue,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Garis vertikal pemisah
                  const VerticalDivider(width: 1, color: kBorderColor),
                  // Nama penerima TTD
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'NAMA PENERIMA TTD',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                              color: kTextMuted,
                              letterSpacing: 0.4,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: _kAccentBg,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.edit_outlined,
                                  size: 12,
                                  color: kAccentBlue,
                                ),
                                const SizedBox(width: 4),
                                Flexible(
                                  child: Text(
                                    signedName ?? '-',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: kAccentBlue,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Divider(height: 1, color: kBorderColor),

          // ── Tombol bukti foto ────────────────────────────────────────────
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: GestureDetector(
              onTap: onTapBuktiFoto,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: kLightBg,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: kBorderColor, width: 0.5),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(
                      Icons.camera_alt_outlined,
                      size: 14,
                      color: kTextMuted,
                    ),
                    SizedBox(width: 6),
                    Text(
                      'Lihat bukti foto',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: kTextMuted,
                      ),
                    ),
                    SizedBox(width: 4),
                    Icon(
                      Icons.chevron_right_rounded,
                      size: 14,
                      color: kBorderColor,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Tombol Hapus ──────────────────────────────────────────────────────────────
class _DeleteButton extends StatelessWidget {
  final VoidCallback onPressed;
  const _DeleteButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        height: 44,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: _kRedBg,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: _kRedBorder, width: 0.5),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.delete_outline_rounded, size: 15, color: _kRedText),
            SizedBox(width: 6),
            Text(
              'Hapus',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: _kRedText,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Tombol Bagikan PDF ────────────────────────────────────────────────────────
class _ShareButton extends StatelessWidget {
  final VoidCallback onPressed;
  const _ShareButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [kNavyBlue, kAccentBlue],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.share_rounded, size: 15, color: Colors.white),
            SizedBox(width: 6),
            Text(
              'Bagikan PDF',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Dialog bukti foto ─────────────────────────────────────────────────────────
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
                  color: Colors.black.withValues(alpha: 0.6),
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

// ─── Dialog konfirmasi hapus ───────────────────────────────────────────────────
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
                    color: Colors.red.withValues(alpha: 0.08),
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
                  'Hapus dokumen?',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w500,
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
                            fontWeight: FontWeight.w500,
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
                                  fontWeight: FontWeight.w500,
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
