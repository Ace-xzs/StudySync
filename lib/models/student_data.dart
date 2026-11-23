import 'assignment.dart';
import 'class_schedule.dart';
import 'subject.dart';

class StudentData {
  StudentData({
    required this.ownerId,
    List<Assignment> tasks = const [],
    List<Subject> subjects = const [],
    List<ClassSchedule> schedules = const [],
  }) : tasks = List.unmodifiable(tasks),
       subjects = List.unmodifiable(subjects),
       schedules = List.unmodifiable(schedules);

  final String ownerId;
  final List<Assignment> tasks;
  final List<Subject> subjects;
  final List<ClassSchedule> schedules;

  StudentData copyWith({
    List<Assignment>? tasks,
    List<Subject>? subjects,
    List<ClassSchedule>? schedules,
  }) {
    return StudentData(
      ownerId: ownerId,
      tasks: tasks ?? this.tasks,
      subjects: subjects ?? this.subjects,
      schedules: schedules ?? this.schedules,
    );
  }

  Map<String, Object?> toJson() => {
    'ownerId': ownerId,
    'tasks': tasks.map((item) => item.toJson()).toList(),
    'subjects': subjects.map((item) => item.toJson()).toList(),
    'schedules': schedules.map((item) => item.toJson()).toList(),
  };

  factory StudentData.fromJson(Map<String, dynamic> json) {
    return StudentData(
      ownerId: json['ownerId'] as String,
      tasks: (json['tasks'] as List<dynamic>)
          .map(
            (item) =>
                Assignment.fromJson(Map<String, dynamic>.from(item as Map)),
          )
          .toList(),
      subjects: (json['subjects'] as List<dynamic>)
          .map(
            (item) => Subject.fromJson(Map<String, dynamic>.from(item as Map)),
          )
          .toList(),
      schedules: (json['schedules'] as List<dynamic>)
          .map(
            (item) =>
                ClassSchedule.fromJson(Map<String, dynamic>.from(item as Map)),
          )
          .toList(),
    );
  }
}
