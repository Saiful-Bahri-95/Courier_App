import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';
import 'package:store_app/models/document_list_model.dart';
import 'package:store_app/services/manage_http_response.dart';

const _primaryColor = PdfColor.fromInt(0xFF1A3C8F);
const _accentColor = PdfColor.fromInt(0xFF2563EB);
const _lightBg = PdfColor.fromInt(0xFFF1F5F9);
const _borderColor = PdfColor.fromInt(0xFFCBD5E1);
const _textDark = PdfColor.fromInt(0xFF1E293B);
const _textMuted = PdfColor.fromInt(0xFF64748B);
const _greenColor = PdfColor.fromInt(0xFF16A34A);
const _purpleColor = PdfColor.fromInt(0xFF7C3AED);

class ReportPdfService {
  static Future<void> generateAndShare({
    required BuildContext context,
    required List<DocumentListModel> documents,
    required DateTime startDate,
    required DateTime endDate,
    required String generatedBy,
  }) async {
    try {
      final fontData = await rootBundle.load(
        'assets/fonts/NotoSans-Regular.ttf',
      );
      final boldFontData = await rootBundle.load(
        'assets/fonts/NotoSans-Bold.ttf',
      );
      final ttf = pw.Font.ttf(fontData);
      final ttfBold = pw.Font.ttf(boldFontData);

      pw.TextStyle base({double size = 9, PdfColor color = _textDark}) =>
          pw.TextStyle(font: ttf, fontSize: size, color: color);
      pw.TextStyle bold({double size = 9, PdfColor color = _textDark}) =>
          pw.TextStyle(font: ttfBold, fontSize: size, color: color);

      final total = documents.length;

      // Per hari untuk grafik
      final Map<String, int> byDay = {};
      for (final doc in documents) {
        final day = DateFormat('dd/MM').format(doc.createdAt);
        byDay[day] = (byDay[day] ?? 0) + 1;
      }
      final sortedDays = byDay.entries.toList()
        ..sort((a, b) {
          final dA = DateFormat('dd/MM').parse(a.key);
          final dB = DateFormat('dd/MM').parse(b.key);
          return dA.compareTo(dB);
        });
      final maxPerDay = byDay.values.isEmpty
          ? 1
          : byDay.values.reduce((a, b) => a > b ? a : b);

      // Top pengirim
      final Map<String, int> bySender = {};
      for (final doc in documents) {
        bySender[doc.senderCompany] = (bySender[doc.senderCompany] ?? 0) + 1;
      }
      final topSenders = bySender.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));

