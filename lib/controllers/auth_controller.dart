import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:store_app/globar_variable.dart';
import 'package:http/http.dart' as http;
import 'package:store_app/views/screens/authentication_screens/login_screen.dart';
import 'package:store_app/views/screens/main_screen.dart';

import '../services/manage_http_response.dart';

class AuthController {
  Future<void> signUpUser({
    required BuildContext context,
    required String email,
    required String fullname,
    required String password,
  }) async {
    try {
      http.Response response = await http.post(
        Uri.parse('$uri/api/signup'),
        headers: const {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode({
          'fullname': fullname,
          'email': email,
          'password': password,
        }),
      );

      manageHttpResponse(
        response: response,
        // ignore: use_build_context_synchronously
        context: context,
        onSuccess: () {
          showSnackbar(context, 'Account has been created');
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const LoginScreen()),
          );
        },
      );
    } catch (e) {
      // ignore: use_build_context_synchronously
      showSnackbar(context, 'Server error');
    }
  }

  //signin user function
  Future<void> signInUser({
    required context,
    required String email,
    required String password,
  }) async {
    try {
      http.Response response = await http.post(
        Uri.parse('$uri/api/signin'),
        body: jsonEncode({'email': email, 'password': password}),
        headers: <String, String>{
          "Content-Type": 'application/json; charset=UTF-8',
        },
      );

      debugPrint('STATUS CODE: ${response.statusCode}');
      debugPrint('RESPONSE BODY: ${response.body}');

      //handle response using the manage http response
      manageHttpResponse(
        response: response,
        context: context,
        onSuccess: () {
          final data = jsonDecode(response.body);
          final token = data['token'];

          // nanti kita simpan pakai secure storage
          debugPrint('JWT Token: $token');

          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const MainScreen()),
            (route) => false,
          );

          showSnackbar(context, 'Login successful');
        },
      );
    } catch (e) {
      print('Error: $e');
    }
  }
}
