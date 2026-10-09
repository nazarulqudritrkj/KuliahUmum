import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_styles.dart';
import '../../core/models/certificate_model.dart';
import '../../core/models/user_model.dart';
import '../../core/services/app_state_service.dart';
import '../../core/utils/responsive_layout.dart';

class ProfileScreen extends StatelessWidget {
  final AppStateService stateService;
  final VoidCallback onLogout;
  final Function(String) onNavigateToCertificate;

  const ProfileScreen({
    super.key,
    required this.stateService,
    required this.onLogout,
    required this.onNavigateToCertificate,
  });

  @override
  Widget build(BuildContext context) {
    final user = stateService.currentUser;
    if (user == null) return const SizedBox.shrink();

    final isMobile = ResponsiveLayout.isMobile(context);

    return SingleChildScrollView(
      padding: EdgeInsets.all(isMobile ? 16 : 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 900),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProfileHeader(context, isMobile),
            const SizedBox(height: 24),
            isMobile
                ? _buildMobileLayout(context)
                : _buildDesktopLayout(context),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, bool isMobile) {
    final user = stateService.currentUser!;
    return Container(
      padding: EdgeInsets.all(isMobile ? 20 : 28),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4C1D95), Color(0xFF7C3AED), Color(0xFF9333EA)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [BoxShadow(color: Color(0x337C3AED), blurRadius: 24, offset: Offset(0, 8))],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -30,
            top: -30,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.sunYellow.withValues(alpha: 0.1)),
            ),
          ),
          Row(
            children: [
              // Avatar
              Container(
                width: isMobile ? 70 : 90,
                height: isMobile ? 70 : 90,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.sunYellow,
                  border: Border.all(color: Colors.white, width: 3),
                  boxShadow: const [BoxShadow(color: AppColors.yellowGlow, blurRadius: 16, offset: Offset(0, 4))],
                ),
                child: Center(
                  child: Text(
                    user.fullName.isNotEmpty ? user.fullName[0].toUpperCase() : 'M',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: isMobile ? 28 : 36,
                      fontWeight: FontWeight.w800,
                      color: AppColors.darkSidebar,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: user.role == UserRole.admin ? AppColors.sunYellow : Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        user.role == UserRole.admin ? '👑 Admin / Panitia' : '🎓 Mahasiswa Aktif',
                        style: GoogleFonts.plusJakartaSans(
                          color: user.role == UserRole.admin ? AppColors.darkSidebar : Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      user.fullName,
                      style: GoogleFonts.plusJakartaSans(
                        color: Colors.white,
                        fontSize: isMobile ? 18 : 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user.nim,
                      style: GoogleFonts.plusJakartaSans(color: AppColors.sunYellow, fontSize: 14, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${user.prodi} • ${user.fakultas}',
                      style: GoogleFonts.plusJakartaSans(color: Colors.white.withValues(alpha: 0.75), fontSize: 12),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopLayout(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: 4, child: _buildPersonalInfo(context)),
        const SizedBox(width: 20),
        Expanded(flex: 3, child: Column(
          children: [
            _buildActivityStats(context),
            const SizedBox(height: 20),
            _buildAccountActions(context),
          ],
        )),
      ],
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return Column(
      children: [
        _buildPersonalInfo(context),
        const SizedBox(height: 20),
        _buildActivityStats(context),
        const SizedBox(height: 20),
        _buildCertificateHistory(context, isMobile: true),
        const SizedBox(height: 20),
        _buildAccountActions(context),
      ],
    );
  }

  Widget _buildPersonalInfo(BuildContext context) {
    final user = stateService.currentUser!;
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: AppStyles.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.person_rounded, color: AppColors.primaryPurple, size: 22),
              const SizedBox(width: 10),
              Text('Data Kemahasiswaan', style: AppStyles.bodyLarge.copyWith(fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 18),
          _buildDetailRow(Icons.badge_rounded, 'NIM', user.nim),
          _buildDetailRow(Icons.person_outline_rounded, 'Nama Lengkap', user.fullName),
          _buildDetailRow(Icons.email_outlined, 'Email', user.email),
          _buildDetailRow(Icons.phone_android_rounded, 'Nomor WhatsApp', user.phoneNumber),
          _buildDetailRow(Icons.account_balance_rounded, 'Fakultas', user.fakultas),
          _buildDetailRow(Icons.book_rounded, 'Program Studi', user.prodi),
          _buildDetailRow(Icons.school_rounded, 'Angkatan', user.angkatan),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(color: AppColors.purpleSurface, borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, size: 16, color: AppColors.primaryPurple),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: AppStyles.bodySmall.copyWith(fontWeight: FontWeight.w600, fontSize: 11)),
              Text(value, style: AppStyles.bodyLarge.copyWith(fontSize: 14)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActivityStats(BuildContext context) {
    final registeredCount = stateService.myRegisteredEventDetails.length;
    final attendedCount = stateService.totalEventsAttended;
    final certCount = stateService.totalCertificatesEarned;

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: AppStyles.glowingPurpleCard,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(gradient: AppColors.goldBadgeGradient, borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.military_tech_rounded, color: Colors.white, size: 18),
              ),
              const SizedBox(width: 10),
              Text('Statistik & Kehadiran', style: AppStyles.bodyLarge.copyWith(fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(child: _buildSkpStatBox('$registeredCount', 'Terdaftar', AppColors.primaryPurple)),
              const SizedBox(width: 12),
              Expanded(child: _buildSkpStatBox('$attendedCount', 'Acara Dihadiri', AppColors.success)),
              const SizedBox(width: 12),
              Expanded(child: _buildSkpStatBox('$certCount', 'Sertifikat', AppColors.sunYellowDark)),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.purpleSurface,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.primaryPurple.withValues(alpha: 0.15)),
            ),
            child: Row(
              children: [
                const Icon(Icons.verified_user_rounded, color: AppColors.primaryPurple, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Status: Partisipasi Aktif Kuliah Umum Mahasiswa',
                    style: AppStyles.bodySmall.copyWith(
                      color: AppColors.primaryPurple,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSkpStatBox(String value, String label, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Text(value, style: GoogleFonts.plusJakartaSans(fontSize: 22, fontWeight: FontWeight.w800, color: color)),
          Text(label, style: AppStyles.bodySmall.copyWith(fontSize: 10, textBaseline: TextBaseline.ideographic), textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _buildCertificateHistory(BuildContext context, {required bool isMobile}) {
    final certs = stateService.certificates;

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: AppStyles.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.workspace_premium_rounded, color: AppColors.sunYellowDark, size: 22),
              const SizedBox(width: 10),
              Text('Koleksi E-Sertifikat', style: AppStyles.bodyLarge.copyWith(fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 14),
          if (certs.isEmpty)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Column(
                children: [
                  Icon(Icons.workspace_premium_outlined, size: 48, color: AppColors.sunYellow.withValues(alpha: 0.4)),
                  const SizedBox(height: 8),
                  Text('Belum ada sertifikat diperoleh', style: AppStyles.bodyMedium),
                  Text('Ikuti kuliah umum & isi evaluasi untuk mendapatkan E-Sertifikat.', style: AppStyles.bodySmall, textAlign: TextAlign.center),
                ],
              ),
            )
          else
            ...certs.map((cert) => _buildCertTile(cert)),
        ],
      ),
    );
  }

  Widget _buildCertTile(CertificateModel cert) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFEF9EE), Color(0xFFFFF7D6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.sunYellow.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(gradient: AppColors.goldBadgeGradient, borderRadius: BorderRadius.circular(10)),
            child: const Icon(Icons.workspace_premium_rounded, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(cert.eventTitle, maxLines: 1, overflow: TextOverflow.ellipsis, style: AppStyles.bodyLarge.copyWith(fontWeight: FontWeight.w700, fontSize: 12)),
                Text('Terverifikasi  •  ${_formatDate(cert.issuedAt)}', style: AppStyles.bodySmall.copyWith(fontSize: 10)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.download_rounded, color: AppColors.sunYellowDark, size: 20),
        ],
      ),
    );
  }

  Widget _buildAccountActions(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: AppStyles.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Pengaturan Akun', style: AppStyles.bodyLarge.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 16),

          _buildActionTile(Icons.edit_rounded, 'Edit Profil & Foto', 'Perbarui data kemahasiswaan Anda', AppColors.primaryPurple, () {}),
          _buildActionTile(Icons.lock_reset_rounded, 'Ganti Kata Sandi', 'Perbarui keamanan akun Anda', AppColors.info, () {}),
          _buildActionTile(Icons.notifications_rounded, 'Preferensi Notifikasi', 'Atur pengiriman notifikasi email & push', AppColors.sunYellowDark, () {}),

          // Demo: Toggle Role
          _buildActionTile(
            Icons.swap_horiz_rounded,
            'Switch Mode (Demo)',
            'Beralih antara tampilan Mahasiswa & Admin',
            AppColors.success,
            () {
              stateService.toggleRole();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: AppColors.primaryPurple,
                  content: Text(
                    'Beralih ke: ${stateService.currentUser?.role == UserRole.admin ? "Mode Admin" : "Mode Mahasiswa"}',
                    style: GoogleFonts.plusJakartaSans(color: Colors.white),
                  ),
                ),
              );
            },
          ),

          const Divider(height: 20),

          // Logout Button
          GestureDetector(
            onTap: () => _confirmLogout(context),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.dangerLight,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.danger.withValues(alpha: 0.3)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.logout_rounded, color: AppColors.danger, size: 20),
                  const SizedBox(width: 10),
                  Text('Keluar dari Akun', style: GoogleFonts.plusJakartaSans(color: AppColors.danger, fontWeight: FontWeight.w700, fontSize: 14)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionTile(IconData icon, String title, String subtitle, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppStyles.bodyLarge.copyWith(fontWeight: FontWeight.w700, fontSize: 13)),
                  Text(subtitle, style: AppStyles.bodySmall.copyWith(fontSize: 11)),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.textMuted),
          ],
        ),
      ),
    );
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Keluar dari Akun?', style: AppStyles.heading3),
        content: Text('Anda akan keluar dari SIM-KU. Data Anda tetap tersimpan dengan aman.', style: AppStyles.bodyMedium),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
            onPressed: () {
              stateService.logout();
              Navigator.pop(ctx);
              onLogout();
            },
            child: const Text('Keluar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime dt) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
  }
}
