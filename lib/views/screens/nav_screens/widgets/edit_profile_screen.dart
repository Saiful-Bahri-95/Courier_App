import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:store_app/controllers/auth_controller.dart';
import 'package:store_app/provider/user_provider.dart';
import 'package:store_app/services/cloudinary_service.dart';
import 'package:store_app/views/screens/utils.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  late TextEditingController nameController;
  late TextEditingController emailController;
  String? avatarUrl;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final user = ref.read(userProvider)!;
    nameController = TextEditingController(text: user.fullname);
    emailController = TextEditingController(text: user.email);
    avatarUrl = user.avatar;
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    super.dispose();
  }

  Future<void> _pickAvatar() async {
    final imageUrl = await UploadService.pickAndUploadImage(
      token: ref.read(userProvider)!.token,
    );
    if (imageUrl != null) {
      setState(() => avatarUrl = imageUrl);
    }
  }

  Future<void> _saveChanges() async {
    setState(() => _isLoading = true);
    await AuthController().updateProfile(
      context: context,
      ref: ref,
      fullname: nameController.text.trim(),
      avatar: avatarUrl,
    );
    if (mounted) setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: kNavyBlue,
      body: Column(
        children: [
          // ===== HEADER =====
          Padding(
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
                      // ignore: deprecated_member_use
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
                      'Edit Profile',
                      style: TextStyle(
                        fontSize: 22,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.3,
                      ),
                    ),
                    Text(
                      'Perbarui informasi akun Anda',
                      style: TextStyle(
                        fontSize: 13,
                        // ignore: deprecated_member_use
                        color: Colors.white.withOpacity(0.65),
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
                    // Avatar
                    Center(child: _buildAvatarPicker()),
                    const SizedBox(height: 32),

                    // Section: Informasi Profil
                    _sectionLabel('Informasi Profil'),
                    const SizedBox(height: 12),
                    _buildFormCard(
                      children: [
                        _buildField(
                          label: 'Nama Lengkap',
                          icon: Icons.person_rounded,
                          controller: nameController,
                        ),
                        _buildField(
                          label: 'Email',
                          icon: Icons.email_rounded,
                          controller: emailController,
                          readOnly: true,
                          hint: 'Email tidak dapat diubah',
                        ),
                      ],
                    ),

                    const SizedBox(height: 32),

                    // Save button
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _saveChanges,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kAccentBlue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 0,
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.check_rounded,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    'Simpan Perubahan',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
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
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarPicker() {
    return GestureDetector(
      onTap: _pickAvatar,
      child: Stack(
        alignment: Alignment.bottomRight,
        children: [
          // Avatar
          Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              // ignore: deprecated_member_use
              color: kAccentBlue.withOpacity(0.2),
              border: Border.all(color: kAccentBlue, width: 2),
            ),
            child: CircleAvatar(
              radius: 52,
              backgroundColor: kLightBg,
              backgroundImage: (avatarUrl != null && avatarUrl!.isNotEmpty)
                  ? NetworkImage(avatarUrl!) as ImageProvider
                  : const AssetImage('assets/images/banner2.png'),
            ),
          ),
          // Camera badge
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: kAccentBlue,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: const Icon(
              Icons.camera_alt_rounded,
              color: Colors.white,
              size: 16,
            ),
          ),
        ],
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

  Widget _buildFormCard({required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: List.generate(children.length, (index) {
          return Column(
            children: [
              children[index],
              if (index < children.length - 1)
                const Divider(height: 1, indent: 56, endIndent: 16),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildField({
    required String label,
    required IconData icon,
    required TextEditingController controller,
    bool readOnly = false,
    String? hint,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              // ignore: deprecated_member_use
              color: readOnly
                  // ignore: deprecated_member_use
                  ? kTextMuted.withOpacity(0.1)
                  // ignore: deprecated_member_use
                  : kAccentBlue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              size: 18,
              color: readOnly ? kTextMuted : kAccentBlue,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: controller,
              readOnly: readOnly,
              style: TextStyle(
                fontSize: 14,
                color: readOnly ? kTextMuted : kTextDark,
                fontWeight: FontWeight.w500,
              ),
              decoration: InputDecoration(
                labelText: label,
                labelStyle: const TextStyle(fontSize: 12, color: kTextMuted),
                hintText: hint,
                hintStyle: const TextStyle(fontSize: 12, color: kBorderColor),
                border: InputBorder.none,
                suffixIcon: readOnly
                    ? const Icon(
                        Icons.lock_outline_rounded,
                        size: 15,
                        color: kBorderColor,
                      )
                    : null,
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
