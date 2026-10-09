import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_styles.dart';
import '../../core/models/registration_model.dart';
import '../../core/services/app_state_service.dart';
import '../../core/utils/responsive_layout.dart';

class AttendanceScannerScreen extends StatefulWidget {
  final AppStateService stateService;

  const AttendanceScannerScreen({
    super.key,
    required this.stateService,
  });

  @override
  State<AttendanceScannerScreen> createState() => _AttendanceScannerScreenState();
}

class _AttendanceScannerScreenState extends State<AttendanceScannerScreen> {
  final _ticketController = TextEditingController();
  Map<String, dynamic>? _lastScanResult;
  bool _isScanning = false;

  @override
  void dispose() {
    _ticketController.dispose();
    super.dispose();
  }

  void _processTicket(String code) async {
    if (code.trim().isEmpty) return;
    setState(() => _isScanning = true);
    await Future.delayed(const Duration(milliseconds: 600));

    final result = widget.stateService.checkInTicket(code);
    setState(() {
      _lastScanResult = result;
      _isScanning = false;
    });
    _ticketController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveLayout.isMobile(context);

    return SingleChildScrollView(
      padding: EdgeInsets.all(isMobile ? 16 : 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildScannerHeader(context, isMobile),
          const SizedBox(height: 24),
          isMobile ? _buildMobileLayout(context) : _buildDesktopLayout(context),
          const SizedBox(height: 24),
          _buildAttendanceList(context, isMobile),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildScannerHeader(BuildContext context, bool isMobile) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 18 : 24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E1B4B), Color(0xFF3730A3)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: AppColors.sunYellow, borderRadius: BorderRadius.circular(14)),
            child: const Icon(Icons.qr_code_scanner_rounded, color: AppColors.darkSidebar, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Scanner Presensi Digital', style: GoogleFonts.plusJakartaSans(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 18)),
                const SizedBox(height: 4),
                Text('Pindai QR Code tiket mahasiswa untuk verifikasi kehadiran real-time.', style: GoogleFonts.plusJakartaSans(color: Colors.white.withValues(alpha: 0.7), fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopLayout(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: 4, child: _buildManualInputCard(context)),
        const SizedBox(width: 20),
        Expanded(flex: 3, child: _buildScanResultCard(context)),
      ],
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return Column(
      children: [
        _buildManualInputCard(context),
        const SizedBox(height: 20),
        _buildScanResultCard(context),
      ],
    );
  }

  Widget _buildManualInputCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: AppStyles.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.keyboard_rounded, color: AppColors.primaryPurple, size: 22),
              const SizedBox(width: 10),
              Text('Input Manual / Scan Kode Tiket', style: AppStyles.bodyLarge.copyWith(fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 16),

          // Quick Demo Buttons
          Text('Demo Tiket Tersedia:', style: AppStyles.bodySmall.copyWith(fontWeight: FontWeight.w600, fontSize: 11)),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: widget.stateService.registrations.take(4).map((reg) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () {
                      _ticketController.text = reg.ticketCode;
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.purpleSurface,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.primaryPurpleLight.withValues(alpha: 0.3)),
                      ),
                      child: Text(
                        reg.ticketCode,
                        style: GoogleFonts.plusJakartaSans(
                          color: AppColors.primaryPurpleDark,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 16),

          // Input Field
          TextField(
            controller: _ticketController,
            decoration: AppStyles.inputDecoration(
              labelText: 'Masukkan Kode Tiket QR',
              hintText: 'Contoh: KU-EV-AI-01-1050',
              prefixIcon: const Icon(Icons.qr_code_2_rounded, color: AppColors.primaryPurple),
            ),
            onSubmitted: _processTicket,
          ),
          const SizedBox(height: 16),

          // Process Button
          Container(
            width: double.infinity,
            height: 52,
            decoration: BoxDecoration(
              gradient: AppColors.purpleGradient,
              borderRadius: BorderRadius.circular(14),
              boxShadow: const [BoxShadow(color: AppColors.purpleGlow, blurRadius: 14, offset: Offset(0, 5))],
            ),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, shadowColor: Colors.transparent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
              onPressed: _isScanning ? null : () => _processTicket(_ticketController.text),
              child: _isScanning
                  ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.check_circle_rounded, color: AppColors.sunYellow, size: 22),
                        const SizedBox(width: 10),
                        Text('Verifikasi Kehadiran', style: GoogleFonts.plusJakartaSans(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15)),
                      ],
                    ),
            ),
          ),

          const SizedBox(height: 20),
          const Divider(),
          const SizedBox(height: 14),

          // Visual QR Demo
          Row(
            children: [
              const Icon(Icons.info_outline_rounded, color: AppColors.info, size: 16),
              const SizedBox(width: 8),
              Expanded(child: Text('Tampilan QR Code Tiket Mahasiswa (contoh):', style: AppStyles.bodySmall.copyWith(fontWeight: FontWeight.w600))),
            ],
          ),
          const SizedBox(height: 14),
          if (widget.stateService.registrations.isNotEmpty)
            Center(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1E1B4B), Color(0xFF4C1D95)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                      child: QrImageView(
                        data: widget.stateService.registrations.first.ticketCode,
                        version: QrVersions.auto,
                        size: 140,
                        eyeStyle: const QrEyeStyle(eyeShape: QrEyeShape.square, color: AppColors.primaryPurpleDark),
                        dataModuleStyle: const QrDataModuleStyle(dataModuleShape: QrDataModuleShape.circle, color: AppColors.darkSidebar),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      widget.stateService.registrations.first.ticketCode,
                      style: GoogleFonts.plusJakartaSans(color: AppColors.sunYellow, fontWeight: FontWeight.w700, fontSize: 13, letterSpacing: 1),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildScanResultCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: AppStyles.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.assignment_turned_in_rounded, color: AppColors.primaryPurple, size: 22),
              const SizedBox(width: 10),
              Text('Hasil Verifikasi', style: AppStyles.bodyLarge.copyWith(fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 16),

          if (_lastScanResult == null)
            _buildEmptyScanState()
          else
            _buildScanResultDisplay(_lastScanResult!),
        ],
      ),
    );
  }

  Widget _buildEmptyScanState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40),
      decoration: BoxDecoration(
        color: AppColors.purpleSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primaryPurpleLight.withValues(alpha: 0.2), style: BorderStyle.solid),
      ),
      child: Column(
        children: [
          Icon(Icons.qr_code_scanner_rounded, size: 64, color: AppColors.primaryPurpleLight.withValues(alpha: 0.5)),
          const SizedBox(height: 12),
          Text('Siap Memindai', style: AppStyles.heading3.copyWith(color: AppColors.primaryPurpleLight)),
          const SizedBox(height: 6),
          Text('Masukkan kode tiket atau\npindai QR Code mahasiswa', textAlign: TextAlign.center, style: AppStyles.bodyMedium),
        ],
      ),
    );
  }

  Widget _buildScanResultDisplay(Map<String, dynamic> result) {
    final isSuccess = result['success'] == true;
    final isWarning = result['type'] == 'already_attended';

    Color mainColor = isSuccess ? AppColors.success : isWarning ? AppColors.warning : AppColors.danger;
    IconData mainIcon = isSuccess ? Icons.check_circle_rounded : isWarning ? Icons.warning_rounded : Icons.cancel_rounded;
    String statusTitle = isSuccess ? 'Verifikasi Berhasil!' : isWarning ? 'Sudah Check-In' : 'Tiket Tidak Valid';

    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: mainColor.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: mainColor.withValues(alpha: 0.3)),
          ),
          child: Column(
            children: [
              Icon(mainIcon, color: mainColor, size: 56),
              const SizedBox(height: 12),
              Text(statusTitle, style: AppStyles.heading3.copyWith(color: mainColor)),
              const SizedBox(height: 8),
              Text(result['message'] ?? '', style: AppStyles.bodyMedium.copyWith(height: 1.4), textAlign: TextAlign.center),
            ],
          ),
        ),

        if (isSuccess) ...[
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: AppColors.purpleSurface, borderRadius: BorderRadius.circular(14)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildResultDetail('Kode Tiket', result['ticketCode'] ?? '-'),
                const SizedBox(height: 8),
                _buildResultDetail('Acara', result['eventTitle'] ?? '-'),
                const SizedBox(height: 8),
                _buildResultDetail(
                  'Waktu Check-in',
                  result['time'] != null ? _formatTime(result['time'] as DateTime) : '-',
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildResultDetail(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(width: 110, child: Text(label, style: AppStyles.bodySmall.copyWith(fontWeight: FontWeight.w600))),
        Expanded(child: Text(': $value', style: AppStyles.bodySmall.copyWith(color: AppColors.primaryPurple, fontWeight: FontWeight.w700))),
      ],
    );
  }

  Widget _buildAttendanceList(BuildContext context, bool isMobile) {
    final attendedRegs = widget.stateService.registrations
        .where((r) => r.status == RegistrationStatus.attended)
        .toList();

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: AppStyles.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('📋 Daftar Hadir Live', style: AppStyles.heading3),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(gradient: AppColors.purpleGradient, borderRadius: BorderRadius.circular(20)),
                child: Text(
                  '${attendedRegs.length} hadir',
                  style: GoogleFonts.plusJakartaSans(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (attendedRegs.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Column(
                children: [
                  Icon(Icons.people_outline_rounded, size: 48, color: AppColors.textMuted.withValues(alpha: 0.5)),
                  const SizedBox(height: 8),
                  Text('Belum ada peserta yang check-in', style: AppStyles.bodyMedium),
                ],
              ),
            )
          else
            ...attendedRegs.map((reg) => _buildAttendanceTile(reg)),
        ],
      ),
    );
  }

  Widget _buildAttendanceTile(RegistrationModel reg) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.successLight.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.success.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: AppColors.success, borderRadius: BorderRadius.circular(10)),
            child: const Icon(Icons.check_rounded, color: Colors.white, size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(reg.ticketCode, style: AppStyles.bodyLarge.copyWith(fontWeight: FontWeight.w700, fontSize: 13)),
                if (reg.checkInTime != null)
                  Text('Check-in: ${_formatTime(reg.checkInTime!)}', style: AppStyles.bodySmall.copyWith(fontSize: 11)),
              ],
            ),
          ),
          const Icon(Icons.verified_rounded, color: AppColors.success, size: 20),
        ],
      ),
    );
  }

  String _formatTime(DateTime dt) {
    return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')} WIB';
  }
}
