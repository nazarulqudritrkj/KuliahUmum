import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_styles.dart';
import '../../core/models/event_model.dart';
import '../../core/models/registration_model.dart';
import '../../core/services/app_state_service.dart';
import '../../core/utils/responsive_layout.dart';
import 'feedback_screen.dart';
import 'certificate_screen.dart';

class EventDetailScreen extends StatefulWidget {
  final EventModel event;
  final AppStateService stateService;
  final VoidCallback onBack;

  const EventDetailScreen({
    super.key,
    required this.event,
    required this.stateService,
    required this.onBack,
  });

  @override
  State<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen> {
  bool get isRegistered {
    return widget.stateService.registrations.any(
      (r) => r.userId == widget.stateService.currentUser?.id &&
          r.eventId == widget.event.id &&
          r.status != RegistrationStatus.cancelled,
    );
  }

  RegistrationModel? get myRegistration {
    try {
      return widget.stateService.registrations.firstWhere(
        (r) => r.userId == widget.stateService.currentUser?.id &&
            r.eventId == widget.event.id &&
            r.status != RegistrationStatus.cancelled,
      );
    } catch (e) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveLayout.isMobile(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: isMobile ? _buildMobileLayout(context) : _buildDesktopLayout(context),
    );
  }

  Widget _buildDesktopLayout(BuildContext context) {
    return Row(
      children: [
        // Left: Event Information
        Expanded(
          flex: 6,
          child: Column(
            children: [
              _buildBannerHeader(context, isMobile: false),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(28),
                  child: _buildEventInfo(context, isMobile: false),
                ),
              ),
            ],
          ),
        ),

        // Right: Sidebar Action Panel
        Container(
          width: 340,
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(left: BorderSide(color: AppColors.border)),
          ),
          child: _buildSidebarActions(context),
        ),
      ],
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return Stack(
      children: [
        SingleChildScrollView(
          child: Column(
            children: [
              _buildBannerHeader(context, isMobile: true),
              Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  children: [
                    _buildEventInfo(context, isMobile: true),
                    const SizedBox(height: 100), // bottom padding for floating button
                  ],
                ),
              ),
            ],
          ),
        ),
        // Floating Bottom Action Button
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: const [BoxShadow(color: Color(0x1A000000), blurRadius: 16, offset: Offset(0, -4))],
              border: const Border(top: BorderSide(color: AppColors.border)),
            ),
            child: _buildRegisterButton(context),
          ),
        ),
      ],
    );
  }

  Widget _buildBannerHeader(BuildContext context, {required bool isMobile}) {
    final gradients = [
      AppColors.heroGradient,
      const LinearGradient(colors: [Color(0xFF1D4ED8), Color(0xFF3B82F6)], begin: Alignment.topLeft, end: Alignment.bottomRight),
      const LinearGradient(colors: [Color(0xFF065F46), Color(0xFF10B981)], begin: Alignment.topLeft, end: Alignment.bottomRight),
      AppColors.sunGradient,
    ];
    final gradIdx = int.tryParse(widget.event.bannerGradientIndex) ?? 0;
    final grad = gradients[gradIdx % gradients.length];

    return Container(
      height: isMobile ? 220 : 240,
      width: double.infinity,
      decoration: BoxDecoration(gradient: grad),
      child: Stack(
        children: [
          Positioned(
            top: -40,
            right: -40,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withValues(alpha: 0.08)),
            ),
          ),
          Positioned(
            bottom: -30,
            left: 20,
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.sunYellow.withValues(alpha: 0.1)),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Back Button & Admin Actions
                  Row(
                    children: [
                      GestureDetector(
                        onTap: widget.onBack,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.arrow_back_ios_rounded, color: Colors.white, size: 16),
                              Text('Kembali', style: GoogleFonts.plusJakartaSans(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              widget.event.eventType == EventType.online
                                  ? Icons.videocam_rounded
                                  : widget.event.eventType == EventType.hybrid
                                      ? Icons.hub_rounded
                                      : Icons.location_on_rounded,
                              color: AppColors.sunYellow,
                              size: 16,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              widget.event.eventType == EventType.online
                                  ? 'Online'
                                  : widget.event.eventType == EventType.hybrid
                                      ? 'Hybrid'
                                      : 'Offline',
                              style: GoogleFonts.plusJakartaSans(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  const SizedBox(height: 8),
                  Text(
                    widget.event.title,
                    style: GoogleFonts.plusJakartaSans(
                      color: Colors.white,
                      fontSize: isMobile ? 18 : 22,
                      fontWeight: FontWeight.w800,
                      height: 1.2,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventInfo(BuildContext context, {required bool isMobile}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Quick Info Bar
        Container(
          padding: const EdgeInsets.all(16),
          decoration: AppStyles.glowingPurpleCard,
          child: Column(
            children: [
              _buildInfoRow(Icons.calendar_today_rounded, 'Tanggal & Waktu', '${_formatDate(widget.event.dateTime)}  •  ${widget.event.duration}', AppColors.primaryPurple),
              const Divider(height: 18),
              _buildInfoRow(Icons.location_on_rounded, 'Lokasi / Tautan', widget.event.location, AppColors.info),
              const Divider(height: 18),
              _buildInfoRow(Icons.groups_rounded, 'Kuota Peserta', '${widget.event.registeredCount} / ${widget.event.quota} (${widget.event.remainingQuota} tersisa)', widget.event.isFull ? AppColors.danger : AppColors.success),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Speaker Section
        Text('👤 Profil Narasumber', style: AppStyles.heading3),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(18),
          decoration: AppStyles.cardDecoration,
          child: Row(
            children: [
              CircleAvatar(
                radius: 36,
                backgroundColor: AppColors.purpleSurface,
                child: Text(
                  widget.event.speakerName.isNotEmpty ? widget.event.speakerName[0] : 'S',
                  style: GoogleFonts.plusJakartaSans(fontSize: 28, fontWeight: FontWeight.w800, color: AppColors.primaryPurple),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.event.speakerName, style: AppStyles.bodyLarge.copyWith(fontWeight: FontWeight.w800)),
                    const SizedBox(height: 4),
                    Text(widget.event.speakerTitle, style: AppStyles.bodyMedium.copyWith(color: AppColors.primaryPurple, fontWeight: FontWeight.w600, fontSize: 13)),
                    const SizedBox(height: 3),
                    Text(widget.event.speakerOrganization, style: AppStyles.bodySmall),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Description
        Text('📋 Deskripsi Kuliah Umum', style: AppStyles.heading3),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(18),
          decoration: AppStyles.cardDecoration,
          child: Text(
            widget.event.description,
            style: AppStyles.bodyMedium.copyWith(height: 1.7),
          ),
        ),
        const SizedBox(height: 20),

        // Quota Progress
        Text('📊 Status Kuota Pendaftar', style: AppStyles.heading3),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(18),
          decoration: AppStyles.cardDecoration,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${widget.event.registeredCount} pendaftar',
                    style: AppStyles.bodyLarge.copyWith(fontWeight: FontWeight.w700),
                  ),
                  Text(
                    'dari ${widget.event.quota} kuota',
                    style: AppStyles.bodyMedium,
                  ),
                ],
              ),
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: widget.event.quotaFillPercentage,
                  minHeight: 12,
                  backgroundColor: AppColors.border,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    widget.event.isFull ? AppColors.danger : AppColors.primaryPurple,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${(widget.event.quotaFillPercentage * 100).toStringAsFixed(0)}% kapasitas terisi',
                    style: AppStyles.bodySmall.copyWith(fontWeight: FontWeight.w600, color: AppColors.primaryPurple),
                  ),
                  Text(
                    widget.event.isFull ? 'Kuota Penuh!' : '${widget.event.remainingQuota} tempat tersisa',
                    style: AppStyles.bodySmall.copyWith(
                      color: widget.event.isFull ? AppColors.danger : AppColors.success,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        if (isMobile && isRegistered && myRegistration != null) ...[
          const SizedBox(height: 20),
          _buildTicketSection(context),
        ],
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
          child: Icon(icon, color: color, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: AppStyles.bodySmall.copyWith(fontWeight: FontWeight.w600, fontSize: 11)),
              Text(value, style: AppStyles.bodyLarge.copyWith(fontSize: 13)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSidebarActions(BuildContext context) {
    final reg = myRegistration;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          Text('Tindakan Pendaftaran', style: AppStyles.heading3),
          const SizedBox(height: 16),

          if (reg != null && reg.status == RegistrationStatus.attended && !reg.isFeedbackSubmitted) ...[
            _buildActionCard(
              icon: Icons.rate_review_rounded,
              title: 'Isi Evaluasi & Dapatkan Sertifikat',
              description: 'Selesaikan kuesioner evaluasi untuk membuka E-Sertifikat Anda.',
              color: AppColors.sunYellowDark,
              bgColor: AppColors.sunYellowLight,
              buttonLabel: 'Mulai Evaluasi →',
              onTap: () => _navigateToFeedback(context, reg),
            ),
            const SizedBox(height: 16),
          ],

          if (reg != null && reg.isCertificateClaimed) ...[
            _buildActionCard(
              icon: Icons.workspace_premium_rounded,
              title: 'Unduh E-Sertifikat Resmi',
              description: 'Sertifikat digital Anda telah diterbitkan dan siap diunduh.',
              color: AppColors.success,
              bgColor: AppColors.successLight,
              buttonLabel: '⬇ Unduh Sertifikat',
              onTap: () => _navigateToCertificate(context, reg),
            ),
            const SizedBox(height: 16),
          ],

          _buildRegisterButton(context),

          if (reg != null && reg.status == RegistrationStatus.registered) ...[
            const SizedBox(height: 12),
            _buildTicketSection(context),
          ],

          const SizedBox(height: 20),
          _buildEventMetaInfo(),
        ],
      ),
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required String description,
    required Color color,
    required Color bgColor,
    required String buttonLabel,
    required VoidCallback onTap,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 22),
              const SizedBox(width: 10),
              Expanded(child: Text(title, style: AppStyles.bodyLarge.copyWith(fontWeight: FontWeight.w700, fontSize: 13))),
            ],
          ),
          const SizedBox(height: 6),
          Text(description, style: AppStyles.bodySmall.copyWith(height: 1.4)),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: onTap,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(
                  buttonLabel,
                  style: GoogleFonts.plusJakartaSans(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRegisterButton(BuildContext context) {
    final reg = myRegistration;
    if (reg != null) {
      // Already registered
      return Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.successLight,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.check_circle_rounded, color: AppColors.success),
                const SizedBox(width: 8),
                Text('Anda Sudah Terdaftar', style: GoogleFonts.plusJakartaSans(color: AppColors.success, fontWeight: FontWeight.w700)),
              ],
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () => _confirmCancel(context, reg.id),
              child: Text(
                'Batalkan Pendaftaran',
                style: GoogleFonts.plusJakartaSans(color: AppColors.danger, fontWeight: FontWeight.w600, fontSize: 13),
              ),
            ),
          ),
        ],
      );
    }

    return Container(
      width: double.infinity,
      height: 52,
      decoration: BoxDecoration(
        gradient: widget.event.isFull ? null : AppColors.purpleGradient,
        color: widget.event.isFull ? AppColors.border : null,
        borderRadius: BorderRadius.circular(14),
        boxShadow: widget.event.isFull
            ? []
            : const [BoxShadow(color: AppColors.purpleGlow, blurRadius: 14, offset: Offset(0, 6))],
      ),
      child: ElevatedButton(
        onPressed: widget.event.isFull ? null : () => _registerForEvent(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              widget.event.isFull ? Icons.block_rounded : Icons.how_to_reg_rounded,
              color: widget.event.isFull ? AppColors.textMuted : AppColors.sunYellow,
              size: 20,
            ),
            const SizedBox(width: 10),
            Text(
              widget.event.isFull ? 'Kuota Sudah Penuh' : 'Daftar Sekarang',
              style: GoogleFonts.plusJakartaSans(
                color: widget.event.isFull ? AppColors.textMuted : Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTicketSection(BuildContext context) {
    final reg = myRegistration;
    if (reg == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E1B4B), Color(0xFF3730A3)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [BoxShadow(color: Color(0x337C3AED), blurRadius: 20, offset: Offset(0, 8))],
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.confirmation_number_rounded, color: AppColors.sunYellow, size: 22),
              const SizedBox(width: 10),
              Text('Tiket Digital QR Anda', style: GoogleFonts.plusJakartaSans(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14)),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
            ),
            child: QrImageView(
              data: reg.ticketCode,
              version: QrVersions.auto,
              size: 150,
              gapless: false,
              eyeStyle: const QrEyeStyle(eyeShape: QrEyeShape.square, color: AppColors.darkSidebar),
              dataModuleStyle: const QrDataModuleStyle(dataModuleShape: QrDataModuleShape.circle, color: Color(0xFF1E1B4B)),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
            ),
            child: Text(
              reg.ticketCode,
              style: GoogleFonts.plusJakartaSans(
                color: AppColors.sunYellow,
                fontSize: 14,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tunjukkan QR Code ini kepada panitia\nuntuk verifikasi kehadiran Anda.',
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 11,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventMetaInfo() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.purpleSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primaryPurpleLight.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          _buildMetaRow('Kategori', widget.event.category, Icons.category_rounded),
          const SizedBox(height: 8),
          _buildMetaRow('Durasi', widget.event.duration, Icons.access_time_rounded),
        ],
      ),
    );
  }

  Widget _buildMetaRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 14, color: AppColors.primaryPurple),
        const SizedBox(width: 8),
        Text('$label: ', style: AppStyles.bodySmall.copyWith(fontWeight: FontWeight.w600)),
        Text(value, style: AppStyles.bodySmall.copyWith(color: AppColors.primaryPurple, fontWeight: FontWeight.w700)),
      ],
    );
  }

  void _registerForEvent(BuildContext context) {
    final result = widget.stateService.registerForEvent(widget.event.id);
    setState(() {});
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: result['success'] ? AppColors.primaryPurple : AppColors.danger,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        content: Row(
          children: [
            Icon(
              result['success'] ? Icons.check_circle_rounded : Icons.error_outline_rounded,
              color: AppColors.sunYellow,
            ),
            const SizedBox(width: 10),
            Expanded(child: Text(result['message'], style: GoogleFonts.plusJakartaSans(color: Colors.white, fontWeight: FontWeight.w600))),
          ],
        ),
      ),
    );
  }

  void _confirmCancel(BuildContext context, String registrationId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Batalkan Pendaftaran?', style: AppStyles.heading3),
        content: Text('Tindakan ini tidak dapat diurungkan. Anda mungkin tidak dapat mendaftar kembali jika kuota telah penuh.', style: AppStyles.bodyMedium),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Tidak, Tetap Daftar')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
            onPressed: () {
              widget.stateService.cancelRegistration(registrationId);
              setState(() {});
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(backgroundColor: AppColors.warning, content: Text('Pendaftaran berhasil dibatalkan.')),
              );
            },
            child: const Text('Ya, Batalkan', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _navigateToFeedback(BuildContext context, RegistrationModel reg) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (ctx) => FeedbackScreen(
          event: widget.event,
          registration: reg,
          stateService: widget.stateService,
          onBack: () => Navigator.pop(ctx),
          onSubmitSuccess: () {
            setState(() {});
            Navigator.pop(ctx);
          },
        ),
      ),
    );
  }

  void _navigateToCertificate(BuildContext context, RegistrationModel reg) {
    try {
      final cert = widget.stateService.certificates.firstWhere(
        (c) => c.registrationId == reg.id,
      );
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (ctx) => CertificateScreen(
            certificate: cert,
            event: widget.event,
            onBack: () => Navigator.pop(ctx),
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(backgroundColor: AppColors.warning, content: Text('Sertifikat belum tersedia. Selesaikan evaluasi terlebih dahulu.')),
      );
    }
  }

  String _formatDate(DateTime dt) {
    const months = ['Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni', 'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'];
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
  }
}
