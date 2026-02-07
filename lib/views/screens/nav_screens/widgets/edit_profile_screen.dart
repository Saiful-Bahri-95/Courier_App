import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:store_app/controllers/auth_controller.dart';
import 'package:store_app/provider/user_provider.dart';
import 'package:store_app/services/cloudinary_service.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  late TextEditingController nameController;
  String? avatarUrl;

  @override
  void initState() {
    super.initState();
    final user = ref.read(userProvider)!;
    nameController = TextEditingController(text: user.fullname);
    avatarUrl = user.avatar;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: const Color(0xFF8B0000),
      backgroundColor: const Color(0xFFA79EFF),
      resizeToAvoidBottomInset: true,
      body: Column(
        children: [
          /// APP BAR
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 20),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.arrow_back,
                      color: Color.fromARGB(255, 0, 0, 0),
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Text(
                    'Edit profile',
                    style: GoogleFonts.getFont(
                      'Poppins',
                      fontSize: 20,
                      color: const Color.fromARGB(255, 0, 0, 0),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),

          /// CONTENT
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom,
                  ),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: IntrinsicHeight(
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(32),
                          ),
                        ),
                        child: Column(
                          children: [
                            /// PROFILE IMAGE
                            GestureDetector(
                              onTap: () async {
                                final imageUrl =
                                    await CloudinaryService.pickAndUploadImage();
                                if (imageUrl != null) {
                                  setState(() => avatarUrl = imageUrl);
                                }
                              },
                              child: Stack(
                                alignment: Alignment.bottomRight,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(
                                      2,
                                    ), // ketebalan border
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.teal, // warna border
                                    ),
                                    child: CircleAvatar(
                                      radius: 50,
                                      backgroundImage:
                                          (avatarUrl != null &&
                                              avatarUrl!.isNotEmpty)
                                          ? NetworkImage(avatarUrl!)
                                          : const AssetImage(
                                                  'assets/images/banner2.png',
                                                )
                                                as ImageProvider,
                                    ),
                                  ),
                                  const CircleAvatar(
                                    radius: 16,
                                    child: Icon(Icons.camera_alt, size: 16),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 30),

                            _ProfileField(
                              label: 'Username',
                              controller: nameController,
                            ),
                            _ProfileField(
                              label: 'Email',
                              controller: TextEditingController(
                                text: ref.read(userProvider)!.email,
                              ),
                              readOnly: true,
                            ),

                            const SizedBox(height: 20),

                            const Spacer(), // 🔥 dorong tombol ke bawah

                            ElevatedButton(
                              onPressed: () async {
                                await AuthController().updateProfile(
                                  context: context,
                                  ref: ref,
                                  fullname: nameController.text.trim(),
                                  avatar: avatarUrl,
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color.fromARGB(
                                  255,
                                  51,
                                  121,
                                  242,
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 80,
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                              child: Text(
                                'Save Changes',
                                style: GoogleFonts.getFont(
                                  'Poppins',
                                  fontSize: 16,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final bool readOnly;

  const _ProfileField({
    required this.label,
    required this.controller,
    this.readOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 12)),
        TextField(
          controller: controller,
          readOnly: readOnly,
          decoration: const InputDecoration(border: InputBorder.none),
        ),
        const Divider(),
        const SizedBox(height: 14),
      ],
    );
  }
}
