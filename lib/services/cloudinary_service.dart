import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class CloudinaryService {
  static const String cloudName = "dc9sx4cot";
  static const String uploadPreset = "u5p17ded";

  /// Upload File (receiver image)
  static Future<String> uploadFile(File file) async {
    final uri = Uri.parse(
      "https://api.cloudinary.com/v1_1/$cloudName/image/upload",
    );

    final request = http.MultipartRequest("POST", uri)
      ..fields['upload_preset'] = uploadPreset
      ..files.add(await http.MultipartFile.fromPath('file', file.path));

    final response = await request.send().timeout(
      Duration(seconds: 20),
      onTimeout: () {
        throw Exception("Upload timed out");
      },
    );

    final body = await response.stream.bytesToString();

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception(
        "Upload image gagal: ${jsonDecode(body)['error']?['message'] ?? body}",
      );
    }

    return jsonDecode(body)['secure_url'];
  }

  /// Upload Signature (Uint8List)
  static Future<String> uploadBytes(Uint8List bytes) async {
    final uri = Uri.parse(
      "https://api.cloudinary.com/v1_1/$cloudName/image/upload",
    );

    final request = http.MultipartRequest("POST", uri)
      ..fields['upload_preset'] = uploadPreset
      ..files.add(
        http.MultipartFile.fromBytes('file', bytes, filename: "signature.png"),
      );

    final response = await request.send();
    final body = await response.stream.bytesToString();

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception(
        "Upload signature gagal: ${jsonDecode(body)['error']?['message'] ?? body}",
      );
    }

    return jsonDecode(body)['secure_url'];
  }

  static Future<String?> pickAndUploadImage() async {
    try {
      final picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);

      if (image == null) return null;

      final file = File(image.path);

      final uri = Uri.parse(
        'https://api.cloudinary.com/v1_1/$cloudName/image/upload',
      );

      final request = http.MultipartRequest('POST', uri)
        ..fields['upload_preset'] = uploadPreset
        ..files.add(await http.MultipartFile.fromPath('file', file.path));

      final response = await request.send();
      final responseData = await response.stream.bytesToString();
      final data = jsonDecode(responseData);

      return data['secure_url'];
    } catch (e) {
      print('Cloudinary upload error: $e');
      return null;
    }
  }
}
