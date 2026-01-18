import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void manageHttpResponse({
  required http.Response response, //Http response from the request
  required BuildContext context, //the contex is to show snackbar
  required VoidCallback onSuccess, //callback to execute on a successfull
}) {
  //switch statement to handle different http status
  switch (response.statusCode) {
    case 200: //status ok
      onSuccess();
      break;
    case 400: //bad request
      showSnackbar(context, json.decode(response.body)['message']);
      break;
    case 500: //internal server error
      showSnackbar(context, json.decode(response.body)['error']);
      break;
    case 201: // create successfully
      onSuccess();
      break;
  }
}

void showSnackbar(BuildContext context, String title) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        title,
        style: TextStyle(color: const Color.fromARGB(255, 14, 76, 114)),
        textAlign: TextAlign.center,
      ),
      backgroundColor: Colors.white,
    ),
  );
}
