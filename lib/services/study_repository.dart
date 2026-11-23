import '../models/student_data.dart';
import '../models/student_profile.dart';

abstract interface class StudyRepository {
  Future<List<StudentProfile>> loadProfiles();

  Future<StudentProfile> createProfile(String name);

  Future<StudentProfile> renameProfile(String profileId, String name);

  Future<String?> loadCurrentProfileId();

  Future<void> setCurrentProfile(String profileId);

  Future<StudentData> loadStudentData(String ownerId);

  Future<void> saveStudentData(StudentData data);
}
