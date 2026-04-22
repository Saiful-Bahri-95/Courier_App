import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

// ========================
// MODEL DRAFT
// ========================
class DraftDocument {
  final String id;
  final String senderCompany;
  final String senderName;
  final String senderPhone;
  final String receiverCompany;
  final String receiverName;
  final String receiverPhone;
  final String? documentType;
  final String? description;
  final DateTime createdAt;

  DraftDocument({
    required this.id,
    required this.senderCompany,
    required this.senderName,
    required this.senderPhone,
    required this.receiverCompany,
    required this.receiverName,
    required this.receiverPhone,
    this.documentType,
    this.description,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'senderCompany': senderCompany,
    'senderName': senderName,
    'senderPhone': senderPhone,
    'receiverCompany': receiverCompany,
    'receiverName': receiverName,
    'receiverPhone': receiverPhone,
    'documentType': documentType,
    'description': description,
    'createdAt': createdAt.toIso8601String(),
  };

  factory DraftDocument.fromJson(Map<String, dynamic> json) => DraftDocument(
    id: json['id'],
    senderCompany: json['senderCompany'] ?? '',
    senderName: json['senderName'] ?? '',
    senderPhone: json['senderPhone'] ?? '',
    receiverCompany: json['receiverCompany'] ?? '',
    receiverName: json['receiverName'] ?? '',
    receiverPhone: json['receiverPhone'] ?? '',
    documentType: json['documentType'],
    description: json['description'],
    createdAt: DateTime.parse(json['createdAt']),
  );
}

// ========================
// SERVICE
// ========================
class DraftService {
  static const _key = 'draft_documents';

  // Ambil semua draft
  static Future<List<DraftDocument>> getAll() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return [];
    final List list = jsonDecode(raw);
    return list.map((e) => DraftDocument.fromJson(e)).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  // Simpan draft baru
  static Future<void> save(DraftDocument draft) async {
    final prefs = await SharedPreferences.getInstance();
    final drafts = await getAll();
    drafts.add(draft);
    await prefs.setString(
      _key,
      jsonEncode(drafts.map((d) => d.toJson()).toList()),
    );
  }

  // Hapus draft berdasarkan id
  static Future<void> delete(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final drafts = await getAll();
    drafts.removeWhere((d) => d.id == id);
    await prefs.setString(
      _key,
      jsonEncode(drafts.map((d) => d.toJson()).toList()),
    );
  }

  // Hitung jumlah draft
  static Future<int> count() async {
    final drafts = await getAll();
    return drafts.length;
  }
}
