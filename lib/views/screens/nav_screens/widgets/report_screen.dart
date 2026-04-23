import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:store_app/models/document_list_model.dart';
import 'package:store_app/provider/user_provider.dart';
import 'package:store_app/services/document_service.dart';
import 'package:store_app/services/report_pdf_service.dart';
import 'package:store_app/views/screens/utils.dart';

class ReportScreen extends ConsumerStatefulWidget {
  const ReportScreen({super.key});

  @override
  ConsumerState<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends ConsumerState<ReportScreen> {
  DateTime _startDate = DateTime(DateTime.now().year, DateTime.now().month, 1);
  DateTime _endDate = DateTime.now();
  bool _isGenerating = false;
  bool _useMonthFilter = true;
  DateTime _selectedMonth = DateTime(DateTime.now().year, DateTime.now().month);

  List<DocumentListModel> _allDocuments = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadDocuments();
  }

  Future<void> _loadDocuments() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final docs = await DocumentService.getDocumentList();
      setState(() {
        _allDocuments = docs;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  List<DocumentListModel> get _filtered {
    final start = DateTime(_startDate.year, _startDate.month, _startDate.day);
    final end = DateTime(
      _endDate.year,
      _endDate.month,
      _endDate.day,
      23,
      59,
      59,
    );
    return _allDocuments
        .where(
          (doc) =>
              doc.createdAt.isAfter(
                start.subtract(const Duration(seconds: 1)),
              ) &&
              doc.createdAt.isBefore(end.add(const Duration(seconds: 1))),
        )
        .toList();
  }

  Map<String, int> get _bySender {
    final Map<String, int> result = {};
    for (final doc in _filtered) {
      result[doc.senderCompany] = (result[doc.senderCompany] ?? 0) + 1;
    }
    return result;
  }

  void _applyMonthFilter(DateTime month) {
    setState(() {
      _selectedMonth = month;
      _startDate = DateTime(month.year, month.month, 1);
      _endDate = DateTime(month.year, month.month + 1, 0);
      _useMonthFilter = true;
    });
  }

  Future<void> _pickDate({required bool isStart}) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isStart ? _startDate : _endDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: kAccentBlue,
            onPrimary: Colors.white,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() {
        _useMonthFilter = false;
        if (isStart) {
          _startDate = picked;
          if (_startDate.isAfter(_endDate)) _endDate = _startDate;
        } else {
          _endDate = picked;
          if (_endDate.isBefore(_startDate)) _startDate = _endDate;
        }
      });
    }
  }

  Future<void> _generatePdf() async {
    final filtered = _filtered;
    // Debug: cek data dulu
    debugPrint('Total filtered: ${filtered.length}');
    for (final doc in filtered.take(2)) {
      debugPrint('Doc: ${doc.senderCompany} | createdAt: ${doc.createdAt}');
    }

    if (filtered.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Tidak ada dokumen di periode ini'),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      return;
    }
    setState(() => _isGenerating = true);
    final user = ref.read(userProvider);
    await ReportPdfService.generateAndShare(
      context: context,
      documents: filtered,
      startDate: _startDate,
      endDate: _endDate,
      generatedBy: user?.fullname ?? '-',
    );
    setState(() => _isGenerating = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kNavyBlue,
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0xFFF8FAFC),
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(color: kAccentBlue),
                    )
                  : _error != null
                  ? _buildError()
                  : SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildMonthSelector(),
                          const SizedBox(height: 16),
                          _buildDateRangePicker(),
                          const SizedBox(height: 20),
                          _buildStatCards(),
                          const SizedBox(height: 20),
                          _buildTopSenders(),
                          const SizedBox(height: 20),
                          _buildDocumentPreview(),
                          const SizedBox(height: 24),
                          _buildGenerateButton(),
                        ],
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
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
                color: Colors.white.withValues(alpha: 0.15),
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
                'Laporan PDF',
                style: TextStyle(
                  fontSize: 22,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Export laporan pengiriman',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.white.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
          const Spacer(),
          GestureDetector(
            onTap: _loadDocuments,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.refresh_rounded,
                color: Colors.white,
                size: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline_rounded, size: 48, color: Colors.red),
          const SizedBox(height: 12),
          const Text(
            'Gagal memuat dokumen',
            style: TextStyle(fontWeight: FontWeight.bold, color: kTextDark),
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: _loadDocuments,
            style: ElevatedButton.styleFrom(
              backgroundColor: kAccentBlue,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              'Coba Lagi',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthSelector() {
    final months = List.generate(
      6,
      (i) => DateTime(DateTime.now().year, DateTime.now().month - i),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionLabel('Pilih Bulan'),
        const SizedBox(height: 10),
        SizedBox(
          height: 42,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: months.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (_, i) {
              final month = months[i];
              final isSelected =
                  _useMonthFilter &&
                  month.month == _selectedMonth.month &&
                  month.year == _selectedMonth.year;
              return GestureDetector(
                onTap: () => _applyMonthFilter(month),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected ? kAccentBlue : Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isSelected ? kAccentBlue : kBorderColor,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: kAccentBlue.withValues(alpha: 0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ]
                        : [],
                  ),
                  child: Text(
                    DateFormat('MMM yyyy').format(month),
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? Colors.white : kTextDark,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDateRangePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionLabel('Atau Pilih Range Tanggal'),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _dateTile(
                label: 'Dari',
                date: _startDate,
                onTap: () => _pickDate(isStart: true),
              ),
            ),
            const SizedBox(width: 10),
            const Icon(
              Icons.arrow_forward_rounded,
              color: kTextMuted,
              size: 18,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _dateTile(
                label: 'Sampai',
                date: _endDate,
                onTap: () => _pickDate(isStart: false),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _dateTile({
    required String label,
    required DateTime date,
    required VoidCallback onTap,
  }) {
    final active = !_useMonthFilter;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: active ? kAccentBlue : kBorderColor,
            width: active ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.calendar_today_rounded,
              size: 16,
              color: active ? kAccentBlue : kTextMuted,
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(fontSize: 10, color: kTextMuted),
                ),
                Text(
                  DateFormat('dd MMM yyyy').format(date),
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: active ? kAccentBlue : kTextDark,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCards() {
    final filtered = _filtered;
    final total = filtered.length;
    final senderCount = _bySender.length;
    final maxSender = _bySender.isEmpty
        ? 0
        : _bySender.values.reduce((a, b) => a > b ? a : b);
    return Row(
      children: [
        _statCard(
          value: '$total',
          label: 'Total Dokumen',
          icon: Icons.description_rounded,
          color: kAccentBlue,
          bgColor: const Color(0xFFEEF2FF),
        ),
        const SizedBox(width: 10),
        _statCard(
          value: '$senderCount',
          label: 'Pengirim Aktif',
          icon: Icons.business_rounded,
          color: const Color(0xFF16A34A),
          bgColor: const Color(0xFFF0FDF4),
        ),
        const SizedBox(width: 10),
        _statCard(
          value: '$maxSender',
          label: 'Terbanyak',
          icon: Icons.trending_up_rounded,
          color: const Color(0xFF7C3AED),
          bgColor: const Color(0xFFF5F3FF),
        ),
      ],
    );
  }

  Widget _statCard({
    required String value,
    required String label,
    required IconData icon,
    required Color color,
    required Color bgColor,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 16, color: color),
            ),
            const SizedBox(height: 10),
            Text(
              value,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: color,
                height: 1,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: const TextStyle(fontSize: 11, color: kTextMuted),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopSenders() {
    final senders = _bySender.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    if (senders.isEmpty) return const SizedBox.shrink();
    final total = _filtered.length;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionLabel('Top Pengirim'),
          const SizedBox(height: 14),
          ...senders.take(5).map((e) {
            final percent = total == 0 ? 0.0 : e.value / total;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          e.key,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: kTextDark,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${e.value} (${(percent * 100).toStringAsFixed(0)}%)',
                        style: const TextStyle(
                          fontSize: 12,
                          color: kAccentBlue,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: percent,
                      minHeight: 8,
                      backgroundColor: kLightBg,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        kAccentBlue,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildDocumentPreview() {
    final filtered = _filtered;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              color: kNavyBlue,
              borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.list_alt_rounded,
                  color: Colors.white,
                  size: 16,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Preview Dokumen',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '${filtered.length} dokumen',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (filtered.isEmpty)
            const Padding(
              padding: EdgeInsets.all(24),
              child: Center(
                child: Text(
                  'Tidak ada dokumen di periode ini',
                  style: TextStyle(color: kTextMuted, fontSize: 13),
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: filtered.take(5).length,
              separatorBuilder: (_, __) =>
                  const Divider(height: 1, color: kLightBg),
              itemBuilder: (_, i) {
                final doc = filtered[i];
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: kAccentBlue.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Text(
                            '${i + 1}',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: kAccentBlue,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
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
                            Text(
                              '→ ${doc.receiverCompany}',
                              style: const TextStyle(
                                fontSize: 11,
                                color: kTextMuted,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        DateFormat('dd MMM').format(doc.createdAt),
                        style: const TextStyle(fontSize: 11, color: kTextMuted),
                      ),
                    ],
                  ),
                );
              },
            ),
          if (filtered.length > 5)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
              child: Text(
                '+ ${filtered.length - 5} dokumen lainnya akan masuk ke PDF',
                style: const TextStyle(
                  fontSize: 12,
                  color: kTextMuted,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildGenerateButton() {
    final filtered = _filtered;
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: _isGenerating || filtered.isEmpty ? null : _generatePdf,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF7C3AED),
          disabledBackgroundColor: kBorderColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 0,
        ),
        child: _isGenerating
            ? const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  ),
                  SizedBox(width: 10),
                  Text(
                    'Membuat PDF...',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ],
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.picture_as_pdf_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    filtered.isEmpty
                        ? 'Tidak ada dokumen'
                        : 'Export ${filtered.length} Dokumen ke PDF',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
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
            letterSpacing: 0.3,
          ),
        ),
      ],
    );
  }
}
