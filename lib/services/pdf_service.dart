import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';
import 'package:store_app/models/document_data.dart';
import 'package:store_app/services/manage_http_response.dart';

// ========================
// COLOR PALETTE
// ========================
const _primaryColor = PdfColor.fromInt(0xFF1A3C8F);
const _accentColor = PdfColor.fromInt(0xFF2563EB);
const _lightBg = PdfColor.fromInt(0xFFF1F5F9);
const _borderColor = PdfColor.fromInt(0xFFCBD5E1);
const _textDark = PdfColor.fromInt(0xFF020407);
const _textMuted = PdfColor.fromInt(0xFF64748B);

class PdfService {
  static Future<void> generateAndShare(
    BuildContext context,
    DocumentData data,
    String userName,
  ) async {
    try {
      // Load fonts
      final fontData = await rootBundle.load(
        'assets/fonts/NotoSans-Regular.ttf',
      );
      final boldFontData = await rootBundle.load(
        'assets/fonts/NotoSans-Bold.ttf',
      );
      final ttf = pw.Font.ttf(fontData);
      final ttfBold = pw.Font.ttf(boldFontData);

      pw.TextStyle base({double size = 10, PdfColor color = _textDark}) =>
          pw.TextStyle(font: ttf, fontSize: size, color: color);

      pw.TextStyle bold({double size = 10, PdfColor color = _textDark}) =>
          pw.TextStyle(font: ttfBold, fontSize: size, color: color);

      final pdf = pw.Document();

      // Load signature
      pw.MemoryImage? signatureImage;
      if (data.signatureUrl != null && data.signatureUrl!.isNotEmpty) {
        try {
          final res = await http.get(Uri.parse(data.signatureUrl!));
          if (res.statusCode == 200) {
            signatureImage = pw.MemoryImage(res.bodyBytes);
          }
        } catch (_) {}
      }

      final docTypes = ['Document', 'Invoice', 'BG/Cheque', 'Cash', 'Others'];
      final selectedType = data.documentType ?? '';
      final formattedDate = data.receivedDate != null
          ? DateFormat('dd MMMM yyyy').format(data.receivedDate!)
          : '-';
      final formattedDateTime = data.receivedDate != null
          ? DateFormat('dd MMMM yyyy, HH:mm').format(data.receivedDate!)
          : '-';

      // Fixed height untuk kedua card tanda tangan
      const signCardHeight = 160.0;

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(32),
          build: (pw.Context ctx) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // ===== HEADER =====
                pw.Container(
                  padding: const pw.EdgeInsets.all(16),
                  decoration: pw.BoxDecoration(
                    color: _primaryColor,
                    borderRadius: pw.BorderRadius.circular(8),
                  ),
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: pw.CrossAxisAlignment.center,
                    children: [
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            'PT KGI SEKURITAS INDONESIA',
                            style: bold(size: 14, color: PdfColors.white),
                          ),
                          pw.SizedBox(height: 3),
                          pw.Text(
                            'Sona Topas Tower Lt. 11, Jl. Jend. Sudirman Kav. 26',
                            style: base(size: 8, color: PdfColors.white),
                          ),
                          pw.Text(
                            'Jakarta 12920  |  (021) 250 5337 - 250 5338',
                            style: base(size: 8, color: PdfColors.white),
                          ),
                        ],
                      ),
                      pw.Container(
                        padding: const pw.EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        decoration: pw.BoxDecoration(
                          color: PdfColors.white,
                          borderRadius: pw.BorderRadius.circular(4),
                        ),
                        child: pw.Text(
                          'TANDA TERIMA / RECEIPT',
                          style: bold(size: 11, color: _primaryColor),
                        ),
                      ),
                    ],
                  ),
                ),

                pw.SizedBox(height: 16),

                // ===== SECTION: PENGIRIM & PENERIMA =====
                pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Expanded(
                      child: _infoCard(
                        title: 'Pengirim / From',
                        color: _primaryColor,
                        ttf: ttf,
                        ttfBold: ttfBold,
                        rows: [
                          _InfoRow('Nama', data.senderName ?? '-'),
                          _InfoRow('Telepon', data.senderPhone ?? '-'),
                          _InfoRow('Tanggal', formattedDateTime),
                        ],
                      ),
                    ),
                    pw.SizedBox(width: 12),
                    pw.Expanded(
                      child: _infoCard(
                        title: 'Penerima / To',
                        color: _accentColor,
                        ttf: ttf,
                        ttfBold: ttfBold,
                        rows: [
                          _InfoRow('Perusahaan', data.receiverCompany ?? '-'),
                          _InfoRow('Nama', data.receiverName ?? '-'),
                          _InfoRow('Telepon', data.receiverPhone ?? '-'),
                        ],
                      ),
                    ),
                  ],
                ),

                pw.SizedBox(height: 12),

                // ===== SECTION: DOKUMEN =====
                pw.Container(
                  padding: const pw.EdgeInsets.all(12),
                  decoration: pw.BoxDecoration(
                    color: _lightBg,
                    borderRadius: pw.BorderRadius.circular(8),
                    border: pw.Border.all(color: _borderColor, width: 0.5),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'Jenis Dokumen',
                        style: bold(size: 9, color: _textMuted),
                      ),
                      pw.SizedBox(height: 8),
                      pw.Row(
                        children: docTypes.map((type) {
                          final isChecked = selectedType == type;
                          return pw.Padding(
                            padding: const pw.EdgeInsets.only(right: 16),
                            child: pw.Row(
                              children: [
                                pw.Container(
                                  width: 13,
                                  height: 13,
                                  decoration: pw.BoxDecoration(
                                    borderRadius: pw.BorderRadius.circular(3),
                                    border: pw.Border.all(
                                      color: isChecked
                                          ? _accentColor
                                          : _borderColor,
                                      width: 1.5,
                                    ),
                                    color: isChecked
                                        ? _accentColor
                                        : PdfColors.white,
                                  ),
                                  child: isChecked
                                      ? pw.Center(
                                          child: pw.Text(
                                            'v',
                                            style: bold(
                                              size: 8,
                                              color: PdfColors.white,
                                            ),
                                          ),
                                        )
                                      : pw.SizedBox(),
                                ),
                                pw.SizedBox(width: 5),
                                pw.Text(
                                  type,
                                  style: base(
                                    size: 9,
                                    color: isChecked
                                        ? _accentColor
                                        : _textMuted,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                      pw.SizedBox(height: 10),
                      pw.Divider(thickness: 0.5, color: _borderColor),
                      pw.SizedBox(height: 8),
                      pw.Row(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            'Perihal / Desc.',
                            style: bold(size: 9, color: _textMuted),
                          ),
                          pw.SizedBox(width: 8),
                          pw.Text(': ', style: base(size: 9)),
                          pw.Expanded(
                            child: pw.Text(
                              data.description ?? '-',
                              style: base(size: 9),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                pw.SizedBox(height: 12),

                // ===== SECTION: TANDA TANGAN =====
                pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    // ✅ Yang Memberi (KIRI)
                    pw.Expanded(
                      child: pw.Container(
                        height: signCardHeight,
                        padding: const pw.EdgeInsets.all(12),
                        decoration: pw.BoxDecoration(
                          border: pw.Border.all(
                            color: _borderColor,
                            width: 0.5,
                          ),
                          borderRadius: pw.BorderRadius.circular(8),
                        ),
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            // Badge label
                            pw.Container(
                              padding: const pw.EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: pw.BoxDecoration(
                                color: _primaryColor,
                                borderRadius: pw.BorderRadius.circular(4),
                              ),
                              child: pw.Text(
                                'Yang Memberi / Sent by',
                                style: bold(size: 8, color: PdfColors.white),
                              ),
                            ),
                            pw.SizedBox(height: 10),
                            _signField('Nama', userName, ttf, ttfBold),
                            _signField('Tanggal', formattedDate, ttf, ttfBold),
                            pw.Spacer(),
                            // Garis & nama
                            pw.Divider(thickness: 0.5, color: _borderColor),
                            pw.SizedBox(height: 4),
                            pw.Center(
                              child: pw.Text(
                                userName,
                                style: base(size: 8, color: _textMuted),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    pw.SizedBox(width: 12),

                    // ✅ Yang Menerima (KANAN)
                    pw.Expanded(
                      child: pw.Container(
                        height: signCardHeight,
                        padding: const pw.EdgeInsets.all(12),
                        decoration: pw.BoxDecoration(
                          border: pw.Border.all(
                            color: _borderColor,
                            width: 0.5,
                          ),
                          borderRadius: pw.BorderRadius.circular(8),
                        ),
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            // Badge label
                            pw.Container(
                              padding: const pw.EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: pw.BoxDecoration(
                                color: _accentColor,
                                borderRadius: pw.BorderRadius.circular(4),
                              ),
                              child: pw.Text(
                                'Yang Menerima / Received by',
                                style: bold(size: 8, color: PdfColors.white),
                              ),
                            ),
                            pw.SizedBox(height: 10),
                            _signField(
                              'Nama',
                              data.signedName ?? '-',
                              ttf,
                              ttfBold,
                            ),
                            _signField('Tanggal', formattedDate, ttf, ttfBold),
                            pw.Spacer(),
                            // Signature image atau ruang kosong
                            if (signatureImage != null)
                              pw.Center(
                                child: pw.Image(
                                  signatureImage,
                                  width: 90,
                                  height: 40,
                                  fit: pw.BoxFit.contain,
                                ),
                              ),
                            // Garis & nama
                            pw.Divider(thickness: 0.5, color: _borderColor),
                            pw.SizedBox(height: 4),
                            pw.Center(
                              child: pw.Text(
                                data.signedName ?? '-',
                                style: base(size: 8, color: _textMuted),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                pw.Spacer(),

                // ===== FOOTER =====
                pw.Container(
                  padding: const pw.EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: pw.BoxDecoration(
                    color: _lightBg,
                    borderRadius: pw.BorderRadius.circular(6),
                  ),
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text(
                        'PT KGI SEKURITAS INDONESIA  |  www.kgi.id',
                        style: base(size: 7, color: _textDark),
                      ),
                      pw.Text(
                        'Generated: ${DateFormat('dd MMM yyyy - HH:mm').format(DateTime.now())}',
                        style: base(size: 7, color: _textMuted),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      );

      // Simpan & share
      final output = await getTemporaryDirectory();
      final file = File(
        '${output.path}/KGI-${DateTime.now().millisecondsSinceEpoch}.pdf',
      );
      await file.writeAsBytes(await pdf.save());

      await Share.shareXFiles(
        [XFile(file.path, mimeType: 'application/pdf')],
        text:
            'Tanda Terima - ${data.senderCompany ?? ''} ke ${data.receiverCompany ?? ''}',
      );
    } catch (e) {
      debugPrint('❌ PDF ERROR: $e');
      // ignore: use_build_context_synchronously
      showSnackbar(context, 'Gagal membuat PDF: $e');
    }
  }

  // ========================
  // INFO CARD WIDGET
  // ========================
  static pw.Widget _infoCard({
    required String title,
    required PdfColor color,
    required pw.Font ttf,
    required pw.Font ttfBold,
    required List<_InfoRow> rows,
  }) {
    return pw.Container(
      decoration: pw.BoxDecoration(
        borderRadius: pw.BorderRadius.circular(8),
        border: pw.Border.all(color: _borderColor, width: 0.5),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Container(
            width: double.infinity,
            padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: pw.BoxDecoration(
              color: color,
              borderRadius: const pw.BorderRadius.only(
                topLeft: pw.Radius.circular(8),
                topRight: pw.Radius.circular(8),
              ),
            ),
            child: pw.Text(
              title,
              style: pw.TextStyle(
                font: ttfBold,
                fontSize: 9,
                color: PdfColors.white,
              ),
            ),
          ),
          pw.Padding(
            padding: const pw.EdgeInsets.all(10),
            child: pw.Column(
              children: rows.map((row) {
                return pw.Padding(
                  padding: const pw.EdgeInsets.only(bottom: 5),
                  child: pw.Row(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.SizedBox(
                        width: 65,
                        child: pw.Text(
                          row.label,
                          style: pw.TextStyle(
                            font: ttf,
                            fontSize: 9,
                            color: _textMuted,
                          ),
                        ),
                      ),
                      pw.Text(
                        ': ',
                        style: pw.TextStyle(font: ttf, fontSize: 9),
                      ),
                      pw.Expanded(
                        child: pw.Text(
                          row.value,
                          style: pw.TextStyle(
                            font: ttfBold,
                            fontSize: 9,
                            color: _textDark,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  // ========================
  // SIGN FIELD WIDGET
  // ========================
  static pw.Widget _signField(
    String label,
    String value,
    pw.Font ttf,
    pw.Font ttfBold,
  ) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 5),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: 55,
            child: pw.Text(
              label,
              style: pw.TextStyle(font: ttf, fontSize: 9, color: _textMuted),
            ),
          ),
          pw.Text(': ', style: pw.TextStyle(font: ttf, fontSize: 9)),
          pw.Expanded(
            child: pw.Text(
              value,
              style: pw.TextStyle(font: ttfBold, fontSize: 9, color: _textDark),
            ),
          ),
        ],
      ),
    );
  }
}

// ========================
// DATA CLASS HELPER
// ========================
class _InfoRow {
  final String label;
  final String value;
  const _InfoRow(this.label, this.value);
}
