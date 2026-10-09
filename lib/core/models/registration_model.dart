enum RegistrationStatus { registered, attended, absent, cancelled }

class RegistrationModel {
  final String id;
  final String userId;
  final String eventId;
  final String ticketCode;
  final DateTime registeredAt;
  final RegistrationStatus status;
  final DateTime? checkInTime;
  final DateTime? checkOutTime;
  final bool isFeedbackSubmitted;
  final bool isCertificateClaimed;

  const RegistrationModel({
    required this.id,
    required this.userId,
    required this.eventId,
    required this.ticketCode,
    required this.registeredAt,
    this.status = RegistrationStatus.registered,
    this.checkInTime,
    this.checkOutTime,
    this.isFeedbackSubmitted = false,
    this.isCertificateClaimed = false,
  });

  RegistrationModel copyWith({
    String? id,
    String? userId,
    String? eventId,
    String? ticketCode,
    DateTime? registeredAt,
    RegistrationStatus? status,
    DateTime? checkInTime,
    DateTime? checkOutTime,
    bool? isFeedbackSubmitted,
    bool? isCertificateClaimed,
  }) {
    return RegistrationModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      eventId: eventId ?? this.eventId,
      ticketCode: ticketCode ?? this.ticketCode,
      registeredAt: registeredAt ?? this.registeredAt,
      status: status ?? this.status,
      checkInTime: checkInTime ?? this.checkInTime,
      checkOutTime: checkOutTime ?? this.checkOutTime,
      isFeedbackSubmitted: isFeedbackSubmitted ?? this.isFeedbackSubmitted,
      isCertificateClaimed: isCertificateClaimed ?? this.isCertificateClaimed,
    );
  }
}
