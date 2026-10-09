import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_styles.dart';
import '../../core/services/app_state_service.dart';
import '../../core/utils/responsive_layout.dart';
import '../../core/widgets/galaxy_animation.dart';

class RegisterScreen extends StatefulWidget {
  final AppStateService stateService;
  final VoidCallback onRegisterSuccess;

  const RegisterScreen({
    super.key,
    required this.stateService,
    required this.onRegisterSuccess,
  });

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nimController = TextEditingController();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  String _selectedJurusan = 'Teknologi Informasi dan Komputer';
  String _selectedProdi = 'Teknologi Rekayasa Multimedia';
  String _selectedAngkatan = '2024';
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _agreeTerms = true;

  final List<String> _jurusanList = [
    'Teknologi Informasi dan Komputer',
  ];

  final List<String> _prodiList = [
    'Teknologi Rekayasa Multimedia',
    'Teknologi Rekayasa Komputer dan Jaringan',
    'Teknik Informatika',
    'Teknologi Rekayasa Perangkat Lunak',
  ];

  final List<String> _angkatanList = ['2023', '2024', '2025', '2026'];

  @override
  void dispose() {
    _nimController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleRegister() {
    if (_formKey.currentState!.validate()) {
      if (!_agreeTerms) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: AppColors.danger,
            content: Text('Harap setujui syarat & ketentuan layanan kampus.'),
          ),
        );
        return;
      }

