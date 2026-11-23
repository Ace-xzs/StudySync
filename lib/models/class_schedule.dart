class ClassSchedule {
  const ClassSchedule({
    required this.id,
    required this.ownerId,
    required this.subjectId,
    required this.dayOfWeek,
    required this.startMinutes,
    required this.endMinutes,
    required this.classroom,
  });

  final String id;
  final String ownerId;
  final String subjectId;
  final int dayOfWeek;
  final int startMinutes;
  final int endMinutes;
  final String classroom;

  Map<String, Object?> toJson() => {
    'id': id,
    'ownerId': ownerId,
    'subjectId': subjectId,
    'dayOfWeek': dayOfWeek,
    'startMinutes': startMinutes,
    'endMinutes': endMinutes,
    'classroom': classroom,
  };

  factory ClassSchedule.fromJson(Map<String, dynamic> json) {
    return ClassSchedule(
      id: json['id'] as String,
      ownerId: json['ownerId'] as String,
      subjectId: json['subjectId'] as String,
      dayOfWeek: json['dayOfWeek'] as int,
      startMinutes: json['startMinutes'] as int,
      endMinutes: json['endMinutes'] as int,
      classroom: json['classroom'] as String,
    );
  }

  ClassSchedule copyWith({
    String? subjectId,
    int? dayOfWeek,
    int? startMinutes,
    int? endMinutes,
    String? classroom,
  }) {
    return ClassSchedule(
      id: id,
      ownerId: ownerId,
      subjectId: subjectId ?? this.subjectId,
      dayOfWeek: dayOfWeek ?? this.dayOfWeek,
      startMinutes: startMinutes ?? this.startMinutes,
      endMinutes: endMinutes ?? this.endMinutes,
      classroom: classroom ?? this.classroom,
    );
  }
}
