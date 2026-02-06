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
      body: Column(
        children: [
          /// APP BAR
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
              ),
              child: Column(
                children: [
                  /// PROFILE IMAGE
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      const CircleAvatar(
                        radius: 50,
                        backgroundImage: AssetImage(
                          'assets/images/banner2.png',
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: GestureDetector(
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
                              CircleAvatar(
                                radius: 50,
                                backgroundImage: avatarUrl != null
                                    ? NetworkImage(avatarUrl!)
                                    : const AssetImage(
                                            'assets/images/banner2.png',
                                          )
                                          as ImageProvider,
                              ),
                              const CircleAvatar(
                                radius: 16,
                                child: Icon(Icons.camera_alt, size: 16),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 30),

                  _ProfileField(label: 'Username', value: 'Ava Michel'),
                  _ProfileField(label: 'Email', value: 'avamichel@gmail.com'),

                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      // Simpan perubahan profil
                      AuthController().updateProfile(
                        context: context,
                        ref: ref,
                        fullname: nameController.text,
                        avatar: avatarUrl,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      // backgroundColor: const Color(0xFF8B0000),
                      backgroundColor: const Color.fromARGB(255, 51, 121, 242),
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
        ],
      ),
    );
  }
}

class _ProfileField extends StatelessWidget {
  final String label;
  final String value;

  const _ProfileField({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: TextEditingController(text: value),
          decoration: const InputDecoration(border: InputBorder.none),
        ),
        const Divider(height: 1),
        const SizedBox(height: 14),
      ],
    );
  }
}
