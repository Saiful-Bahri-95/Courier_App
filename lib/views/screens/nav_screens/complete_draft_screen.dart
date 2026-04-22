import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:signature/signature.dart';
import 'package:store_app/models/document_data.dart';
import 'package:store_app/provider/user_provider.dart';
import 'package:store_app/services/cloudinary_service.dart';
import 'package:store_app/services/document_service.dart';
import 'package:store_app/services/draft_service.dart';
import 'package:store_app/services/manage_http_response.dart';
import 'package:store_app/views/screens/main_screen.dart';
import 'package:store_app/views/screens/utils.dart';

class CompleteDraftScreen extends ConsumerStatefulWidget {
  final DraftDocument draft;
  const CompleteDraftScreen({super.key, required this.draft});

  @override
  ConsumerState<CompleteDraftScreen> createState() =>
      _CompleteDraftScreenState();
}

class _CompleteDraftScreenState extends ConsumerState<CompleteDraftScreen> {
  final _formKey = GlobalKey<FormState>();
  final signedNameCtrl = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  File? receiverImage;
  bool _hasSignature = false;

  final SignatureController _signatureController = SignatureController(
    penStrokeWidth: 3,
    penColor: Colors.black,
  );

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _signatureController.addListener(() {
      if (_signatureController.isNotEmpty && !_hasSignature) {
        setState(() => _hasSignature = true);
      }
    });
  }

  @override
  void dispose() {
    signedNameCtrl.dispose();
    _signatureController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    final XFile? image = await _picker.pickImage(
      source: source,
      imageQuality: 80,
    );
    if (image != null) setState(() => receiverImage = File(image.path));
  }

  void _showImageSourcePicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: kBorderColor,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Pilih Sumber Foto',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: kTextDark,
              ),
            ),
            const SizedBox(height: 16),
            _sourceTile(
              icon: Icons.camera_alt_rounded,
              label: 'Ambil dari Kamera',
              color: kAccentBlue,
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            const SizedBox(height: 10),
            _sourceTile(
              icon: Icons.photo_library_rounded,
              label: 'Pilih dari Galeri',
              color: kNavyBlue,
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _sourceTile({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 14),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
            const Spacer(),
            Icon(Icons.arrow_forward_ios_rounded, color: color, size: 14),
          ],
        ),
      ),
    );
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
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Info card dokumen
                      _buildDraftInfoCard(),
                      const SizedBox(height: 20),

                      // Tanggal
                      _sectionLabel('Tanggal Penerimaan'),
                      const SizedBox(height: 12),
                      _buildDatePicker(),
                      const SizedBox(height: 20),

                      // Nama penerima
                      _sectionLabel('Nama Penerima'),
                      const SizedBox(height: 12),
                      _buildField(
                        label: 'Nama Penerima',
                        icon: Icons.person_rounded,
                        controller: signedNameCtrl,
                      ),

                      // Foto bukti
                      _sectionLabel('Foto Bukti Penerimaan'),
                      const SizedBox(height: 6),
                      const Text(
                        'Foto penerima saat menerima dokumen',
                        style: TextStyle(fontSize: 12, color: kTextMuted),
                      ),
                      const SizedBox(height: 10),
                      _buildImagePicker(),
                      const SizedBox(height: 20),

                      // Tanda tangan
                      _sectionLabel('Tanda Tangan Penerima'),
                      const SizedBox(height: 12),
                      _buildSignaturePad(),
                      const SizedBox(height: 28),

                      // Submit button
                      _buildSubmitButton(),
                    ],
                  ),
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
                'Lengkapi Dokumen',
                style: TextStyle(
                  fontSize: 22,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Tanda tangan & foto bukti',
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

  Widget _buildDraftInfoCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1A3C8F), Color(0xFF2563EB)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.receipt_long_rounded,
                color: Colors.white70,
                size: 14,
              ),
              const SizedBox(width: 6),
              Text(
                widget.draft.documentType ?? 'Dokumen',
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'Draft',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            widget.draft.senderCompany,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            '→ ${widget.draft.receiverCompany}',
            style: const TextStyle(color: Colors.white70, fontSize: 13),
          ),
          const SizedBox(height: 3),
          Text(
            'Kepada: ${widget.draft.receiverName}',
            style: const TextStyle(color: Colors.white60, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildDatePicker() {
    final DateTime today = DateTime.now();
    final List<DateTime> dates = List.generate(
      5,
      (i) => today.subtract(const Duration(days: 2)).add(Duration(days: i)),
    );
    const days = ['Min', 'Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab'];
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];

    return SizedBox(
      height: 88,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: dates.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (_, index) {
          final date = dates[index];
          final isSelected =
              date.day == _selectedDate.day &&
              date.month == _selectedDate.month &&
              date.year == _selectedDate.year;
          return GestureDetector(
            onTap: () => setState(() => _selectedDate = date),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 64,
              decoration: BoxDecoration(
                color: isSelected ? kAccentBlue : kLightBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected ? kAccentBlue : kBorderColor,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: kAccentBlue.withValues(alpha: 0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : [],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    days[date.weekday % 7],
                    style: TextStyle(
                      fontSize: 11,
                      color: isSelected ? Colors.white70 : kTextMuted,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${date.day}',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.white : kTextDark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    months[date.month - 1],
                    style: TextStyle(
                      fontSize: 11,
                      color: isSelected ? Colors.white70 : kTextMuted,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildField({
    required String label,
    required IconData icon,
    required TextEditingController controller,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: TextFormField(
        controller: controller,
        style: const TextStyle(fontSize: 14, color: kTextDark),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: kTextMuted, fontSize: 13),
          prefixIcon: Icon(icon, size: 20, color: kAccentBlue),
          filled: true,
          fillColor: kLightBg,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: kBorderColor, width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: kAccentBlue, width: 1.5),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.red, width: 1),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.red, width: 1.5),
          ),
        ),
        validator: (value) =>
            value == null || value.trim().isEmpty ? '$label wajib diisi' : null,
      ),
    );
  }

  Widget _buildImagePicker() {
    return GestureDetector(
      onTap: _showImageSourcePicker,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 160,
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          color: receiverImage != null ? Colors.transparent : kLightBg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: receiverImage != null ? kAccentBlue : kBorderColor,
            width: receiverImage != null ? 2 : 1,
          ),
        ),
        child: receiverImage == null
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: kAccentBlue.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.camera_alt_rounded,
                      size: 28,
                      color: kAccentBlue,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Tap untuk ambil foto',
                    style: TextStyle(
                      color: kTextMuted,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              )
            : Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(
                      receiverImage!,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: () => setState(() => receiverImage = null),
                      child: Container(
                        padding: const EdgeInsets.all(5),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 14,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildSignaturePad() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 200,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: _hasSignature ? kAccentBlue : kBorderColor,
              width: _hasSignature ? 2 : 1,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(13),
            child: Stack(
              children: [
                Signature(
                  controller: _signatureController,
                  backgroundColor: kLightBg,
                ),
                if (!_hasSignature)
                  const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.draw_rounded, size: 30, color: kBorderColor),
                        SizedBox(height: 8),
                        Text(
                          'Tanda tangan di sini',
                          style: TextStyle(color: kTextMuted, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        TextButton.icon(
          onPressed: () {
            _signatureController.clear();
            setState(() => _hasSignature = false);
          },
          icon: const Icon(Icons.refresh_rounded, size: 16, color: kTextMuted),
          label: const Text(
            'Ulangi Tanda Tangan',
            style: TextStyle(color: kTextMuted, fontSize: 13),
          ),
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: () async {
          if (!_formKey.currentState!.validate()) return;

          if (_signatureController.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Row(
                  children: [
                    Icon(Icons.warning_rounded, color: Colors.white),
                    SizedBox(width: 8),
                    Text('Tanda tangan wajib diisi'),
                  ],
                ),
                backgroundColor: Colors.orange,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            );
            return;
          }

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
            final signatureBytes = await _signatureController.toPngBytes();

            // Build DocumentData dari draft
            final docData = DocumentData()
              ..senderCompany = widget.draft.senderCompany
              ..senderName = widget.draft.senderName
              ..senderPhone = widget.draft.senderPhone
              ..receiverCompany = widget.draft.receiverCompany
              ..receiverName = widget.draft.receiverName
              ..receiverPhone = widget.draft.receiverPhone
              ..documentType = widget.draft.documentType
              ..description = widget.draft.description
              ..receivedDate = _selectedDate
              ..signedName = signedNameCtrl.text.trim()
              ..signature = signatureBytes
              ..receiverImage = receiverImage;

            // Upload gambar
            String? receiverImageUrl;
            if (receiverImage != null) {
              receiverImageUrl = await UploadService.uploadImageFile(
                receiverImage!,
                user.token,
              );
            }

            String? signatureUrl;
            if (signatureBytes != null) {
              signatureUrl = await UploadService.uploadSignature(
                signatureBytes,
                user.token,
              );
            }

            // Submit ke backend
            await DocumentService.submit(
              docData,
              receiverImageUrl,
              signatureUrl,
            );

            // Hapus draft setelah berhasil submit
            await DraftService.delete(widget.draft.id);

            if (!mounted) return;

            Navigator.pop(context); // tutup loading

            showSnackbar(context, 'Dokumen berhasil dikirim ✅');

            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const MainScreen()),
              (route) => false,
            );
          } catch (e) {
            if (!mounted) return;
            Navigator.pop(context);
            showSnackbar(context, e.toString());
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF16A34A),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 0,
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
            SizedBox(width: 8),
            Text(
              'Submit Dokumen',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget _sectionLabel(String label) {
  return Row(
    children: [
      Container(
        width: 4,
        height: 18,
        decoration: BoxDecoration(
          color: kAccentBlue,
          borderRadius: BorderRadius.circular(4),
        ),
      ),
      const SizedBox(width: 8),
      Text(
        label,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: kTextDark,
          letterSpacing: 0.2,
        ),
      ),
    ],
  );
}
