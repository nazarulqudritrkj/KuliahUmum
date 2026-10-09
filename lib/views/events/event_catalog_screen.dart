import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_styles.dart';
import '../../core/models/event_model.dart';
import '../../core/models/registration_model.dart';
import '../../core/services/app_state_service.dart';
import '../../core/utils/responsive_layout.dart';

class EventCatalogScreen extends StatefulWidget {
  final AppStateService stateService;
  final Function(EventModel) onViewEvent;

  const EventCatalogScreen({
    super.key,
    required this.stateService,
    required this.onViewEvent,
  });

  @override
  State<EventCatalogScreen> createState() => _EventCatalogScreenState();
}

class _EventCatalogScreenState extends State<EventCatalogScreen> {
  final _searchController = TextEditingController();
  final _categories = ['Semua', 'Teknologi & AI', 'Cybersecurity', 'Kewirausahaan', 'Ekonomi & Sosial', 'Kesehatan'];
  final _statusFilters = ['Semua', 'Tersedia', 'Penuh', 'Selesai'];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveLayout.isMobile(context);
    final filteredEvents = widget.stateService.filteredEvents;

    return Column(
      children: [
        _buildSearchAndFilters(context, isMobile),
        Expanded(
          child: filteredEvents.isEmpty
              ? _buildEmptyState()
              : isMobile
                  ? _buildMobileList(filteredEvents)
                  : _buildDesktopGrid(filteredEvents),
        ),
      ],
    );
  }

  Widget _buildSearchAndFilters(BuildContext context, bool isMobile) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.fromLTRB(isMobile ? 16 : 24, 16, isMobile ? 16 : 24, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: AppColors.purpleGradient,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.auto_stories_rounded, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Katalog Kuliah Umum', style: AppStyles.heading2.copyWith(fontSize: 20)),
                    Text('${widget.stateService.events.length} kuliah umum tersedia', style: AppStyles.bodySmall),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Search Bar
          TextField(
            controller: _searchController,
            onChanged: (val) => setState(() => widget.stateService.setSearchQuery(val)),
            decoration: AppStyles.inputDecoration(
              labelText: 'Cari judul, narasumber, atau institusi...',
              prefixIcon: const Icon(Icons.search_rounded, color: AppColors.primaryPurple),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear_rounded, color: AppColors.textMuted),
                      onPressed: () {
                        _searchController.clear();
                        widget.stateService.setSearchQuery('');
                        setState(() {});
                      },
                    )
                  : null,
            ),
          ),
          const SizedBox(height: 14),

          // Category Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _categories.map((cat) {
                final isSelected = widget.stateService.selectedCategory == cat;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () => setState(() => widget.stateService.setSelectedCategory(cat)),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        gradient: isSelected ? AppColors.purpleGradient : null,
                        color: isSelected ? null : AppColors.purpleSurface,
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(
                          color: isSelected ? Colors.transparent : AppColors.primaryPurpleLight.withValues(alpha: 0.3),
                        ),
                        boxShadow: isSelected
                            ? const [BoxShadow(color: AppColors.purpleGlow, blurRadius: 8, offset: Offset(0, 3))]
                            : [],
                      ),
                      child: Text(
                        cat,
                        style: GoogleFonts.plusJakartaSans(
                          color: isSelected ? Colors.white : AppColors.primaryPurpleDark,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 12),

          // Status Filter Chips (small)
          Row(
            children: [
              Text('Status: ', style: AppStyles.bodySmall.copyWith(fontWeight: FontWeight.w600)),
              ..._statusFilters.map((f) {
                final isSelected = widget.stateService.selectedStatusFilter == f;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () => setState(() => widget.stateService.setSelectedStatusFilter(f)),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.sunYellow : Colors.transparent,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected ? AppColors.sunYellowDark : AppColors.border,
                        ),
                      ),
                      child: Text(
                        f,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: isSelected ? AppColors.darkSidebar : AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(height: 1),
        ],
      ),
    );
  }

  Widget _buildMobileList(List<EventModel> events) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: events.length,
      separatorBuilder: (context, idx) => const SizedBox(height: 14),
      itemBuilder: (ctx, i) => _buildEventListCard(events[i]),
    );
  }

  Widget _buildDesktopGrid(List<EventModel> events) {
    final crossCount = ResponsiveLayout.isTablet(context) ? 2 : 3;
    return GridView.builder(
      padding: const EdgeInsets.all(24),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossCount,
        crossAxisSpacing: 18,
        mainAxisSpacing: 18,
        childAspectRatio: 0.78,
      ),
      itemCount: events.length,
      itemBuilder: (ctx, i) => _buildEventGridCard(events[i]),
    );
  }

  Widget _buildEventListCard(EventModel event) {
    final isRegistered = widget.stateService.registrations.any(
      (r) => r.userId == widget.stateService.currentUser?.id && r.eventId == event.id && r.status != RegistrationStatus.cancelled,
    );

    final gradients = [
      AppColors.heroGradient,
      const LinearGradient(colors: [Color(0xFF1D4ED8), Color(0xFF3B82F6)], begin: Alignment.topLeft, end: Alignment.bottomRight),
      const LinearGradient(colors: [Color(0xFF065F46), Color(0xFF10B981)], begin: Alignment.topLeft, end: Alignment.bottomRight),
      AppColors.sunGradient,
    ];
    final gradIdx = int.tryParse(event.bannerGradientIndex) ?? 0;
    final grad = gradients[gradIdx % gradients.length];

    return GestureDetector(
      onTap: () => widget.onViewEvent(event),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.border),
          boxShadow: const [BoxShadow(color: Color(0x08000000), blurRadius: 12, offset: Offset(0, 4))],
        ),
        child: Row(
          children: [
            // Left color strip / mini banner
            Container(
              width: 6,
              height: double.infinity,
              decoration: BoxDecoration(
                gradient: grad,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(18),
                  bottomLeft: Radius.circular(18),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        _buildTypeBadge(event),
                        const SizedBox(width: 8),
                        _buildStatusBadge(event),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      event.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppStyles.bodyLarge.copyWith(fontWeight: FontWeight.w700, fontSize: 14, height: 1.3),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.person_outline_rounded, size: 13, color: AppColors.primaryPurple),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            '${event.speakerName} • ${event.speakerOrganization}',
                            overflow: TextOverflow.ellipsis,
                            style: AppStyles.bodySmall.copyWith(color: AppColors.primaryPurple, fontWeight: FontWeight.w600, fontSize: 11),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.calendar_today_rounded, size: 13, color: AppColors.textMuted),
                        const SizedBox(width: 4),
                        Text(_formatDate(event.dateTime), style: AppStyles.bodySmall.copyWith(fontSize: 11)),
                        const SizedBox(width: 12),
                        const Icon(Icons.location_on_outlined, size: 13, color: AppColors.textMuted),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            event.location,
                            overflow: TextOverflow.ellipsis,
                            style: AppStyles.bodySmall.copyWith(fontSize: 11),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${event.registeredCount}/${event.quota} peserta',
                                style: AppStyles.bodySmall.copyWith(fontSize: 10),
                              ),
                              const SizedBox(height: 3),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: LinearProgressIndicator(
                                  value: event.quotaFillPercentage,
                                  minHeight: 4,
                                  backgroundColor: AppColors.border,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    event.isFull ? AppColors.danger : AppColors.primaryPurple,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            gradient: isRegistered
                                ? const LinearGradient(colors: [AppColors.success, Color(0xFF34D399)])
                                : event.isFull
                                    ? null
                                    : AppColors.purpleGradient,
                            color: event.isFull && !isRegistered ? AppColors.border : null,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            isRegistered ? '✓ Terdaftar' : event.isFull ? 'Penuh' : 'Daftar →',
                            style: GoogleFonts.plusJakartaSans(
                              color: event.isFull && !isRegistered ? AppColors.textMuted : Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEventGridCard(EventModel event) {
    final isRegistered = widget.stateService.registrations.any(
      (r) => r.userId == widget.stateService.currentUser?.id && r.eventId == event.id && r.status != RegistrationStatus.cancelled,
    );

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
      onTap: () => widget.onViewEvent(event),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border),
          boxShadow: const [BoxShadow(color: Color(0x08000000), blurRadius: 12, offset: Offset(0, 4))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Gradient Banner Header
            Container(
              height: 120,
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: grad,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      _buildTypeBadge(event),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: event.isFull ? AppColors.danger : AppColors.sunYellow,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          event.isFull ? 'PENUH' : event.status == EventStatus.completed ? 'SELESAI' : '$daysUntil hari',
                          style: GoogleFonts.plusJakartaSans(
                            color: event.isFull ? Colors.white : AppColors.darkSidebar,
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
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
                    event.category,
                    style: AppStyles.bodySmall.copyWith(color: AppColors.primaryPurple, fontWeight: FontWeight.w600, fontSize: 11),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    event.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppStyles.bodyLarge.copyWith(fontWeight: FontWeight.w700, fontSize: 13, height: 1.3),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.person_outline_rounded, size: 13, color: AppColors.textMuted),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          event.speakerName,
                          overflow: TextOverflow.ellipsis,
                          style: AppStyles.bodySmall.copyWith(fontWeight: FontWeight.w600, fontSize: 11),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      const Icon(Icons.calendar_today_rounded, size: 13, color: AppColors.textMuted),
                      const SizedBox(width: 4),
                      Text(_formatDate(event.dateTime), style: AppStyles.bodySmall.copyWith(fontSize: 11)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  // Quota progress bar
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('${event.registeredCount}/${event.quota}', style: AppStyles.bodySmall.copyWith(fontSize: 10)),
                          Text(
                            event.isFull ? 'Kuota Penuh' : '${event.remainingQuota} tempat tersisa',
                            style: AppStyles.bodySmall.copyWith(
                              fontSize: 10,
                              color: event.isFull ? AppColors.danger : AppColors.success,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
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
                  const SizedBox(height: 12),
                  // Action Button
                  SizedBox(
                    width: double.infinity,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: isRegistered
                            ? const LinearGradient(colors: [AppColors.success, Color(0xFF34D399)])
                            : event.isFull
                                ? null
                                : AppColors.purpleGradient,
                        color: event.isFull && !isRegistered ? AppColors.border : null,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: isRegistered || !event.isFull
                            ? const [BoxShadow(color: Color(0x20000000), blurRadius: 6, offset: Offset(0, 3))]
                            : [],
                      ),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                        ),
                        onPressed: () => widget.onViewEvent(event),
                        child: Text(
                          isRegistered ? '✓ Sudah Terdaftar' : event.isFull ? 'Daftar Tunggu' : 'Daftar Sekarang →',
                          style: GoogleFonts.plusJakartaSans(
                            color: event.isFull && !isRegistered ? AppColors.textMuted : Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeBadge(EventModel event) {
    final typeMap = {
      EventType.online: ('Online', Icons.videocam_rounded, AppColors.info),
      EventType.offline: ('Offline', Icons.location_on_rounded, AppColors.success),
      EventType.hybrid: ('Hybrid', Icons.hub_rounded, AppColors.sunYellowDark),
    };
    final t = typeMap[event.eventType]!;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(t.$2, size: 11, color: Colors.white),
          const SizedBox(width: 4),
          Text(t.$1, style: GoogleFonts.plusJakartaSans(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(EventModel event) {
    if (event.status != EventStatus.upcoming) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: AppColors.successLight,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          'Selesai',
          style: GoogleFonts.plusJakartaSans(color: AppColors.success, fontSize: 10, fontWeight: FontWeight.w700),
        ),
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off_rounded, size: 72, color: AppColors.primaryPurpleLight.withValues(alpha: 0.5)),
          const SizedBox(height: 16),
          Text('Tidak Ada Hasil', style: AppStyles.heading3.copyWith(color: AppColors.textSecondary)),
          const SizedBox(height: 8),
          Text(
            'Coba ubah kata kunci atau filter kategori\nuntuk menemukan kuliah umum yang sesuai.',
            textAlign: TextAlign.center,
            style: AppStyles.bodyMedium,
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () {
              _searchController.clear();
              widget.stateService.setSearchQuery('');
              widget.stateService.setSelectedCategory('Semua');
              widget.stateService.setSelectedStatusFilter('Semua');
              setState(() {});
            },
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Reset Filter'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryPurple,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
