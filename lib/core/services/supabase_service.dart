import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../constants/supabase_constants.dart';
import '../models/event_model.dart';
import '../models/feedback_model.dart';
import '../models/certificate_model.dart';

class SupabaseService {
  static SupabaseClient? get client {
    try {
      return Supabase.instance.client;
    } catch (_) {
      return null;
    }
  }

  static bool get isConnected => client != null;

  /// Inisialisasi koneksi client Supabase dengan publishableKey
  static Future<bool> initialize() async {
    try {
      await Supabase.initialize(
        url: SupabaseConstants.url,
        publishableKey: SupabaseConstants.publishableKey,
      );
      debugPrint('Supabase initialized successfully.');
      return true;
    } catch (e) {
      debugPrint('Supabase init notice: $e');
      return false;
    }
  }

  // ==========================================
  // AUTHENTICATION
  // ==========================================

  /// Pendaftaran akun mahasiswa baru via Supabase Auth
  static Future<AuthResponse?> signUp({
    required String email,
    required String password,
    required String fullName,
    required String nim,
    required String fakultas,
    required String prodi,
    required String angkatan,
    required String phoneNumber,
  }) async {
    final c = client;
    if (c == null) return null;

    try {
      return await c.auth.signUp(
        email: email,
        password: password,
        data: {
          'full_name': fullName,
          'nim': nim,
          'fakultas': fakultas,
          'prodi': prodi,
          'angkatan': angkatan,
          'phone_number': phoneNumber,
          'role': 'mahasiswa',
        },
      );
    } catch (e) {
      debugPrint('SignUp error: $e');
      rethrow;
    }
  }

  /// Login via Supabase Auth
  static Future<AuthResponse?> signIn({
    required String email,
    required String password,
  }) async {
    final c = client;
    if (c == null) return null;

    try {
      return await c.auth.signInWithPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      debugPrint('SignIn error: $e');
      rethrow;
    }
  }

  /// Logout dari Supabase
  static Future<void> signOut() async {
    final c = client;
    if (c == null) return;
    try {
      await c.auth.signOut();
    } catch (e) {
      debugPrint('SignOut error: $e');
    }
  }

  // ==========================================
  // EVENTS (KULIAH UMUM)
  // ==========================================

  /// Mengambil daftar kuliah umum dari Supabase
  static Future<List<EventModel>> fetchEvents() async {
    final c = client;
    if (c == null) return [];

    try {
      final res = await c
          .from('events')
          .select()
          .order('date_time', ascending: true);

      return (res as List).map((row) {
        final data = Map<String, dynamic>.from(row);
        return EventModel(
          id: data['id'] ?? '',
          title: data['title'] ?? '',
          description: data['description'] ?? '',
          speakerName: data['speaker_name'] ?? '',
          speakerTitle: data['speaker_title'] ?? '',
          speakerOrganization: data['speaker_organization'] ?? '',
          speakerAvatar: data['speaker_avatar'] ?? '',
          dateTime: DateTime.tryParse(data['date_time'] ?? '') ?? DateTime.now(),
          duration: data['duration'] ?? '2 Jam',
          location: data['location'] ?? 'Auditorium',
          eventType: _parseEventType(data['event_type']),
          quota: data['quota'] ?? 200,
          registeredCount: data['registered_count'] ?? 0,
          bannerGradientIndex: (data['banner_gradient_index'] ?? '0').toString(),
          materialsUrl: data['materials_url'] ?? '',
          status: _parseEventStatus(data['status']),
          category: data['category'] ?? 'Teknologi & AI',
        );
      }).toList();
    } catch (e) {
      debugPrint('Fetch events error: $e');
      return [];
    }
  }

  /// Membuat acara kuliah umum baru (Admin)
  static Future<bool> createEvent(EventModel event) async {
    final c = client;
    if (c == null) return false;

    try {
      await c.from('events').insert({
        'id': event.id,
        'title': event.title,
        'description': event.description,
        'speaker_name': event.speakerName,
        'speaker_title': event.speakerTitle,
        'speaker_organization': event.speakerOrganization,
        'speaker_avatar': event.speakerAvatar,
        'date_time': event.dateTime.toIso8601String(),
        'duration': event.duration,
        'location': event.location,
        'event_type': event.eventType.name,
        'quota': event.quota,
        'registered_count': 0,
        'banner_gradient_index': event.bannerGradientIndex,
        'materials_url': event.materialsUrl,
        'status': event.status.name,
        'category': event.category,
      });
      return true;
    } catch (e) {
      debugPrint('Create event error: $e');
      return false;
    }
  }

  // ==========================================
  // REGISTRATIONS & TIKET
  // ==========================================

  /// Mendaftarkan peserta ke acara kuliah umum
  static Future<bool> registerToEvent({
    required String registrationId,
    required String eventId,
    required String ticketCode,
  }) async {
    final c = client;
    if (c == null) return false;

    try {
      await c.from('registrations').insert({
        'id': registrationId,
        'event_id': eventId,
        'ticket_code': ticketCode,
        'status': 'registered',
      });
      return true;
    } catch (e) {
      debugPrint('Register to event error: $e');
      return false;
    }
  }

  // ==========================================
  // FEEDBACK & SERTIFIKAT
  // ==========================================

  /// Mengirim ulasan evaluasi kuesioner
  static Future<bool> submitFeedback(FeedbackModel feedback) async {
    final c = client;
    if (c == null) return false;

    try {
      await c.from('feedbacks').insert({
        'id': feedback.id,
        'event_id': feedback.eventId,
        'rating_speaker': feedback.ratingSpeaker,
        'rating_material': feedback.ratingMaterial,
        'rating_facilities': feedback.ratingFacilities,
        'comments': feedback.comments,
        'submitted_at': feedback.submittedAt.toIso8601String(),
      });
      return true;
    } catch (e) {
      debugPrint('Submit feedback error: $e');
      return false;
    }
  }

  /// Menerbitkan sertifikat ke Supabase
  static Future<bool> saveCertificate(CertificateModel cert) async {
    final c = client;
    if (c == null) return false;

    try {
      await c.from('certificates').insert({
        'id': cert.id,
        'registration_id': cert.registrationId,
        'event_id': cert.eventId,
        'certificate_number': cert.certificateNumber,
        'student_name': cert.studentName,
        'student_nim': cert.studentNim,
        'event_title': cert.eventTitle,
        'speaker_name': cert.speakerName,
        'event_date': cert.eventDate.toIso8601String(),
        'issued_at': cert.issuedAt.toIso8601String(),
      });
      return true;
    } catch (e) {
      debugPrint('Save certificate error: $e');
      return false;
    }
  }

  // Helper parsing
  static EventType _parseEventType(dynamic type) {
    if (type == 'online') return EventType.online;
    if (type == 'hybrid') return EventType.hybrid;
    return EventType.offline;
  }

  static EventStatus _parseEventStatus(dynamic status) {
    if (status == 'ongoing') return EventStatus.ongoing;
    if (status == 'completed') return EventStatus.completed;
    if (status == 'cancelled') return EventStatus.cancelled;
    return EventStatus.upcoming;
  }
}
