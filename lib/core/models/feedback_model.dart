class FeedbackModel {
  final String id;
  final String eventId;
  final String userId;
  final double ratingSpeaker;
  final double ratingMaterial;
  final double ratingFacilities;
  final String comments;
  final DateTime submittedAt;

  const FeedbackModel({
    required this.id,
    required this.eventId,
    required this.userId,
    required this.ratingSpeaker,
    required this.ratingMaterial,
    required this.ratingFacilities,
    required this.comments,
    required this.submittedAt,
  });

  double get averageRating => (ratingSpeaker + ratingMaterial + ratingFacilities) / 3.0;
}
