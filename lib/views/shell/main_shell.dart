import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_styles.dart';
import '../../core/models/event_model.dart';
import '../../core/models/user_model.dart';
import '../../core/services/app_state_service.dart';
import '../../core/utils/responsive_layout.dart';
import '../dashboard/student_dashboard.dart';
import '../dashboard/admin_dashboard.dart';
import '../events/event_catalog_screen.dart';
import '../events/event_detail_screen.dart';
import '../attendance/attendance_scanner_screen.dart';
import '../profile/profile_screen.dart';

class MainShell extends StatefulWidget {
  final AppStateService stateService;
  final VoidCallback onLogout;

  const MainShell({
    super.key,
    required this.stateService,
    required this.onLogout,
  });

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> with TickerProviderStateMixin {
  int _selectedIndex = 0;
  EventModel? _selectedEvent;

  final List<_NavItem> _studentNavItems = const [
    _NavItem(icon: Icons.home_rounded, label: 'Beranda', activeIcon: Icons.home_filled),
    _NavItem(icon: Icons.auto_stories_outlined, label: 'Katalog', activeIcon: Icons.auto_stories),
    _NavItem(icon: Icons.qr_code_scanner_rounded, label: 'Presensi', activeIcon: Icons.qr_code_scanner_rounded),
    _NavItem(icon: Icons.person_outline_rounded, label: 'Profil', activeIcon: Icons.person_rounded),
  ];

  final List<_NavItem> _adminNavItems = const [
    _NavItem(icon: Icons.dashboard_outlined, label: 'Dashboard', activeIcon: Icons.dashboard_rounded),
    _NavItem(icon: Icons.event_note_outlined, label: 'Kelola Acara', activeIcon: Icons.event_note_rounded),
    _NavItem(icon: Icons.qr_code_scanner_rounded, label: 'Scanner QR', activeIcon: Icons.qr_code_scanner_rounded),
    _NavItem(icon: Icons.person_outline_rounded, label: 'Akun', activeIcon: Icons.person_rounded),
  ];

  List<_NavItem> get _navItems {
    return widget.stateService.isAdmin ? _adminNavItems : _studentNavItems;
  }

  bool get isAdmin => widget.stateService.isAdmin;

  void _onNavTap(int index) {
    setState(() {
      _selectedIndex = index;
      _selectedEvent = null;
    });
  }

  Widget _buildActiveScreen() {
    // Event detail takes priority when set
    if (_selectedEvent != null) {
      return ListenableBuilder(
        listenable: widget.stateService,
        builder: (context, child) => EventDetailScreen(
          event: widget.stateService.events.firstWhere(
            (e) => e.id == _selectedEvent!.id,
            orElse: () => _selectedEvent!,
          ),
          stateService: widget.stateService,
          onBack: () => setState(() => _selectedEvent = null),
        ),
      );
    }

    return ListenableBuilder(
      listenable: widget.stateService,
      builder: (context, child) {
        switch (_selectedIndex) {
          case 0:
            return isAdmin
                ? AdminDashboard(
                    stateService: widget.stateService,
                    onViewEvent: (e) => setState(() => _selectedEvent = e),
                    onGoToEvents: () => setState(() => _selectedIndex = 1),
                  )
                : StudentDashboard(
                    stateService: widget.stateService,
                    onGoToCatalog: () => setState(() => _selectedIndex = 1),
                    onViewEvent: (e) => setState(() => _selectedEvent = e),
                  );
          case 1:
            return EventCatalogScreen(
              stateService: widget.stateService,
              onViewEvent: (e) => setState(() => _selectedEvent = e),
            );
          case 2:
            return AttendanceScannerScreen(stateService: widget.stateService);
          case 3:
            return ProfileScreen(
              stateService: widget.stateService,
              onLogout: widget.onLogout,
              onNavigateToCertificate: (id) {},
            );
          default:
            return const SizedBox.shrink();
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveLayout.isMobile(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: isMobile ? _buildMobileShell() : _buildDesktopShell(),
    );
  }

  Widget _buildDesktopShell() {
    return Row(
      children: [
        _buildSidebar(),
        Expanded(
          child: Column(
            children: [
              _buildTopBar(),
              Expanded(child: _buildActiveScreen()),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMobileShell() {
    return Column(
      children: [
        Expanded(
          child: _selectedEvent != null
              ? _buildActiveScreen()
              : Column(
                  children: [
                    _buildMobileTopBar(),
                    Expanded(child: _buildActiveScreen()),
                  ],
                ),
        ),
        if (_selectedEvent == null) _buildBottomNavBar(),
      ],
    );
  }

  Widget _buildSidebar() {
    final user = widget.stateService.currentUser;
    return Container(
      width: 240,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1E1B4B), Color(0xFF2E2867)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        boxShadow: [BoxShadow(color: Color(0x30000000), blurRadius: 20)],
      ),
      child: Column(
        children: [
          const SizedBox(height: 20),
          // Brand Logo
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.sunYellow,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: const [BoxShadow(color: AppColors.yellowGlow, blurRadius: 12, offset: Offset(0, 3))],
                  ),
                  child: const Icon(Icons.school_rounded, color: AppColors.darkSidebar, size: 24),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'SIM-KU',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: 1,
                      ),
                    ),
                    Text(
                      'Kuliah Umum',
                      style: GoogleFonts.plusJakartaSans(fontSize: 11, color: AppColors.sunYellowLight),
                    ),
                  ],
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(height: 1, color: Colors.white.withValues(alpha: 0.1)),
          ),
          const SizedBox(height: 8),

          // User Mini Card
          if (user != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.07),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.sunYellow,
                        border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 2),
                      ),
                      child: Center(
                        child: Text(
                          user.fullName.isNotEmpty ? user.fullName[0] : 'U',
                          style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.darkSidebar),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user.fullName.split(' ').take(2).join(' '),
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.plusJakartaSans(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700),
                          ),
                          Text(
                            user.role == UserRole.admin ? '👑 Admin' : user.nim,
                            style: GoogleFonts.plusJakartaSans(color: AppColors.sunYellow, fontSize: 11, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

          const SizedBox(height: 8),

          // Nav Items
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: _navItems.length,
              itemBuilder: (_, i) => _buildSidebarNavItem(i),
            ),
          ),


          // Logout
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 20),
            child: GestureDetector(
              onTap: widget.onLogout,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.danger.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.logout_rounded, color: AppColors.danger, size: 18),
                    const SizedBox(width: 10),
                    Text('Keluar', style: GoogleFonts.plusJakartaSans(color: AppColors.danger, fontSize: 13, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebarNavItem(int index) {
    final item = _navItems[index];
    final isSelected = _selectedIndex == index && _selectedEvent == null;

    return GestureDetector(
      onTap: () => _onNavTap(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 4),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryPurple.withValues(alpha: 0.25) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: isSelected
              ? Border.all(color: AppColors.primaryPurpleLight.withValues(alpha: 0.4))
              : null,
        ),
        child: Row(
          children: [
            if (isSelected)
              Container(
                width: 3,
                height: 20,
                decoration: BoxDecoration(
                  color: AppColors.sunYellow,
                  borderRadius: BorderRadius.circular(2),
                ),
                margin: const EdgeInsets.only(right: 12),
              ),
            Icon(
              isSelected ? item.activeIcon : item.icon,
              color: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.5),
              size: 20,
            ),
            const SizedBox(width: 12),
            Text(
              item.label,
              style: GoogleFonts.plusJakartaSans(
                color: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.6),
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    final pageTitle = _selectedEvent != null
        ? 'Detail Kuliah Umum'
        : _navItems[_selectedIndex].label;

    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          Text(pageTitle, style: AppStyles.heading3),
          const Spacer(),

          // Notification Bell
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.purpleSurface,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Stack(
              children: [
                const Icon(Icons.notifications_outlined, color: AppColors.primaryPurple, size: 22),
                Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(color: AppColors.sunYellow, shape: BoxShape.circle),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),

          // User Avatar quick button
          GestureDetector(
            onTap: () => setState(() { _selectedIndex = 3; _selectedEvent = null; }),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: AppColors.purpleGradient,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.person_rounded, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileTopBar() {
    final pageTitle = _navItems[_selectedIndex].label;

    return Container(
      padding: EdgeInsets.fromLTRB(16, MediaQuery.of(context).padding.top + 8, 16, 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.sunYellow,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.school_rounded, color: AppColors.darkSidebar, size: 18),
              ),
              const SizedBox(width: 8),
              Text(
                'SIM-KU',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primaryPurpleDark,
                ),
              ),
            ],
          ),
          const Spacer(),
          Text(pageTitle, style: AppStyles.bodyLarge.copyWith(fontWeight: FontWeight.w700, color: AppColors.textSecondary, fontSize: 13)),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(color: AppColors.purpleSurface, borderRadius: BorderRadius.circular(8)),
            child: const Icon(Icons.notifications_outlined, color: AppColors.primaryPurple, size: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavBar() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.border)),
        boxShadow: [BoxShadow(color: Color(0x0C000000), blurRadius: 16, offset: Offset(0, -4))],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(_navItems.length, (i) {
              final item = _navItems[i];
              final isSelected = _selectedIndex == i;
              return GestureDetector(
                onTap: () => _onNavTap(i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: isSelected ? AppColors.purpleGradient : null,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isSelected ? item.activeIcon : item.icon,
                        color: isSelected ? AppColors.sunYellow : AppColors.textMuted,
                        size: 22,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        item.label,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 10,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                          color: isSelected ? Colors.white : AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  const _NavItem({required this.icon, required this.activeIcon, required this.label});
}
