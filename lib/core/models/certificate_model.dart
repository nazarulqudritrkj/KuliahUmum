class CertificateModel {
  final String id;
  final String registrationId;
  final String eventId;
  final String userId;
  final String certificateNumber;
  final String studentName;
  final String studentNim;
  final String eventTitle;
  final String speakerName;
  final DateTime eventDate;
  final DateTime issuedAt;

  const CertificateModel({
    required this.id,
    required this.registrationId,
    required this.eventId,
    required this.userId,
    required this.certificateNumber,
    required this.studentName,
    required this.studentNim,
    required this.eventTitle,
    required this.speakerName,
    required this.eventDate,
    required this.issuedAt,
  });
}
