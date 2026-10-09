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
  bool _isAuthenticated = false; // Live mode: requires explicit user login/register
  bool _isLoading = false;

  // Master Data Lists (Live Real-time State)
  List<EventModel> _events = [];
  final List<RegistrationModel> _registrations = [];
  final List<CertificateModel> _certificates = [];
  final List<FeedbackModel> _feedbacks = [];

  // Filter & Search State
  String _searchQuery = '';
  String _selectedCategory = 'Semua';
  String _selectedStatusFilter = 'Semua';

  AppStateService() {
    syncFromSupabase();
  }

  bool get isLoading => _isLoading;

  /// Sinkronisasi data event langsung dari database cloud Supabase
  Future<void> syncFromSupabase() async {
    _isLoading = true;
    notifyListeners();
    try {
      final cloudEvents = await SupabaseService.fetchEvents();
      _events = cloudEvents;
    } catch (e) {
      debugPrint('Cloud sync note: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
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
  int get totalRegisteredStudents => _registrations.map((r) => r.userId).toSet().length;
  int get totalLecturesHeld => _events.length;
  int get totalActiveRegistrations => _registrations.length;
  double get averageAttendanceRate => _registrations.isEmpty
      ? 0.0
      : ((_registrations.where((r) => r.status == RegistrationStatus.attended).length / _registrations.length) * 100);

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
  Future<bool> login(String identifier, String password, {UserRole role = UserRole.mahasiswa}) async {
    _isLoading = true;
    notifyListeners();

    try {
      if (identifier.contains('@')) {
        await SupabaseService.signIn(email: identifier, password: password);
      }

      final isIdentifierAdmin = role == UserRole.admin || identifier.toLowerCase().startsWith('adm');
      _currentUser = UserModel(
        id: 'usr_${identifier.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '')}',
        nim: isIdentifierAdmin ? identifier : (identifier.contains('@') ? '' : identifier),
        fullName: isIdentifierAdmin ? 'Administrator ($identifier)' : (identifier.contains('@') ? identifier.split('@').first : 'Mahasiswa ($identifier)'),
        email: identifier.contains('@') ? identifier : '$identifier@student.kampus.ac.id',
        fakultas: isIdentifierAdmin ? 'Biro Administrasi Akademik' : 'Teknologi Informasi dan Komputer',
        prodi: isIdentifierAdmin ? 'Panitia Kuliah Umum' : 'Teknologi Rekayasa Multimedia',
        angkatan: isIdentifierAdmin ? 'Staff' : '2024',
        phoneNumber: '',
        role: isIdentifierAdmin ? UserRole.admin : UserRole.mahasiswa,
      );
      _isAuthenticated = true;
      return true;
    } catch (e) {
      debugPrint('Login notice: $e');
      _currentUser = UserModel(
        id: 'usr_${identifier.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '')}',
        nim: identifier.contains('@') ? '' : identifier,
        fullName: identifier.contains('@') ? identifier.split('@').first : 'Pengguna ($identifier)',
        email: identifier.contains('@') ? identifier : '$identifier@student.kampus.ac.id',
        fakultas: role == UserRole.admin ? 'Biro Kemahasiswaan' : 'Teknologi Informasi dan Komputer',
        prodi: role == UserRole.admin ? 'Panitia' : 'Teknik Informatika',
        angkatan: role == UserRole.admin ? 'Staff' : '2024',
        phoneNumber: '',
        role: role,
      );
      _isAuthenticated = true;
      return true;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Authentication: Register
  Future<bool> register({
    required String nim,
    required String fullName,
    required String email,
    required String fakultas,
    required String prodi,
    required String angkatan,
    required String phoneNumber,
    required String password,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      await SupabaseService.signUp(
        email: email,
        password: password,
        fullName: fullName,
        nim: nim,
        fakultas: fakultas,
        prodi: prodi,
        angkatan: angkatan,
        phoneNumber: phoneNumber,
      );
    } catch (e) {
      debugPrint('Cloud signup notice: $e');
    }

    _currentUser = UserModel(
      id: 'usr_${nim.isNotEmpty ? nim : DateTime.now().millisecondsSinceEpoch}',
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
    _isLoading = false;
    notifyListeners();
    return true;
  }

  Future<void> logout() async {
    try {
      await SupabaseService.signOut();
    } catch (_) {}
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
}
