import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:store_app/models/document_list_model.dart';
import 'package:store_app/services/document_service.dart';
import 'package:store_app/views/screens/nav_screens/widgets/preview_history.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  late Future<List<DocumentListModel>> _futureDocuments;

  @override
  void initState() {
    super.initState();
    _loadDocuments();
  }

  void _loadDocuments() {
    _futureDocuments = DocumentService.getDocumentList();
  }

  String _formatDate(DateTime date) {
    return DateFormat('EEEE, dd MMM yyyy').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFA79EFF),
      // backgroundColor: Color(0xFFD25353),
      body: Column(
        children: [
          SizedBox(height: 30),
          Padding(
            padding: const EdgeInsets.only(left: 20, top: 20),
            child: Row(
              children: [
                Text(
                  'History',
                  style: TextStyle(
                    fontSize: 25,
                    color: Color(0xFF030F2F),
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.01,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 24),
          Expanded(
            child: Container(
              padding: const EdgeInsets.only(top: 10, left: 5, right: 5),
              decoration: const BoxDecoration(
                color: Color(0xFFE0E0E0),
                borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                boxShadow: [
                  BoxShadow(
                    // ignore: deprecated_member_use
                    color: Colors.black12,
                    blurRadius: 10,
                    offset: Offset(0, -5),
                  ),
                ],
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(
                  bottom: 20,
                  top: 10,
                  left: 10,
                  right: 10,
                ),
                child: FutureBuilder<List<DocumentListModel>>(
                  future: _futureDocuments,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.hasError) {
                      return Center(
                        child: Text(
                          snapshot.error.toString(),
                          style: const TextStyle(color: Colors.red),
                        ),
                      );
                    }

                    final documents = snapshot.data ?? [];

                    if (documents.isEmpty) {
                      return SizedBox(
                        height: MediaQuery.of(context).size.height * 0.6,
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(
                                'assets/images/searchdata.png',
                                width: 300,
                              ),
                              const SizedBox(height: 2),
                              const Text(
                                'Belum ada dokumen',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.black,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    return Column(
                      children: documents.map((doc) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Container(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 2,
                              vertical: 2,
                            ),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  // ignore: deprecated_member_use
                                  color: Colors.black54.withOpacity(0.5),
                                  blurRadius: 8,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: InkWell(
                              onTap: () async {
                                final result = await showModalBottomSheet<bool>(
                                  context: context,
                                  isScrollControlled: true,
                                  backgroundColor: Colors.transparent,
                                  builder: (_) {
                                    return DraggableScrollableSheet(
                                      expand: false,
                                      initialChildSize: 0.65,
                                      minChildSize: 0.5,
                                      maxChildSize: 1,
                                      builder: (context, scrollController) {
                                        return SafeArea(
                                          top: false,
                                          child: Container(
                                            decoration: const BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.vertical(
                                                    top: Radius.circular(24),
                                                  ),
                                            ),
                                            child: BottomSheetPreviewDocument(
                                              documentId: doc.id,
                                              scrollController:
                                                  scrollController,
                                            ),
                                          ),
                                        );
                                      },
                                    );
                                  },
                                );

                                /// 🔥 JIKA ADA DELETE → REFRESH
                                if (result == true) {
                                  setState(() {
                                    _loadDocuments();
                                  });
                                }
                              },

                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  /// Status & Date
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          color: const Color.fromARGB(
                                            255,
                                            8,
                                            255,
                                            210,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            5,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              // ignore: deprecated_member_use
                                              color: Colors.black54.withOpacity(
                                                0.3,
                                              ),
                                              blurRadius: 3,
                                              offset: const Offset(0, 5),
                                            ),
                                          ],
                                        ),
                                        child: const Text(
                                          "Completed",
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        _formatDate(doc.createdAt),
                                        style: TextStyle(
                                          color: Colors.grey.shade600,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 2),
                                  Divider(
                                    thickness: 2,
                                    color: Colors.grey.shade300,
                                  ),
                                  const SizedBox(height: 5),

                                  /// FROM
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      /// ICON PLACEHOLDER
                                      Container(
                                        width: 36,
                                        height: 36,
                                        decoration: BoxDecoration(
                                          color: Colors.blue.shade100,
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: Image.asset(
                                          'assets/icons/up.png',
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            doc.senderCompany,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          const SizedBox(height: 1),
                                          Text(
                                            "From ${doc.senderName}",
                                            style: TextStyle(
                                              color: Colors.grey.shade600,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 12),

                                  /// TO
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      /// ICON PLACEHOLDER
                                      Container(
                                        width: 36,
                                        height: 36,
                                        decoration: BoxDecoration(
                                          color: Colors.orange.shade100,
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: Image.asset(
                                          'assets/icons/location.png',
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            doc.receiverCompany,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          const SizedBox(height: 1),
                                          Text(
                                            "To ${doc.receiverName}",
                                            style: TextStyle(
                                              color: Colors.grey.shade600,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
