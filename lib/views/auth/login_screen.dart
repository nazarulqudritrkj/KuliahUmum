import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_styles.dart';
import '../../core/models/user_model.dart';
import '../../core/services/app_state_service.dart';
import '../../core/utils/responsive_layout.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  final AppStateService stateService;
  final VoidCallback onLoginSuccess;

  const LoginScreen({
    super.key,
    required this.stateService,
    required this.onLoginSuccess,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _identifierController = TextEditingController(text: '220401050');
  final _passwordController = TextEditingController(text: 'password123');
  bool _obscurePassword = true;
  bool _rememberMe = true;
  UserRole _selectedRole = UserRole.mahasiswa;

  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    if (_formKey.currentState!.validate()) {
      widget.stateService.login(
        _identifierController.text,
        _passwordController.text,
        role: _selectedRole,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.primaryPurple,
          behavior: SnackBarBehavior.floating,
          content: Row(
            children: [
              const Icon(Icons.check_circle_rounded, color: AppColors.sunYellow),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Selamat datang kembali, ${widget.stateService.currentUser?.fullName}!',
                  style: GoogleFonts.plusJakartaSans(color: Colors.white, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
      );
      widget.onLoginSuccess();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: ResponsiveLayout(
        mobile: _buildMobileForm(context),
        tablet: _buildSplitLayout(context, isTablet: true),
        desktop: _buildSplitLayout(context, isTablet: false),
      ),
    );
  }

  Widget _buildSplitLayout(BuildContext context, {required bool isTablet}) {
    return Row(
      children: [
        // Left Hero Branding Panel (Ungu Terang & Kuning Matahari)
        Expanded(
          flex: isTablet ? 4 : 5,
          child: Container(
            decoration: const BoxDecoration(
              gradient: AppColors.heroGradient,
            ),
            child: Stack(
              children: [
                // Background decorative glowing circles
                Positioned(
                  top: -80,
                  right: -80,
                  child: Container(
                    width: 320,
                    height: 320,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.sunYellow.withValues(alpha: 0.18),
                    ),
                  ),
                ),
                Positioned(
                  bottom: -60,
                  left: -60,
                  child: Container(
                    width: 280,
                    height: 280,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primaryPurpleLight.withValues(alpha: 0.3),
                    ),
                  ),
                ),

                // Content
                Padding(
                  padding: const EdgeInsets.all(48.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Brand Logo Header
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.sunYellow,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: const [
                                BoxShadow(
                                  color: AppColors.yellowGlow,
                                  blurRadius: 15,
                                  offset: Offset(0, 4),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.school_rounded,
                              color: AppColors.darkSidebar,
                              size: 30,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'SIM-KU',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                  letterSpacing: 1.2,
                                ),
                              ),
                              Text(
                                'Portal Kuliah Umum Mahasiswa',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.sunYellowLight,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                      // Middle Illustration & Headline
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(30),
                              border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.stars_rounded, color: AppColors.sunYellow, size: 18),
                                const SizedBox(width: 8),
                                Text(
                                  'Sistem Presensi & E-Sertifikat Terpadu',
                                  style: GoogleFonts.plusJakartaSans(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            'Wujudkan Wawasan Global & Prestasi Akademik',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: isTablet ? 26 : 34,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              height: 1.25,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Akses ratusan kuliah umum dari tokoh inspiratif nasional & internasional. Presensi instan dengan QR Code dan unduh E-Sertifikat resmi secara otomatis.',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 15,
                              color: Colors.white.withValues(alpha: 0.85),
                              height: 1.6,
                            ),
                          ),
                        ],
                      ),

                      // Feature Mini Badges
                      Row(
                        children: [
                          _buildFeatureBadge(Icons.qr_code_scanner_rounded, 'Tiket QR Instan'),
                          const SizedBox(width: 16),
                          _buildFeatureBadge(Icons.verified_rounded, 'E-Sertifikat Otomatis'),
                          const SizedBox(width: 16),
                          _buildFeatureBadge(Icons.auto_graph_rounded, 'Riwayat Terpadu'),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        // Right Form Panel
        Expanded(
          flex: isTablet ? 5 : 5,
          child: Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: isTablet ? 36 : 64,
                vertical: 40,
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: _buildFormCard(context),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFeatureBadge(IconData icon, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.sunYellow, size: 22),
            const SizedBox(height: 6),
            Text(
              label,
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileForm(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Mobile Top Gradient Header
          Container(
            padding: const EdgeInsets.fromLTRB(24, 60, 24, 36),
            decoration: const BoxDecoration(
              gradient: AppColors.heroGradient,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(32),
                bottomRight: Radius.circular(32),
              ),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.sunYellow,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(Icons.school_rounded, color: AppColors.darkSidebar, size: 28),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'SIM-KU',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          'Portal Kuliah Umum Mahasiswa',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            color: AppColors.sunYellowLight,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  'Masuk ke Akun Anda',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Kelola pendaftaran kuliah umum & e-sertifikat',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(24.0),
            child: _buildFormCard(context),
          ),
        ],
      ),
    );
  }

  Widget _buildFormCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F7C3AED),
            blurRadius: 30,
            offset: Offset(0, 10),
          ),
        ],
        border: Border.all(color: AppColors.border),
      ),
      padding: const EdgeInsets.all(32),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Text (Desktop/Tablet)
            if (!ResponsiveLayout.isMobile(context)) ...[
              Text(
                'Selamat Datang! 👋',
                style: AppStyles.heading2.copyWith(color: AppColors.textPrimary),
              ),
              const SizedBox(height: 8),
              Text(
                'Masukkan kredensial akun Anda untuk mengakses portal kuliah umum.',
                style: AppStyles.bodyMedium,
              ),
              const SizedBox(height: 24),
            ],

            // Role Selector Tab (Mahasiswa vs Panitia/Admin)
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppColors.purpleSurface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.primaryPurpleLight.withValues(alpha: 0.2)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _buildRoleTabButton(
                      title: 'Mahasiswa',
                      icon: Icons.person_rounded,
                      isSelected: _selectedRole == UserRole.mahasiswa,
                      onTap: () {
                        setState(() {
                          _selectedRole = UserRole.mahasiswa;
                          _identifierController.text = '220401050';
                        });
                      },
                    ),
                  ),
                  Expanded(
                    child: _buildRoleTabButton(
                      title: 'Admin / Panitia',
                      icon: Icons.admin_panel_settings_rounded,
                      isSelected: _selectedRole == UserRole.admin,
                      onTap: () {
                        setState(() {
                          _selectedRole = UserRole.admin;
                          _identifierController.text = 'ADM-9901';
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Identifier Input (NIM / Email)
            Text(
              _selectedRole == UserRole.mahasiswa ? 'NIM atau Email Kampus' : 'NIP / ID Admin',
              style: AppStyles.bodyLarge.copyWith(fontSize: 13, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _identifierController,
              decoration: AppStyles.inputDecoration(
                labelText: _selectedRole == UserRole.mahasiswa ? 'Nomor Induk Mahasiswa (NIM)' : 'ID Administrator',
                hintText: _selectedRole == UserRole.mahasiswa ? 'Contoh: 220401050' : 'Contoh: ADM-9901',
                prefixIcon: const Icon(Icons.badge_outlined, color: AppColors.primaryPurple),
              ),
              validator: (val) {
                if (val == null || val.isEmpty) {
                  return 'Harap masukkan NIM atau Email Anda';
                }
                return null;
              },
            ),
            const SizedBox(height: 18),

            // Password Input
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Kata Sandi',
                  style: AppStyles.bodyLarge.copyWith(fontSize: 13, fontWeight: FontWeight.w600),
                ),
                TextButton(
                  onPressed: () => _showForgotPasswordDialog(context),
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    'Lupa Sandi?',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryPurple,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              decoration: AppStyles.inputDecoration(
                labelText: 'Kata Sandi',
                prefixIcon: const Icon(Icons.lock_outline_rounded, color: AppColors.primaryPurple),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                    color: AppColors.textMuted,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                ),
              ),
              validator: (val) {
                if (val == null || val.length < 6) {
                  return 'Kata sandi minimal 6 karakter';
                }
                return null;
              },
            ),
            const SizedBox(height: 14),

            // Remember Me
            Row(
              children: [
                SizedBox(
                  height: 24,
                  width: 24,
                  child: Checkbox(
                    value: _rememberMe,
                    activeColor: AppColors.primaryPurple,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                    onChanged: (v) => setState(() => _rememberMe = v ?? true),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Ingat saya di perangkat ini',
                  style: AppStyles.bodyMedium.copyWith(fontSize: 13),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Login Button (Gradient Purple with Yellow Hover effect)
            Container(
              width: double.infinity,
              height: 52,
              decoration: BoxDecoration(
                gradient: AppColors.purpleGradient,
                borderRadius: BorderRadius.circular(14),
                boxShadow: const [
                  BoxShadow(
                    color: AppColors.purpleGlow,
                    blurRadius: 16,
                    offset: Offset(0, 6),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: _handleLogin,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Masuk ke Sistem',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.arrow_forward_rounded, color: AppColors.sunYellow, size: 20),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Divider or Register Link
            Row(
              children: [
                const Expanded(child: Divider(color: AppColors.border)),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'Belum punya akun?',
                    style: AppStyles.bodySmall,
                  ),
                ),
                const Expanded(child: Divider(color: AppColors.border)),
              ],
            ),
            const SizedBox(height: 16),

            // Register CTA Button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (ctx) => RegisterScreen(
                        stateService: widget.stateService,
                        onRegisterSuccess: widget.onLoginSuccess,
                      ),
                    ),
                  );
                },
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.primaryPurpleLight, width: 1.5),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  backgroundColor: AppColors.purpleSurface.withValues(alpha: 0.5),
                ),
                child: Text(
                  'Daftar Akun Mahasiswa Baru',
                  style: GoogleFonts.plusJakartaSans(
                    color: AppColors.primaryPurpleDark,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleTabButton({
    required String title,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          boxShadow: isSelected
              ? const [
                  BoxShadow(
                    color: Color(0x10000000),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ]
              : [],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected ? AppColors.primaryPurple : AppColors.textMuted,
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? AppColors.primaryPurple : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showForgotPasswordDialog(BuildContext context) {
    final emailController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.sunYellowLight,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.lock_reset_rounded, color: AppColors.sunYellowDark),
            ),
            const SizedBox(width: 12),
            Text('Reset Kata Sandi', style: AppStyles.heading3),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Masukkan NIM atau Email kampus Anda yang terdaftar. Tautan reset password akan dikirimkan.',
              style: AppStyles.bodyMedium,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: emailController,
              decoration: AppStyles.inputDecoration(
                labelText: 'Email Kampus / NIM',
                hintText: 'nim@student.kampus.ac.id',
                prefixIcon: const Icon(Icons.email_outlined, color: AppColors.primaryPurple),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Batal', style: GoogleFonts.plusJakartaSans(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  backgroundColor: AppColors.success,
                  content: Text('Instruksi reset password telah dikirim ke email institusi Anda.'),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryPurple,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Kirim Tautan', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
