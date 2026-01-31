import 'package:store_app/models/document_data.dart';

class DocumentDetailModel {
  final String senderCompany;
  final String senderName;
  final String senderPhone;
  final String documentType;
  final String description;

  final String receiverCompany;
  final String receiverName;
  final String receiverPhone;
  final String receiverImageUrl;

  final DateTime receivedDate;
  final String signedName;
  final String signatureUrl;

  DocumentDetailModel({
    required this.senderCompany,
    required this.senderName,
    required this.senderPhone,
    required this.documentType,
    required this.description,
    required this.receiverCompany,
    required this.receiverName,
    required this.receiverPhone,
    required this.receiverImageUrl,
    required this.receivedDate,
    required this.signedName,
    required this.signatureUrl,
  });

  factory DocumentDetailModel.fromJson(Map<String, dynamic> json) {
    return DocumentDetailModel(
      senderCompany: json['senderCompany'] ?? '',
      senderName: json['senderName'] ?? '',
      senderPhone: json['senderPhone'] ?? '',
      documentType: json['documentType'] ?? '',
      description: json['description'] ?? '',
      receiverCompany: json['receiverCompany'] ?? '',
      receiverName: json['receiverName'] ?? '',
      receiverPhone: json['receiverPhone'] ?? '',
      receiverImageUrl: json['receiverImageUrl'] ?? '',
      receivedDate: DateTime.parse(json['receivedDate']),
      signedName: json['signedName'] ?? '',
      signatureUrl: json['signatureUrl'] ?? '',
    );
  }
}

extension DocumentDetailMapper on DocumentDetailModel {
  DocumentData toDocumentData() {
    return DocumentData()
      ..senderCompany = senderCompany
      ..senderName = senderName
      ..senderPhone = senderPhone
      ..documentType = documentType
      ..description = description
      ..receiverCompany = receiverCompany
      ..receiverName = receiverName
      ..receiverPhone = receiverPhone
      ..receivedDate = receivedDate
      ..signedName = signedName;
    // ⚠️ receiverImage & signature TIDAK diisi File
  }
}