      final pdf = pw.Document();

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(32),
          build: (ctx) => [
            // HEADER
            pw.Container(
              padding: const pw.EdgeInsets.all(18),
              decoration: pw.BoxDecoration(
                color: _primaryColor,
                borderRadius: pw.BorderRadius.circular(10),
              ),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                crossAxisAlignment: pw.CrossAxisAlignment.start,
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
                        'Jakarta 12920  |  (021) 250 5337',
                        style: base(size: 8, color: PdfColors.white),
                      ),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Container(
                        padding: const pw.EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: pw.BoxDecoration(
                          color: PdfColors.white,
                          borderRadius: pw.BorderRadius.circular(4),
                        ),
                        child: pw.Text(
                          'LAPORAN PENGIRIMAN',
                          style: bold(size: 10, color: _primaryColor),
                        ),
                      ),
                      pw.SizedBox(height: 6),
                      pw.Text(
                        '${DateFormat('dd MMM yyyy').format(startDate)} – ${DateFormat('dd MMM yyyy').format(endDate)}',
                        style: base(size: 8, color: PdfColors.white),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            pw.SizedBox(height: 16),

            // STAT CARDS
            pw.Row(
              children: [
                _statCard(
                  'Total Dokumen',
                  '$total',
                  'pengiriman',
                  _accentColor,
                  ttf,
                  ttfBold,
                ),
                pw.SizedBox(width: 10),
                _statCard(
                  'Pengirim Aktif',
                  '${bySender.length}',
                  'perusahaan',
                  _greenColor,
                  ttf,
                  ttfBold,
                ),
                pw.SizedBox(width: 10),
                _statCard(
                  'Rata-rata/Hari',
                  byDay.isEmpty
                      ? '0'
                      : (total / byDay.length).toStringAsFixed(1),
                  'dokumen/hari',
                  _purpleColor,
                  ttf,
                  ttfBold,
                ),
              ],
            ),

            pw.SizedBox(height: 16),

            // GRAFIK BAR
            if (sortedDays.isNotEmpty) ...[
              pw.Container(
                padding: const pw.EdgeInsets.all(14),
                decoration: pw.BoxDecoration(
                  color: PdfColors.white,
                  borderRadius: pw.BorderRadius.circular(8),
                  border: pw.Border.all(color: _borderColor, width: 0.5),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'Grafik Pengiriman per Hari',
                      style: bold(size: 10),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text(
                      'Menampilkan ${sortedDays.take(20).length} hari',
                      style: base(size: 7, color: _textMuted),
                    ),
                    pw.SizedBox(height: 12),
                    pw.Row(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: sortedDays.take(20).map((e) {
                        final h = (e.value / maxPerDay * 80).toDouble();
                        final isMax = e.value == maxPerDay;
                        return pw.Padding(
                          padding: const pw.EdgeInsets.only(right: 5),
                          child: pw.Column(
                            mainAxisAlignment: pw.MainAxisAlignment.end,
                            children: [
                              pw.Text(
                                '${e.value}',
                                style: base(
                                  size: 7,
                                  color: isMax ? _accentColor : _textMuted,
                                ),
                              ),
                              pw.SizedBox(height: 2),
                              pw.Container(
                                width: 18,
                                height: h < 4 ? 4 : h,
                                decoration: pw.BoxDecoration(
                                  color: isMax ? _accentColor : _lightBg,
                                  borderRadius: pw.BorderRadius.circular(3),
                                ),
                              ),
                              pw.SizedBox(height: 4),
                              pw.Transform.rotate(
                                angle: -0.5,
                                child: pw.Text(
                                  e.key,
                                  style: base(size: 6, color: _textMuted),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 16),
            ],

            // TOP PENGIRIM
            if (topSenders.isNotEmpty) ...[
              pw.Container(
                padding: const pw.EdgeInsets.all(14),
                decoration: pw.BoxDecoration(
                  color: PdfColors.white,
                  borderRadius: pw.BorderRadius.circular(8),
                  border: pw.Border.all(color: _borderColor, width: 0.5),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('Top Pengirim', style: bold(size: 10)),
                    pw.SizedBox(height: 10),
                    ...topSenders.take(5).map((e) {
                      final percent = total == 0 ? 0.0 : e.value / total;
                      return pw.Padding(
                        padding: const pw.EdgeInsets.only(bottom: 8),
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Row(
                              mainAxisAlignment:
                                  pw.MainAxisAlignment.spaceBetween,
                              children: [
                                pw.Text(
                                  e.key,
                                  style: base(size: 9),
                                  maxLines: 1,
                                ),
                                pw.Text(
                                  '${e.value} (${(percent * 100).toStringAsFixed(0)}%)',
                                  style: bold(size: 9, color: _accentColor),
                                ),
                              ],
                            ),
                            pw.SizedBox(height: 4),
                            pw.Stack(
                              children: [
                                pw.Container(
                                  height: 7,
                                  width: double.infinity,
                                  decoration: pw.BoxDecoration(
                                    color: _lightBg,
                                    borderRadius: pw.BorderRadius.circular(4),
                                  ),
                                ),
                                pw.Container(
                                  height: 7,
                                  width: 450 * percent,
                                  decoration: pw.BoxDecoration(
                                    color: _accentColor,
                                    borderRadius: pw.BorderRadius.circular(4),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
              pw.SizedBox(height: 16),
            ],

            // TABEL DOKUMEN
            pw.Container(
              decoration: pw.BoxDecoration(
                borderRadius: pw.BorderRadius.circular(8),
                border: pw.Border.all(color: _borderColor, width: 0.5),
              ),
              child: pw.Column(
                children: [
                  pw.Container(
                    padding: const pw.EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    decoration: const pw.BoxDecoration(
                      color: _primaryColor,
                      borderRadius: pw.BorderRadius.only(
                        topLeft: pw.Radius.circular(8),
                        topRight: pw.Radius.circular(8),
                      ),
                    ),
                    child: pw.Row(
                      children: [
                        pw.SizedBox(
                          width: 22,
                          child: pw.Text(
                            'No',
                            style: bold(size: 8, color: PdfColors.white),
                          ),
                        ),
                        pw.Expanded(
                          flex: 2,
                          child: pw.Text(
                            'Pengirim',
                            style: bold(size: 8, color: PdfColors.white),
                          ),
                        ),
                        pw.Expanded(
                          flex: 2,
                          child: pw.Text(
                            'Penerima',
                            style: bold(size: 8, color: PdfColors.white),
                          ),
                        ),
                        pw.SizedBox(
                          width: 65,
                          child: pw.Text(
                            'Tanggal',
                            style: bold(size: 8, color: PdfColors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                  ...documents.asMap().entries.map((entry) {
                    final i = entry.key;
                    final doc = entry.value;
                    return pw.Container(
                      padding: const pw.EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: pw.BoxDecoration(
                        color: i % 2 == 0 ? PdfColors.white : _lightBg,
                      ),
                      child: pw.Row(
                        children: [
                          pw.SizedBox(
                            width: 22,
                            child: pw.Text(
                              '${i + 1}',
                              style: base(size: 8, color: _textMuted),
                            ),
                          ),
                          pw.Expanded(
                            flex: 2,
                            child: pw.Column(
                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                              children: [
                                pw.Text(
                                  doc.senderCompany,
                                  style: bold(size: 8),
                                  maxLines: 1,
                                ),
                                pw.Text(
                                  'Dari ${doc.senderName}',
                                  style: base(size: 7, color: _textMuted),
                                  maxLines: 1,
                                ),
                              ],
                            ),
                          ),
                          pw.Expanded(
                            flex: 2,
                            child: pw.Column(
                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                              children: [
                                pw.Text(
                                  doc.receiverCompany,
                                  style: bold(size: 8),
                                  maxLines: 1,
                                ),
                                pw.Text(
                                  'Kpd ${doc.receiverName}',
                                  style: base(size: 7, color: _textMuted),
                                  maxLines: 1,
                                ),
                              ],
                            ),
                          ),
                          pw.SizedBox(
                            width: 65,
                            child: pw.Text(
                              DateFormat('dd MMM yy').format(doc.createdAt),
                              style: base(size: 8, color: _textMuted),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),

            pw.SizedBox(height: 16),

            // FOOTER
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
                    'Dibuat oleh: $generatedBy  |  PT KGI SEKURITAS INDONESIA',
                    style: base(size: 7, color: _textMuted),
                  ),
                  pw.Text(
                    'Generated: ${DateFormat('dd MMM yyyy HH:mm').format(DateTime.now())}',
                    style: base(size: 7, color: _textMuted),
                  ),
                ],
              ),
            ),
          ],
        ),
      );

      final output = await getTemporaryDirectory();
      final file = File(
        '${output.path}/Laporan_KGI_${DateFormat('MMM_yyyy').format(startDate)}.pdf',
      );
      await file.writeAsBytes(await pdf.save());

      debugPrint('✅ PDF saved at: ${file.path}');
      debugPrint('✅ File size: ${await file.length()} bytes');
      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path, mimeType: 'application/pdf')],
          text: 'Laporan Pengiriman Dokumen - PT KGI Sekuritas Indonesia',
        ),
      );
    } catch (e, stackTrace) {
      debugPrint('❌ Report PDF ERROR: $e');
      debugPrint('Stack trace: $stackTrace'); // ← tambah ini
      // ignore: use_build_context_synchronously
      showSnackbar(context, 'Gagal membuat laporan PDF: $e');
    }
  }

  static pw.Widget _statCard(
    String label,
    String value,
    String sub,
    PdfColor color,
    pw.Font ttf,
    pw.Font ttfBold,
  ) {
    return pw.Expanded(
      child: pw.Container(
        padding: const pw.EdgeInsets.all(12),
        decoration: pw.BoxDecoration(
          color: PdfColors.white,
          borderRadius: pw.BorderRadius.circular(8),
          border: pw.Border.all(color: _borderColor, width: 0.5),
        ),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Container(
              width: 6,
              height: 6,
              decoration: pw.BoxDecoration(
                color: color,
                shape: pw.BoxShape.circle,
              ),
            ),
            pw.SizedBox(height: 6),
            pw.Text(
              value,
              style: pw.TextStyle(
                font: ttfBold,
                fontSize: 18,
                color: color,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 2),
            pw.Text(
              label,
              style: pw.TextStyle(font: ttfBold, fontSize: 8, color: _textDark),
            ),
            pw.Text(
              sub,
              style: pw.TextStyle(font: ttf, fontSize: 7, color: _textMuted),
            ),
          ],
        ),
      ),
    );
  }
}
