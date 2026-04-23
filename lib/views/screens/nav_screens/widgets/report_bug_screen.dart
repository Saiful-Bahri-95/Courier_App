import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:store_app/provider/user_provider.dart';
import 'package:store_app/views/screens/utils.dart';

class ReportBugScreen extends ConsumerStatefulWidget {
  const ReportBugScreen({super.key});

  @override
  ConsumerState<ReportBugScreen> createState() => _ReportBugScreenState();
}

class _ReportBugScreenState extends ConsumerState<ReportBugScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descCtrl = TextEditingController();
  final _stepsCtrl = TextEditingController();

  String? _selectedCategory;
  String _selectedPriority = 'Sedang';
  bool _isSubmitting = false;
  bool _isSubmitted = false;

  final List<String> _categories = [
    'Login / Autentikasi',
    'Kirim Dokumen',
    'Tanda Tangan',
    'Riwayat / History',
    'Draft Dokumen',
    'Export PDF',
    'Laporan',
    'Profil / Akun',
    'Lainnya',
  ];

  final List<_PriorityOption> _priorities = [
    _PriorityOption(
      'Rendah',
      Icons.arrow_downward_rounded,
      const Color(0xFF16A34A),
      const Color(0xFFF0FDF4),
    ),
    _PriorityOption(
      'Sedang',
      Icons.remove_rounded,
      const Color(0xFFD97706),
      const Color(0xFFFFF7ED),
    ),
    _PriorityOption(
      'Tinggi',
      Icons.arrow_upward_rounded,
      const Color(0xFFDC2626),
      const Color(0xFFFEF2F2),
    ),
  ];

  @override
  void dispose() {
    _descCtrl.dispose();
    _stepsCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);
    // Simulasi submit (bisa dihubungkan ke API/email nanti)
    await Future.delayed(const Duration(seconds: 2));
    setState(() {
      _isSubmitting = false;
      _isSubmitted = true;
    });
  }

  void _reset() {
    _formKey.currentState?.reset();
    _descCtrl.clear();
    _stepsCtrl.clear();
    setState(() {
      _selectedCategory = null;
      _selectedPriority = 'Sedang';
      _isSubmitted = false;
    });
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
              child: _isSubmitted ? _buildSuccessState() : _buildForm(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: topPadding + 16,
        bottom: 24,
      ),
      child: Row(
        children: [
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
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Laporkan Bug',
                style: TextStyle(
                  fontSize: 22,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Bantu kami meningkatkan aplikasi',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.white.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildForm() {
    final user = ref.watch(userProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Info card
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: kAccentBlue.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: kAccentBlue.withValues(alpha: 0.2)),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.info_outline_rounded,
                    color: kAccentBlue,
                    size: 18,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Laporan kamu akan membantu tim developer memperbaiki masalah lebih cepat.',
                      style: TextStyle(
                        fontSize: 12,
                        color: kAccentBlue.withValues(alpha: 0.8),
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Pelapor
            _sectionLabel('Pelapor'),
            const SizedBox(height: 10),
            Container(
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
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: kAccentBlue.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.person_rounded,
                      color: kAccentBlue,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user?.fullname ?? '-',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: kTextDark,
                        ),
                      ),
                      Text(
                        user?.email ?? '-',
                        style: const TextStyle(fontSize: 12, color: kTextMuted),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Kategori bug
            _sectionLabel('Kategori Bug'),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              initialValue: _selectedCategory,
              decoration: InputDecoration(
                hintText: 'Pilih kategori',
                hintStyle: const TextStyle(color: kTextMuted, fontSize: 13),
                prefixIcon: const Icon(
                  Icons.category_rounded,
                  size: 20,
                  color: kAccentBlue,
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: kBorderColor),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: kAccentBlue, width: 1.5),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.red),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.red, width: 1.5),
                ),
              ),
              items: _categories
                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
              onChanged: (v) => setState(() => _selectedCategory = v),
              validator: (v) => v == null ? 'Pilih kategori bug' : null,
            ),

            const SizedBox(height: 20),

            // Prioritas
            _sectionLabel('Tingkat Prioritas'),
            const SizedBox(height: 10),
            Row(
              children: _priorities.map((p) {
                final isSelected = _selectedPriority == p.label;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedPriority = p.label),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: EdgeInsets.only(
                        right: p.label != 'Tinggi' ? 8 : 0,
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: isSelected ? p.color : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected ? p.color : kBorderColor,
                          width: isSelected ? 0 : 1,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: p.color.withValues(alpha: 0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ]
                            : [],
                      ),
                      child: Column(
                        children: [
                          Icon(
                            p.icon,
                            size: 18,
                            color: isSelected ? Colors.white : p.color,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            p.label,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: isSelected ? Colors.white : kTextDark,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 20),

            // Deskripsi bug
            _sectionLabel('Deskripsi Bug'),
            const SizedBox(height: 10),
            TextFormField(
              controller: _descCtrl,
              maxLines: 4,
              minLines: 3,
              style: const TextStyle(fontSize: 14, color: kTextDark),
              decoration: InputDecoration(
                hintText: 'Jelaskan bug yang kamu temukan...',
                hintStyle: const TextStyle(color: kTextMuted, fontSize: 13),
                alignLabelWithHint: true,
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.all(14),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: kBorderColor),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: kAccentBlue, width: 1.5),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.red),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.red, width: 1.5),
                ),
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) {
                  return 'Deskripsi bug wajib diisi';
                }
                if (v.trim().length < 20) {
                  return 'Deskripsi minimal 20 karakter';
                }
                return null;
              },
            ),

            const SizedBox(height: 20),

            // Langkah reproduksi
            _sectionLabel('Langkah Reproduksi (Opsional)'),
            const SizedBox(height: 6),
            Text(
              'Bagaimana cara memunculkan bug ini?',
              style: const TextStyle(fontSize: 12, color: kTextMuted),
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _stepsCtrl,
              maxLines: 4,
              minLines: 3,
              style: const TextStyle(fontSize: 14, color: kTextDark),
              decoration: InputDecoration(
                hintText:
                    '1. Buka halaman...\n2. Klik tombol...\n3. Bug muncul...',
                hintStyle: const TextStyle(color: kTextMuted, fontSize: 13),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.all(14),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: kBorderColor),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: kAccentBlue, width: 1.5),
                ),
              ),
            ),

            const SizedBox(height: 28),

            // Submit button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: kAccentBlue,
                  disabledBackgroundColor: kBorderColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                child: _isSubmitting
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
                            'Mengirim laporan...',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      )
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.bug_report_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Kirim Laporan',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuccessState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF16A34A).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle_rounded,
                size: 64,
                color: Color(0xFF16A34A),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Laporan Terkirim!',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: kTextDark,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Terima kasih telah melaporkan bug ini. Tim developer akan segera menindaklanjuti laporan kamu.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: kTextMuted, height: 1.5),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _reset,
                style: ElevatedButton.styleFrom(
                  backgroundColor: kAccentBlue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Laporkan Bug Lain',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Kembali ke Profil',
                style: TextStyle(color: kTextMuted),
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

class _PriorityOption {
  final String label;
  final IconData icon;
  final Color color;
  final Color bgColor;

  const _PriorityOption(this.label, this.icon, this.color, this.bgColor);
}
