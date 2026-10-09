import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_styles.dart';
import '../../core/models/event_model.dart';
import '../../core/models/registration_model.dart';
import '../../core/services/app_state_service.dart';

class FeedbackScreen extends StatefulWidget {
  final EventModel event;
  final RegistrationModel registration;
  final AppStateService stateService;
  final VoidCallback onBack;
  final VoidCallback onSubmitSuccess;

  const FeedbackScreen({
    super.key,
    required this.event,
    required this.registration,
    required this.stateService,
    required this.onBack,
    required this.onSubmitSuccess,
  });

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  double _ratingSpeaker = 0;
  double _ratingMaterial = 0;
  double _ratingFacilities = 0;
  final _commentsController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _commentsController.dispose();
    super.dispose();
  }

  void _submitFeedback() async {
    if (_ratingSpeaker == 0 || _ratingMaterial == 0 || _ratingFacilities == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: AppColors.warning,
          content: Text('Harap berikan penilaian untuk semua aspek evaluasi.'),
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    await Future.delayed(const Duration(seconds: 1));

    final result = widget.stateService.submitFeedback(
      registrationId: widget.registration.id,
      eventId: widget.event.id,
      ratingSpeaker: _ratingSpeaker,
      ratingMaterial: _ratingMaterial,
      ratingFacilities: _ratingFacilities,
      comments: _commentsController.text,
    );

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (result['success'] == true) {
      _showSuccessDialog(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(backgroundColor: AppColors.danger, content: Text(result['message'] ?? 'Gagal menyimpan evaluasi.')),
      );
    }
  }

  void _showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(gradient: AppColors.sunGradient, shape: BoxShape.circle),
                child: const Icon(Icons.workspace_premium_rounded, color: Colors.white, size: 48),
              ),
              const SizedBox(height: 20),
              Text('E-Sertifikat Diterbitkan! 🎉', style: AppStyles.heading2, textAlign: TextAlign.center),
              const SizedBox(height: 10),
              Text(
                'Evaluasi berhasil disimpan. E-Sertifikat resmi kuliah umum "${widget.event.title}" telah berhasil diterbitkan untuk Anda!',
                style: AppStyles.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Container(
                width: double.infinity,
                decoration: BoxDecoration(gradient: AppColors.purpleGradient, borderRadius: BorderRadius.circular(14)),
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, shadowColor: Colors.transparent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)), padding: const EdgeInsets.symmetric(vertical: 14)),
                  icon: const Icon(Icons.download_rounded, color: AppColors.sunYellow),
                  label: Text('Lihat & Unduh Sertifikat', style: GoogleFonts.plusJakartaSans(color: Colors.white, fontWeight: FontWeight.w700)),
                  onPressed: () {
                    Navigator.pop(ctx);
                    widget.onSubmitSuccess();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

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
          onPressed: widget.onBack,
        ),
        title: Text('Formulir Evaluasi', style: AppStyles.heading3),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppColors.border),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 700),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Event Info Header
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    gradient: AppColors.heroGradient,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.event_rounded, color: AppColors.sunYellow, size: 28),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.event.title,
                              style: GoogleFonts.plusJakartaSans(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              widget.event.speakerName,
                              style: GoogleFonts.plusJakartaSans(color: Colors.white.withValues(alpha: 0.8), fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Info Banner
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.sunYellowLight,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.sunYellow.withValues(alpha: 0.4)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline_rounded, color: AppColors.sunYellowDark, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Penilaian Anda sangat berharga! Setelah submit evaluasi, E-Sertifikat resmi akan otomatis diterbitkan dan dapat segera diunduh.',
                          style: AppStyles.bodySmall.copyWith(color: AppColors.sunYellowDark, height: 1.4),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Rating Sections
                _buildRatingSection(
                  label: '⭐ Penilaian Narasumber',
                  subtitle: 'Kualitas penyampaian materi, penguasaan topik, dan interaksi dengan peserta',
                  value: _ratingSpeaker,
                  onChanged: (v) => setState(() => _ratingSpeaker = v),
                ),
                const SizedBox(height: 20),
                _buildRatingSection(
                  label: '📚 Kualitas Materi',
                  subtitle: 'Relevansi topik, kedalaman pembahasan, dan manfaat bagi mahasiswa',
                  value: _ratingMaterial,
                  onChanged: (v) => setState(() => _ratingMaterial = v),
                ),
                const SizedBox(height: 20),
                _buildRatingSection(
                  label: '🏛️ Fasilitas & Penyelenggaraan',
                  subtitle: 'Kondisi tempat, manajemen waktu, dan persiapan panitia',
                  value: _ratingFacilities,
                  onChanged: (v) => setState(() => _ratingFacilities = v),
                ),
                const SizedBox(height: 24),

                // Comments Text Area
                Text('💬 Kritik, Saran & Masukan', style: AppStyles.heading3),
                const SizedBox(height: 6),
                Text(
                  'Saran konstruktif Anda akan digunakan untuk meningkatkan kualitas kuliah umum selanjutnya.',
                  style: AppStyles.bodyMedium,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _commentsController,
                  maxLines: 5,
                  decoration: AppStyles.inputDecoration(
                    labelText: 'Tuliskan kritik dan saran Anda di sini...',
                    hintText: 'Contoh: Materinya sangat informatif namun waktu tanya jawab bisa diperpanjang...',
                  ),
                ),
                const SizedBox(height: 28),

                // Submit Button
                Container(
                  width: double.infinity,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: AppColors.purpleGradient,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: const [BoxShadow(color: AppColors.purpleGlow, blurRadius: 20, offset: Offset(0, 8))],
                  ),
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : _submitFeedback,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: _isSubmitting
                        ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.send_rounded, color: AppColors.sunYellow, size: 22),
                              const SizedBox(width: 12),
                              Text(
                                'Kirim Evaluasi & Terbitkan Sertifikat',
                                style: GoogleFonts.plusJakartaSans(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white),
                              ),
                            ],
                          ),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRatingSection({
    required String label,
    required String subtitle,
    required double value,
    required ValueChanged<double> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppStyles.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppStyles.bodyLarge.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text(subtitle, style: AppStyles.bodySmall.copyWith(height: 1.4)),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (i) {
              final starValue = (i + 1).toDouble();
              return GestureDetector(
                onTap: () => onChanged(starValue),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  margin: const EdgeInsets.symmetric(horizontal: 6),
                  child: Icon(
                    value >= starValue ? Icons.star_rounded : Icons.star_outline_rounded,
                    size: 44,
                    color: value >= starValue ? AppColors.sunYellow : AppColors.border,
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 10),
          Center(
            child: Text(
              value == 0
                  ? 'Belum dinilai'
                  : value == 1
                      ? '😞 Kurang'
                      : value == 2
                          ? '😐 Cukup'
                          : value == 3
                              ? '🙂 Baik'
                              : value == 4
                                  ? '😊 Sangat Baik'
                                  : '🤩 Luar Biasa!',
              style: GoogleFonts.plusJakartaSans(
                color: value == 0 ? AppColors.textMuted : AppColors.primaryPurple,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
