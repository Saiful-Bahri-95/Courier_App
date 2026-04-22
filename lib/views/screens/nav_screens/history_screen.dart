import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:store_app/models/document_list_model.dart';
import 'package:store_app/services/document_service.dart';
import 'package:store_app/views/screens/nav_screens/widgets/preview_history.dart';
import 'package:store_app/views/screens/utils.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  late Future<List<DocumentListModel>> _futureDocuments;

  // ── Search state ──
  bool _isSearching = false;
  String _searchQuery = '';
  final TextEditingController _searchCtrl = TextEditingController();
  final FocusNode _searchFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    _loadDocuments();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  void _loadDocuments() {
    _futureDocuments = DocumentService.getDocumentList();
  }

  void _openSearch() {
    setState(() => _isSearching = true);
    Future.delayed(const Duration(milliseconds: 100), () {
      _searchFocus.requestFocus();
    });
  }

  void _closeSearch() {
    setState(() {
      _isSearching = false;
      _searchQuery = '';
    });
    _searchCtrl.clear();
    _searchFocus.unfocus();
  }

  /// Filter berdasarkan nama pengirim, penerima, dan perusahaan
  List<DocumentListModel> _filterDocuments(List<DocumentListModel> docs) {
    if (_searchQuery.trim().isEmpty) return docs;
    final q = _searchQuery.trim().toLowerCase();
    return docs.where((doc) {
      return doc.senderCompany.toLowerCase().contains(q) ||
          doc.senderName.toLowerCase().contains(q) ||
          doc.receiverCompany.toLowerCase().contains(q) ||
          doc.receiverName.toLowerCase().contains(q);
    }).toList();
  }

  String _formatDate(DateTime date) {
    return DateFormat('dd MMM yyyy').format(date);
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: kNavyBlue,
      body: Column(
        children: [
          // ===== HEADER =====
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: topPadding + 20,
              bottom: 20,
            ),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: _isSearching ? _buildSearchBar() : _buildHeaderRow(),
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
              child: FutureBuilder<List<DocumentListModel>>(
                future: _futureDocuments,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(color: kAccentBlue),
                    );
                  }

                  if (snapshot.hasError) {
                    final err = snapshot.error.toString();
                    final isNetworkError =
                        err.contains('SocketException') ||
                        err.contains('Failed host lookup');
                    return _buildErrorState(isNetworkError);
                  }

                  final all = snapshot.data ?? [];
                  final filtered = _filterDocuments(all);

                  if (all.isEmpty) return _buildEmptyState();

                  if (filtered.isEmpty && _searchQuery.isNotEmpty) {
                    return _buildNotFoundState();
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _buildDocumentCard(filtered[index]),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Header normal ──────────────────────────────────────────
  Widget _buildHeaderRow() {
    return Row(
      key: const ValueKey('header'),
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'History',
                style: TextStyle(
                  fontSize: 26,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.3,
                ),
              ),
              Text(
                'Riwayat pengiriman dokumen',
                style: TextStyle(
                  fontSize: 13,
                  // ignore: deprecated_member_use
                  color: Colors.white.withOpacity(0.65),
                ),
              ),
            ],
          ),
        ),
        _HeaderIconButton(icon: Icons.search_rounded, onTap: _openSearch),
        const SizedBox(width: 10),
        _HeaderIconButton(
          icon: Icons.refresh_rounded,
          onTap: () => setState(() => _loadDocuments()),
        ),
      ],
    );
  }

  // ── Search bar ─────────────────────────────────────────────
  Widget _buildSearchBar() {
    return Row(
      key: const ValueKey('search'),
      children: [
        Expanded(
          child: Container(
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const SizedBox(width: 12),
                const Icon(Icons.search_rounded, color: kTextMuted, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _searchCtrl,
                    focusNode: _searchFocus,
                    style: const TextStyle(fontSize: 14, color: kTextDark),
                    decoration: const InputDecoration(
                      hintText: 'Cari pengirim atau penerima...',
                      hintStyle: TextStyle(fontSize: 13, color: kBorderColor),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                    onChanged: (v) => setState(() => _searchQuery = v),
                  ),
                ),
                if (_searchQuery.isNotEmpty)
                  GestureDetector(
                    onTap: () {
                      _searchCtrl.clear();
                      setState(() => _searchQuery = '');
                      _searchFocus.requestFocus();
                    },
                    child: const Padding(
                      padding: EdgeInsets.all(8),
                      child: Icon(
                        Icons.cancel_rounded,
                        size: 16,
                        color: kBorderColor,
                      ),
                    ),
                  )
                else
                  const SizedBox(width: 12),
              ],
            ),
          ),
        ),
        const SizedBox(width: 10),
        GestureDetector(
          onTap: _closeSearch,
          child: Container(
            height: 44,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              // ignore: deprecated_member_use
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.center,
            child: const Text(
              'Batal',
              style: TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ── Error state ────────────────────────────────────────────
  Widget _buildErrorState(bool isNetworkError) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                // ignore: deprecated_member_use
                color: Colors.red.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isNetworkError
                    ? Icons.wifi_off_rounded
                    : Icons.error_outline_rounded,
                size: 48,
                color: Colors.red.shade400,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              isNetworkError
                  ? 'Tidak dapat terhubung ke server'
                  : 'Terjadi kesalahan',
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: kTextDark,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              isNetworkError
                  ? 'Periksa koneksi internet Anda dan coba lagi.'
                  : 'Silakan coba beberapa saat lagi.',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, color: kTextMuted),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () => setState(() => _loadDocuments()),
              icon: const Icon(Icons.refresh_rounded, size: 16),
              label: const Text('Coba Lagi'),
              style: ElevatedButton.styleFrom(
                backgroundColor: kAccentBlue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                elevation: 0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Empty state ────────────────────────────────────────────
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                // ignore: deprecated_member_use
                color: kAccentBlue.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.inbox_rounded,
                size: 52,
                color: kAccentBlue,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Belum ada dokumen',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: kTextDark,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Dokumen yang dikirim akan muncul di sini.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: kTextMuted),
            ),
          ],
        ),
      ),
    );
  }

  // ── Not found state ────────────────────────────────────────
  Widget _buildNotFoundState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                // ignore: deprecated_member_use
                color: kTextMuted.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.search_off_rounded,
                size: 44,
                color: kTextMuted,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Dokumen tidak ditemukan',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: kTextDark,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Tidak ada hasil untuk "$_searchQuery".',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, color: kTextMuted),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {
                _searchCtrl.clear();
                setState(() => _searchQuery = '');
              },
              child: const Text(
                'Hapus pencarian',
                style: TextStyle(color: kAccentBlue),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Document card ──────────────────────────────────────────
  Widget _buildDocumentCard(DocumentListModel doc) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () async {
          final result = await showModalBottomSheet<bool>(
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
          if (result == true) setState(() => _loadDocuments());
        },
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                // ignore: deprecated_member_use
                color: Colors.black.withOpacity(0.06),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      // ignore: deprecated_member_use
                      color: const Color(0xFF059669).withOpacity(0.12),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.check_circle_rounded,
                          size: 12,
                          color: Color(0xFF059669),
                        ),
                        SizedBox(width: 4),
                        Text(
                          'Completed',
                          style: TextStyle(
                            color: Color(0xFF059669),
                            fontWeight: FontWeight.w700,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  const Icon(
                    Icons.calendar_today_rounded,
                    size: 11,
                    color: kTextMuted,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _formatDate(doc.createdAt),
                    style: const TextStyle(
                      color: kTextMuted,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(height: 1, color: kLightBg),
              const SizedBox(height: 12),

              // FROM
              Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      // ignore: deprecated_member_use
                      color: kAccentBlue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Image.asset(
                      'assets/icons/up.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _HighlightText(
                          text: doc.senderCompany,
                          query: _searchQuery,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                            color: kTextDark,
                          ),
                        ),
                        const SizedBox(height: 2),
                        _HighlightText(
                          text: 'Dari ${doc.senderName}',
                          query: _searchQuery,
                          style: const TextStyle(
                            color: kTextMuted,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              // Connector dots
              Padding(
                padding: const EdgeInsets.only(left: 19),
                child: Column(
                  children: List.generate(
                    3,
                    (_) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Container(
                        width: 2,
                        height: 4,
                        decoration: BoxDecoration(
                          color: kBorderColor,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // TO
              Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      // ignore: deprecated_member_use
                      color: const Color(0xFFD97706).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Image.asset(
                      'assets/icons/location.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _HighlightText(
                          text: doc.receiverCompany,
                          query: _searchQuery,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                            color: kTextDark,
                          ),
                        ),
                        const SizedBox(height: 2),
                        _HighlightText(
                          text: 'Kepada ${doc.receiverName}',
                          query: _searchQuery,
                          style: const TextStyle(
                            color: kTextMuted,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 13,
                    color: kBorderColor,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Reusable header icon button ─────────────────────────────
class _HeaderIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _HeaderIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(9),
        decoration: BoxDecoration(
          // ignore: deprecated_member_use
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: Colors.white, size: 18),
      ),
    );
  }
}

// ── Highlight kata yang cocok dengan query ─────────────────
class _HighlightText extends StatelessWidget {
  final String text;
  final String query;
  final TextStyle style;

  const _HighlightText({
    required this.text,
    required this.query,
    required this.style,
  });

  @override
  Widget build(BuildContext context) {
    if (query.trim().isEmpty) {
      return Text(text, style: style, overflow: TextOverflow.ellipsis);
    }

    final lowerText = text.toLowerCase();
    final lowerQuery = query.trim().toLowerCase();
    final matchIdx = lowerText.indexOf(lowerQuery);

    if (matchIdx == -1) {
      return Text(text, style: style, overflow: TextOverflow.ellipsis);
    }

    final before = text.substring(0, matchIdx);
    final matched = text.substring(matchIdx, matchIdx + lowerQuery.length);
    final after = text.substring(matchIdx + lowerQuery.length);

    return Text.rich(
      TextSpan(
        children: [
          TextSpan(text: before, style: style),
          TextSpan(
            text: matched,
            style: style.copyWith(
              // ignore: deprecated_member_use
              backgroundColor: kAccentBlue.withOpacity(0.18),
              color: kAccentBlue,
              fontWeight: FontWeight.w800,
            ),
          ),
          TextSpan(text: after, style: style),
        ],
      ),
      overflow: TextOverflow.ellipsis,
    );
  }
}
