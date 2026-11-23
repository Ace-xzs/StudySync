class Subject {
  const Subject({required this.id, required this.ownerId, required this.name});

  final String id;
  final String ownerId;
  final String name;

  Map<String, Object?> toJson() => {'id': id, 'ownerId': ownerId, 'name': name};

  factory Subject.fromJson(Map<String, dynamic> json) {
    return Subject(
      id: json['id'] as String,
      ownerId: json['ownerId'] as String,
      name: json['name'] as String,
    );
  }

  Subject copyWith({String? name}) {
    return Subject(id: id, ownerId: ownerId, name: name ?? this.name);
  }
}
