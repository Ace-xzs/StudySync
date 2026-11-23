class StudentProfile {
  const StudentProfile({required this.id, required this.name});

  final String id;
  final String name;

  Map<String, Object?> toJson() => {'id': id, 'name': name};

  factory StudentProfile.fromJson(Map<String, dynamic> json) {
    return StudentProfile(
      id: json['id'] as String,
      name: json['name'] as String,
    );
  }

  StudentProfile copyWith({String? name}) {
    return StudentProfile(id: id, name: name ?? this.name);
  }
}
