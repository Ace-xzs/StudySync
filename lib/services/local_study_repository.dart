import 'dart:convert';
import 'dart:math';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/student_data.dart';
import '../models/student_profile.dart';
import 'study_repository.dart';

class LocalStudyRepository implements StudyRepository {
  static const _profilesKey = 'studysync.profiles.v1';
  static const _currentProfileKey = 'studysync.currentProfile.v1';
  static const _dataKeyPrefix = 'studysync.studentData.v1.';

  Future<SharedPreferences> get _preferences => SharedPreferences.getInstance();

  @override
  Future<List<StudentProfile>> loadProfiles() async {
    final stored = (await _preferences).getString(_profilesKey);
    if (stored == null) return [];

    final decoded = jsonDecode(stored) as List<dynamic>;
    return decoded
        .map(
          (item) =>
              StudentProfile.fromJson(Map<String, dynamic>.from(item as Map)),
        )
        .toList();
  }

  @override
  Future<StudentProfile> createProfile(String name) async {
    final profile = StudentProfile(id: _newId(), name: name.trim());
    final profiles = await loadProfiles();
    profiles.add(profile);
    await _saveProfiles(profiles);
    return profile;
  }

  @override
  Future<StudentProfile> renameProfile(String profileId, String name) async {
    final profiles = await loadProfiles();
    final index = profiles.indexWhere((profile) => profile.id == profileId);
    if (index < 0) {
      throw Exception('The selected student profile no longer exists.');
    }

    final updated = profiles[index].copyWith(name: name.trim());
    profiles[index] = updated;
    await _saveProfiles(profiles);
    return updated;
  }

  @override
  Future<String?> loadCurrentProfileId() async {
    return (await _preferences).getString(_currentProfileKey);
  }

  @override
  Future<void> setCurrentProfile(String profileId) async {
    final profiles = await loadProfiles();
    if (!profiles.any((profile) => profile.id == profileId)) {
      throw Exception('The selected student profile no longer exists.');
    }
    final saved = await (await _preferences).setString(
      _currentProfileKey,
      profileId,
    );
    if (!saved) throw Exception('Could not save the selected profile.');
  }

  @override
  Future<StudentData> loadStudentData(String ownerId) async {
    final stored = (await _preferences).getString('$_dataKeyPrefix$ownerId');
    if (stored == null) return StudentData(ownerId: ownerId);

    final data = StudentData.fromJson(
      Map<String, dynamic>.from(jsonDecode(stored) as Map),
    );
    if (data.ownerId != ownerId ||
        data.tasks.any((item) => item.ownerId != ownerId) ||
        data.subjects.any((item) => item.ownerId != ownerId) ||
        data.schedules.any((item) => item.ownerId != ownerId)) {
      throw FormatException('Saved data does not belong to this profile.');
    }
    return data;
  }

  @override
  Future<void> saveStudentData(StudentData data) async {
    if (data.tasks.any((item) => item.ownerId != data.ownerId) ||
        data.subjects.any((item) => item.ownerId != data.ownerId) ||
        data.schedules.any((item) => item.ownerId != data.ownerId)) {
      throw Exception('Student data contains records for another profile.');
    }

    final saved = await (await _preferences).setString(
      '$_dataKeyPrefix${data.ownerId}',
      jsonEncode(data.toJson()),
    );
    if (!saved) throw Exception('Could not save this student’s data.');
  }

  Future<void> _saveProfiles(List<StudentProfile> profiles) async {
    final saved = await (await _preferences).setString(
      _profilesKey,
      jsonEncode(profiles.map((profile) => profile.toJson()).toList()),
    );
    if (!saved) throw Exception('Could not save student profiles.');
  }

  String _newId() {
    final randomPart = Random.secure().nextInt(1 << 32).toRadixString(16);
    return '${DateTime.now().microsecondsSinceEpoch}-$randomPart';
  }
}
