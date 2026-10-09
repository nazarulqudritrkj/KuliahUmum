enum EventStatus { upcoming, ongoing, completed, cancelled }
enum EventType { hybrid, offline, online }

class EventModel {
  final String id;
  final String title;
  final String description;
  final String speakerName;
  final String speakerTitle;
  final String speakerOrganization;
  final String speakerAvatar;
  final DateTime dateTime;
  final String duration;
  final String location;
  final EventType eventType;
  final int quota;
  final int registeredCount;
  final String bannerGradientIndex;
  final String materialsUrl;
  final EventStatus status;
  final String category;

  const EventModel({
    required this.id,
    required this.title,
    required this.description,
    required this.speakerName,
    required this.speakerTitle,
    required this.speakerOrganization,
    this.speakerAvatar = '',
    required this.dateTime,
    required this.duration,
    required this.location,
    required this.eventType,
    required this.quota,
    required this.registeredCount,
    this.bannerGradientIndex = '0',
    this.materialsUrl = '',
    this.status = EventStatus.upcoming,
    this.category = 'Teknologi & AI',
  });

  bool get isFull => registeredCount >= quota;
  int get remainingQuota => (quota - registeredCount).clamp(0, quota);
  double get quotaFillPercentage => quota > 0 ? (registeredCount / quota).clamp(0.0, 1.0) : 0.0;

  EventModel copyWith({
    String? id,
    String? title,
    String? description,
    String? speakerName,
    String? speakerTitle,
    String? speakerOrganization,
    String? speakerAvatar,
    DateTime? dateTime,
    String? duration,
    String? location,
    EventType? eventType,
    int? quota,
    int? registeredCount,
    String? bannerGradientIndex,
    String? materialsUrl,
    EventStatus? status,
    String? category,
  }) {
    return EventModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      speakerName: speakerName ?? this.speakerName,
      speakerTitle: speakerTitle ?? this.speakerTitle,
      speakerOrganization: speakerOrganization ?? this.speakerOrganization,
      speakerAvatar: speakerAvatar ?? this.speakerAvatar,
      dateTime: dateTime ?? this.dateTime,
      duration: duration ?? this.duration,
      location: location ?? this.location,
      eventType: eventType ?? this.eventType,
      quota: quota ?? this.quota,
      registeredCount: registeredCount ?? this.registeredCount,
      bannerGradientIndex: bannerGradientIndex ?? this.bannerGradientIndex,
      materialsUrl: materialsUrl ?? this.materialsUrl,
      status: status ?? this.status,
      category: category ?? this.category,
    );
  }
}
