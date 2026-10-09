import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_styles.dart';
import '../../core/models/event_model.dart';
import '../../core/models/registration_model.dart';
import '../../core/services/app_state_service.dart';
import '../../core/utils/responsive_layout.dart';

class StudentDashboard extends StatelessWidget {
  final AppStateService stateService;
  final VoidCallback onGoToCatalog;
  final Function(EventModel) onViewEvent;

  const StudentDashboard({
    super.key,
    required this.stateService,
    required this.onGoToCatalog,
    required this.onViewEvent,
  });

  @override
  Widget build(BuildContext context) {
    final user = stateService.currentUser!;
    final isMobile = ResponsiveLayout.isMobile(context);

    return SingleChildScrollView(
      padding: EdgeInsets.all(isMobile ? 16 : 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildWelcomeBanner(context, user.fullName, isMobile),
          const SizedBox(height: 24),
          _buildStatsRow(context, isMobile),
          const SizedBox(height: 24),
          _buildQuickActions(context, isMobile),
          const SizedBox(height: 24),
          _buildUpcomingEvents(context, isMobile),
          const SizedBox(height: 24),
          _buildMyRegistrations(context, isMobile),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildWelcomeBanner(BuildContext context, String name, bool isMobile) {
    final hour = DateTime.now().hour;
    final greeting = hour < 12 ? 'Selamat Pagi ☀️' : hour < 17 ? 'Selamat Siang 🌤️' : 'Selamat Sore 🌆';
    final now = DateTime.now();
    final upcomingCount = stateService.totalUpcomingRegistered;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isMobile ? 20 : 28),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4C1D95), Color(0xFF7C3AED), Color(0xFF9333EA)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(color: Color(0x337C3AED), blurRadius: 24, offset: Offset(0, 8)),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            right: -20,
            top: -20,
            child: Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.sunYellow.withValues(alpha: 0.12),
              ),
            ),
          ),
          Positioned(
            right: 30,
            bottom: -30,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.06),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.sunYellow.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.sunYellow.withValues(alpha: 0.4)),
                ),
                child: Text(
                  '📅 ${_formatDate(now)}',
                  style: GoogleFonts.plusJakartaSans(
                    color: AppColors.sunYellow,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                greeting,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: isMobile ? 14 : 15,
                  color: Colors.white.withValues(alpha: 0.8),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                name,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: isMobile ? 22 : 28,
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                stateService.currentUser?.prodi ?? '',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  color: Colors.white.withValues(alpha: 0.7),
                ),
              ),
              if (upcomingCount > 0) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.notifications_active_rounded, color: AppColors.sunYellow, size: 18),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          'Anda memiliki $upcomingCount kuliah umum yang akan segera berlangsung',
                          style: GoogleFonts.plusJakartaSans(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow(BuildContext context, bool isMobile) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 650) {
          return Column(
            children: [
              _buildStatCard(
                icon: Icons.event_available_rounded,
                label: 'Kuliah Dihadiri',
                value: '${stateService.totalEventsAttended}',
                color: AppColors.primaryPurple,
                bgColor: AppColors.purpleSurface,
                trend: '+2 bulan ini',
              ),
              const SizedBox(height: 12),
              _buildStatCard(
                icon: Icons.workspace_premium_rounded,
                label: 'E-Sertifikat',
                value: '${stateService.totalCertificatesEarned}',
                color: AppColors.sunYellowDark,
                bgColor: AppColors.sunYellowLight,
                trend: 'Diraih',
              ),
              const SizedBox(height: 12),
              _buildStatCard(
                icon: Icons.pending_actions_rounded,
                label: 'Akan Datang',
                value: '${stateService.totalUpcomingRegistered}',
                color: AppColors.info,
                bgColor: AppColors.infoLight,
                trend: 'Terdaftar',
              ),
            ],
          );
        }
        return Row(
          children: [
            Expanded(
              child: _buildStatCard(
                icon: Icons.event_available_rounded,
                label: 'Kuliah Dihadiri',
                value: '${stateService.totalEventsAttended}',
                color: AppColors.primaryPurple,
                bgColor: AppColors.purpleSurface,
                trend: '+2 bulan ini',
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: _buildStatCard(
                icon: Icons.workspace_premium_rounded,
                label: 'E-Sertifikat',
                value: '${stateService.totalCertificatesEarned}',
                color: AppColors.sunYellowDark,
                bgColor: AppColors.sunYellowLight,
                trend: 'Diraih',
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: _buildStatCard(
                icon: Icons.pending_actions_rounded,
                label: 'Akan Datang',
                value: '${stateService.totalUpcomingRegistered}',
                color: AppColors.info,
                bgColor: AppColors.infoLight,
                trend: 'Terdaftar',
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    required Color bgColor,
    required String trend,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withValues(alpha: 0.15)),
        boxShadow: const [
          BoxShadow(color: Color(0x08000000), blurRadius: 12, offset: Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  trend,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppStyles.bodyMedium.copyWith(fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }



  Widget _buildQuickActions(BuildContext context, bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Aksi Cepat', style: AppStyles.heading3),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: _buildQuickActionBtn(
                icon: Icons.search_rounded,
                label: 'Cari Kuliah\nUmum',
                gradient: AppColors.purpleGradient,
                onTap: onGoToCatalog,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildQuickActionBtn(
                icon: Icons.qr_code_2_rounded,
                label: 'Tiket QR\nSaya',
                gradient: AppColors.sunGradient,
                onTap: () {},
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildQuickActionBtn(
                icon: Icons.workspace_premium_rounded,
                label: 'Unduh\nSertifikat',
                gradient: const LinearGradient(
                  colors: [Color(0xFF10B981), Color(0xFF34D399)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                onTap: () {},
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildQuickActionBtn(
                icon: Icons.bar_chart_rounded,
                label: 'Riwayat\nKehadiran',
                gradient: const LinearGradient(
                  colors: [Color(0xFF3B82F6), Color(0xFF60A5FA)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                onTap: () {},
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickActionBtn({
    required IconData icon,
    required String label,
    required LinearGradient gradient,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 10),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: gradient.colors.first.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.white, size: 28),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUpcomingEvents(BuildContext context, bool isMobile) {
    final upcoming = stateService.events
        .where((e) => e.status == EventStatus.upcoming)
        .take(3)
        .toList();

    if (upcoming.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                '📢 Kuliah Umum Terkini',
                style: AppStyles.heading3,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            TextButton(
              onPressed: onGoToCatalog,
              child: Text(
                'Lihat Semua →',
                style: GoogleFonts.plusJakartaSans(
                  color: AppColors.primaryPurple,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth < 650) {
              return Column(
                children: upcoming.map((e) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _buildEventCard(context, e, isMobile: true),
                )).toList(),
              );
            }
            final cardWidth = constraints.maxWidth < 900
                ? (constraints.maxWidth - 14) / 2
                : (constraints.maxWidth - 28) / 3;
            return Wrap(
              spacing: 14,
              runSpacing: 14,
              children: upcoming.map((e) {
                return SizedBox(
                  width: cardWidth,
                  child: _buildEventCard(context, e, isMobile: false),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }

  Widget _buildEventCard(BuildContext context, EventModel event, {required bool isMobile}) {
    final gradients = [
      AppColors.heroGradient,
      const LinearGradient(colors: [Color(0xFF1D4ED8), Color(0xFF3B82F6)], begin: Alignment.topLeft, end: Alignment.bottomRight),
      const LinearGradient(colors: [Color(0xFF065F46), Color(0xFF10B981)], begin: Alignment.topLeft, end: Alignment.bottomRight),
      AppColors.sunGradient,
    ];
    final gradIdx = int.tryParse(event.bannerGradientIndex) ?? 0;
    final grad = gradients[gradIdx % gradients.length];
    final daysUntil = event.dateTime.difference(DateTime.now()).inDays;

    return GestureDetector(
      onTap: () => onViewEvent(event),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.border),
          boxShadow: const [BoxShadow(color: Color(0x08000000), blurRadius: 12, offset: Offset(0, 4))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Banner
            Container(
              height: 100,
              decoration: BoxDecoration(
                gradient: grad,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(18),
                  topRight: Radius.circular(18),
                ),
              ),
              padding: const EdgeInsets.all(14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      event.category,
                      style: GoogleFonts.plusJakartaSans(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: event.isFull ? AppColors.danger : AppColors.sunYellow,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      event.isFull ? 'PENUH' : daysUntil == 0 ? 'HARI INI' : '$daysUntil hari lagi',
                      style: GoogleFonts.plusJakartaSans(
                        color: event.isFull ? Colors.white : AppColors.darkSidebar,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppStyles.bodyLarge.copyWith(fontWeight: FontWeight.w700, fontSize: 13),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.person_outline_rounded, size: 14, color: AppColors.textMuted),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          event.speakerName,
                          overflow: TextOverflow.ellipsis,
                          style: AppStyles.bodySmall.copyWith(color: AppColors.primaryPurple, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.calendar_today_rounded, size: 14, color: AppColors.textMuted),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          _formatDate(event.dateTime),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppStyles.bodySmall,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  // Quota Bar
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${event.registeredCount} / ${event.quota} peserta',
                        style: AppStyles.bodySmall.copyWith(fontSize: 11),
                      ),
                      const SizedBox(height: 4),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: event.quotaFillPercentage,
                          minHeight: 5,
                          backgroundColor: AppColors.border,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            event.isFull ? AppColors.danger : AppColors.primaryPurple,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMyRegistrations(BuildContext context, bool isMobile) {
    final myEvents = stateService.myRegisteredEventDetails;
    if (myEvents.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('🎫 Pendaftaran Saya', style: AppStyles.heading3),
        const SizedBox(height: 14),
        ...myEvents.map((data) {
          final reg = data['registration'] as RegistrationModel;
          final event = data['event'] as EventModel;
          return _buildMyRegistrationTile(reg, event);
        }),
      ],
    );
  }

  Widget _buildMyRegistrationTile(RegistrationModel reg, EventModel event) {
    Color statusColor;
    String statusLabel;
    IconData statusIcon;

    switch (reg.status) {
      case RegistrationStatus.registered:
        statusColor = AppColors.primaryPurple;
        statusLabel = 'Terdaftar';
        statusIcon = Icons.how_to_reg_rounded;
        break;
      case RegistrationStatus.attended:
        statusColor = AppColors.success;
        statusLabel = 'Hadir ✓';
        statusIcon = Icons.verified_rounded;
        break;
      case RegistrationStatus.absent:
        statusColor = AppColors.danger;
        statusLabel = 'Tidak Hadir';
        statusIcon = Icons.cancel_rounded;
        break;
      default:
        statusColor = AppColors.textMuted;
        statusLabel = 'Dibatalkan';
        statusIcon = Icons.remove_circle_outline_rounded;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: statusColor.withValues(alpha: 0.2)),
        boxShadow: const [BoxShadow(color: Color(0x06000000), blurRadius: 10, offset: Offset(0, 3))],
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(statusIcon, color: statusColor, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppStyles.bodyLarge.copyWith(fontWeight: FontWeight.w700, fontSize: 13),
                ),
                const SizedBox(height: 3),
                Text(
                  '📅 ${_formatDate(event.dateTime)}  •  🎫 ${reg.ticketCode}',
                  style: AppStyles.bodySmall.copyWith(fontSize: 11),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              statusLabel,
              style: GoogleFonts.plusJakartaSans(
                color: statusColor,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
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
