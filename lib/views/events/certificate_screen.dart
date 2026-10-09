import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_styles.dart';
import '../../core/models/certificate_model.dart';
import '../../core/models/event_model.dart';

class CertificateScreen extends StatelessWidget {
  final CertificateModel certificate;
  final EventModel event;
  final VoidCallback onBack;

  const CertificateScreen({
    super.key,
    required this.certificate,
    required this.event,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textPrimary),
          onPressed: onBack,
        ),
        title: Text('E-Sertifikat Resmi', style: AppStyles.heading3),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Container(
              decoration: BoxDecoration(
                gradient: AppColors.sunGradient,
                borderRadius: BorderRadius.circular(10),
              ),
              child: TextButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      backgroundColor: AppColors.success,
                      content: Text('Sertifikat sedang diunduh sebagai PDF...'),
                    ),
                  );
                },
                icon: const Icon(Icons.download_rounded, color: AppColors.darkSidebar, size: 18),
                label: Text(
                  'Unduh PDF',
                  style: GoogleFonts.plusJakartaSans(
                    color: AppColors.darkSidebar,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppColors.border),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: Column(
              children: [
                _buildCertificateCard(context),
                const SizedBox(height: 24),
                _buildVerificationInfo(context),
                const SizedBox(height: 24),
                _buildShareActions(context),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCertificateCard(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(color: Color(0x1A7C3AED), blurRadius: 30, offset: Offset(0, 10)),
        ],
        border: Border.all(color: AppColors.primaryPurpleLight.withValues(alpha: 0.3), width: 2),
      ),
      child: Column(
        children: [
          // Certificate Header - Royal Purple
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(30),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1E1B4B), Color(0xFF4C1D95), Color(0xFF7C3AED)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(22),
                topRight: Radius.circular(22),
              ),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Decorative background circles
                Positioned(
                  top: -30,
                  right: -30,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.sunYellow.withValues(alpha: 0.1)),
                  ),
                ),
                Column(
                  children: [
                    // Institution Logo
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.sunYellow,
                        shape: BoxShape.circle,
                        boxShadow: const [BoxShadow(color: AppColors.yellowGlow, blurRadius: 16, offset: Offset(0, 4))],
                      ),
                      child: const Icon(Icons.school_rounded, color: AppColors.darkSidebar, size: 36),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'UNIVERSITAS CONTOH NUSANTARA',
                      style: GoogleFonts.plusJakartaSans(
                        color: AppColors.sunYellow,
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 2.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Biro Kemahasiswaan & Kuliah Umum',
                      style: GoogleFonts.plusJakartaSans(
                        color: Colors.white.withValues(alpha: 0.75),
                        fontSize: 12,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.sunYellow.withValues(alpha: 0.5)),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'SERTIFIKAT KEIKUTSERTAAN KULIAH UMUM',
                        style: GoogleFonts.plusJakartaSans(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Certificate Body
          Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              children: [
                // Decorative top divider
                Row(
                  children: [
                    Container(height: 2, width: 40, color: AppColors.sunYellow),
                    Expanded(child: Container(height: 1, color: AppColors.border)),
                    const SizedBox(width: 12),
                    const Icon(Icons.stars_rounded, color: AppColors.sunYellow, size: 20),
                    const SizedBox(width: 12),
                    Expanded(child: Container(height: 1, color: AppColors.border)),
                    Container(height: 2, width: 40, color: AppColors.sunYellow),
                  ],
                ),
                const SizedBox(height: 24),

                Text(
                  'Diberikan kepada:',
                  style: GoogleFonts.plusJakartaSans(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  certificate.studentName.toUpperCase(),
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primaryPurpleDark,
                    letterSpacing: 0.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 6),
                Text(
                  'NIM: ${certificate.studentNim}',
                  style: GoogleFonts.plusJakartaSans(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 20),

                Text(
                  'Telah berhasil mengikuti Kuliah Umum:',
                  style: GoogleFonts.plusJakartaSans(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(height: 12),

                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  decoration: BoxDecoration(
                    color: AppColors.purpleSurface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.primaryPurpleLight.withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    '"${certificate.eventTitle}"',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryPurpleDark,
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 16),

                Text(
                  'Oleh Narasumber: ${certificate.speakerName}',
                  style: GoogleFonts.plusJakartaSans(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Tanggal: ${_formatDate(certificate.eventDate)}',
                  style: GoogleFonts.plusJakartaSans(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),

                const SizedBox(height: 24),

                // Official Certificate Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    gradient: AppColors.sunGradient,
                    borderRadius: BorderRadius.circular(40),
                    boxShadow: const [BoxShadow(color: AppColors.yellowGlow, blurRadius: 12, offset: Offset(0, 4))],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.verified_user_rounded, color: Colors.white, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Sertifikat Resmi Terverifikasi',
                        style: GoogleFonts.plusJakartaSans(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),
                Row(
                  children: [
                    Container(height: 2, width: 40, color: AppColors.sunYellow),
                    Expanded(child: Container(height: 1, color: AppColors.border)),
                    const SizedBox(width: 12),
                    const Icon(Icons.verified_rounded, color: AppColors.success, size: 20),
                    const SizedBox(width: 12),
                    Expanded(child: Container(height: 1, color: AppColors.border)),
                    Container(height: 2, width: 40, color: AppColors.sunYellow),
                  ],
                ),

                const SizedBox(height: 24),

                // Footer: QR Verify + Cert Number
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Signature placeholder
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(height: 50, width: 130, decoration: BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.textSecondary.withValues(alpha: 0.4))))),
                          const SizedBox(height: 6),
                          Text('Prof. Dr. Rektor Kampus', style: AppStyles.bodySmall.copyWith(fontWeight: FontWeight.w700, fontSize: 11)),
                          Text('Rektor Universitas Contoh Nusantara', style: AppStyles.bodySmall.copyWith(fontSize: 10)),
                        ],
                      ),
                    ),
                    const SizedBox(width: 20),
                    // QR Code for Verification
                    Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: QrImageView(
                            data: 'VERIFY:${certificate.certificateNumber}',
                            version: QrVersions.auto,
                            size: 80,
                            eyeStyle: const QrEyeStyle(eyeShape: QrEyeShape.square, color: AppColors.primaryPurpleDark),
                            dataModuleStyle: const QrDataModuleStyle(dataModuleShape: QrDataModuleShape.circle, color: AppColors.darkSidebar),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text('Scan untuk Verifikasi', style: AppStyles.bodySmall.copyWith(fontSize: 9)),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Certificate Footer - Gold Border
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFF59E0B), Color(0xFFFCD34D), Color(0xFFF59E0B)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(22),
                bottomRight: Radius.circular(22),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'No: ${certificate.certificateNumber}',
                  style: GoogleFonts.plusJakartaSans(
                    color: AppColors.darkSidebar,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  'Diterbitkan: ${_formatDate(certificate.issuedAt)}',
                  style: GoogleFonts.plusJakartaSans(
                    color: AppColors.darkSidebar,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVerificationInfo(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: AppStyles.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.verified_rounded, color: AppColors.success, size: 22),
              const SizedBox(width: 10),
              Text('Informasi Verifikasi Digital', style: AppStyles.bodyLarge.copyWith(fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 12),
          _buildInfoItem('Nomor Sertifikat', certificate.certificateNumber),
          _buildInfoItem('Status', '✅ Terverifikasi & Sah secara Digital'),
          _buildInfoItem('Kategori', 'Kuliah Umum Universitas'),
          _buildInfoItem('Diterbitkan Pada', _formatDate(certificate.issuedAt)),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 160,
            child: Text(label, style: AppStyles.bodySmall.copyWith(fontWeight: FontWeight.w600)),
          ),
          Text(': ', style: AppStyles.bodySmall),
          Expanded(
            child: Text(value, style: AppStyles.bodySmall.copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  Widget _buildShareActions(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 50,
            decoration: BoxDecoration(gradient: AppColors.purpleGradient, borderRadius: BorderRadius.circular(14)),
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, shadowColor: Colors.transparent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
              icon: const Icon(Icons.download_rounded, color: AppColors.sunYellow, size: 20),
              label: Text('Unduh PDF', style: GoogleFonts.plusJakartaSans(color: Colors.white, fontWeight: FontWeight.w700)),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(backgroundColor: AppColors.success, content: Text('Sertifikat berhasil diunduh!')),
                );
              },
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            height: 50,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.primaryPurpleLight),
            ),
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, shadowColor: Colors.transparent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
              icon: const Icon(Icons.share_rounded, color: AppColors.primaryPurple, size: 20),
              label: Text('Bagikan', style: GoogleFonts.plusJakartaSans(color: AppColors.primaryPurple, fontWeight: FontWeight.w700)),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(backgroundColor: AppColors.primaryPurple, content: Text('Fitur berbagi akan segera tersedia!')),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime dt) {
    const months = ['Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni', 'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'];
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
  }
}
