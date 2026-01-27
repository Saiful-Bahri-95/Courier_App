import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:store_app/provider/user_provider.dart';
import 'package:store_app/services/auth_secure_storage.dart';

/// Provider untuk cek login saat app start
final authCheckProvider = FutureProvider<bool>((ref) async {
  final user = await AuthSecureStorage.getUser();

  if (user != null) {
    // set user ke global state
    ref.read(userProvider.notifier).setUser(user);
    return true;
  }

  // tidak ada user → belum login
  ref.read(userProvider.notifier).signOut();
  return false;
});