      widget.stateService.register(
        nim: _nimController.text.trim(),
        fullName: _nameController.text.trim(),
        email: _emailController.text.trim(),
        fakultas: _selectedJurusan,
        prodi: _selectedProdi,
        angkatan: _selectedAngkatan,
        phoneNumber: _phoneController.text.trim(),
        password: _passwordController.text,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          content: Row(
            children: [
              const Icon(Icons.check_circle_rounded, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Registrasi Berhasil! Selamat datang di SIM-KU.',
                  style: GoogleFonts.plusJakartaSans(color: Colors.white, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
      );

      Navigator.of(context).pop(); // pop register screen
      widget.onRegisterSuccess();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF06030F),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFFCDC8FF)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Registrasi Mahasiswa Baru',
          style: AppStyles.heading3.copyWith(color: Colors.white),
        ),
        centerTitle: false,
      ),
      body: GalaxyBackground(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 780),
              child: Container(
                padding: const EdgeInsets.all(36),
                decoration: BoxDecoration(
                  color: const Color(0xFF0E0A28).withValues(alpha: 0.92),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF7C3AED).withValues(alpha: 0.30),
                      blurRadius: 50,
                      offset: const Offset(0, 12),
                    ),
                  ],
                  border: Border.all(
                    color: const Color(0xFF2D1F5E),
                    width: 1.5,
                  ),
                ),
                child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top Highlight Badge
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF7C3AED), Color(0xFF4F46E5)],
                            ),
                            borderRadius: BorderRadius.circular(30),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF7C3AED).withValues(alpha: 0.4),
                                blurRadius: 16,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.auto_awesome, color: Colors.white, size: 16),
                              const SizedBox(width: 6),
                              Text(
                                'Verifikasi Data Akademik',
                                style: GoogleFonts.plusJakartaSans(
                                  color: Colors.white,
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
                      'Formulir Pendaftaran Mahasiswa',
                      style: AppStyles.heading2.copyWith(color: Colors.white),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Lengkapi data identitas kemahasiswaan Anda untuk pendaftaran kuliah umum dan penerbitan sertifikat digital resmi.',
                      style: AppStyles.bodyMedium.copyWith(color: const Color(0xFF9D8FCC)),
                    ),
                    const SizedBox(height: 28),

                    // Grid / Two Column Form on Tablet & Desktop
                    ResponsiveLayout.isMobile(context)
                        ? _buildMobileInputs()
                        : _buildDesktopInputs(),

                    const SizedBox(height: 24),

                    // Terms Checkbox
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: 24,
                          width: 24,
                          child: Checkbox(
                            value: _agreeTerms,
                            activeColor: AppColors.primaryPurple,
                            checkColor: Colors.white,
                            side: const BorderSide(color: Color(0xFF5B3F9A)),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                            onChanged: (v) => setState(() => _agreeTerms = v ?? true),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Saya menyatakan bahwa data kemahasiswaan yang diinput adalah benar dan bersedia mematuhi tata tertib kuliah umum.',
                            style: AppStyles.bodySmall.copyWith(color: const Color(0xFF9D8FCC), height: 1.4),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),

                    // Submit Button
                    Container(
                      width: double.infinity,
                      height: 54,
                      decoration: BoxDecoration(
                        gradient: AppColors.purpleGradient,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: const [
                          BoxShadow(
                            color: AppColors.purpleGlow,
                            blurRadius: 20,
                            offset: Offset(0, 8),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: _handleRegister,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.person_add_alt_1_rounded, color: AppColors.sunYellow),
                            const SizedBox(width: 10),
                            Text(
                              'Daftarkan Akun & Aktifkan SIM-KU',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Back to login link
                    Center(
                      child: GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: RichText(
                          text: TextSpan(
                            text: 'Sudah memiliki akun terdaftar? ',
                            style: AppStyles.bodyMedium.copyWith(color: const Color(0xFF7B6FBB)),
                            children: [
                              TextSpan(
                                text: 'Masuk Sekarang',
                                style: GoogleFonts.plusJakartaSans(
                                  color: const Color(0xFFA78BFA),
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          ),
        ),
      ),
    );
  }

  Widget _buildDesktopInputs() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Row 1: Nama Lengkap & NIM
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                label: 'Nama Lengkap',
                controller: _nameController,
                hint: 'Masukkan nama lengkap',
                icon: Icons.person_outline_rounded,
                validator: (val) => val == null || val.trim().isEmpty ? 'Nama lengkap wajib diisi' : null,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildTextField(
                label: 'NIM (Nomor Induk Mahasiswa)',
                controller: _nimController,
                hint: 'Contoh: 220401050',
                icon: Icons.badge_outlined,
                validator: (val) => val == null || val.trim().isEmpty ? 'NIM wajib diisi' : null,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Row 2: Email & WhatsApp
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                label: 'Email Kampus / Mahasiswa/i',
                controller: _emailController,
                hint: 'nama@student.kampus.ac.id',
                icon: Icons.email_outlined,
                validator: (val) {
                  if (val == null || !val.contains('@')) return 'Format email tidak valid';
                  return null;
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildTextField(
                label: 'Nomor WhatsApp',
                controller: _phoneController,
                hint: '081234567890',
                icon: Icons.phone_android_rounded,
                validator: (val) => val == null || val.trim().length < 9 ? 'Nomor WhatsApp tidak valid' : null,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Row 3: Jurusan & Angkatan
        Row(
          children: [
            Expanded(
              flex: 3,
              child: _buildDropdown(
                label: 'Jurusan',
                value: _selectedJurusan,
                items: _jurusanList,
                onChanged: (val) => setState(() => _selectedJurusan = val!),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              flex: 1,
              child: _buildDropdown(
                label: 'Angkatan',
                value: _selectedAngkatan,
                items: _angkatanList,
                onChanged: (val) => setState(() => _selectedAngkatan = val!),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Row 4: Program Studi (Full width for long prodi names)
        _buildDropdown(
          label: 'Program Studi',
          value: _selectedProdi,
          items: _prodiList,
          onChanged: (val) => setState(() => _selectedProdi = val!),
        ),
        const SizedBox(height: 16),

        // Row 5: Kata Sandi & Konfirmasi Kata Sandi
        Row(
          children: [
            Expanded(
              child: _buildPasswordField(
                label: 'Kata Sandi',
                controller: _passwordController,
                obscure: _obscurePassword,
                onToggle: () => setState(() => _obscurePassword = !_obscurePassword),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildPasswordField(
                label: 'Konfirmasi Kata Sandi',
                controller: _confirmPasswordController,
                obscure: _obscureConfirmPassword,
                onToggle: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                validator: (val) {
                  if (val != _passwordController.text) return 'Kata sandi tidak cocok';
                  return null;
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMobileInputs() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTextField(
          label: 'Nama Lengkap',
          controller: _nameController,
          hint: 'Masukkan nama lengkap',
          icon: Icons.person_outline_rounded,
          validator: (val) => val == null || val.trim().isEmpty ? 'Nama lengkap wajib diisi' : null,
        ),
        const SizedBox(height: 14),
        _buildTextField(
          label: 'NIM (Nomor Induk Mahasiswa)',
          controller: _nimController,
          hint: 'Contoh: 220401050',
          icon: Icons.badge_outlined,
          validator: (val) => val == null || val.trim().isEmpty ? 'NIM wajib diisi' : null,
        ),
        const SizedBox(height: 14),
        _buildTextField(
          label: 'Email Kampus / Mahasiswa/i',
          controller: _emailController,
          hint: 'nama@student.kampus.ac.id',
          icon: Icons.email_outlined,
          validator: (val) => val == null || !val.contains('@') ? 'Email tidak valid' : null,
        ),
        const SizedBox(height: 14),
        _buildTextField(
          label: 'Nomor WhatsApp',
          controller: _phoneController,
          hint: '081234567890',
          icon: Icons.phone_android_rounded,
          validator: (val) => val == null || val.trim().length < 9 ? 'Nomor WhatsApp tidak valid' : null,
        ),
        const SizedBox(height: 14),
        _buildDropdown(
          label: 'Jurusan',
          value: _selectedJurusan,
          items: _jurusanList,
          onChanged: (val) => setState(() => _selectedJurusan = val!),
        ),
        const SizedBox(height: 14),
        _buildDropdown(
          label: 'Program Studi',
          value: _selectedProdi,
          items: _prodiList,
          onChanged: (val) => setState(() => _selectedProdi = val!),
        ),
        const SizedBox(height: 14),
        _buildDropdown(
          label: 'Angkatan',
          value: _selectedAngkatan,
          items: _angkatanList,
          onChanged: (val) => setState(() => _selectedAngkatan = val!),
        ),
        const SizedBox(height: 14),
        _buildPasswordField(
          label: 'Kata Sandi',
          controller: _passwordController,
          obscure: _obscurePassword,
          onToggle: () => setState(() => _obscurePassword = !_obscurePassword),
        ),
        const SizedBox(height: 14),
        _buildPasswordField(
          label: 'Konfirmasi Kata Sandi',
          controller: _confirmPasswordController,
          obscure: _obscureConfirmPassword,
          onToggle: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
          validator: (val) => val != _passwordController.text ? 'Kata sandi tidak cocok' : null,
        ),
      ],
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppStyles.bodyLarge.copyWith(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: const Color(0xFFCDC8FF),
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
          decoration: AppStyles.inputDecoration(
            labelText: '',
            hintText: hint,
            prefixIcon: Icon(icon, color: AppColors.primaryPurple, size: 20),
          ).copyWith(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
          validator: validator,
        ),
      ],
    );
  }

  Widget _buildPasswordField({
    required String label,
    required TextEditingController controller,
    required bool obscure,
    required VoidCallback onToggle,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppStyles.bodyLarge.copyWith(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: const Color(0xFFCDC8FF),
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          obscureText: obscure,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
          decoration: AppStyles.inputDecoration(
            labelText: '',
            hintText: '••••••••',
            prefixIcon: const Icon(Icons.lock_outline_rounded, color: AppColors.primaryPurple, size: 20),
            suffixIcon: IconButton(
              icon: Icon(
                obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                color: AppColors.textMuted,
                size: 20,
              ),
              onPressed: onToggle,
            ),
          ).copyWith(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
          validator: validator ?? (val) => val == null || val.length < 6 ? 'Minimal 6 karakter' : null,
        ),
      ],
    );
  }

  Widget _buildDropdown({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppStyles.bodyLarge.copyWith(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: const Color(0xFFCDC8FF),
          ),
        ),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          initialValue: items.contains(value) ? value : items.first,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.primaryPurple),
          decoration: AppStyles.inputDecoration(labelText: '').copyWith(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          items: items.map((item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(
                item,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }
}
