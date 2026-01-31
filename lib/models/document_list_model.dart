class DocumentListModel {
  final String id;
  final String senderCompany;
  final String senderName;
  final String receiverCompany;
  final String receiverName;
  final DateTime createdAt;

  DocumentListModel({
    required this.id,
    required this.senderCompany,
    required this.senderName,
    required this.receiverCompany,
    required this.receiverName,
    required this.createdAt,
  });

  factory DocumentListModel.fromJson(Map<String, dynamic> json) {
    return DocumentListModel(
      id: json['_id'],
      senderCompany: json['senderCompany'] ?? '-',
      senderName: json['senderName'] ?? '-',
      receiverCompany: json['receiverCompany'] ?? '-',
      receiverName: json['receiverName'] ?? '-',
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}
