import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:studysync/models/assignment.dart';
import 'package:studysync/models/student_data.dart';
import 'package:studysync/services/local_study_repository.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('keeps saved data separate between local student profiles', () async {
    final repository = LocalStudyRepository();
    final firstProfile = await repository.createProfile('Alex');
    final secondProfile = await repository.createProfile('Sam');

    await repository.saveStudentData(
      StudentData(
        ownerId: firstProfile.id,
        tasks: [
          Assignment(
            id: 'first-task',
            ownerId: firstProfile.id,
            title: 'Alex task',
            description: '',
            dueDate: DateTime(2026, 12, 1),
            priority: TaskPriority.high,
          ),
        ],
      ),
    );
    await repository.saveStudentData(
      StudentData(
        ownerId: secondProfile.id,
        tasks: [
          Assignment(
            id: 'second-task',
            ownerId: secondProfile.id,
            title: 'Sam task',
            description: '',
            dueDate: DateTime(2026, 12, 2),
            priority: TaskPriority.low,
          ),
        ],
      ),
    );

    final alexData = await LocalStudyRepository().loadStudentData(
      firstProfile.id,
    );
    final samData = await LocalStudyRepository().loadStudentData(
      secondProfile.id,
    );

    expect(alexData.tasks.single.title, 'Alex task');
    expect(samData.tasks.single.title, 'Sam task');
    expect(alexData.tasks.single.ownerId, firstProfile.id);
    expect(samData.tasks.single.ownerId, secondProfile.id);
  });

  test('rejects saving records owned by a different profile', () async {
    final repository = LocalStudyRepository();
    final profile = await repository.createProfile('Alex');

    expect(
      () => repository.saveStudentData(
        StudentData(
          ownerId: profile.id,
          tasks: [
            Assignment(
              id: 'foreign-task',
              ownerId: 'another-profile',
              title: 'Not Alex task',
              description: '',
              dueDate: DateTime(2026, 12, 1),
              priority: TaskPriority.medium,
            ),
          ],
        ),
      ),
      throwsException,
    );
  });
}
