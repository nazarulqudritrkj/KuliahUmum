import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../models/event_model.dart';
import '../models/registration_model.dart';
import '../models/feedback_model.dart';
import '../models/certificate_model.dart';
import 'supabase_service.dart';

class AppStateService extends ChangeNotifier {
  // Current logged in user
  UserModel? _currentUser;
  bool _isAuthenticated = true; // Auto-login with mock user for demo readiness

  // Master Data Lists
  List<EventModel> _events = [];
  List<RegistrationModel> _registrations = [];
  List<CertificateModel> _certificates = [];
  final List<FeedbackModel> _feedbacks = [];

  // Filter & Search State
  String _searchQuery = '';
  String _selectedCategory = 'Semua';
  String _selectedStatusFilter = 'Semua';

  AppStateService() {
    _initMockData();
    syncFromSupabase();
  }

  /// Sinkronisasi event langsung dari database cloud Supabase
  Future<void> syncFromSupabase() async {
    try {
      final cloudEvents = await SupabaseService.fetchEvents();
      if (cloudEvents.isNotEmpty) {
        _events = cloudEvents;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Cloud sync note: $e');
    }
  }

  // Getters
  UserModel? get currentUser => _currentUser;
  bool get isAuthenticated => _isAuthenticated;
  bool get isAdmin => _currentUser?.role == UserRole.admin;
  List<EventModel> get events => _events;
  List<RegistrationModel> get registrations => _registrations;
  List<CertificateModel> get certificates => _certificates;
  List<FeedbackModel> get feedbacks => _feedbacks;
  String get searchQuery => _searchQuery;
  String get selectedCategory => _selectedCategory;
  String get selectedStatusFilter => _selectedStatusFilter;

  // Filtered Events
  List<EventModel> get filteredEvents {
    return _events.where((event) {
      final matchesSearch = event.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          event.speakerName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          event.speakerOrganization.toLowerCase().contains(_searchQuery.toLowerCase());

      final matchesCategory = _selectedCategory == 'Semua' || event.category == _selectedCategory;

      bool matchesStatus = true;
      if (_selectedStatusFilter == 'Tersedia') {
        matchesStatus = !event.isFull && event.status == EventStatus.upcoming;
      } else if (_selectedStatusFilter == 'Penuh') {
        matchesStatus = event.isFull;
      } else if (_selectedStatusFilter == 'Selesai') {
        matchesStatus = event.status == EventStatus.completed;
      }

      return matchesSearch && matchesCategory && matchesStatus;
    }).toList();
  }

  // User's Registered Events with Details
  List<Map<String, dynamic>> get myRegisteredEventDetails {
    if (_currentUser == null) return [];
    final userRegs = _registrations.where((r) => r.userId == _currentUser!.id).toList();

    return userRegs.map((reg) {
      final event = _events.firstWhere(
        (e) => e.id == reg.eventId,
        orElse: () => EventModel(
          id: 'unknown',
          title: 'Kuliah Umum',
          description: '',
          speakerName: '',
          speakerTitle: '',
          speakerOrganization: '',
          dateTime: DateTime.now(),
          duration: '2 Jam',
          location: 'Auditorium',
          eventType: EventType.offline,
          quota: 100,
          registeredCount: 0,
        ),
      );
      return {
        'registration': reg,
        'event': event,
      };
    }).toList();
  }

  // Stats for Student Dashboard
  int get totalEventsAttended => _registrations
      .where((r) => r.userId == _currentUser?.id && r.status == RegistrationStatus.attended)
      .length;

  int get totalCertificatesEarned => _certificates
      .where((c) => c.userId == _currentUser?.id)
      .length;

  int get totalUpcomingRegistered => _registrations
      .where((r) => r.userId == _currentUser?.id && r.status == RegistrationStatus.registered)
      .length;

  // Stats for Admin Dashboard
  int get totalRegisteredStudents => 1248;
  int get totalLecturesHeld => _events.length;
  int get totalActiveRegistrations => _registrations.length;
  double get averageAttendanceRate => 92.4;

  // --- ACTIONS ---

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setSelectedCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void setSelectedStatusFilter(String filter) {
    _selectedStatusFilter = filter;
    notifyListeners();
  }

  // Switch between student and admin quickly for demo
  void toggleRole() {
    if (_currentUser == null) return;
    final newRole = _currentUser!.role == UserRole.mahasiswa ? UserRole.admin : UserRole.mahasiswa;
    _currentUser = _currentUser!.copyWith(
      role: newRole,
      fullName: newRole == UserRole.admin ? 'Dr. Hendra Gunawan, M.T. (Admin)' : 'Muhammad Farhan Syahputra',
    );
    notifyListeners();
  }

  // Authentication: Login
  bool login(String identifier, String password, {UserRole role = UserRole.mahasiswa}) {
    if (role == UserRole.admin) {
      _currentUser = const UserModel(
        id: 'user_admin_1',
        nim: 'ADM-9901',
        fullName: 'Dr. Hendra Gunawan, M.T. (Panitia)',
        email: 'hendra.gunawan@kampus.ac.id',
        fakultas: 'Biro Kemahasiswaan & Alumni',
        prodi: 'Pusat Karir & Kuliah Umum',
        angkatan: 'Staff',
        phoneNumber: '081298765432',
        role: UserRole.admin,
        avatarUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150',
      );
    } else {
      _currentUser = const UserModel(
        id: 'user_mhs_1',
        nim: '220401050',
        fullName: 'Muhammad Farhan Syahputra',
        email: 'farhan.syah@student.kampus.ac.id',
        fakultas: 'Ilmu Komputer & TI',
        prodi: 'Teknik Informatika',
        angkatan: '2022',
        phoneNumber: '082167891234',
        role: UserRole.mahasiswa,
        avatarUrl: 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=150',
      );
    }
    _isAuthenticated = true;
    notifyListeners();
    return true;
  }

  // Authentication: Register
  bool register({
    required String nim,
    required String fullName,
    required String email,
    required String fakultas,
    required String prodi,
    required String angkatan,
    required String phoneNumber,
    required String password,
  }) {
    _currentUser = UserModel(
      id: 'user_${DateTime.now().millisecondsSinceEpoch}',
      nim: nim,
      fullName: fullName,
      email: email,
      fakultas: fakultas,
      prodi: prodi,
      angkatan: angkatan,
      phoneNumber: phoneNumber,
      role: UserRole.mahasiswa,
    );
    _isAuthenticated = true;
    notifyListeners();
    return true;
  }

  void logout() {
    _isAuthenticated = false;
    _currentUser = null;
    notifyListeners();
  }

  // Event Registration
  Map<String, dynamic> registerForEvent(String eventId) {
    if (_currentUser == null) {
      return {'success': false, 'message': 'Silakan login terlebih dahulu!'};
    }

    final eventIndex = _events.indexWhere((e) => e.id == eventId);
    if (eventIndex == -1) {
      return {'success': false, 'message': 'Kuliah umum tidak ditemukan.'};
    }

    final event = _events[eventIndex];
    if (event.isFull) {
      return {'success': false, 'message': 'Mohon maaf, kuota peserta sudah penuh!'};
    }

    final isAlreadyRegistered = _registrations.any(
      (r) => r.userId == _currentUser!.id && r.eventId == eventId && r.status != RegistrationStatus.cancelled,
    );

    if (isAlreadyRegistered) {
      return {'success': false, 'message': 'Anda sudah terdaftar pada kuliah umum ini.'};
    }

    // Generate unique ticket code
    final ticketCode = 'KU-${event.id.toUpperCase()}-${_currentUser!.nim.substring(_currentUser!.nim.length > 4 ? _currentUser!.nim.length - 4 : 0)}';

    final newReg = RegistrationModel(
      id: 'reg_${DateTime.now().millisecondsSinceEpoch}',
      userId: _currentUser!.id,
      eventId: eventId,
      ticketCode: ticketCode,
      registeredAt: DateTime.now(),
      status: RegistrationStatus.registered,
    );

    _registrations.insert(0, newReg);

    _events[eventIndex] = event.copyWith(
      registeredCount: event.registeredCount + 1,
    );

    // Sync to Supabase
    SupabaseService.registerToEvent(
      registrationId: newReg.id,
      eventId: eventId,
      ticketCode: ticketCode,
    );

    notifyListeners();
    return {
      'success': true,
      'message': 'Pendaftaran berhasil! Tiket QR digital Anda telah diterbitkan.',
      'ticketCode': ticketCode,
    };
  }

  // Cancel Registration
  bool cancelRegistration(String registrationId) {
    final regIndex = _registrations.indexWhere((r) => r.id == registrationId);
    if (regIndex == -1) return false;

    final reg = _registrations[regIndex];
    final eventIndex = _events.indexWhere((e) => e.id == reg.eventId);

    if (eventIndex != -1) {
      final event = _events[eventIndex];
      _events[eventIndex] = event.copyWith(
        registeredCount: (event.registeredCount - 1).clamp(0, event.quota),
      );
    }

    _registrations.removeAt(regIndex);
    notifyListeners();
    return true;
  }

  // Check-in via QR Scanner (Admin or System)
  Map<String, dynamic> checkInTicket(String scannedCode) {
    final cleanCode = scannedCode.trim().toUpperCase();
    final regIndex = _registrations.indexWhere(
      (r) => r.ticketCode.toUpperCase() == cleanCode,
    );

    if (regIndex == -1) {
      return {
        'success': false,
        'type': 'not_found',
        'message': 'Tiket tidak valid atau tidak ditemukan dalam database sistem.',
      };
    }

    final reg = _registrations[regIndex];
    if (reg.status == RegistrationStatus.attended) {
      return {
        'success': false,
        'type': 'already_attended',
        'message': 'Peserta ini SUDAH CHECK-IN sebelumnya pada pukul ${reg.checkInTime?.hour.toString().padLeft(2, '0')}:${reg.checkInTime?.minute.toString().padLeft(2, '0')} WIB.',
        'registration': reg,
      };
    }

    final now = DateTime.now();
    _registrations[regIndex] = reg.copyWith(
      status: RegistrationStatus.attended,
      checkInTime: now,
    );

    final event = _events.firstWhere((e) => e.id == reg.eventId);

    notifyListeners();
    return {
      'success': true,
      'type': 'success',
      'message': 'Presensi Berhasil! Mahasiswa telah diverifikasi hadir.',
      'ticketCode': reg.ticketCode,
      'eventTitle': event.title,
      'time': now,
    };
  }

  // Submit Feedback & Auto Generate Certificate
  Map<String, dynamic> submitFeedback({
    required String registrationId,
    required String eventId,
    required double ratingSpeaker,
    required double ratingMaterial,
    required double ratingFacilities,
    required String comments,
  }) {
    if (_currentUser == null) return {'success': false, 'message': 'User belum login.'};

    final regIndex = _registrations.indexWhere((r) => r.id == registrationId);
    if (regIndex == -1) return {'success': false, 'message': 'Data registrasi tidak ditemukan.'};

    final reg = _registrations[regIndex];
    final event = _events.firstWhere((e) => e.id == eventId);

    // Save feedback
    final feedback = FeedbackModel(
      id: 'fb_${DateTime.now().millisecondsSinceEpoch}',
      eventId: eventId,
      userId: _currentUser!.id,
      ratingSpeaker: ratingSpeaker,
      ratingMaterial: ratingMaterial,
      ratingFacilities: ratingFacilities,
      comments: comments,
      submittedAt: DateTime.now(),
    );
    _feedbacks.add(feedback);

    // Auto issue Certificate
    final certNumber = 'CERT/KU/${DateTime.now().year}/${event.id.toUpperCase()}/${_currentUser!.nim}';
    final certificate = CertificateModel(
      id: 'cert_${DateTime.now().millisecondsSinceEpoch}',
      registrationId: registrationId,
      eventId: eventId,
      userId: _currentUser!.id,
      certificateNumber: certNumber,
      studentName: _currentUser!.fullName,
      studentNim: _currentUser!.nim,
      eventTitle: event.title,
      speakerName: event.speakerName,
      eventDate: event.dateTime,
      issuedAt: DateTime.now(),
    );
    _certificates.insert(0, certificate);

    // Update registration state
    _registrations[regIndex] = reg.copyWith(
      isFeedbackSubmitted: true,
      isCertificateClaimed: true,
    );

    // Sync to Supabase
    SupabaseService.submitFeedback(feedback);
    SupabaseService.saveCertificate(certificate);

    notifyListeners();
    return {
      'success': true,
      'message': 'Evaluasi tersimpan dan E-Sertifikat resmi Anda telah berhasil diterbitkan!',
      'certificate': certificate,
    };
  }

  // Admin: Create Event
  void addEvent(EventModel newEvent) {
    _events.insert(0, newEvent);
    SupabaseService.createEvent(newEvent);
    notifyListeners();
  }

  // Admin: Delete Event
  void deleteEvent(String eventId) {
    _events.removeWhere((e) => e.id == eventId);
    _registrations.removeWhere((r) => r.eventId == eventId);
    notifyListeners();
  }

  // --- INITIAL MOCK DATA ---
  void _initMockData() {
    _currentUser = const UserModel(
      id: 'user_mhs_1',
      nim: '220401050',
      fullName: 'Muhammad Farhan Syahputra',
      email: 'farhan.syah@student.kampus.ac.id',
      fakultas: 'Ilmu Komputer & Teknologi Informasi',
      prodi: 'Teknik Informatika',
      angkatan: '2022',
      phoneNumber: '082167891234',
      role: UserRole.mahasiswa,
      avatarUrl: 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=150',
    );

    _events = [
      EventModel(
        id: 'ev-ai-01',
        title: 'Transformasi Generative AI & Masa Depan Talenta Digital 2026',
        description: 'Membahas perkembangan mutakhir Artificial Intelligence, implementasi Agentic Workflow di industri global, serta kesiapan mahasiswa dalam menghadapi era otomasi cerdas.',
        speakerName: 'Dr. Gita Wirjawan, M.B.A.',
        speakerTitle: 'Educator, Founder & Former Minister',
        speakerOrganization: 'Endeavor Indonesia & Ancora Group',
        speakerAvatar: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150',
        dateTime: DateTime.now().add(const Duration(days: 3, hours: 2)),
        duration: '2.5 Jam (09.00 - 11.30 WIB)',
        location: 'Auditorium Utama Lantai 3 / Zoom Hybrid',
        eventType: EventType.hybrid,
        quota: 350,
        registeredCount: 312,
        bannerGradientIndex: '0',
        category: 'Teknologi & AI',
        status: EventStatus.upcoming,
      ),
      EventModel(
        id: 'ev-cyber-02',
        title: 'Kedaulatan Data & Strategi Pertahanan Cybersecurity Modern',
        description: 'Menganalisis arsitektur pertahanan siber Zero-Trust, regulasi perlindungan data pribadi nasional (UU PDP), dan teknik mitigasi serangan ransomware perusahaan.',
        speakerName: 'Pratama Persadha, Ph.D.',
        speakerTitle: 'Chairman Lembaga Riset CISSReC',
        speakerOrganization: 'Cyber Security Research Center',
        speakerAvatar: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=150',
        dateTime: DateTime.now().add(const Duration(days: 7, hours: 5)),
        duration: '2 Jam (13.30 - 15.30 WIB)',
        location: 'Gedung Serbaguna Kampus A',
        eventType: EventType.offline,
        quota: 250,
        registeredCount: 250,
        bannerGradientIndex: '1',
        category: 'Cybersecurity',
        status: EventStatus.upcoming,
      ),
      EventModel(
        id: 'ev-startup-03',
        title: 'Building Scalable Fintech: From MVP to Sustainable Profitability',
        description: 'Strategi membangun produk finansial teknologi yang adaptif, kepatuhan regulasi OJK & BI, serta manajemen risiko likuiditas bagi pendiri startup muda.',
        speakerName: 'Nadia Amalia, CFA',
        speakerTitle: 'Co-Founder & CEO Sribuu',
        speakerOrganization: 'Forbes 30 Under 30 Asia',
        speakerAvatar: 'https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?w=150',
        dateTime: DateTime.now().add(const Duration(days: 12, hours: 1)),
        duration: '2 Jam (10.00 - 12.00 WIB)',
        location: 'Live Zoom Meeting & YouTube Live',
        eventType: EventType.online,
        quota: 500,
        registeredCount: 180,
        bannerGradientIndex: '2',
        category: 'Kewirausahaan',
        status: EventStatus.upcoming,
      ),
      EventModel(
        id: 'ev-green-04',
        title: 'Green Economy & Transisi Energi Berkelanjutan di Indonesia',
        description: 'Peluang karier dan inovasi teknologi ramah lingkungan (Renewable Energy) dalam mendukung komitmen Net Zero Emission 2060.',
        speakerName: 'Prof. Emil Salim, Ph.D.',
        speakerTitle: 'Guru Besar Ekonomi Lingkungan',
        speakerOrganization: 'Dewan Riset Nasional',
        speakerAvatar: 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=150',
        dateTime: DateTime.now().subtract(const Duration(days: 5)),
        duration: '2 Jam (09.00 - 11.00 WIB)',
        location: 'Balai Sidang Akademik',
        eventType: EventType.offline,
        quota: 300,
        registeredCount: 290,
        bannerGradientIndex: '3',
        category: 'Ekonomi & Sosial',
        status: EventStatus.completed,
      ),
    ];

    // Seed registrations
    _registrations = [
      RegistrationModel(
        id: 'reg_demo_1',
        userId: 'user_mhs_1',
        eventId: 'ev-ai-01',
        ticketCode: 'KU-EV-AI-01-1050',
        registeredAt: DateTime.now().subtract(const Duration(days: 2)),
        status: RegistrationStatus.registered,
      ),
      RegistrationModel(
        id: 'reg_demo_2',
        userId: 'user_mhs_1',
        eventId: 'ev-green-04',
        ticketCode: 'KU-EV-GREEN-04-1050',
        registeredAt: DateTime.now().subtract(const Duration(days: 6)),
        status: RegistrationStatus.attended,
        checkInTime: DateTime.now().subtract(const Duration(days: 5, hours: 2)),
        isFeedbackSubmitted: true,
        isCertificateClaimed: true,
      ),
    ];

    // Seed certificates
    _certificates = [
      CertificateModel(
        id: 'cert_demo_1',
        registrationId: 'reg_demo_2',
        eventId: 'ev-green-04',
        userId: 'user_mhs_1',
        certificateNumber: 'CERT/KU/2026/EV-GREEN-04/220401050',
        studentName: 'Muhammad Farhan Syahputra',
        studentNim: '220401050',
        eventTitle: 'Green Economy & Transisi Energi Berkelanjutan di Indonesia',
        speakerName: 'Prof. Emil Salim, Ph.D.',
        eventDate: DateTime.now().subtract(const Duration(days: 5)),
        issuedAt: DateTime.now().subtract(const Duration(days: 4)),
      ),
    ];
  }
}
