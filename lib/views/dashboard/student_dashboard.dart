import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_styles.dart';
import '../../core/models/event_model.dart';
import '../../core/models/registration_model.dart';
import '../../core/services/app_state_service.dart';
import '../../core/utils/responsive_layout.dart';

class StudentDashboard extends StatefulWidget {
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
  State<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> with SingleTickerProviderStateMixin {
  late DateTime _currentTime;
  Timer? _timer;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _currentTime = DateTime.now();
    // Realtime live ticker every second
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _currentTime = DateTime.now();
        });
      }
    });

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.88, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.stateService.currentUser!;
    final isMobile = ResponsiveLayout.isMobile(context);

    return SingleChildScrollView(
      padding: EdgeInsets.all(isMobile ? 16 : 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLiveStatusBar(isMobile),
          const SizedBox(height: 16),
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

  /// Live System Status Bar with pulsing connection beacon (Psychology: Trust & Realtime Authority)
  Widget _buildLiveStatusBar(bool isMobile) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF100C2A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF2D1F5E)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A7C3AED),
            blurRadius: 16,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              ScaleTransition(
                scale: _pulseAnimation,
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: const BoxDecoration(
                    color: Color(0xFF10B981),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Color(0xFF10B981),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'SISTEM SIM-KU AKTIF • CLOUD SYNC LIVE',
                style: GoogleFonts.plusJakartaSans(
                  color: const Color(0xFF34D399),
                  fontSize: isMobile ? 10 : 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
          // Live Digital Clock
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFF3B2D75)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.access_time_rounded, size: 13, color: AppColors.sunYellow),
                const SizedBox(width: 6),
                Text(
                  _formatLiveTime(_currentTime),
                  style: GoogleFonts.firaCode(
                    color: AppColors.sunYellow,
                    fontSize: isMobile ? 11 : 12,
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

  Widget _buildWelcomeBanner(BuildContext context, String name, bool isMobile) {
    final hour = _currentTime.hour;
    String greeting;
    String motivationQuote;

    if (hour >= 4 && hour < 11) {
      greeting = 'Selamat Pagi 🌅';
      motivationQuote = 'Mulai harimu dengan antusiasme belajar & perluas wawasan akademikmu!';
    } else if (hour >= 11 && hour < 15) {
      greeting = 'Selamat Siang ☀️';
      motivationQuote = 'Kembangkan potensi terbaikmu melalui kuliah umum interaktif!';
    } else if (hour >= 15 && hour < 18) {
      greeting = 'Selamat Sore 🌇';
      motivationQuote = 'Waktu inspiratif untuk mendalami inovasi dan wawasan masa depan.';
    } else {
      greeting = 'Selamat Malam 🌙';
      motivationQuote = 'Refleksikan capaian hari ini dan siapkan target prestasimu esok hari.';
    }

    final upcomingCount = widget.stateService.totalUpcomingRegistered;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isMobile ? 22 : 32),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF3B1373), Color(0xFF6D28D9), Color(0xFF4338CA)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: const [
          BoxShadow(color: Color(0x407C3AED), blurRadius: 30, offset: Offset(0, 10)),
        ],
        border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Ambient glowing orb
          Positioned(
            right: -30,
            top: -30,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.sunYellow.withValues(alpha: 0.25),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            right: 40,
            bottom: -40,
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF06B6D4).withValues(alpha: 0.20),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Real-time Date Badge with Golden Live Icon
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                    decoration: BoxDecoration(
                      color: AppColors.sunYellow.withValues(alpha: 0.20),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: AppColors.sunYellow.withValues(alpha: 0.5)),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.sunYellow.withValues(alpha: 0.25),
                          blurRadius: 14,
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.event_available_rounded, color: AppColors.sunYellow, size: 15),
                        const SizedBox(width: 8),
                        Text(
                          _formatFullIndonesianDate(_currentTime),
                          style: GoogleFonts.plusJakartaSans(
                            color: AppColors.sunYellow,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                greeting,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: isMobile ? 14 : 16,
                  color: const Color(0xFFE0D8FF),
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.3,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                name,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: isMobile ? 24 : 32,
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                  shadows: [
                    Shadow(
                      color: const Color(0xFF7C3AED).withValues(alpha: 0.5),
                      blurRadius: 16,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 6),
              Text(
                widget.stateService.currentUser?.prodi ?? 'Teknologi Rekayasa Komputer dan Jaringan',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFFCDC8FF),
                ),
              ),
              const SizedBox(height: 12),
              // Motivational Psychological Quote
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.auto_awesome, color: AppColors.sunYellow, size: 16),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        motivationQuote,
                        style: GoogleFonts.plusJakartaSans(
                          color: Colors.white.withValues(alpha: 0.95),
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (upcomingCount > 0) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF59E0B).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFF59E0B).withValues(alpha: 0.5)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.notifications_active_rounded, color: AppColors.sunYellow, size: 18),
                      const SizedBox(width: 10),
                      Flexible(
                        child: Text(
                          'Anda memiliki $upcomingCount kuliah umum yang siap dihadiri!',
                          style: GoogleFonts.plusJakartaSans(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
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
                value: '${widget.stateService.totalEventsAttended}',
                color: AppColors.primaryPurple,
                bgColor: AppColors.purpleSurface,
                trend: 'Pencapaian',
              ),
              const SizedBox(height: 12),
              _buildStatCard(
                icon: Icons.workspace_premium_rounded,
                label: 'E-Sertifikat Terverifikasi',
                value: '${widget.stateService.totalCertificatesEarned}',
                color: AppColors.sunYellowDark,
                bgColor: AppColors.sunYellowLight,
                trend: '⭐ Resmi',
                isGoldHighlight: true,
              ),
              const SizedBox(height: 12),
              _buildStatCard(
                icon: Icons.pending_actions_rounded,
                label: 'Akan Datang',
                value: '${widget.stateService.totalUpcomingRegistered}',
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
                value: '${widget.stateService.totalEventsAttended}',
                color: AppColors.primaryPurple,
                bgColor: AppColors.purpleSurface,
                trend: 'Pencapaian',
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: _buildStatCard(
                icon: Icons.workspace_premium_rounded,
                label: 'E-Sertifikat Terverifikasi',
                value: '${widget.stateService.totalCertificatesEarned}',
                color: AppColors.sunYellowDark,
                bgColor: AppColors.sunYellowLight,
                trend: '⭐ Resmi',
                isGoldHighlight: true,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: _buildStatCard(
                icon: Icons.pending_actions_rounded,
                label: 'Akan Datang',
                value: '${widget.stateService.totalUpcomingRegistered}',
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
    bool isGoldHighlight = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isGoldHighlight ? AppColors.sunYellow.withValues(alpha: 0.6) : color.withValues(alpha: 0.18),
          width: isGoldHighlight ? 1.5 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: isGoldHighlight ? const Color(0x22F59E0B) : const Color(0x0C000000),
            blurRadius: 16,
            offset: const Offset(0, 5),
          ),
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
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  color: isGoldHighlight ? AppColors.sunYellow.withValues(alpha: 0.18) : color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(14),
                  border: isGoldHighlight ? Border.all(color: AppColors.sunYellow.withValues(alpha: 0.4)) : null,
                ),
                child: Text(
                  trend,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: isGoldHighlight ? const Color(0xFFD97706) : color,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: isGoldHighlight ? const Color(0xFFB45309) : color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppStyles.bodyMedium.copyWith(fontSize: 13, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context, bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.bolt_rounded, color: AppColors.sunYellow, size: 22),
            const SizedBox(width: 8),
            Text('Aksi Cepat Interaktif', style: AppStyles.heading3),
          ],
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: _buildQuickActionBtn(
                icon: Icons.search_rounded,
                label: 'Cari Kuliah\nUmum',
                gradient: AppColors.purpleGradient,
                onTap: widget.onGoToCatalog,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildQuickActionBtn(
                icon: Icons.qr_code_2_rounded,
                label: 'Tiket QR\nSaya',
                gradient: AppColors.sunGradient,
                onTap: widget.onGoToCatalog,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildQuickActionBtn(
                icon: Icons.workspace_premium_rounded,
                label: 'Unduh\nSertifikat',
                gradient: const LinearGradient(
                  colors: [Color(0xFF059669), Color(0xFF10B981)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                onTap: widget.onGoToCatalog,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildQuickActionBtn(
                icon: Icons.bar_chart_rounded,
                label: 'Riwayat\nKehadiran',
                gradient: const LinearGradient(
                  colors: [Color(0xFF2563EB), Color(0xFF60A5FA)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                onTap: widget.onGoToCatalog,
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
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 10),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: gradient.colors.first.withValues(alpha: 0.35),
              blurRadius: 14,
              offset: const Offset(0, 6),
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
    final upcoming = widget.stateService.events
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
            Row(
              children: [
                const Icon(Icons.campaign_rounded, color: AppColors.primaryPurple, size: 22),
                const SizedBox(width: 8),
                Text(
                  'Kuliah Umum Terkini & Live Countdown',
                  style: AppStyles.heading3,
                ),
              ],
            ),
            TextButton(
              onPressed: widget.onGoToCatalog,
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
                children: upcoming
                    .map((e) => Padding(
                          padding: const EdgeInsets.only(bottom: 14),
                          child: _buildEventCard(context, e, isMobile: true),
                        ))
                    .toList(),
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
    final countdownString = _formatLiveCountdown(event.dateTime);

    return GestureDetector(
      onTap: () => widget.onViewEvent(event),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border),
          boxShadow: const [BoxShadow(color: Color(0x0C000000), blurRadius: 14, offset: Offset(0, 5))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Banner
            Container(
              height: 110,
              decoration: BoxDecoration(
                gradient: grad,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              padding: const EdgeInsets.all(14),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          event.category,
                          style: GoogleFonts.plusJakartaSans(
                            color: Colors.white.withValues(alpha: 0.95),
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: event.isFull ? AppColors.danger : AppColors.sunYellow,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: const [
                            BoxShadow(color: Color(0x22000000), blurRadius: 4),
                          ],
                        ),
                        child: Text(
                          event.isFull ? 'KUOTA PENUH' : 'TERSEDIA',
                          style: GoogleFonts.plusJakartaSans(
                            color: event.isFull ? Colors.white : AppColors.darkSidebar,
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                  // Real-time live countdown ticker badge
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.35),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.timer_outlined, color: AppColors.sunYellow, size: 14),
                        const SizedBox(width: 6),
                        Text(
                          countdownString,
                          style: GoogleFonts.firaCode(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
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
                        style: AppStyles.bodySmall.copyWith(fontSize: 11, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 5),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: event.quotaFillPercentage,
                          minHeight: 6,
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
    final myEvents = widget.stateService.myRegisteredEventDetails;
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

  // --- Realtime Formatting Helpers ---

  String _formatLiveTime(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    final s = dt.second.toString().padLeft(2, '0');
    return '$h:$m:$s WIB';
  }

  String _formatFullIndonesianDate(DateTime dt) {
    const days = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'];
    const months = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    final dayName = days[dt.weekday - 1];
    final monthName = months[dt.month - 1];
    return '$dayName, ${dt.day} $monthName ${dt.year}';
  }

  String _formatLiveCountdown(DateTime target) {
    final diff = target.difference(_currentTime);
    if (diff.isNegative) {
      return 'Acara Berlangsung / Selesai';
    }
    final days = diff.inDays;
    final hours = diff.inHours % 24;
    final minutes = diff.inMinutes % 60;
    final seconds = diff.inSeconds % 60;

    if (days > 0) {
      return '${days}h ${hours}j ${minutes}m ${seconds}s';
    }
    return '${hours}j ${minutes}m ${seconds}s';
  }

  String _formatDate(DateTime dt) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
  }
}
