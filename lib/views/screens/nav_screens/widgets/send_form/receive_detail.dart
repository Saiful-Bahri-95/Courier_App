import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:store_app/models/document_data.dart';
import 'package:store_app/views/screens/nav_screens/widgets/send_form/sender_detail.dart';
import 'package:store_app/views/screens/nav_screens/widgets/send_form/sign_detail.dart';

class ReceiverDetailScreen extends StatefulWidget {
  final DocumentData documentData;
  const ReceiverDetailScreen({super.key, required this.documentData});

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
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
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
      backgroundColor: kNavyBlue,
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: Container(
              width: double.infinity,
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
                      _stepIndicator(current: 2, total: 3),
                      const SizedBox(height: 20),
                      _sectionLabel('Informasi Penerima'),
                      const SizedBox(height: 12),
                      _buildField(
                        label: 'Alamat / Nama Perusahaan',
                        icon: Icons.business_rounded,
                        controller: companyCtrl,
                      ),
                      _buildField(
                        label: 'Nama Penerima / UP',
                        icon: Icons.person_rounded,
                        controller: receiverCtrl,
                      ),
                      _buildField(
                        label: 'Nomor Telepon',
                        icon: Icons.phone_rounded,
                        controller: phoneCtrl,
                        keyboardType: TextInputType.phone,
                      ),
                      const SizedBox(height: 8),
                      _sectionLabel('Bukti Penerimaan'),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Text(
                            'Foto penerima (opsional)',
                            style: TextStyle(fontSize: 12, color: kTextMuted),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      _buildImagePicker(),
                      const SizedBox(height: 28),
                      _buildBottomButtons(),
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
                'Send Document',
                style: TextStyle(
                  fontSize: 22,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Detail Penerima',
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

  Widget _stepIndicator({required int current, required int total}) {
    return Row(
      children: List.generate(total, (index) {
        final isActive = index + 1 == current;
        final isDone = index + 1 < current;
        return Expanded(
          child: Row(
            children: [
              Expanded(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  height: 4,
                  decoration: BoxDecoration(
                    color: isActive || isDone ? kAccentBlue : kBorderColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              if (index < total - 1) const SizedBox(width: 6),
            ],
          ),
        );
      }),
    );
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

  Widget _buildField({
    required String label,
    required IconData icon,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
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

  Widget _buildBottomButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(0, 52),
              side: const BorderSide(color: kBorderColor),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: const Text(
              'Kembali',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: kTextDark,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                widget.documentData
                  ..receiverCompany = companyCtrl.text.trim()
                  ..receiverName = receiverCtrl.text.trim()
                  ..receiverPhone = phoneCtrl.text.trim()
                  ..receiverImage = receiverImage;

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        SignDetail(documentData: widget.documentData),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(0, 52),
              backgroundColor: kAccentBlue,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              elevation: 0,
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Selanjutnya',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(width: 6),
                Icon(
                  Icons.arrow_forward_rounded,
                  color: Colors.white,
                  size: 18,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
