import 'package:flutter_riverpod/legacy.dart';
import 'package:store_app/models/user.dart';

// Provider untuk mengelola state data user
class UserProvider extends StateNotifier<User?> {
  // Constructor dengan nilai awal user (default / kosong)
  UserProvider() : super(User(id: '', fullname: '', email: '', token: ''));

  // Getter untuk mengambil data user dari state
  User? get user => state;

  // Method untuk mengubah state user dari data JSON
  // Tujuan: memperbarui data user berdasarkan representasi JSON
  // void setUser(String userJson) {
  //   state = User.fromJson(userJson);
  // }

  /// Set user dari object User
  void setUser(User user) {
    state = user;
  }

  //method untuk menghapus data user (logout)
  void signOut() {
    state = null;
  }
}

// Membuat provider agar data user dapat diakses di seluruh aplikasi
final userProvider = StateNotifierProvider<UserProvider, User?>(
  (ref) => UserProvider(),
);
