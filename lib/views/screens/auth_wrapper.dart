import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:store_app/provider/auth_check_provider.dart';
import 'package:store_app/views/screens/authentication_screens/login_screen.dart';
import 'package:store_app/views/screens/main_screen.dart';

class AuthWrapper extends ConsumerWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authCheck = ref.watch(authCheckProvider);

    return authCheck.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (_, __) => const LoginScreen(),
      data: (isLoggedIn) {
        return isLoggedIn ? const MainScreen() : const LoginScreen();
      },
    );
  }
}
