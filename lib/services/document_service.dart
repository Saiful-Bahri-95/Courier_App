import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:store_app/config/globar_variable.dart';
import 'package:store_app/models/document_detail_model.dart';
import 'package:store_app/models/document_list_model.dart';
import 'package:store_app/services/auth_secure_storage.dart';
import '../models/document_data.dart';

class DocumentService {
  static Future<void> submit(
    DocumentData data,
    String? receiverImageUrl,
    String? signatureUrl,
  ) async {
    final body = {
      "senderCompany": data.senderCompany,
      "senderName": data.senderName,
      "senderPhone": data.senderPhone,
      "documentType": data.documentType,
      "description": data.description,
      "receiverCompany": data.receiverCompany,
      "receiverName": data.receiverName,
      "receiverPhone": data.receiverPhone,
      "receivedDate": data.receivedDate?.toIso8601String(),
      "signedName": data.signedName,
      "receiverImageUrl": receiverImageUrl,
      "signatureUrl": signatureUrl,
    };

    final token = await AuthSecureStorage.getToken();

    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/documents'),
      headers: {
        "Content-Type": "application/json;  charset=UTF-8",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode(body),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception("Gagal menyimpan dokumen");
    }
  }

  static Future<List<DocumentListModel>> getDocumentList() async {
    final token = await AuthSecureStorage.getToken();

    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/documents'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode != 200) {
      throw Exception('Gagal mengambil list dokumen');
    }

    final body = jsonDecode(response.body);
    final List data = body['data'];

    return data.map((e) => DocumentListModel.fromJson(e)).toList();
  }

  static Future<DocumentDetailModel> getDocumentDetail(
    String documentId,
  ) async {
    final token = await AuthSecureStorage.getToken();

    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/documents/$documentId'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode != 200) {
      throw Exception('Gagal mengambil detail dokumen');
    }

    final body = jsonDecode(response.body);
    return DocumentDetailModel.fromJson(body['data']);
  }

  static Future<void> deleteDocument(String documentId) async {
    final token = await AuthSecureStorage.getToken();

    final response = await http.delete(
      Uri.parse('${ApiConfig.baseUrl}/documents/$documentId'),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json; charset=UTF-8",
      },
    );

    // ✅ SUCCESS CASE
    if (response.statusCode == 200 || response.statusCode == 204) {
      return;
    }

    // ❌ ERROR CASE
    String message = 'Gagal menghapus dokumen';

    if (response.body.isNotEmpty) {
      try {
        final body = jsonDecode(response.body);
        message = body['message'] ?? message;
      } catch (_) {
        // body bukan JSON → abaikan
      }
    }

    throw Exception(message);
  }
}
