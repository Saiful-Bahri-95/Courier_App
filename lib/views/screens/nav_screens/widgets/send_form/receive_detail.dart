import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:store_app/models/document_data.dart';
import 'package:store_app/services/draft_service.dart';
import 'package:store_app/views/screens/main_screen.dart';
import 'package:store_app/views/screens/nav_screens/widgets/send_form/sign_detail.dart';
import 'package:store_app/views/screens/utils.dart';
import 'send_form_widgets.dart';

class ReceiverDetailScreen extends StatefulWidget {
  final DocumentData documentData;
  final bool isDraft; // ← tambah ini
  const ReceiverDetailScreen({
    super.key,
    required this.documentData,
    this.isDraft = false,
  });

  @override
  State<ReceiverDetailScreen> createState() => _ReceiverDetailScreenState();
}

class _ReceiverDetailScreenState extends State<ReceiverDetailScreen> {
  final _formKey = GlobalKey<FormState>();
  final companyCtrl = TextEditingController();
  final receiverCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();

  final ImagePicker _picker = ImagePicker();
  File? receiverImage;

  @override
  void dispose() {
    companyCtrl.dispose();
    receiverCtrl.dispose();
    phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    final XFile? image = await _picker.pickImage(
      source: source,
      imageQuality: 80,
    );
    if (image != null) {
      setState(() => receiverImage = File(image.path));
    }
  }

  void _showImageSourcePicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
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
              _imageSourceTile(
                icon: Icons.camera_alt_rounded,
                label: 'Ambil dari Kamera',
                color: kAccentBlue,
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              const SizedBox(height: 10),
              _imageSourceTile(
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
        );
      },
    );
  }

  Widget _imageSourceTile({
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
          // ignore: deprecated_member_use
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
          // ignore: deprecated_member_use
          border: Border.all(color: color.withOpacity(0.2)),
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
      resizeToAvoidBottomInset: true,
      backgroundColor: kNavyBlue,
      body: Column(
        children: [
          buildSendHeader(
            context,
            title: 'Send Document',
            subtitle: 'Detail Penerima',
          ),
          buildWhiteFormContainer(
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildStepIndicator(current: 2, total: 3),
                    const SizedBox(height: 20),
                    buildSectionLabel('Informasi Penerima'),
                    const SizedBox(height: 12),
                    buildFormField(
                      label: 'Alamat / Nama Perusahaan',
                      icon: Icons.business_rounded,
                      controller: companyCtrl,
                    ),
                    buildFormField(
                      label: 'Nama Penerima / UP',
                      icon: Icons.person_rounded,
                      controller: receiverCtrl,
                    ),
                    buildFormField(
                      label: 'Nomor Telepon',
                      icon: Icons.phone_rounded,
                      controller: phoneCtrl,
                      keyboardType: TextInputType.phone,
                      validator: (_) => null, // ← tidak wajib diisi
                    ),
                    const SizedBox(height: 8),
                    buildSectionLabel('Bukti Penerimaan'),
                    const SizedBox(height: 6),
                    Text(
                      'Foto penerima (opsional)',
                      style: TextStyle(fontSize: 12, color: kTextMuted),
                    ),
                    const SizedBox(height: 10),
                    _buildImagePicker(),
                    // Ganti bagian buildBottomNavButtons dan TextButton.icon dengan:
                    const SizedBox(height: 28),

                    widget.isDraft
                        // ===== MODE DRAFT: hanya tombol simpan =====
                        ? SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: ElevatedButton(
                              onPressed: () async {
                                if (_formKey.currentState!.validate()) {
                                  widget.documentData
                                    ..receiverCompany = companyCtrl.text.trim()
                                    ..receiverName = receiverCtrl.text.trim()
                                    ..receiverPhone = phoneCtrl.text.trim();

                                  final draft = DraftDocument(
                                    id: DateTime.now().millisecondsSinceEpoch
                                        .toString(),
                                    senderCompany:
                                        widget.documentData.senderCompany ?? '',
                                    senderName:
                                        widget.documentData.senderName ?? '',
                                    senderPhone:
                                        widget.documentData.senderPhone ?? '',
                                    receiverCompany:
                                        widget.documentData.receiverCompany ??
                                        '',
                                    receiverName:
                                        widget.documentData.receiverName ?? '',
                                    receiverPhone:
                                        widget.documentData.receiverPhone ?? '',
                                    documentType:
                                        widget.documentData.documentType,
                                    description:
                                        widget.documentData.description,
                                    createdAt: DateTime.now(),
                                  );

                                  await DraftService.save(draft);

                                  // ignore: use_build_context_synchronously
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: const Row(
                                        children: [
                                          Icon(
                                            Icons.check_circle_rounded,
                                            color: Colors.white,
                                          ),
                                          SizedBox(width: 8),
                                          Text('Draft berhasil disimpan'),
                                        ],
                                      ),
                                      backgroundColor: const Color(0xFF16A34A),
                                      behavior: SnackBarBehavior.floating,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                  );

                                  // ignore: use_build_context_synchronously
                                  Navigator.of(context).pushAndRemoveUntil(
                                    MaterialPageRoute(
                                      builder: (_) => const MainScreen(),
                                    ),
                                    (route) => false,
                                  );
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFD97706),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                elevation: 0,
                              ),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.save_rounded,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    'Simpan Draft',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        // ===== MODE KIRIM: tombol next + simpan draft =====
                        : Column(
                            children: [
                              buildBottomNavButtons(
                                context: context,
                                nextLabel: 'Selanjutnya',
                                nextIcon: Icons.arrow_forward_rounded,
                                onNext: () {
                                  if (_formKey.currentState!.validate()) {
                                    widget.documentData
                                      ..receiverCompany = companyCtrl.text
                                          .trim()
                                      ..receiverName = receiverCtrl.text.trim()
                                      ..receiverPhone = phoneCtrl.text.trim()
                                      ..receiverImage = receiverImage;

                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => SignDetail(
                                          documentData: widget.documentData,
                                        ),
                                      ),
                                    );
                                  }
                                },
                              ),
                            ],
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

  Widget _buildImagePicker() {
    return GestureDetector(
      onTap: _showImageSourcePicker,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 180,
        width: double.infinity,
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
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      // ignore: deprecated_member_use
                      color: kAccentBlue.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.camera_alt_rounded,
                      size: 32,
                      color: kAccentBlue,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Tap untuk ambil foto',
                    style: TextStyle(
                      color: kTextMuted,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Kamera atau Galeri',
                    style: TextStyle(color: kBorderColor, fontSize: 12),
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
                        padding: const EdgeInsets.all(6),
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
                  Positioned(
                    bottom: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: _showImageSourcePicker,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          // ignore: deprecated_member_use
                          color: Colors.black.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.edit_rounded,
                              color: Colors.white,
                              size: 14,
                            ),
                            SizedBox(width: 4),
                            Text(
                              'Ganti',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
