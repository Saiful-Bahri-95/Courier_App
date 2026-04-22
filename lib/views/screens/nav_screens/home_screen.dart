import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:store_app/models/document_list_model.dart';
import 'package:store_app/services/document_service.dart';
import 'package:store_app/views/screens/nav_screens/draft_list_screen.dart';
import 'package:store_app/views/screens/nav_screens/send_screen.dart';
import 'package:store_app/views/screens/nav_screens/widgets/header_widget.dart';
import 'package:store_app/views/screens/nav_screens/widgets/preview_history.dart';
import 'package:store_app/views/screens/utils.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  late Future<List<DocumentListModel>> _futureDocuments;

  @override
  void initState() {
    super.initState();
    _futureDocuments = DocumentService.getDocumentList();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        body: Column(
          children: [
            const HeaderWidget(),
            Expanded(
              child: FutureBuilder<List<DocumentListModel>>(
                future: _futureDocuments,
                builder: (context, snapshot) {
                  final docs = snapshot.data ?? [];
                  final total = docs.length;
                  final completed = docs.length;

                  return RefreshIndicator(
                    color: kAccentBlue,
                    onRefresh: () async {
                      setState(() {
                        _futureDocuments = DocumentService.getDocumentList();
                      });
                    },
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildStatRow(total: total, completed: completed),
                          const SizedBox(height: 24),
                          _sectionLabel('Aksi Cepat'),
                          const SizedBox(height: 12),
                          _buildQuickActions(),
                          const SizedBox(height: 24),
                          _sectionLabel('Pengiriman Terbaru'),
                          const SizedBox(height: 12),
                          _buildRecentDocuments(snapshot),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

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
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildStatRow({required int total, required int completed}) {
    final double rate = total == 0 ? 0 : (completed / total * 100);
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            iconBg: const Color(0xFFEEF2FF),
            iconColor: kAccentBlue,
            icon: Icons.description_rounded,
            value: '$total',
            label: 'Total Dokumen',
            sub: 'Semua waktu',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            iconBg: const Color(0xFFDCFCE7),
            iconColor: const Color(0xFF16A34A),
            icon: Icons.check_circle_rounded,
            value: '$completed',
            label: 'Terkirim',
            sub: '${rate.toStringAsFixed(0)}% success',
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActions() {
    final actions = [
      _QuickAction(
        label: 'Kirim Dokumen',
        desc: 'Buat pengiriman baru',
        icon: Icons.send_rounded,
        iconBg: const Color(0xFFEEF2FF),
        iconColor: kAccentBlue,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => SendScreen()),
          );
        },
      ),
      _QuickAction(
        label: 'Tanda Tangan',
        desc: 'Konfirmasi penerimaan',
        icon: Icons.draw_rounded,
        iconBg: const Color(0xFFF0FDF4),
        iconColor: const Color(0xFF16A34A),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const DraftListScreen()),
          );
        },
      ),
      _QuickAction(
        label: 'Riwayat',
        desc: 'Lihat semua dokumen',
        icon: Icons.history_rounded,
        iconBg: const Color(0xFFFFF7ED),
        iconColor: const Color(0xFFD97706),
        onTap: () {},
      ),
      _QuickAction(
        label: 'Unduh PDF',
        desc: 'Export laporan',
        icon: Icons.picture_as_pdf_rounded,
        iconBg: const Color(0xFFFDF4FF),
        iconColor: const Color(0xFF7C3AED),
        onTap: () {},
      ),
    ];

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.55,
      children: actions.map((a) => _QuickActionCard(action: a)).toList(),
    );
  }

  Widget _buildRecentDocuments(
    AsyncSnapshot<List<DocumentListModel>> snapshot,
  ) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: CircularProgressIndicator(color: kAccentBlue),
        ),
      );
    }

    final docs = snapshot.data ?? [];

    if (docs.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: kLightBg),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                // ignore: deprecated_member_use
                color: kAccentBlue.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.inbox_rounded,
                size: 28,
                color: kAccentBlue,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Belum ada dokumen',
              style: TextStyle(fontSize: 13, color: kTextMuted),
            ),
          ],
        ),
      );
    }

    final recent = docs.take(5).toList();
    return Column(
      children: recent
          .map(
            (doc) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _RecentDocCard(doc: doc),
            ),
          )
          .toList(),
    );
  }
}

// ── Stat Card ───────────────────────────────────────────────
class _StatCard extends StatelessWidget {
  final Color iconBg;
  final Color iconColor;
  final IconData icon;
  final String value;
  final String label;
  final String sub;

  const _StatCard({
    required this.iconBg,
    required this.iconColor,
    required this.icon,
    required this.value,
    required this.label,
    required this.sub,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
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
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 16, color: iconColor),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: kTextDark,
              height: 1,
            ),
          ),
          const SizedBox(height: 3),
          Text(label, style: const TextStyle(fontSize: 12, color: kTextMuted)),
          const SizedBox(height: 1),
          Text(sub, style: const TextStyle(fontSize: 11, color: kBorderColor)),
        ],
      ),
    );
  }
}

// ── Quick Action ────────────────────────────────────────────
class _QuickAction {
  final String label;
  final String desc;
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final VoidCallback onTap;

  const _QuickAction({
    required this.label,
    required this.desc,
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.onTap,
  });
}

class _QuickActionCard extends StatelessWidget {
  final _QuickAction action;
  const _QuickActionCard({required this.action});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: action.onTap,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: kLightBg),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: action.iconBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(action.icon, size: 16, color: action.iconColor),
              ),
              const SizedBox(height: 8),
              Text(
                action.label,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: kTextDark,
                ),
              ),
              const SizedBox(height: 1),
              Text(
                action.desc,
                style: const TextStyle(fontSize: 10, color: kTextMuted),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Recent Doc Card ─────────────────────────────────────────
class _RecentDocCard extends StatelessWidget {
  final DocumentListModel doc;
  const _RecentDocCard({required this.doc});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        // SESUDAH
        await showModalBottomSheet<bool>(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (_) {
            return DraggableScrollableSheet(
              expand: false,
              initialChildSize: 0.65,
              minChildSize: 0.5,
              maxChildSize: 1,
              builder: (context, scrollController) {
                return SafeArea(
                  top: false,
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(24),
                      ),
                    ),
                    child: BottomSheetPreviewDocument(
                      documentId: doc.id,
                      scrollController: scrollController,
                    ),
                  ),
                );
              },
            );
          },
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: kLightBg),
          boxShadow: [
            BoxShadow(
              // ignore: deprecated_member_use
              color: Colors.black.withOpacity(0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                // ignore: deprecated_member_use
                color: kAccentBlue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.description_rounded,
                size: 16,
                color: kAccentBlue,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    doc.senderCompany,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: kTextDark,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '→ ${doc.receiverCompany}',
                    style: const TextStyle(fontSize: 11, color: kTextMuted),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFDCFCE7),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text(
                'Selesai',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF16A34A),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
