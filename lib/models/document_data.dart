import 'dart:io';

class DocumentData {
  // Sender
  String? senderCompany;
  String? senderName;
  String? senderPhone;
  String? documentType;
  String? description;

  // Receiver
  String? receiverCompany;
  String? receiverName;
  String? receiverPhone;
  File? receiverImage;

  // Sign
  DateTime? receivedDate;
  String? signedName;
  dynamic signature; // Uint8List nanti

  String? receiverImageUrl;
  String? signatureUrl;

  DocumentData();
}
