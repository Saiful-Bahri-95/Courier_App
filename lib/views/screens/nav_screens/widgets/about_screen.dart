import 'package:flutter/material.dart';
import 'package:store_app/views/screens/utils.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: kNavyBlue,
      body: Column(
        children: [
          // ===== HEADER =====
          Padding(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: topPadding + 16,
              bottom: 24,
            ),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.all(9),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.arrow_back_ios_new,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Tentang Aplikasi',
                      style: TextStyle(
                        fontSize: 22,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Informasi & versi aplikasi',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // ===== CONTENT =====
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Color(0xFFF8FAFC),
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 28, 20, 32),
                child: Column(
                  children: [
                    // ===== APP LOGO CARD =====
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF1A3C8F), Color(0xFF2563EB)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: kAccentBlue.withValues(alpha: 0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Container(
                            width: 72,
                            height: 72,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: const Icon(
                              Icons.local_shipping_rounded,
                              color: Colors.white,
                              size: 36,
                            ),
                          ),
                          const SizedBox(height: 14),
                          const Text(
                            'Courier App',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 0.3,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'PT KGI Sekuritas Indonesia',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.white.withValues(alpha: 0.75),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              'Versi 1.0.0',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // ===== DESKRIPSI =====
                    _sectionLabel('Tentang'),
                    const SizedBox(height: 10),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Text(
                        'Courier App adalah aplikasi manajemen pengiriman dokumen digital yang dirancang khusus untuk PT KGI Sekuritas Indonesia. Aplikasi ini memungkinkan pencatatan pengiriman, tanda tangan digital, dan pembuatan tanda terima secara efisien.',
                        style: TextStyle(
                          fontSize: 13,
                          color: kTextMuted,
                          height: 1.6,
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // ===== FITUR =====
                    _sectionLabel('Fitur Utama'),
                    const SizedBox(height: 10),
                    _featureCard(
                      children: [
                        _featureTile(
                          icon: Icons.send_rounded,
                          color: kAccentBlue,
                          bgColor: const Color(0xFFEEF2FF),
                          title: 'Kirim Dokumen',
                          desc: 'Catat pengiriman dengan detail lengkap',
                        ),
                        _featureTile(
                          icon: Icons.draw_rounded,
                          color: const Color(0xFF16A34A),
                          bgColor: const Color(0xFFF0FDF4),
                          title: 'Tanda Tangan Digital',
                          desc: 'Konfirmasi penerimaan langsung di app',
                        ),
                        _featureTile(
                          icon: Icons.picture_as_pdf_rounded,
                          color: const Color(0xFF7C3AED),
                          bgColor: const Color(0xFFF5F3FF),
                          title: 'Export PDF',
                          desc: 'Tanda terima & laporan bulanan',
                        ),
                        _featureTile(
                          icon: Icons.history_rounded,
                          color: const Color(0xFFD97706),
                          bgColor: const Color(0xFFFFF7ED),
                          title: 'Riwayat Dokumen',
                          desc: 'Lacak semua pengiriman dengan mudah',
                        ),
                        _featureTile(
                          icon: Icons.pending_rounded,
                          color: const Color(0xFFDB2777),
                          bgColor: const Color(0xFFFDF2F8),
                          title: 'Draft Dokumen',
                          desc: 'Simpan draft, tanda tangan di lokasi',
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // ===== INFO TEKNIS =====
                    _sectionLabel('Informasi Teknis'),
                    const SizedBox(height: 10),
                    _infoCard(
                      children: [
                        _infoTile('Platform', 'Android & iOS'),
                        _infoTile('Framework', 'Flutter'),
                        _infoTile('Backend', 'Node.js + MongoDB Atlas'),
                        _infoTile('Storage', 'Cloudinary'),
                        _infoTile('Email Service', 'Resend'),
                        _infoTile('Deployment', 'Railway'),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // ===== KONTAK =====
                    _sectionLabel('Kontak'),
                    const SizedBox(height: 10),
                    _infoCard(
                      children: [
                        _infoTile('Perusahaan', 'PT KGI Sekuritas Indonesia'),
                        _infoTile('Alamat', 'Sona Topas Tower Lt. 11'),
                        _infoTile('Kota', 'Jakarta 12920'),
                        _infoTile('Telepon', '(021) 250 5337'),
                        _infoTile('Website', 'www.kgi.id'),
                      ],
                    ),

                    const SizedBox(height: 28),

                    // ===== COPYRIGHT =====
                    Text(
                      '© ${DateTime.now().year} PT KGI Sekuritas Indonesia',
                      style: const TextStyle(fontSize: 12, color: kTextMuted),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'All rights reserved',
                      style: TextStyle(fontSize: 11, color: kBorderColor),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionLabel(String label) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 16,
          decoration: BoxDecoration(
            color: kAccentBlue,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: kTextMuted,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  Widget _featureCard({required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: List.generate(children.length, (i) {
          return Column(
            children: [
              children[i],
              if (i < children.length - 1)
                const Divider(height: 1, indent: 64, endIndent: 16),
            ],
          );
        }),
      ),
    );
  }

  Widget _featureTile({
    required IconData icon,
    required Color color,
    required Color bgColor,
    required String title,
    required String desc,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: kTextDark,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  desc,
                  style: const TextStyle(fontSize: 12, color: kTextMuted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoCard({required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: List.generate(children.length, (i) {
          return Column(
            children: [
              children[i],
              if (i < children.length - 1)
                const Divider(height: 1, indent: 16, endIndent: 16),
            ],
          );
        }),
      ),
    );
  }

  Widget _infoTile(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 13, color: kTextMuted)),
          Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: kTextDark,
            ),
          ),
        ],
      ),
    );
  }
}
