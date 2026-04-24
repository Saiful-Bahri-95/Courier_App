import 'package:flutter/material.dart';
import 'package:store_app/models/document_data.dart';
import 'package:store_app/views/screens/nav_screens/draft_list_screen.dart';
import 'package:store_app/views/screens/nav_screens/widgets/send_form/sender_detail.dart';
import 'package:store_app/views/screens/utils.dart';

class SendScreen extends StatelessWidget {
  const SendScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: kNavyBlue,
      body: Column(
        children: [
          // ===== HEADER =====
          Padding(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: topPadding + 16,
              bottom: 24,
            ),
            child: Row(
              children: [
                if (Navigator.canPop(context))
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(9),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.arrow_back_ios_new,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
                if (Navigator.canPop(context)) const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Kirim Dokumen',
                      style: TextStyle(
                        fontSize: 22,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Pilih cara pengiriman',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // ===== CONTENT =====
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Color(0xFFF8FAFC),
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 32, 20, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Label
                    Row(
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
                        const Text(
                          'Pilih Opsi',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: kTextMuted,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 14),

                    // ===== OPSI 1: LANGSUNG KIRIM =====
                    _OptionCard(
                      icon: Icons.send_rounded,
                      iconColor: kAccentBlue,
                      iconBg: const Color(0xFFEEF2FF),
                      title: 'Langsung Kirim',
                      desc:
                          'Isi form pengirim, penerima, dan tanda tangan sekarang. Dokumen langsung dikirim setelah selesai.',
                      badge: 'Rekomendasi',
                      badgeColor: kAccentBlue,
                      steps: const [
                        'Isi detail pengirim',
                        'Isi detail penerima',
                        'Tanda tangan & submit',
                      ],
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => SenderDetail(
                            documentData: DocumentData(),
                            isDraft: false,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 14),

                    // ===== OPSI 2: BUAT DRAFT =====
                    _OptionCard(
                      icon: Icons.save_rounded,
                      iconColor: const Color(0xFFD97706),
                      iconBg: const Color(0xFFFFF7ED),
                      title: 'Buat Draft',
                      desc:
                          'Isi form sekarang, simpan sebagai draft. Lengkapi tanda tangan saat sudah di lokasi penerima.',
                      badge: 'Tanda tangan nanti',
                      badgeColor: const Color(0xFFD97706),
                      steps: const [
                        'Isi detail pengirim & penerima',
                        'Simpan sebagai draft',
                        'Tanda tangan di lokasi',
                      ],
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => SenderDetail(
                            documentData: DocumentData(),
                            isDraft: true,
                          ),
                        ),
                      ),
                      showDraftNote: true,
                    ),

                    const SizedBox(height: 20),

                    // Lihat draft tersimpan
                    GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const DraftListScreen(),
                        ),
                      ),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: kBorderColor),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color(
                                  0xFF16A34A,
                                ).withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.pending_rounded,
                                color: Color(0xFF16A34A),
                                size: 18,
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Lihat Draft Tersimpan',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: kTextDark,
                                    ),
                                  ),
                                  Text(
                                    'Lengkapi tanda tangan draft yang sudah ada',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: kTextMuted,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(
                              Icons.arrow_forward_ios_rounded,
                              size: 14,
                              color: kTextMuted,
                            ),
                          ],
                        ),
                      ),
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

// ========================
// OPTION CARD WIDGET
// ========================
class _OptionCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String title;
  final String desc;
  final String badge;
  final Color badgeColor;
  final List<String> steps;
  final VoidCallback onTap;
  final bool showDraftNote;

  const _OptionCard({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.title,
    required this.desc,
    required this.badge,
    required this.badgeColor,
    required this.steps,
    required this.onTap,
    this.showDraftNote = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: kBorderColor),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: iconBg,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, color: iconColor, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: kTextDark,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: badgeColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            badge,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: badgeColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 14,
                    color: iconColor,
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Deskripsi
              Text(
                desc,
                style: const TextStyle(
                  fontSize: 12,
                  color: kTextMuted,
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 14),
              const Divider(height: 1, color: kLightBg),
              const SizedBox(height: 12),

              // Steps
              ...steps.asMap().entries.map((entry) {
                final i = entry.key;
                final step = entry.value;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    children: [
                      Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          color: iconColor,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '${i + 1}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        step,
                        style: const TextStyle(fontSize: 12, color: kTextDark),
                      ),
                    ],
                  ),
                );
              }),

              // Note untuk draft
              if (showDraftNote) ...[
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF7ED),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: const Color(0xFFD97706).withValues(alpha: 0.3),
                    ),
                  ),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.info_outline_rounded,
                        size: 14,
                        color: Color(0xFFD97706),
                      ),
                      SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'Draft tersimpan di perangkat. Lengkapi tanda tangan kapan saja.',
                          style: TextStyle(
                            fontSize: 11,
                            color: Color(0xFFD97706),
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
