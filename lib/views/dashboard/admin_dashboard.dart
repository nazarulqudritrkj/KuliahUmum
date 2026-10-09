import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_styles.dart';
import '../../core/models/event_model.dart';
import '../../core/services/app_state_service.dart';
import '../../core/utils/responsive_layout.dart';

class AdminDashboard extends StatelessWidget {
  final AppStateService stateService;
  final Function(EventModel) onViewEvent;
  final VoidCallback onGoToEvents;

  const AdminDashboard({
    super.key,
    required this.stateService,
    required this.onViewEvent,
    required this.onGoToEvents,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveLayout.isMobile(context);

    return SingleChildScrollView(
      padding: EdgeInsets.all(isMobile ? 16 : 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildAdminBanner(context, isMobile),
          const SizedBox(height: 24),
          _buildAdminStatsGrid(context, isMobile),
          const SizedBox(height: 24),
          if (!isMobile) _buildTwoColumnLayout(context) else _buildMobileLayout(context),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildAdminBanner(BuildContext context, bool isMobile) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isMobile ? 20 : 28),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E1B4B), Color(0xFF3730A3), Color(0xFF4C1D95)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [BoxShadow(color: Color(0x3F1E1B4B), blurRadius: 24, offset: Offset(0, 8))],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppColors.sunYellow.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.sunYellow.withValues(alpha: 0.4)),
                  ),
                  child: Text(
                    '⚙️ Panel Administrasi SIM-KU',
                    style: GoogleFonts.plusJakartaSans(
                      color: AppColors.sunYellow,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Selamat Datang,',
                  style: GoogleFonts.plusJakartaSans(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  stateService.currentUser?.fullName ?? 'Admin',
                  style: GoogleFonts.plusJakartaSans(
                    color: Colors.white,
                    fontSize: isMobile ? 20 : 24,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _buildAdminQuickBtn(
                      icon: Icons.add_circle_outline_rounded,
                      label: 'Buat Acara',
                      onTap: () => _showCreateEventDialog(context),
                    ),
                    const SizedBox(width: 12),
                    _buildAdminQuickBtn(
                      icon: Icons.qr_code_scanner_rounded,
                      label: 'Scanner QR',
                      onTap: () {},
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (!isMobile) ...[
            const SizedBox(width: 24),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
              ),
              child: Column(
                children: [
                  Icon(Icons.admin_panel_settings_rounded, color: AppColors.sunYellow, size: 48),
                  const SizedBox(height: 8),
                  Text(
                    stateService.currentUser?.prodi ?? 'Panitia',
                    style: GoogleFonts.plusJakartaSans(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAdminQuickBtn({required IconData icon, required String label, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.sunYellow,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [BoxShadow(color: AppColors.yellowGlow, blurRadius: 12, offset: Offset(0, 4))],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: AppColors.darkSidebar, size: 18),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                color: AppColors.darkSidebar,
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdminStatsGrid(BuildContext context, bool isMobile) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: isMobile ? 2 : 4,
      crossAxisSpacing: 14,
      mainAxisSpacing: 14,
      childAspectRatio: isMobile ? 1.3 : 1.5,
      children: [
        _buildAdminStatCard(
          value: '${stateService.totalRegisteredStudents}',
          label: 'Total Mahasiswa\nTerdaftar',
          icon: Icons.groups_rounded,
          color: AppColors.primaryPurple,
          bgColor: AppColors.purpleSurface,
          suffix: ' mhs',
        ),
        _buildAdminStatCard(
          value: '${stateService.totalLecturesHeld}',
          label: 'Total Kuliah\nUmum Aktif',
          icon: Icons.event_note_rounded,
          color: AppColors.sunYellowDark,
          bgColor: AppColors.sunYellowLight,
          suffix: ' acara',
        ),
        _buildAdminStatCard(
          value: '${stateService.totalActiveRegistrations}',
          label: 'Total Pendaftar\nAktif',
          icon: Icons.how_to_reg_rounded,
          color: AppColors.info,
          bgColor: AppColors.infoLight,
          suffix: ' tiket',
        ),
        _buildAdminStatCard(
          value: '${stateService.averageAttendanceRate.toStringAsFixed(1)}%',
          label: 'Rata-rata Tingkat\nKehadiran',
          icon: Icons.bar_chart_rounded,
          color: AppColors.success,
          bgColor: AppColors.successLight,
          suffix: '',
        ),
      ],
    );
  }

  Widget _buildAdminStatCard({
    required String value,
    required String label,
    required IconData icon,
    required Color color,
    required Color bgColor,
    required String suffix,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withValues(alpha: 0.15)),
        boxShadow: const [BoxShadow(color: Color(0x08000000), blurRadius: 12, offset: Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: color, size: 22),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
              ),
              Text(label, style: AppStyles.bodySmall.copyWith(fontSize: 11, height: 1.4)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTwoColumnLayout(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: 3, child: _buildEventManagementList(context)),
        const SizedBox(width: 20),
        Expanded(flex: 2, child: _buildActivityFeed(context)),
      ],
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return Column(
      children: [
        _buildEventManagementList(context),
        const SizedBox(height: 20),
        _buildActivityFeed(context),
      ],
    );
  }

  Widget _buildEventManagementList(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppStyles.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Manajemen Kuliah Umum', style: AppStyles.heading3),
              TextButton.icon(
                onPressed: onGoToEvents,
                icon: const Icon(Icons.arrow_forward_rounded, size: 16, color: AppColors.primaryPurple),
                label: Text('Semua', style: GoogleFonts.plusJakartaSans(color: AppColors.primaryPurple, fontWeight: FontWeight.w700, fontSize: 13)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...stateService.events.take(4).map((event) => _buildEventAdminTile(context, event)),
        ],
      ),
    );
  }

  Widget _buildEventAdminTile(BuildContext context, EventModel event) {
    final statusColor = event.status == EventStatus.upcoming
        ? AppColors.primaryPurple
        : event.status == EventStatus.completed
            ? AppColors.success
            : AppColors.danger;

    final statusLabel = event.status == EventStatus.upcoming
        ? 'Aktif'
        : event.status == EventStatus.completed
            ? 'Selesai'
            : 'Dibatalkan';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.event_rounded, color: statusColor, size: 22),
          ),
          const SizedBox(width: 12),
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
                  '${event.registeredCount}/${event.quota} peserta  •  ${_formatDate(event.dateTime)}',
                  style: AppStyles.bodySmall.copyWith(fontSize: 11),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  statusLabel,
                  style: GoogleFonts.plusJakartaSans(
                    color: statusColor,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              GestureDetector(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      title: Text('Hapus Acara?', style: AppStyles.heading3),
                      content: Text('Apakah Anda yakin ingin menghapus kuliah umum "${event.title}"?', style: AppStyles.bodyMedium),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                          onPressed: () {
                            stateService.deleteEvent(event.id);
                            Navigator.pop(ctx);
                          },
                          child: const Text('Hapus', style: TextStyle(color: Colors.white)),
                        ),
                      ],
                    ),
                  );
                },
                child: const Icon(Icons.delete_outline_rounded, size: 18, color: AppColors.danger),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActivityFeed(BuildContext context) {
    final activities = [
      {'icon': Icons.person_add_rounded, 'color': AppColors.primaryPurple, 'text': 'Mahasiswa baru terdaftar pada "Generative AI 2026"', 'time': '5 mnt lalu'},
      {'icon': Icons.qr_code_scanner_rounded, 'color': AppColors.success, 'text': 'Check-in berhasil: Farhan S. (Teknologi AI)', 'time': '12 mnt lalu'},
      {'icon': Icons.workspace_premium_rounded, 'color': AppColors.sunYellowDark, 'text': 'E-Sertifikat diterbitkan: Green Economy', 'time': '1 jam lalu'},
      {'icon': Icons.star_rounded, 'color': AppColors.info, 'text': 'Rating baru (4.8★) diterima untuk "Cybersecurity"', 'time': '2 jam lalu'},
      {'icon': Icons.cancel_rounded, 'color': AppColors.danger, 'text': 'Pendaftaran dibatalkan: Fintech Startup', 'time': '3 jam lalu'},
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppStyles.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('🔔 Aktivitas Terkini', style: AppStyles.heading3),
          const SizedBox(height: 16),
          ...activities.map((a) => _buildActivityItem(
            icon: a['icon'] as IconData,
            color: a['color'] as Color,
            text: a['text'] as String,
            time: a['time'] as String,
          )),
        ],
      ),
    );
  }

  Widget _buildActivityItem({
    required IconData icon,
    required Color color,
    required String text,
    required String time,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 16),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(text, style: AppStyles.bodySmall.copyWith(color: AppColors.textPrimary, fontSize: 12, height: 1.4)),
                const SizedBox(height: 2),
                Text(time, style: AppStyles.bodySmall.copyWith(fontSize: 10)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showCreateEventDialog(BuildContext context) {
    final titleCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final speakerCtrl = TextEditingController();
    final locationCtrl = TextEditingController();
    final quotaCtrl = TextEditingController(text: '200');

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(gradient: AppColors.purpleGradient, borderRadius: BorderRadius.circular(12)),
                        child: const Icon(Icons.add_circle_rounded, color: Colors.white),
                      ),
                      const SizedBox(width: 12),
                      Text('Buat Kuliah Umum Baru', style: AppStyles.heading3),
                    ],
                  ),
                  const SizedBox(height: 20),
                  TextField(controller: titleCtrl, decoration: AppStyles.inputDecoration(labelText: 'Judul Kuliah Umum')),
                  const SizedBox(height: 14),
                  TextField(controller: descCtrl, maxLines: 3, decoration: AppStyles.inputDecoration(labelText: 'Deskripsi Singkat')),
                  const SizedBox(height: 14),
                  TextField(controller: speakerCtrl, decoration: AppStyles.inputDecoration(labelText: 'Nama Narasumber')),
                  const SizedBox(height: 14),
                  TextField(controller: locationCtrl, decoration: AppStyles.inputDecoration(labelText: 'Lokasi / Link Zoom')),
                  const SizedBox(height: 14),
                  TextField(controller: quotaCtrl, keyboardType: TextInputType.number, decoration: AppStyles.inputDecoration(labelText: 'Kuota Peserta')),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
                      const SizedBox(width: 12),
                      Container(
                        decoration: BoxDecoration(gradient: AppColors.purpleGradient, borderRadius: BorderRadius.circular(12)),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, shadowColor: Colors.transparent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                          onPressed: () {
                            if (titleCtrl.text.isNotEmpty) {
                              stateService.addEvent(EventModel(
                                id: 'ev-new-${DateTime.now().millisecondsSinceEpoch}',
                                title: titleCtrl.text,
                                description: descCtrl.text,
                                speakerName: speakerCtrl.text.isEmpty ? 'TBD' : speakerCtrl.text,
                                speakerTitle: 'Narasumber',
                                speakerOrganization: 'Institusi',
                                dateTime: DateTime.now().add(const Duration(days: 14)),
                                duration: '2 Jam',
                                location: locationCtrl.text.isEmpty ? 'Auditorium' : locationCtrl.text,
                                eventType: EventType.offline,
                                quota: int.tryParse(quotaCtrl.text) ?? 200,
                                registeredCount: 0,
                              ));
                              Navigator.pop(ctx);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  backgroundColor: AppColors.success,
                                  content: Text('Kuliah umum baru berhasil dibuat!'),
                                ),
                              );
                            }
                          },
                          child: const Text('Simpan & Publikasikan', style: TextStyle(color: Colors.white)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
  }
}
