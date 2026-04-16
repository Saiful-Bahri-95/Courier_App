import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:store_app/config/globar_variable.dart';

class UploadService {
  /// 📸 Pick image (gallery / camera) lalu upload ke backend
  static Future<String?> pickAndUploadImage({
    required String token,
    ImageSource source = ImageSource.gallery,
  }) async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: source);

    if (image == null) return null;

    final file = File(image.path);
    return uploadImageFile(file, token);
  }

  /// 🖼️ Upload image FILE (gallery / camera / document)
  static Future<String> uploadImageFile(File file, String token) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/api/upload/image');

    final request = http.MultipartRequest('POST', uri)
      ..headers['Authorization'] = 'Bearer $token'
      ..files.add(await http.MultipartFile.fromPath('file', file.path));

    final response = await request.send();
    final body = await response.stream.bytesToString();

    if (response.statusCode != 200) {
      throw Exception('Upload image failed');
    }

    return jsonDecode(body)['url'];
  }

  /// ✍️ Upload SIGNATURE (Uint8List)
  static Future<String> uploadSignature(Uint8List bytes, String token) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/api/upload/signature');

    final response = await http.post(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'imageBase64': 'data:image/png;base64,${base64Encode(bytes)}',
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Upload signature failed');
    }

    return jsonDecode(response.body)['url'];
  }
}
